%{
#include "heading.h"
int yyerror(char const * s);
int yylex(void);
%}

%union{
  int   int_val;
  string * op_val;
}

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY 
%token END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP
%token ENDLOOP CONTINUE READ WRITE NOT TRUE FALSE RETURN SEMICOLON COLON COMMA 
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET

%token <op_val> IDENT
%token <int_val> NUMBER 

%left MULT DIV MOD ADD SUB LT LTE GT GTE EQ NEQ AND OR

%right NOT ASSIGN

%start program
%%

program 
  : functions { puts("program -> functions"); }
  ;

functions 
  : functions function { puts("functions -> functions function"); }
  | function { puts("functions -> function"); }
  ;

identifiers
  : identifiers COMMA IDENT { puts("identifiers -> identifiers COMMA IDENT"); }
  | IDENT { puts("identifiers -> IDENT"); }
  ;

function
  : FUNCTION IDENT SEMICOLON params locals body {
      puts("function -> FUNCTION IDENT SEMICOLON params locals body"); 
    }
  ;

params
  : BEGIN_PARAMS declarations END_PARAMS { 
      puts("params -> BEGIN_PARAMS declarations END_PARAMS"); 
    }
  | BEGIN_PARAMS END_PARAMS { puts("params -> BEGIN_PARAMS END_PARAMS"); }
  ;

locals
  : BEGIN_LOCALS declarations END_LOCALS { 
      puts("locals -> BEGIN_LOCALS declarations END_LOCALS"); 
    }
  | BEGIN_LOCALS END_LOCALS { puts("locals -> BEGIN_LOCALS END_LOCALS"); }
  ;

body
  : BEGIN_BODY statements END_BODY { 
      puts("body -> BEGIN_BODY statements END_BODY"); 
    }

declarations
  : declarations declaration SEMICOLON { 
      puts("declarations -> declarations declaration SEMICOLON"); 
    }
  | declaration SEMICOLON { puts("declarations -> declaration SEMICOLON"); }
  ;

declaration
  : identifiers COLON INTEGER { 
      puts("declaration -> identifiers COLON INTEGER"); 
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { 
      puts("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET "
           "NUMBER R_SQUARE_BRACKET OF INTEGER"); 
    }
  ;

statements
  : statements statement SEMICOLON { 
      puts("statements -> statements statement SEMICOLON"); 
    }
  | statement SEMICOLON
  ;

statement
  : statement_assign { puts("statement -> statement_assign"); }
  | statement_if { puts("statement -> statement_if"); }
  | statement_while { puts("statement -> statement_while"); }
  | statement_do_while { puts("statement -> statement_do_while"); }
  | statement_for { puts("statement -> statement_for"); }
  | statement_read { puts("statement -> statement_read"); }
  | statement_write { puts("statement -> statement_write"); }
  | statement_continue { puts("statement -> statement_continue"); }
  | statement_return { puts("statement -> statement_return"); }
  ;

statement_assign
  : variable ASSIGN expression { 
      puts("statement_assign -> variable ASSIGN expression"); 
    }
  ;

statement_if
  : IF bool_exp THEN statements ENDIF { 
      puts("statement_if -> IF bool_exp THEN statements ENDIF"); 
    }
  | IF bool_exp THEN statements ELSE statements ENDIF {
      puts("statement_if -> IF bool_exp THEN statements ELSE statements ENDIF");
    }
  ;

statement_while
  : WHILE bool_exp BEGINLOOP statements ENDLOOP { 
      puts("statement_while -> WHILE bool_exp BEGINLOOP statements ENDLOOP"); 
    }
  ;

statement_do_while
  : DO BEGINLOOP statements ENDLOOP WHILE bool_exp {
      puts("statement_do_while -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp");
    }
  ;

statement_for
  : FOR variable ASSIGN NUMBER SEMICOLON 
        bool_exp SEMICOLON 
        statement_assign 
        BEGINLOOP statements ENDLOOP {
      puts("statement_for -> FOR variable ASSIGN NUMBER SEMICOLON bool_exp "
           "SEMICOLON statement_assign BEGINLOOP statements ENDLOOP");
    }
  ;

statement_read
  : READ variables { puts("statement_read -> READ variables"); }
  ;

statement_write
  : WRITE variables { puts("statement_write -> WRITE variables"); }
  ;

statement_continue
  : CONTINUE { puts("statement_continue -> CONTINUE"); }
  ;

statement_return
  : RETURN expression { puts("statement_return -> RETURN expression"); }
  ;

bool_exp
  : bool_exp OR relation_and_exp { 
      puts("bool_exp -> bool_exp OR relation_and_exp"); 
    }
  | relation_and_exp { puts("bool_exp -> relation_and_exp"); }
  ;

relation_and_exp
  : relation_and_exp AND relation_exp { 
      puts("relation_and_exp -> relation_and_exp AND relation_exp"); 
    }
  | relation_exp { puts("relation_and_exp -> relation_exp"); }
  ;

relation_exp
  : NOT relation_exp1 { puts("relation_exp -> NOT relation_exp1"); }
  | relation_exp1 { puts("relation_exp -> relation_exp1"); }
  ;

relation_exp1
  : expression comp expression { 
      puts("relation_exp1 -> expression comp expression"); 
    }
  | TRUE { puts("relation_exp1 -> TRUE"); }
  | FALSE { puts("relation_exp1 -> FALSE"); }
  | L_PAREN bool_exp R_PAREN { 
      puts("relation_exp1 -> L_PAREN bool_exp R_PAREN"); 
    }
  ;
 
comp
  : EQ { puts("comp -> EQ"); }
  | NEQ { puts("comp -> NEQ"); }
  | LT { puts("comp -> LT"); }
  | GT { puts("comp -> GT"); }
  | LTE { puts("comp -> LTE"); }
  | GTE { puts("comp -> GTE"); }
  ;

expression 
  : expression ADD multiplicative_exp  { 
      puts("expression -> expression ADD multiplicative_exp"); 
    }
  | expression SUB multiplicative_exp  { 
      puts("expression -> expression SUB multiplicative_exp"); 
    }
  | multiplicative_exp { puts("expression -> multiplicative_exp"); }
  ;

multiplicative_exp
  : multiplicative_exp MULT term  { 
      puts("multiplicative_exp -> multiplicative_exp MULT term"); 
    }
  | multiplicative_exp DIV term  { 
      puts("multiplicative_exp -> multiplicative_exp DIV term"); 
    }
  | multiplicative_exp MOD term  { 
      puts("multiplicative_exp -> multiplicative_exp MOD term"); 
    }
  | term
  ;

variables
  : variables COMMA variable { puts("variables -> variables COMMA variable"); }
  | variable { puts("variables -> variable"); }
  ; 

variable
  : IDENT  { puts("variable -> IDENT"); }
  | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET { 
      puts("variable -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET"); 
    }
  ;

term
  : SUB term1 { puts("term -> SUB term1"); }
  | term1 { puts("term -> term1"); }
  | IDENT L_PAREN term2 R_PAREN  { puts("term -> IDENT L_PAREN term2 R_PAREN"); }
  ;

term1
  : variable { puts("term1 -> variable"); }
  | NUMBER  { puts("term1 -> NUMBER"); }
  | L_PAREN expression R_PAREN { puts("term1 -> L_PAREN expression R_PAREN"); }
  ;

term2
  : term2 COMMA expression { puts("term2 -> term2 COMMA expression"); }
  | expression { puts("term2 -> expression"); }
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
