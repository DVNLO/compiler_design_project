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
  function_t * function_nt_val;
  functions_t * functions_nt_val;
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
%nterm<id_nt_val> function
%nterm<functions_nt_val> functions
%nterm<functions_nt_val> program
%nterm<statement_nt_val> body

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
  : 
    {
      emit_error_message("no main function defined");
    }
  | functions
    { 
      std::vector<std::string> & functions = $1->functions;
      if(!is_main_defined(functions))
      {
        emit_error_message("no main function defined");
      }
      if(!is_error())
      {
        size_t const SIZE_FUNCTIONS = $1->functions.size();
        for(size_t i = 0; i < SIZE_FUNCTIONS; ++i)
        {
          std::string const & function_identifier_alias = get_alias_function(functions[i]);
          function_t & this_function = get_function(function_identifier_alias);
          puts(this_function.code.c_str());
        }
      }
    }
  ;

functions
  : functions function 
    {
      $$ = new functions_t;
      $$->functions = $1->functions;
      $$->functions.push_back($2->name);
      delete $2;
      delete $1; 
    }
  | function 
    {
      $$ = new functions_t;
      $$->functions.push_back($1->name);
      delete $1; 
    }
  ;

function
  : function1 identifier 
    { 
      std::string & function_identifier = $2->name;
      std::string function_identifier_alias;
      if(is_function_declared(function_identifier))
      {
        emit_error_message("function '" + function_identifier + "' previously declared");
        function_identifier = generate_name();
      }
      function_identifier_alias = generate_alias_function();
      if(function_identifier == "main")
      {
        record_alias_function(function_identifier, 
                              function_identifier); // treat main as it's own alias
      }
      else
      {
        record_alias_function(function_identifier, 
                              function_identifier_alias);
      }
      push_function_stack(function_identifier_alias);
    } 
    semicolon params locals body 
    {
      std::string & function_identifier = $2->name;
      std::string function_identifier_alias = get_alias_function(function_identifier);
      parameters_t & params = *$5;
      locals_t & locals = *$6;
      statement_t & body = *$7;

      function_t & this_function = get_function(function_identifier_alias);
      this_function.name = function_identifier_alias;
      this_function.code += gen_ins_declare_function(function_identifier_alias);
      this_function.code += params.code;
      this_function.code += locals.code;
      this_function.code += body.code;
      this_function.code += gen_ins_end_function();
      
      $$ = new identifier_t;
      $$->name = function_identifier;
      
      delete $6;
      delete $5;
      pop_function_stack();
    }
  | error { $$ = new identifier_t; }
  ;

function1
  : FUNCTION { }
  | error { }
  ;

semicolon
  : SEMICOLON { }
  | error { }
  ;

params
  : begin_params declarations end_params 
    {
      $$ = new parameters_t;
      int param_number = 0;
      std::vector<declaration_t> & declarations = $2->declarations;
      size_t const SIZE_DECLARATIONS = declarations.size();
      for(size_t i = 0; i < SIZE_DECLARATIONS; ++i)
      {
        variable_type_t const & var_type = declarations[i].variable_type;
        size_t const SIZE_IDENTIFIERS = declarations[i].identifiers.size(); 
        for (size_t j = 0; j < SIZE_IDENTIFIERS; ++j) 
        {
          std::string const & identifier_name = declarations[i].identifiers[j].name;
          std::string const & identifier_name_alias = get_alias_variable(identifier_name);
          std::string const size = declarations[i].size;
          if(is_integer(var_type))
          {
            $$->code += gen_ins_declare_variable(identifier_name_alias);
          }
          else
          {
            $$->code += gen_ins_declare_variable(identifier_name_alias, size);
          }
          $$->code += gen_ins_copy(identifier_name_alias, '$' + std::to_string(param_number++));
          add_parameter_type(var_type); // populates parameter type vector
        }
      }
      delete $2;
    }
  | begin_params end_params 
    {
      $$ = new parameters_t;
    }
  ;

begin_params
  : BEGIN_PARAMS { }
  | error { }
  ;

end_params
  : END_PARAMS { }
  | error { }
  ;

locals
  : begin_locals declarations end_locals 
    {
      $$ = new locals_t;
      std::vector<declaration_t> & declarations = $2->declarations; 
      size_t const SIZE_DECLARATIONS = declarations.size();
      for(size_t i = 0; i < SIZE_DECLARATIONS; ++i)
      {
        variable_type_t const & var_type = declarations[i].variable_type;
        size_t const SIZE_IDENTIFIERS = declarations[i].identifiers.size();
        for(size_t j = 0; j < SIZE_IDENTIFIERS; ++j) 
        {
          std::string const & identifier_name = declarations[i].identifiers[j].name;
          std::string const & identifier_name_alias = get_alias_variable(identifier_name);
          std::string const size = declarations[i].size;
          if(is_integer(var_type))
          {
            $$->code += gen_ins_declare_variable(identifier_name_alias);
          }
          else
          {
            $$->code += gen_ins_declare_variable(identifier_name_alias, size);
          }
        }
      }
      delete $2;
    }
  | begin_locals end_locals 
    {
      $$ = new locals_t;
    }
  ;

begin_locals
  : BEGIN_LOCALS { }
  | error { }
  ;

end_locals
  : END_LOCALS { }
  | error { }
  ;

body
  : begin_body statements end_body 
    {
      $$ = $2; 
    }
  ;

begin_body
  : BEGIN_BODY { }
  | error { }
  ;

end_body
  : END_BODY { }
  | error { }
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
  : identifiers COLON INTEGER 
    { 
      std::string identifier_name_alias;
      size_t const SIZE_IDENTIFIERS = $1->identifiers.size();
      for(size_t i = 0; i < SIZE_IDENTIFIERS; ++i)
      {
        std::string & identifier_name = $1->identifiers[i].name;
        if(is_keyword(identifier_name))
        {
          emit_error_message("declaration of symbol using language keyword");
          identifier_name = generate_name();
        }
        if(is_symbol_declared(identifier_name))
        {
          emit_error_message("symbol '" + identifier_name + "' previously declared");
          identifier_name = generate_name();
        }
        identifier_name_alias = generate_alias_variable();
        record_alias_variable(identifier_name, 
                              identifier_name_alias);
        record_symbol(identifier_name_alias,
                      variable_type_t::INTEGER);
      }
      $$ = new declaration_t;
      $$->identifiers = $1->identifiers;
      $$->variable_type = variable_type_t::INTEGER;
      delete $1;
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER 
    { 
      if(std::stoi($5->val) <= 0)
      {
        emit_error_message("declaration of array with non-positive size");
      }
      std::string identifier_name_alias;
      size_t const SIZE_IDENTIFIERS = $1->identifiers.size();
      for (size_t i = 0; i < SIZE_IDENTIFIERS; ++i)
      {
        std::string & identifier_name = $1->identifiers[i].name;
        if (is_keyword(identifier_name))
        {
          emit_error_message("declaration of symbol using language keyword");
          identifier_name = generate_name();
        }
        if(is_symbol_declared(identifier_name))
        {
          emit_error_message("symbol '" + identifier_name + "' previously declared");
          identifier_name = generate_name();
        }
        identifier_name_alias = generate_alias_variable();
        record_alias_variable(identifier_name, 
                              identifier_name_alias);
        record_symbol(identifier_name_alias,
                      variable_type_t::ARRAY);
      }
      $$ = new declaration_t;
      $$->identifiers = $1->identifiers;
      $$->size = $5->val;
      $$->variable_type = variable_type_t::ARRAY;

      delete $5;
      delete $1;
    }
  | error { $$ = new declaration_t; }
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
  | error              { $$ = new statement_t; }
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
      entering_loop();
    }
    statements 
    ENDLOOP 
    { 
      // Generates a while loop. unique_loop_label is used to 
      // label the beginning of the boolean expression which
      // will be checked every iteration until condition fails.
      // When the condition fails we branch to loop_body_end_label
      // terminating out loop. unique_loop_label will be the label
      // that any continue statement within this loop will branch to.
      $$ = new statement_t;
      std::string const loop_body_start_label = generate_label();
      std::string const loop_body_end_label = generate_label();
      std::string const unique_loop_label = get_current_loop_label();

      $$->code += gen_ins_declare_label(unique_loop_label);
      $$->code += $2->code; // bool_exp
      $$->code += gen_ins_branch_conditional(loop_body_start_label, $2->dst);
      $$->code += gen_ins_branch_goto(loop_body_end_label);
      $$->code += gen_ins_declare_label(loop_body_start_label);
      $$->code += $5->code; // statements
      $$->code += gen_ins_branch_goto(unique_loop_label);
      $$->code += gen_ins_declare_label(loop_body_end_label);
      leaving_loop();
    }
  ;

statement_do_while
  : DO BEGINLOOP
    {
      entering_loop();
    } 
    statements ENDLOOP WHILE bool_exp 
    {
      // Generates a do-while loop. loop_body_start_label is used
      // to label the beginning of the loop body and unique_loop_label
      // is used to label the end of the loop body along with the 
      // beginning of the boolean expression. unique_loop_label will
      // be the label that any continue statement within this loop
      // will branch to.
      $$ = new statement_t;
      std::string const loop_body_start_label = generate_label();
      std::string const unique_loop_label = get_current_loop_label();

      $$->code += gen_ins_declare_label(loop_body_start_label);
      $$->code += $4->code; // statements
      $$->code += gen_ins_declare_label(unique_loop_label);
      $$->code += $7->code; // bool_exp
      $$->code += gen_ins_branch_conditional(loop_body_start_label, $7->dst);
      leaving_loop();
    }
  ;

statement_for
  : FOR variable ASSIGN number SEMICOLON 
    bool_exp SEMICOLON 
    statement_assign 
    BEGINLOOP 
    { 
      entering_loop();
    } 
    statements 
    ENDLOOP
    {
      // Generates a for loop. loop_body_start_label is used to branch
      // into the body of the loop while loop_body_end_label is used
      // to branch out of the body of the loop. unique_loop_label is
      // used to label the beginning of the boolean expression and will
      // be the label that all continue statements within this loop 
      // will branch to. first_iteration_label is used to skip over the
      // statement_assign portion of the loop during the first iteration.
      std::string const loop_body_start_label = generate_label();
      std::string const loop_body_end_label = generate_label();
      std::string const first_iteration_label = generate_label();
      std::string const unique_loop_label = get_current_loop_label();
      variable_t var = *$2;

      $$ = new statement_t;
      if (is_array(var.type))
      {
        $$->code = var.expression.code;
        $$->code += gen_ins_array_access_lval(var.name,
                                              var.expression.dst,
                                              $4->val);
      }
      else
        $$->code = gen_ins_copy(var.name, $4->val);

      $$->code += gen_ins_branch_goto(first_iteration_label);
      $$->code += gen_ins_declare_label(unique_loop_label);
      $$->code += $8->code; // statement_assign
      $$->code += gen_ins_declare_label(first_iteration_label);
      $$->code += $6->code; // bool_exp
      $$->code += gen_ins_branch_conditional(loop_body_start_label, $6->dst);
      $$->code += gen_ins_branch_goto(loop_body_end_label);
      $$->code += gen_ins_declare_label(loop_body_start_label);
      $$->code += $11->code; // statements
      $$->code += gen_ins_branch_goto(unique_loop_label); // loop back for another iteration
      $$->code += gen_ins_declare_label(loop_body_end_label); 
      $$->src1.clear();
      $$->dst = loop_body_end_label;
      leaving_loop();
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
      $$ = new statement_t;
      if(in_loop())
      {
        //std::cout << "\nLOOP LABEL: " << get_current_loop_label() << '\n';
        std::string loop_label = get_current_loop_label();
        $$->code = gen_ins_branch_goto(loop_label);
      }
      else
        emit_error_message("continue statement not within a loop.");
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
                    variable_type_t::INTEGER);
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
      record_symbol($$->dst, 
                    variable_type_t::INTEGER);
    }
  | FALSE 
    { 
      $$ = new expression_t;
      $$->dst = generate_name();
      $$->src1 = "0";
      $$->code += gen_ins_declare_variable($$->dst);
      $$->code += gen_ins_copy($$->dst, $$->src1);
      record_symbol($$->dst, 
                    variable_type_t::INTEGER); 
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
      $$->variables = $1->variables;
      $$->variables.push_back(*$3);
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
      std::string variable_name = $1->name;
      std::string variable_name_alias;
      if(!is_symbol_declared(variable_name))
      {
        emit_error_message("use of undeclared variable '" + variable_name + "'");
      }
      else
      {
        variable_name_alias = get_alias_variable(variable_name);
        if(!is_integer(get_variable_type(variable_name_alias)))
        {
          emit_error_message("invalid use of non-integer variable '" + variable_name + "'");
        }
      }
      $$ = new variable_t;
      $$->name = variable_name_alias;
      $$->type = variable_type_t::INTEGER;
      delete $1;
    }
  | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET 
    { 
      std::string variable_name = $1->name;
      std::string variable_name_alias;
      if(!is_symbol_declared(variable_name))
      {
        emit_error_message("use of undeclared variable '" + variable_name + "'");
      }
      else
      {
        variable_name_alias = get_alias_variable(variable_name);
        if(!is_array(get_variable_type(variable_name_alias)))
        {
          emit_error_message("invalid use of non-array variable '" + variable_name + "'");
        }
      }
      $$ = new variable_t;
      $$->name = variable_name_alias;
      $$->type = variable_type_t::ARRAY;
      $$->expression = *$3;
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
                    variable_type_t::INTEGER);
    }
  | term1 
    { 
      $$ = copy_expression($1);
      delete $1;
    }
  | identifier L_PAREN term2 R_PAREN  
    { 
      std::string function_identifier = $1->name;
      std::string function_identifier_alias;
      if(!is_function_declared(function_identifier))
      {
        emit_error_message("use of undeclared function");
        function_identifier_alias = generate_alias_function();
        record_alias_function(function_identifier,
                              function_identifier_alias);
      }
      else if(!do_parameters_match_function_identifier($3->parameters, function_identifier))
      {
        emit_error_message("paramaters do not match function signature");
        function_identifier_alias = get_alias_function(function_identifier);
      }
      else
      {
        function_identifier_alias = get_alias_function(function_identifier);
      }
      $$ = new expression_t;
      $$->dst = generate_name();
      $$->code += gen_ins_declare_variable($$->dst);
      $$->code += $3->code;
      $$->code += gen_ins_call(function_identifier_alias, $$->dst);
      record_symbol($$->dst, 
                    variable_type_t::INTEGER);
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
                      variable_type_t::INTEGER);
      }
      else
      {
        $$->dst = $1->name; 
      }
      delete $1;
    }
  | number  
    { 
      // convert a number into an expression, immediate. 
      $$ = new expression_t;
      $$->dst = $1->val; 
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
  | { $$ = new parameter_list_t; }
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

number
  : NUMBER 
    { 
      $$ = new number_t;
      $$->val = *yylval.op_val;
      delete yylval.op_val;
    }
  ;

%%

