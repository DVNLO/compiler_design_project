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

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE NOT TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token <op_val> IDENT
%token <int_val> NUMBER 
%left MULT DIV MOD ADD SUB LT LTE GT GTE EQ NEQ AND OR
%right NOT ASSIGN

%%

Expression 
  : Expression ADD Multiplicative_Expr  { printf("PLUS\n"); }
  | Expression SUB Multiplicative_Expr  { printf("SUB\n"); }
  | Multiplicative_Expr
  ;

Multiplicative_Expr
  : Multiplicative_Expr MULT Term  { printf("MULT\n"); }
  | Multiplicative_Expr DIV Term  { printf("DIV\n"); }
  | Multiplicative_Expr MOD Term  { printf("MOD\n"); }
  | Term
  ;

Var
  : IDENT  { printf("IDENT\n"); }
  | IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
  ;

Term
  : '-' Term1 { printf("- TERM\n"); }
  | Term1 { printf("TERM1\n"); }
  | Term2 L_PAREN Expression R_PAREN  { printf("TERM2\n"); }
  ;

Term1
  : Var { printf("VAR\n"); }
  | NUMBER  { printf("NUMBER\n"); }
  | L_PAREN Expression R_PAREN
  ;

Term2
  : Term2 COMMA Expression
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
