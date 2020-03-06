%{
int yylex(void);
extern char * yytext; 
%}

%code requires 
{
#include "types.h"
#include "semantics.h"
#include "errors.h"
}

%union
{
  int int_val;
  std::string * op_val;
  std::string * params_val;
  std::string * functions_val;
  identifier_t * id_nt_val;
  identifiers_t * ids_nt_val;
  number_t * num_nt_val;
  variable_t * var_nt_val;
  expression_t * exp_nt_val; 
  function_t * func_nt_val;
}

%define parse.error verbose
%define parse.lac full
%start program

%token <op_val> IDENT
%token <int_val> NUMBER 

%nterm<id_nt_val> identifier
%nterm<ids_nt_val> identifiers
%nterm<num_nt_val> number
%nterm<var_nt_val> variable
%nterm<exp_nt_val> expression
%nterm<exp_nt_val> multiplicative_exp
%nterm<exp_nt_val> term
%nterm<func_nt_val> function
%nterm<functions_val> functions
%nterm<params_val> params

%right ASSIGN
%left OR
%left AND 
%right NOT
%left LT LTE GT GTE EQ NEQ 

%left ADD SUB
%left MULT DIV MOD
%left L_SQUARE_BRACKET R_SQUARE_BRACKET

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN 
%%

program
  : { puts("program -> epsilon"); }
  | functions { puts("program -> functions"); }
  ;

functions
  : functions function { puts("functions -> functions function"); }
  | function { puts("functions -> function"); }
  ;

function
  : function1 identifier semicolon params locals body {
      
    }
  | error { puts("function -> error"); }
  ;

function1
  : FUNCTION { puts("function1 -> FUNCTION"); }
  | error { puts("function1 -> error"); }
  ;

semicolon
  : SEMICOLON { puts("semicolon -> SEMICOLON"); }
  | error { puts("semicolon -> error"); }
  ;

params
  : begin_params declarations end_params {
      $$ = new params_t;
      $$->code = generate_declarations_code($2);
    }
  | begin_params end_params {
      $$ = new params_t;
    }
  ;

begin_params
  : BEGIN_PARAMS { puts("begin_params -> BEGIN_PARAMS"); }
  | error { puts("begin_params -> error"); }
  ;

end_params
  : END_PARAMS { puts("end_params -> END_PARAMS"); }
  | error { puts("end_params -> error"); }
  ;

locals
  : begin_locals declarations end_locals {
      puts("locals -> begin_locals declarations end_locals");
    }
  | begin_locals end_locals {
      puts("locals -> begin_locals end_locals");
    }
  ;

begin_locals
  : BEGIN_LOCALS { puts("begin_locals -> BEGIN_LOCALS"); }
  | error { puts("begin_locals -> error"); }
  ;

end_locals
  : END_LOCALS { puts("end_locals -> END_LOCALS"); }
  | error { puts("end_locals -> error"); }
  ;

body
  : begin_body statements end_body {
      puts("body -> begin_body statements end_body");
    }
  ;

begin_body
  : BEGIN_BODY { puts("begin_body -> BEGIN_BODY"); }
  | error { puts("begin_body -> error"); }
  ;

end_body
  : END_BODY { puts("end_body -> END_BODY"); }
  | error { puts("end_body -> error"); }
  ;

declarations
  : declarations declaration SEMICOLON { 
      $$ = $1;
      $$->declarations.push_back($2);
    }
  | declaration SEMICOLON { 
      $$ = new declarations_t;
      $$->declarations.push_back($1);
    }
  ;

declaration
  : identifiers COLON INTEGER { 
      $$ = new declaration_t;
      $$->code = generate_declaration_code($1);
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      $$ = new declaration_t;
      $$->code = generate_array_declaration_code($1, $5);
    }
  | error { puts("declaration -> error"); }
  ;

statements
  : statements statement SEMICOLON { 
      puts("statements -> statements statement SEMICOLON"); 
    }
  | statement SEMICOLON {
      puts("statements -> statement SEMICOLON");
    }
  ;

statement
  : statement_assign   { puts("statement -> statement_assign"); }
  | statement_if       { puts("statement -> statement_if"); }
  | statement_while    { puts("statement -> statement_while"); }
  | statement_do_while { puts("statement -> statement_do_while"); }
  | statement_for      { puts("statement -> statement_for"); }
  | statement_read     { puts("statement -> statement_read"); }
  | statement_write    { puts("statement -> statement_write"); }
  | statement_continue { puts("statement -> statement_continue"); }
  | statement_return   { puts("statement -> statement_return"); }
  | error              { puts("statement -> error"); }
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
  : FOR variable ASSIGN number SEMICOLON 
        bool_exp SEMICOLON 
        statement_assign 
        BEGINLOOP statements ENDLOOP {
      puts("statement_for -> FOR variable ASSIGN number SEMICOLON bool_exp "
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
  : expression ADD multiplicative_exp  
    { 
      // + dst, src1, src2
      $$ = synthesize_expression('+', $1, $3);
      delete $1;
      delete $3;
    }
  | expression SUB multiplicative_exp  
    { 
      // - dst, src1, src2
      $$ = synthesize_expression('-', $1, $3);
      delete $1;
      delete $3;
    }
  | multiplicative_exp 
    { 
      // $$ = $1, assign the 
      puts("expression -> multiplicative_exp"); 
    }
  ;

multiplicative_exp
  : multiplicative_exp MULT term  
    { 
      // * dst, src1, src2
      $$ = synthesize_expression('*', $1, $3);
      delete $1;
      delete $3;
    }
  | multiplicative_exp DIV term  
    { 
      // / dst, src1, src2
      $$ = synthesize_expression('/', $1, $3);
      delete $1;
      delete $3;
    }
  | multiplicative_exp MOD term  
    {
      // % dst, src1, src2
      $$ = synthesize_expression('%', $1, $3);
      delete $1;
      delete $3;
    }
  | term
    {
      
    }
  ;

variables
  : variables COMMA variable { puts("variables -> variables COMMA variable"); }
  | variable { puts("variables -> variable"); }
  ; 

variable
  : identifier  
    { 
      $$ = new variable_t;
      $$->name = $1->name;
      delete $1;
    }
  | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET 
    { 
      $$ = new variable_t;
      $$->name = $1->name;
      $$->expression = *$3;
      delete $1;
      delete $3; 
    }
  ;

term
  : SUB term1 { puts("term -> SUB term1"); }
  | term1 { puts("term -> term1"); }
  | identifier L_PAREN term2 R_PAREN  { puts("term -> identifier L_PAREN term2 R_PAREN"); }
  ;

term1
  : variable { puts("term1 -> variable"); }
  | number  { puts("term1 -> number"); }
  | L_PAREN expression R_PAREN { puts("term1 -> L_PAREN expression R_PAREN"); }
  ;

term2
  : expression COMMA term2 { puts("term2 -> term2 COMMA expression"); }
  | expression { puts("term2 -> expression"); }
  | { puts("term2 -> epsilon"); }
  ;

// captures identifier information from an identifier list
identifiers
  : identifiers COMMA identifier 
    {
      $$ = new identifiers_t; 
      $1->identifiers.push_back(*$3);
      $$->identifiers = $1->identifiers; 
      delete $3;
      delete $1;
    }
  | identifier 
    {
      $$ = new identifiers_t;
      $$->identifiers.push_back(*$1); 
      delete $1;
    }
  ;

// captures identifer information from IDENT token 
identifier
  : IDENT 
    {
      $$ = new identifier_t;
      $$->name = *yylval.op_val; 
      delete yylval.op_val;
    }
  ;

// capture number information from NUMBER token
number
  : NUMBER 
    { 
      $$ = new number_t;
      $$->val = yylval.int_val;
    }
  ;

%%

