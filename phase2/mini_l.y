/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
  int yyerror(char *s);
  int yylex(void);
  %}

  %union{
    int   int_val;
    string* op_val;
  }

%token  IDENTIFIER NUMBER 

%%

Expression 
  : Expression '+' Multiplicative_Expr  { printf("PLUS\n"); }
  | Expression '-' Multiplicative_Expr  { printf("MINUS\n"); }
  | Multiplicative_Expr
  ;

Multiplicative_Expr
  : Multiplicative_Expr '*' Term  { printf("MULT\n"); }
  | Multiplicative_Expr '/' Term  { printf("DIV\n"); }
  | Multiplicative_Expr '%' Term  { printf("MOD\n"); }
  | Term
  ;

Var
  : IDENTIFIER  { printf("IDENT\n"); }
  | IDENTIFIER '[' Expression ']'
  ;

Term
  : '-' Term1 { printf("- TERM\n"); }
  | Term1 { printf("TERM1\n"); }
  | Term2 '(' Expression ')'  { printf("TERM2\n"); }
  ;

Term1
  : Var { printf("VAR\n"); }
  | NUMBER  { printf("NUMBER\n"); }
  | '(' Expression ')'
  ;

Term2
  : Term2 ',' Expression
  | Expression
  ;

%%

int yyerror(string s)
{
  extern int yylineno;  // defined and maintained in lex.c
  extern char *yytext;  // defined and maintained in lex.c
        
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}
