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
#include <iostream>
}

%union
{
  std::string * op_val;
  identifier_t * id_nt_val;
  identifiers_t * ids_nt_val;
  number_t * num_nt_val;
  variable_t * var_nt_val;
  variables_t * vars_nt_val;
  expression_t * exp_nt_val;
  comparison_t * comp_nt_val;
  statement_t * statement_nt_val; 
  parameters_t * params_nt_val;
  declaration_t * decl_nt_val;
  declarations_t * decls_nt_val;
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
%nterm<vars_nt_val> variables
%nterm<exp_nt_val> expression
%nterm<exp_nt_val> multiplicative_exp
%nterm<exp_nt_val> term2
%nterm<exp_nt_val> term1
%nterm<exp_nt_val> term
%nterm<comp_nt_val> comp
%nterm<exp_nt_val> bool_exp
%nterm<exp_nt_val> relation_and_exp
%nterm<exp_nt_val> relation_exp
%nterm<exp_nt_val> relation_exp1
%nterm<statement_nt_val> statement_read
%nterm<statement_nt_val> statement_write
%nterm<decl_nt_val> declaration
%nterm<decls_nt_val> declarations
%nterm<params_nt_val> params

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
  : function1 identifier 
    { 
      function_stack.push($2->name); 
    } 
    semicolon params locals body 
    {
      function_stack.pop();
      // TODO : Pop function identifer from the function stack
      std::cout << $5->code << std::endl;
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
      $$ = new parameters_t;

      int param_number = 0;
      for (size_t i = 0; i < $2->declarations.size(); i++)
      {
        $$->parameter_types.push_back($2->declarations[i].variable_type);

        for (size_t j = 0; j < $2->declarations[i].identifiers.size(); j++) 
        {
          std::string identifier_name = $2->declarations[i].identifiers[j].name;
          std::string size = $2->declarations[i].size;

          if ($2->declarations[i].variable_type == variable_type_t::INTEGER) 
            $$->code += gen_ins_declare_variable(identifier_name);
          else
            $$->code += gen_ins_declare_variable(identifier_name, size);

          $$->code += gen_ins_copy(identifier_name, '$' + std::to_string(param_number++));
        }
      }
      // TODO : Populate function_map[function_stack.top()].parameter_types
      delete $2;
    }
  | begin_params end_params {
      $$ = new parameters_t;
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
      $$ = new declarations_t;
      $$->declarations = $1->declarations;
      $$->declarations.push_back(*$2);
      delete $1;
      delete $2;
    }
  | declaration SEMICOLON {
      $$ = new declarations_t;
      $$->declarations.push_back(*$1);
      delete $1;
    }
  ;

declaration
  : identifiers COLON INTEGER { 
      $$ = new declaration_t;
      $$->identifiers = $1->identifiers;
      $$->variable_type = variable_type_t::INTEGER;
      delete $1;
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      $$ = new declaration_t;
      $$->identifiers = $1->identifiers;
      $$->size = $5->val;
      $$->variable_type = variable_type_t::ARRAY;
      delete $1;
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
  : READ variables 
    { 
      $$ = new statement_t;
      variable_t cur_var;
      size_t const SIZE_VARIABLES = $2->variables.size();
      for(size_t i = 0; i < SIZE_VARIABLES; ++i)
      {
        cur_var = $2->variables[i];
        if(is_array(&cur_var))
        {
          $$->dst = cur_var.name;
          $$->src1 = cur_var.expression.dst;
          $$->code += gen_ins_read_in($$->dst, $$->src1);
        }
        else
        {
          $$->dst = cur_var.name;
          $$->src1.clear();
          $$->code += gen_ins_read_in($$->dst);
        }
      }
      delete $2; 
    }
  ;

statement_write
  : WRITE variables 
    {
      $$ = new statement_t;
      variable_t cur_var;
      size_t const SIZE_VARIABLES = $2->variables.size();
      for(size_t i = 0; i < SIZE_VARIABLES; ++i)
      {
        cur_var = $2->variables[i];
        if(is_array(&cur_var))
        {
          $$->dst = cur_var.name;
          $$->src1 = cur_var.expression.dst;
          $$->code += gen_ins_write_out($$->dst, $$->src1);
        }
        else
        {
          $$->dst = cur_var.name;
          $$->src1.clear();
          $$->code += gen_ins_write_out($$->dst);
        }
      }
      delete $2;
    }
  ;

statement_continue
  : CONTINUE { puts("statement_continue -> CONTINUE"); }
  ;

statement_return
  : RETURN expression { puts("statement_return -> RETURN expression"); }
  ;

bool_exp
  : bool_exp OR relation_and_exp 
    { 
      $$ = synthesize_comparison_expression("||", $1, $3);
      delete $3;
      delete $1;
    }
  | relation_and_exp 
    { 
      $$ = copy_expression($1);
      delete $1;
    }
  ;

relation_and_exp
  : relation_and_exp AND relation_exp 
    { 
      $$ = synthesize_comparison_expression("&&", $1, $3);
      delete $3;
      delete $1;
    }
  | relation_exp 
    {
      $$ = copy_expression($1);
      delete $1; 
    }
  ;

relation_exp
  : NOT relation_exp1 
    { 
      $$ = new expression_t;
      $$->op_code = "!";
      $$->dst = generate_name();
      $$->src1 = $2->dst;
      $$->code += gen_ins_declare_variable($$->dst);
      $$->code += gen_ins_logical_not($$->dst, $$->src1);
      record_symbol($$->dst, 
                    variable_type_t::INTEGER, 
                    function_map[function_stack.top()].symbol_table);
      delete $2;
    }
  | relation_exp1 
    {
      $$ = copy_expression($1);
      delete $1; 
    }
  ;

relation_exp1
  : expression comp expression 
    { 
      $$ = synthesize_comparison_expression($2->op_code, $1, $3);
      delete $3;
      delete $1;
    }
  | TRUE 
    {
      $$ = new expression_t;
      $$->dst = generate_name();
      $$->src1 = "1";
      $$->code += gen_ins_declare_variable($$->dst);
      $$->code += gen_ins_copy($$->dst, $$->src1);
    }
  | FALSE 
    { 
      $$ = new expression_t;
      $$->dst = generate_name();
      $$->src1 = "0";
      $$->code += gen_ins_declare_variable($$->dst);
      $$->code += gen_ins_copy($$->dst, $$->src1);
    }
  | L_PAREN bool_exp R_PAREN 
    {
      $$ = copy_expression($2);
      delete $2; 
    }
  ;
 
comp
  : EQ 
    { 
      $$ = new comparison_t;
      $$->op_code = "=="; 
    }
  | NEQ 
    {
      $$ = new comparison_t;
      $$->op_code = "!="; 
    }
  | LT 
    { 
      $$ = new comparison_t;
      $$->op_code = "<";
    }
  | GT 
    { 
      $$ = new comparison_t;
      $$->op_code = ">"; 
    }
  | LTE 
    {
      $$ = new comparison_t;
      $$->op_code = "<="; 
    }
  | GTE 
    { 
      $$ = new comparison_t;
      $$->op_code = ">=";
    }
  ;

expression 
  : expression ADD multiplicative_exp  
    { 
      // + dst, src1, src2
      $$ = synthesize_arithmetic_expression("+", $1, $3);
      delete $1;
      delete $3;
    }
  | expression SUB multiplicative_exp  
    { 
      // - dst, src1, src2
      $$ = synthesize_arithmetic_expression("-", $1, $3);
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
      delete $1;
      delete $3;
    }
  | multiplicative_exp DIV term  
    { 
      // / dst, src1, src2
      $$ = synthesize_arithmetic_expression("/", $1, $3);
      delete $1;
      delete $3;
    }
  | multiplicative_exp MOD term  
    {
      // % dst, src1, src2
      $$ = synthesize_arithmetic_expression("%", $1, $3);
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
      $$->type = variable_type_t::INTEGER;
      delete $1;
    }
  | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET 
    { 
      $$ = new variable_t;
      $$->name = $1->name;
      $$->expression = *$3;
      $$->type = variable_type_t::ARRAY;
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
      $$->code += gen_ins_arithmetic($$->op_code, $$->dst, $$->src1, $$->src2);
      record_symbol($$->dst, 
                    variable_type_t::INTEGER,
                    function_map[function_stack.top()].symbol_table);
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
      // the expression is simply the name of the integer variable. 
      $$ = new expression_t;
      if(is_array($1))
      {
        $$->dst = generate_name();
        $$->src1 = $1->name;
        $$->src2 = $1->expression.dst;
        $$->code += gen_ins_declare_variable($$->dst);
        $$->code += gen_ins_array_access_rval($$->dst, $$->src1, $$->src2);
        record_symbol($$->dst, 
                      variable_type_t::INTEGER,
                      function_map[function_stack.top()].symbol_table);
      }
      else
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
      $$->code += gen_ins_copy($$->dst, $$->src1);
      record_symbol($$->dst, 
                    variable_type_t::INTEGER,
                    function_map[function_stack.top()].symbol_table);
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
      // TODO : Check that function_map[function_stack.top()].symbol_table[$3->name] doesn't exist
      $$ = new identifiers_t; 
      $1->identifiers.push_back(*$3);
      $$->identifiers = $1->identifiers; 
      delete $3;
      delete $1;
    }
  | identifier 
    {
      // TODO : Check that function_map[function_stack.top()].symbol_table[$1->name] doesn't exist
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

number
  : NUMBER 
    { 
      $$ = new number_t;
      $$->val = *yylval.op_val;
      delete yylval.op_val;
    }
  ;

%%

