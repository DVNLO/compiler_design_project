%{
int yylex(void);
extern char * yytext; 
%}

%code requires 
{
#include "errors.h"
#include "instructions.h"
#include "semantics.h"
#include "types.h"
}

%union
{
  std::string * op_val;
  identifier_t * id_nt_val;
  identifiers_t * ids_nt_val;
  number_t * num_nt_val;
  variable_t * var_nt_val;
  expression_t * exp_nt_val; 
}

%define parse.error verbose
%define parse.lac full
%start program

%token <op_val> IDENT
%token <op_val> NUMBER 

%nterm<id_nt_val> identifier
%nterm<ids_nt_val> identifiers
%nterm<num_nt_val> number
%nterm<var_nt_val> variable
%nterm<exp_nt_val> expression
%nterm<exp_nt_val> multiplicative_exp
%nterm<exp_nt_val> term2
%nterm<exp_nt_val> term1
%nterm<exp_nt_val> term

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
      puts("function -> function1 identifier semicolon params locals body");
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
      puts("params -> begin_params declarations end_params");
    }
  | begin_params end_params {
      puts("params -> begin_params end_params");
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
      puts("declarations -> declarations declaration SEMICOLON"); 
    }
  | declaration SEMICOLON { puts("declarations -> declaration SEMICOLON"); }
  ;

declaration
  : identifiers COLON INTEGER { 
      puts("declaration -> identifiers COLON INTEGER"); 
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      puts("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET "
           "number R_SQUARE_BRACKET OF INTEGER"); 
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
      $$ = synthesize_arithmetic_expression("+", $1, $3);
      // TODO : add generated and declared name to symbol table 
      delete $1;
      delete $3;
    }
  | expression SUB multiplicative_exp  
    { 
      // - dst, src1, src2
      $$ = synthesize_arithmetic_expression("-", $1, $3);
      // TODO : add generated and declared name to symbol table 
      delete $1;
      delete $3;
    }
  | multiplicative_exp 
    { 
      $$ = copy_expression($1);
      delete $1;
    }
  ;

multiplicative_exp
  : multiplicative_exp MULT term  
    { 
      // * dst, src1, src2
      $$ = synthesize_arithmetic_expression("*", $1, $3);
      // TODO : add generated and declared name to symbol table 
      delete $1;
      delete $3;
    }
  | multiplicative_exp DIV term  
    { 
      // / dst, src1, src2
      $$ = synthesize_arithmetic_expression("/", $1, $3);
      // TODO : add generated and declared name to symbol table 
      delete $1;
      delete $3;
    }
  | multiplicative_exp MOD term  
    {
      // % dst, src1, src2
      $$ = synthesize_arithmetic_expression("%", $1, $3);
      // TODO : add generated and declared name to symbol table 
      delete $1;
      delete $3;
    }
  | term
    {
      $$ = copy_expression($1);
      delete $1; 
    }
  ;

variables
  : variables COMMA variable 
    { 
      $$ = new variables_t;
      $1->variables.push_back(*$3);
      $$->variables = $1->variables;
      delete $3;
      delete $1;
    }
  | variable 
    {
      $$ = new variables_t;
      $$->variables.push_back(*$1);
      delete $1;
    }
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
      // TODO : handle compile time out of range exception
      delete $1;
      delete $3; 
    }
  ;

term
  : SUB term1 
    {
      // convert the value of expression received from term1
      // to a negative value by subtrating it from 0. 
      $$ = new expression_t;
      $$->op_code = "-";
      $$->dst = generate_name();
      $$->src1 = "0";
      $$->src2 = $2->dst;
      $$->code = $2->code;
      $$->code += gen_ins_declare_variable($$->dst);
      // TODO : add generated and declared name to symbol table
      $$->code += gen_ins_arithmetic($$->op_code, $$->dst, $$->src1, $$->src2);
    }
  | term1 
    { 
      $$ = copy_expression($1);
      delete $1;
    }
  | identifier L_PAREN term2 R_PAREN  
    { 
      // synthesizes a function call. 
      puts("term -> identifier L_PAREN term2 R_PAREN"); 
    }
  ;

term1
  : variable 
    { 
      // convert a variable into an expression. If the variable
      // is an array, use an array access instruction to load 
      // the value into a temporary name. Else, the variable 
      // is a scalar variable in which case the destination of 
      // the expression is simply the name of the scalar variable. 
      $$ = new expression_t;
      if(is_array($1))
      {
        $$->dst = generate_name();
        $$->src1 = $1->name;
        $$->src2 = $1->expression.dst;
        $$->code += gen_ins_declare_variable($$->dst);
        // TODO : add generated and declared name to symbol table
        $$->code += gen_ins_array_access_rval($$->dst, $$->src1, $$->src2);
      }
      else // scalar variable
      {
        $$->dst = $1->name; 
      }
    }
  | number  
    { 
      // convert a number into an expression. Declare a temporary
      // name to hold the value of the number. Copy the value into
      // the temporary name.
      $$ = new expression_t;
      $$->dst = generate_name(); 
      $$->src1 = $1->val; 
      $$->code += gen_ins_declare_variable($$->dst);
      // TODO : add generated and declared name to symbol table
      $$->code += gen_ins_copy($$->dst, $$->src1);
      delete $1;
    }
  | L_PAREN expression R_PAREN 
    { 
      $$ = copy_expression($2);
      delete $2;
    }
  ;

term2
  : expression COMMA term2 
    { 
      // generates a paramater list
      // TODO : This requires determining our data structure for a
      // function, something we have not done yet. After reviewing some
      // of the intermediate mil code, we will need to declare the 
      // final result of the expression evaluations here as a parameter
      // for the next function call. Additionally, we will need
      // to populate these paramaters in the callee's data structure 
      // (caller -> callee).
      puts("term2 -> term2 COMMA expression"); 
    }
  | expression 
    {
      // TODO : This or the epsilon terminal below are the final 
      // terminals constructing the paramater list. So by this block,
      // the code for the paramater list must be generated and the 
      // function ready to be called in the parent terminal.
      puts("term2 -> expression"); 
    }
  | { puts("term2 -> epsilon"); }
  ;

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
      $$->val = *yylval.op_val;
      delete yylval.op_val;
    }
  ;

%%

