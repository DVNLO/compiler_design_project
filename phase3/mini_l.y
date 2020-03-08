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
  declaration_t * decl_nt_val;
  declarations_t * decls_nt_val;
  parameters_t * params_nt_val;
  locals_t * locals_nt_val;
  parameter_list_t * param_list_nt_val;
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
%nterm<param_list_nt_val> term2
%nterm<exp_nt_val> term1
%nterm<exp_nt_val> term
%nterm<comp_nt_val> comp
%nterm<exp_nt_val> bool_exp
%nterm<exp_nt_val> relation_and_exp
%nterm<exp_nt_val> relation_exp
%nterm<exp_nt_val> relation_exp1
%nterm<statement_nt_val> statements
%nterm<statement_nt_val> statement
%nterm<statement_nt_val> statement_assign
%nterm<statement_nt_val> statement_if
%nterm<statement_nt_val> statement_while
%nterm<statement_nt_val> statement_do_while
%nterm<statement_nt_val> statement_for
%nterm<statement_nt_val> statement_read
%nterm<statement_nt_val> statement_write
%nterm<statement_nt_val> statement_continue
%nterm<statement_nt_val> statement_return
%nterm<decl_nt_val> declaration
%nterm<decls_nt_val> declarations
%nterm<params_nt_val> params
%nterm<locals_nt_val> locals

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
      if (function_map.find($2->name) != std::end(function_map))
      // TODO : We may want to create temp function name for the
      // case where function name has already be declared. This
      // will allow us to continue to create a function mapping
      // so that we can continue to parse the program and find
      // other possible errors.
      {
        emit_error_message("function with name '" + $2->name + "' previously declared");

        // generates a temporary function name that we can 
        // map to a function structure and continue parsing 
        // the program
        function_stack.push(generate_name()); 
      }
      else
        function_stack.push($2->name); 
    } 
    semicolon params locals body 
    {
      // TODO : Do not generate code if there are errors
      if (!has_semantic_errors()) {
        std::cout << "\nGenerate code.\n\n";
        std::cout << "func " << $2->name << std::endl;
        std::cout << $5->code;
        std::cout << $6->code;
        std::cout << "endfun\n\n";
      }
      else
        std::cout << "\nDo not generate code.\n\n";

      function_stack.pop();
      delete $6;
      delete $5;
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
        variable_type_t var_type = $2->declarations[i].variable_type;
        for (size_t j = 0; j < $2->declarations[i].identifiers.size(); j++) 
        {
          std::string identifier_name = $2->declarations[i].identifiers[j].name;
          std::string size = $2->declarations[i].size;

          if (is_integer(var_type)) 
            $$->code += gen_ins_declare_variable(identifier_name);
          else
            $$->code += gen_ins_declare_variable(identifier_name, size);
          $$->code += gen_ins_copy(identifier_name, '$' + std::to_string(param_number++));

          add_parameter_type(var_type); // populates parameter type vector
        }
      }
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
      $$ = new locals_t;

      for (size_t i = 0; i < $2->declarations.size(); i++)
      {
        variable_type_t var_type = $2->declarations[i].variable_type;
        for (size_t j = 0; j < $2->declarations[i].identifiers.size(); j++) 
        {
          std::string identifier_name = $2->declarations[i].identifiers[j].name;
          std::string size = $2->declarations[i].size;

          if (is_integer(var_type)) 
            $$->code += gen_ins_declare_variable(identifier_name);
          else
            $$->code += gen_ins_declare_variable(identifier_name, size);
        }
      }
      delete $2;
    }
  | begin_locals end_locals {
      $$ = new locals_t;
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
      delete $2;
      delete $1;
    }
  | declaration SEMICOLON {
      $$ = new declarations_t;
      $$->declarations.push_back(*$1);
      delete $1;
    }
  ;

declaration
  : identifiers COLON INTEGER { 
      std::string identifier_name;
      for (size_t i = 0; i < $1->identifiers.size(); i++)
      {
        identifier_name = $1->identifiers[i].name;
        if (in_symbol_table(identifier_name))
          emit_error_message("symbol '" + identifier_name + "' previously declared");
        else
          record_symbol(identifier_name,
                        variable_type_t::INTEGER,
                        function_map[function_stack.top()].symbol_table);
      }

      $$ = new declaration_t;
      $$->identifiers = $1->identifiers;
      $$->variable_type = variable_type_t::INTEGER;
      delete $1;
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      std::string identifier_name;
      for (size_t i = 0; i < $1->identifiers.size(); i++)
      {
        identifier_name = $1->identifiers[i].name;
        if (in_symbol_table(identifier_name))
          emit_error_message("symbol '" + identifier_name + "' previously declared");
        else
          record_symbol(identifier_name,
                        variable_type_t::ARRAY,
                        function_map[function_stack.top()].symbol_table);
      }
      $$ = new declaration_t;
      $$->identifiers = $1->identifiers;
      $$->size = $5->val;
      $$->variable_type = variable_type_t::ARRAY;

      delete $5;
      delete $1;
    }
  | error { puts("declaration -> error"); }
  ;

statements
  : statements statement SEMICOLON 
    {
      // appends statement to statements and copies
      // statements on the rhs to the lhs statements 
      append_statement($2, $1);
      $$ = copy_statement($1);

      delete $2;
      delete $1;
    }
  | statement SEMICOLON 
    {
      $$ = copy_statement($1);
      delete $1;
    }
  ;

statement
  : statement_assign   { $$ = $1; }
  | statement_if       { $$ = $1; }
  | statement_while    { $$ = $1; }
  | statement_do_while { $$ = $1; }
  | statement_for      { $$ = $1; }
  | statement_read     { $$ = $1; }
  | statement_write    { $$ = $1; }
  | statement_continue { $$ = $1; }
  | statement_return   { $$ = $1; }
  | error              { puts("statement -> error"); }
  ;

statement_assign
  : variable ASSIGN expression 
    {
      // assign the value of an expression to a variable.
      // If variable is an array store the value of the 
      // array index position in src1. Append the expressions
      // instructions and generate the instruction.
      $$ = new statement_t;
      if(is_array($1))
      {
        $$->dst = $1->name;
        $$->src1 = $1->expression.dst;  // TODO : may be out of bounds.
        $$->src2 = $3->dst;
        $$->code += $3->code;
        $$->code += $1->expression.code;
        $$->code += gen_ins_array_access_lval($$->dst,
                                              $$->src1,
                                              $$->src2);
      }
      else
      {
        $$->dst = $1->name;
        $$->src1 = $3->dst;
        $$->code += $3->code;
        $$->code += gen_ins_copy($$->dst, 
                                 $$->src1);
      }
      delete $3;
      delete $1;
    }
  ;

statement_if
  : IF bool_exp THEN statements ENDIF 
    { 
      // generates a new if statement. Copies the code
      // from bool_exp. Generates two labels, true and 
      // false representing the label targets of the 
      // conditional branch instruction. If the conditional
      // branch is true the branch will be taken and 
      // jump to the true label declaration. If the branch
      // conditional is false control flow will fall
      // through and a unconditional branch will jump 
      // over the statements block to the false label.
      $$ = new statement_t;
      std::string const true_label = generate_label(); 
      std::string const false_label = generate_label();
      $$->src1 = $2->dst;  // contains the predicate of bool_exp
      $$->code += $2->code;
      $$->code += gen_ins_branch_conditional(true_label, $$->src1);
      $$->code += gen_ins_branch_goto(false_label);
      $$->code += gen_ins_declare_label(true_label);
      $$->code += $4->code;  // statements
      $$->code += gen_ins_declare_label(false_label);
      $$->src1.clear();
      $$->dst = false_label;
      delete $4;
      delete $2;
    }
  | IF bool_exp THEN statements ELSE statements ENDIF 
    {
      // generates a new if-else statement. Copies code
      // from bool_exp. Generates three labels, true, false
      // and end. If the conditional branch is true control
      // flow will jump to the true label, and at the end 
      // the true statements block will unconditionally jump
      // to the end lable. Otherwise, if the branch conditional 
      // is false control flow will jump to the false lablel.
      $$ = new statement_t;
      std::string const true_label = generate_label(); 
      std::string const false_label = generate_label();
      std::string const end_label = generate_label();
      $$->src1 = $2->dst;  // contains the predicate of bool_exp
      $$->code += $2->code;
      $$->code += gen_ins_branch_conditional(true_label, $$->src1);
      $$->code += gen_ins_branch_goto(false_label);
      $$->code += gen_ins_declare_label(true_label);
      $$->code += $4->code;  // true statements
      $$->code += gen_ins_branch_goto(end_label);
      $$->code += gen_ins_declare_label(false_label);
      $$->code += $6->code;  // false statements
      $$->code += gen_ins_declare_label(end_label);
      $$->src1.clear();
      $$->dst = end_label;
      delete $4;
      delete $2;
}
  ;

statement_while
  : WHILE bool_exp 
    BEGINLOOP 
    { 
      is_in_loop = true; 
    }
    statements 
    ENDLOOP 
    { 
      is_in_loop = false;
      // TODO : build a while loop...
    }
  ;

statement_do_while
  : DO BEGINLOOP
    {
      is_in_loop = true;
    } 
    statements ENDLOOP WHILE bool_exp 
    {
      is_in_loop = false;
      // TODO : build a do while loop...
    }
  ;

statement_for
  : FOR variable ASSIGN number SEMICOLON 
    bool_exp SEMICOLON 
    statement_assign 
    BEGINLOOP 
    { 
      is_in_loop = true; 
    } 
    statements 
    ENDLOOP
    {
      is_in_loop = false;
      // TODO : build the for loop. 
    }
  ;

statement_read
  : READ variables 
    { 
      // synthesizes statements to read to variables. If a variable
      // is an array, use destination expression as the index. Otherwise,
      // read into the variable's name directly. 
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
          $$->code += cur_var.expression.code;
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
      // synthesizes statements to write to variables. If a variable
      // is an array, use destination expression as the index. Otherwise,
      // write into the variable's name directly. 
      $$ = new statement_t;
      variable_t cur_var;
      size_t const SIZE_VARIABLES = $2->variables.size();
      for(size_t i = 0; i < SIZE_VARIABLES; ++i)
      {
        cur_var = $2->variables[i];
        if(is_array(&cur_var))
        {
          $$->dst = cur_var.name;
          $$->src1 = cur_var.expression.dst; // index
          $$->code += cur_var.expression.code;
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
  : CONTINUE 
    {
      if(!is_in_loop)
      {
        // TODO : raise exception, continue statement used outside loop
      }
      else
      {
        // TODO : branch
      }
    }
  ;

statement_return
  : RETURN expression 
    {
      $$ = new statement_t;
      $$->dst = $2->dst;
      $$->code += $2->code;
      $$->code += gen_ins_ret($$->dst);
      delete $2;
    }
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
      $$->code += $2->code;
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
      if(!parameters_match_function_identifier($3->parameters, $1->name))
      {
        // TODO : record the error.
      }
      $$ = new expression_t;
      $$->dst = generate_name();
      $$->code += $3->code;
      record_symbol($$->dst,
                    variable_type_t::INTEGER,
                    function_map[function_stack.top()].symbol_table);
      $$->code += gen_ins_call($1->name, $$->dst);
      delete $3;
      delete $1;
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
        $$->code += $1->expression.code;
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
      delete $1;
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
      $$ = new parameter_list_t;
      $$->code += $1->code;
      $$->parameters.push_back($1->dst);
      for(size_t i = 0; i < $3->parameters.size(); ++i)
        $$->parameters.push_back($3->parameters[i]);
      $$->code += gen_ins_param($1->dst);
      $$->code += $3->code;
      delete $3;
      delete $1;
    }
  | expression 
    {
      $$ = new parameter_list_t;
      $$->code += $1->code;
      $$->parameters.push_back($1->dst);
      $$->code += gen_ins_param($1->dst);
      delete $1;
    }
  | { }
  ;

identifiers
  : identifiers COMMA identifier 
    {
      // TODO : Check that function_map[function_stack.top()].symbol_table[$3->name] doesn't exist
      //std::cout << (int)function_map[function_stack.top()].symbol_table[$$->dst] << std::endl;
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

