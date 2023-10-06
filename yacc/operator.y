%{
/*********************************************
中缀表达式转后缀表达式
YACC file
**********************************************/
// 定义段：包括头文件、函数定义、全局变量等
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#ifndef YYSTYPE
// 由于需要返回的是一个后缀表达式，是一个字符串，因此 YYSTYPE可声明为 char*
#define YYSTYPE char*
#endif

// 存储标识符的数组
char idStr[50];
// 存储数字的数组
char numStr[50];
int yylex();

// yyparse不断调用yylex函数来得到token的类型
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}


%token NUMBER
%token ID
%token ADD
%token SUB
%token MUL
%token DIV
%token LEFT_PAR
%token RIGHT_PAR

//指定运算符的优先级和结合性，优先级按声明顺序由低到高排列
%left ADD SUB
%left MUL DIV
%right UMINUS

// 规则段：语法制导翻译
%%

lines : lines expr ';' { printf("%s\n", $2); }
	| lines ';'
	|
	;

// 将计算值修改成字符串的拷贝（strcpy）和连接（strcat）
expr : expr ADD expr { $$ = (char *)malloc(50*sizeof (char)); 
                       strcpy($$,$1);
                       strcat($$,$3); 
                       strcat($$,"+ "); }
	| expr SUB expr { $$ = (char *)malloc(50*sizeof (char)); 
                      strcpy($$,$1);
                      strcat($$,$3); 
                      strcat($$,"- "); }
	| expr MUL expr { $$ = (char *)malloc(50*sizeof (char)); 
                      strcpy($$,$1);
                      strcat($$,$3);
                      strcat($$,"* "); }
	| expr DIV expr { $$ = (char *)malloc(50*sizeof (char)); 
                      strcpy($$,$1);
                      strcat($$,$3);
                      strcat($$,"/ "); }
	| LEFT_PAR expr RIGHT_PAR { $$ = (char *)malloc(50*sizeof (char)); 
                                strcpy($$,$2); }
	| SUB expr %prec UMINUS { $$ = (char *)malloc(50*sizeof (char));
                              strcpy($$,"-");
                              strcat($$,$2); }
	| NUMBER { $$ = (char *)malloc(50*sizeof (char));
               strcpy($$, $1); 
               strcat($$," "); }
    | ID { $$ = (char *)malloc(50*sizeof (char));
           strcpy($$, $1); 
           strcat($$," "); } 
	;

%%

// programs section

int yylex()
{
    // place your token retrieving code here
    int t;
    while(1)
    {
        t = getchar();
        // 忽略空格、换行符、制表符
        if(t == ' ' || t == '\t' || t == '\n'){

        }
        // 如果识别到字符0-9，说明是数字，返回数字串
        else if(isdigit(t)){
            int i = 0;
            while(isdigit(t)){
                numStr[i] = t;
                t = getchar();
                i++;
            }
			// 添加结束符
            numStr[i] = '\0';
			// 将这个字符串的地址赋给yylval
			// 这里语法规则的代码中并未出现 yylval, 却依然完成了赋值操作，这是因为 yacc 与 lex 默认将 yylval 的值赋给了识别出的标识符, 例如strcpy($$,$1)等价于 strcpy($$,yylval)
            yylval = numStr;
            ungetc(t, stdin);
            return NUMBER;
        }
        // 为当读到一个字符为字母或下划线时，连续读接下来的字符，直到出现一个不是数字或字母或下划线的字符停止
        else if(( t >= 'a' && t <= 'z' ) || ( t >= 'A' && t<= 'Z' ) || ( t == '_' )){
            int i = 0;
            while(( t >= 'a' && t <= 'z' ) || ( t >= 'A' && t<= 'Z' ) || ( t == '_' ) || isdigit(t)){
                idStr[i] = t;
                t = getchar();
                i++;
            }
            idStr[i] = '\0';
			// 将读到的若干字符存为一个字符串，将这个字符串的地址赋给 yylval
            yylval = idStr;
            ungetc(t, stdin);
            return ID;
        }
        // 遇到终结符
        else{
            switch (t)
            {
            case '+':
                return ADD;
                break;
            case '-':
                return SUB;
                break;
            case '*':
                return MUL;
                break;
            case '/':
                return DIV;
                break;
            case '(':
                return LEFT_PAR;
                break;
            case ')':
                return RIGHT_PAR;
                break;
            default:
                return t;
            }
        }
    }
}

int main(void)
{
    yyin = stdin ;
    do {
        yyparse();
    } 
    while (! feof (yyin));
    return 0;
}
void yyerror(const char* s) {
    fprintf (stderr , "Parse error : %s\n", s );
    exit (1);
}

