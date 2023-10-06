%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
// 定义段：用于添加所需头文件、函数定义、全局变量等
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>  //导入isdigit()函数

#ifndef YYSTYPE
// 用于确定$$的变量类型，由于返回的是简单表达式计算结果，因此定义为double类型
#define YYSTYPE double
#endif

int yylex();

// yyparse不断调用yylex函数来得到token的类型
extern int yyparse();
FILE* yyin;
void yyerror(const char*s);
%}

%token ADD
%token MINUS
%token MUL
%token DIV
%token LEFT_PAR
%token RIGHT_PAR
%token NUMBER

//指定运算符的优先级和结合性，优先级按声明顺序由低到高排列
%left ADD MINUS
%left MUL DIV
%right UMINUS // 取负


// 规则段：语法制导翻译
%%

// 处理以分号结束的表达式
lines   :   lines expr ';' {printf("%f\n", $2);}
        |   lines ';'
        |   
        ;

expr    :   expr ADD expr           {$$ = $1 + $3;} // $$代表产生式左部的属性值，$n 为产生式右部第n个token的属性值
        |   expr MINUS expr           {$$ = $1 - $3;}
        |   expr MUL expr           {$$ = $1 * $3;}
        |   expr DIV expr           {$$ = $1 / $3;}
        |   LEFT_PAR expr RIGHT_PAR         {$$ = $2;}
        |   MINUS expr %prec UMINUS   {$$ = -$2;} // 果遇到一个以-开头的表达式，Yacc将使用UMINUS指定的优先级来归约这个表达式
        |   NUMBER                  {$$ = $1;}
        ;

%%

// yylex函数：实现词法分析功能
int yylex()
{
    int ch;
    while(1) 
	{
        ch = getchar();
		// 忽略空格、制表符、回车
        if(ch == ' ' || ch == '\t' || ch =='\n');
        else if (isdigit(ch))
        {
            yylval = 0;
            while(isdigit(ch))
            {
                yylval = yylval * 10 + ch - '0';
                ch = getchar();
            }
			// 最后一个读出的字符不是数字,因此需要再次放回缓冲区
            ungetc(ch, stdin);
            return NUMBER;
        }
        else if (ch == '+')
        {
            return ADD;
        }
        else if(ch == '-')
        {
            return MINUS;
        }
        else if (ch == '*')
        {
            return MUL;
        }
        else if (ch == '/')
        {
            return DIV;
        }
        else if (ch == '(')
        {
            return LEFT_PAR;
        }
        else if (ch == ')')
        {
            return RIGHT_PAR;
        }
        else
        {
            return ch;
        }
    }
}

int main()
{
    yyin = stdin;
	// feof()是检测流上的文件结束符的函数，如果文件结束，则返回非0值，否则返回0
    do {
        yyparse();
    } while(!feof(yyin));
    return 0;
}

// 发生错误时,yyparse函数调用yyerror()
void yyerror(const char* s)
{
    fprintf(stderr, "Parse error:%s\n", s);
    exit(1);
}

