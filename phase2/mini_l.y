%{
#include "heading.h"
int yyerror(char const * s);
int yylex(void);
%}

%union{
  int   int_val;
  string* op_val;
}

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY 
%token END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP
%token ENDLOOP CONTINUE READ WRITE NOT TRUE FALSE RETURN SEMICOLON COLON COMMA 
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET

%token <op_val> IDENT
%token <int_val> NUMBER 

%left MULT DIV MOD ADD SUB LT LTE GT GTE EQ NEQ AND OR

%right NOT ASSIGN

%%


program 
  : functions
  ;

functions 
  : functions function
  | function
  ;

identifiers
  : identifiers COMMA IDENT
  | IDENT
  ;

function
  : FUNCTION IDENT SEMICOLON params locals body
  ;

params
  : BEGIN_PARAMS declarations END_PARAMS
  ;

locals
  : BEGIN_LOCALS declarations END_LOCALS
  ;

body
  : BEGIN_BODY statements END_BODY

declarations
  : declarations declaration SEMICOLON
  | declaration
  ;

declaration
  : identifiers SEMICOLON INTEGER
  | identifiers SEMICOLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
  ;

statements
  : statements statement SEMICOLON
  | statement SEMICOLON
  ;

statement
  : statement_assign
  | statement_if
  | statement_while
  | statement_do_while
  | statement_for
  | statement_read
  | statement_write
  | statement_continue
  | statement_return
  ;

statement_assign
  : variable ASSIGN expression
  ;

statement_if
  : IF bool_exp THEN statements ENDIF
  | IF bool_exp THEN statements ELSE statements ENDIF
  ;

statement_while
  : WHILE bool_exp BEGINLOOP statements ENDLOOP
  ;

statement_do_while
  : DO BEGINLOOP statements ENDLOOP WHILE bool_exp
  ;

statement_for
  : FOR variable ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON statement_assign BEGINLOOP statements ENDLOOP
  ;

statement_read
  : READ variables
  ;

statement_write
  : WRITE variables
  ;

statement_continue
  : CONTINUE
  ;

statement_return
  : RETURN expression
  ;

bool_exp
  : bool_exp OR relation_and_exp
  | relation_and_exp
  ;

relation_and_exp
  : relation_and_exp AND relation_exp
  | relation_exp
  ;

relation_exp
  : NOT relation_exp1
  | relation_exp1
  ;

relation_exp1
  : expression comp expression
  | TRUE
  | FALSE
  | L_PAREN bool_exp R_PAREN
  ;
 
comp
  : EQ
  | NEQ
  | LT
  | GT
  | LTE
  | GTE 
  ;

expression 
  : expression ADD multiplicative_exp  { printf("PLUS\n"); }
  | expression SUB multiplicative_exp  { printf("SUB\n"); }
  | multiplicative_exp 
  ;

multiplicative_exp
  : multiplicative_exp MULT term  { printf("MULT\n"); }
  | multiplicative_exp DIV term  { printf("DIV\n"); }
  | multiplicative_exp MOD term  { printf("MOD\n"); }
  | term
  ;

variables
  : variables COMMA variable
  | variable
  ; 

variable
  : IDENT  { printf("IDENT\n"); }
  | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET
  ;

term
  : SUB term1 { printf("SUB TERM\n"); }
  | term1 { printf("TERM1\n"); }
  | IDENT L_PAREN term2 R_PAREN  { printf("TERM2\n"); }
  ;

term1
  : variable { printf("VAR\n"); }
  | NUMBER  { printf("NUMBER\n"); }
  | L_PAREN expression R_PAREN
  ;

term2
  : term2 COMMA expression
  | expression
  ;

%%

int yyerror(string const s)
{
  extern int yylineno;  // defined and maintained in lex.c
  extern char *yytext;  // defined and maintained in lex.c
        
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(EXIT_FAILURE);
}

int yyerror(char const * s)
{
  return yyerror(string(s));
}
