#include "semantics.h"
#include "instructions.h"
#include <iostream>

std::unordered_map<std::string, std::string> function_alias_map;
std::stack<std::string> function_stack;
std::unordered_map<std::string, function_t> function_map;

static struct loop_t {
  std::stack<std::string> label_stack;
  bool in_loop = false;
} loop;

std::string
generate_name()
// returns a generated temporary name of the form "__temp__#"
// where # is a numerical counter.
{
  static unsigned id = 0;
  static std::string const NAME_PREFIX = "__temp__";
  function_t & top = get_function(function_stack.top());
  std::string ret;
  do
  {
    ret = NAME_PREFIX + std::to_string(id++);
  }
  while(top.alias_map.count(ret) 
        || function_alias_map.count(ret));
  return ret;
}

std::string
generate_label()
// returns a generated label of the form "__label__#"
// where # is a numerical count.
{
  static unsigned id = 0;
  static std::string const LABEL_PREFIX = "__label__";
  function_t & top = get_function(function_stack.top());
  std::string ret;
  do
  {
    ret = LABEL_PREFIX + std::to_string(id++);
  }
  while(top.alias_map.count(ret) 
        || function_alias_map.count(ret));
  return ret;
}

std::string
generate_alias_variable()
// returns a generated variable alias of the for "__var__#"
{
  static unsigned id = 0;
  static std::string const VARIABLE_ALIAS_PREFIX = "__var__";
  function_t & top = get_function(function_stack.top());
  std::string ret;
  do
  {
    ret = VARIABLE_ALIAS_PREFIX + std::to_string(id++);
  }
  while(top.alias_map.count(ret) 
        || function_alias_map.count(ret));
  return ret;
}

std::string
generate_alias_function()
// returns a generated function alias of the form "__fx__#"
{
  static unsigned id = 0;
  static std::string const FUNCTION_ALIAS_PREFIX = "__fx__";
  return FUNCTION_ALIAS_PREFIX + std::to_string(id++);
}
  
std::string
generate_loop_label()
// helper function that is only used by entering_loop().
// creates and returns a unique loop label which will be used 
// to branch to the loop variable increment/condition statement
{
  static std::string const LOOP_LABEL_PREFIX = "__loop__";
  static unsigned id = 0;
  function_t & top = get_function(function_stack.top());
  std::string ret;
  do
  {
    ret = LOOP_LABEL_PREFIX + std::to_string(id++);
  }
  while(top.alias_map.count(ret) 
        || function_alias_map.count(ret));
  return ret;
}

std::string
get_current_loop_label()
// returns the value value of the current loop label
{
  return loop.label_stack.top();
}

bool
in_loop()
// returns true if we are within a loop body
{
  return loop.in_loop;
}
  
void
entering_loop()
// generates a unique loop label and pushes it
// onto the loop label stack
{
  loop.in_loop = true;
  loop.label_stack.push(generate_loop_label());
}

void
leaving_loop()
// pops the unique label that was created for the loop
// that we are leaving
{
  loop.label_stack.pop();
  if (loop.label_stack.empty())
  // when all labels have been popped off
  // we are no longer in a loop
  { 
    loop.in_loop = false;
  }
}

bool 
is_empty_expression(expression_t const * const exp)
// returns true if an expression is empty. Note that
// an expression without a destination dst is considered
// empty.
{
  return exp && exp->dst.empty();
}

bool
is_array(variable_type_t const var_type)
// returns true if var_type is array.
{
  return var_type == variable_type_t::ARRAY;
}

bool 
is_array(variable_t const * const var)
// returns true if the argument variable_t val is an array.
{
  return var && is_array(var->type);
}

bool
is_integer(variable_type_t const var_type)
// returns true if var_type is integer
{
  return var_type == variable_type_t::INTEGER;
}

bool
is_integer(variable_t const * const var)
// returns true if var_type is integer
{
  return var && is_integer(var->type);
}

void
add_parameter_type(variable_type_t var_type)
// appends var_type to current function's
// vector of parameter_types
{
  function_t & function = get_function(function_stack.top());
  function.parameter_types.push_back(var_type);
}

function_t & 
get_function(std::string const & function_identifier_alias)
{
  return function_map[function_identifier_alias];
}

void
record_alias_function(std::string const & function_identifier,
                      std::string const & function_identifier_alias)
{
  function_alias_map[function_identifier] = function_identifier_alias;
}

void
record_alias_variable(std::string const & name,
                      std::string const & name_alias)
{
  function_t & function = get_function(function_stack.top());
  function.alias_map[name] = name_alias;
}

void
record_symbol(std::string symbol, 
              variable_type_t variable_type)
{
  function_map[function_stack.top()].symbol_table[symbol] = variable_type;
}

bool
is_symbol_declared(std::string const & symbol)
// returns true if symbol already exists within
// the local symbol table
{
  return static_cast<bool>(function_map[function_stack.top()].alias_map.count(symbol));
}

expression_t *
synthesize_tac_expression(std::string const & op_code,
                          expression_t const * const lhs,
                          expression_t const * const rhs)
// returns a synthesized three address code expression from op_code, expression
// lhs and rhs arguments.
{
  expression_t * ret = new expression_t;
  ret->op_code = op_code;
  ret->dst = generate_name();
  ret->src1 = lhs->dst;
  ret->src2 = rhs->dst;
  ret->code += lhs->code;
  ret->code += rhs->code;
  ret->code += gen_ins_declare_variable(ret->dst);
  ret->code += gen_ins_tac(ret->op_code,
                           ret->dst,
                           ret->src1,
                           ret->src2);
  record_symbol(ret->dst, 
                variable_type_t::INTEGER); 
  return ret;
}

expression_t *
synthesize_arithmetic_expression(std::string const & op_code,
                                 expression_t const * const lhs,
                                 expression_t const * const rhs)
// returns a synthesized expression from op_code, expression
// lhs and rhs arguments.
{
  return synthesize_tac_expression(op_code, lhs, rhs);
}

expression_t *
synthesize_comparison_expression(std::string const & op_code,
                                 expression_t const * const lhs,
                                 expression_t const * const rhs)
{
  return synthesize_tac_expression(op_code, lhs, rhs);
}
                                     

expression_t *
copy_expression(expression_t const * const exp)
// returns a copy of the provided expression val.
{
  expression_t * ret = new expression_t;
  ret->op_code = exp->op_code;
  ret->dst = exp->dst;
  ret->src1 = exp->src1;
  ret->src2 = exp->src2;
  ret->code = exp->code;
  return ret;
}


statement_t * 
convert_expression_to_statement(expression_t const * const exp)
// returns a statement converted from an argument exp expression_t
{
  statement_t * ret = new statement_t;
  ret->op_code = exp->op_code;
  ret->dst = exp->dst;
  ret->src1 = exp->src1;
  ret->src2 = exp->src2;
  ret->code = exp->code;
  return ret; 
}

statement_t *
copy_statement(statement_t const * const statement)
// returns a copy of an agrument statement statement_t
{
  statement_t * ret = new statement_t;
  ret->op_code = statement->op_code;
  ret->dst = statement->dst;
  ret->src1 = statement->src1;
  ret->src2 = statement->src2;
  ret->code = statement->code;
  return ret; 
}

void
append_statement(statement_t const * const statement,
                 statement_t * const trgt)
// appends a source statement to a target statement.
{
  trgt->op_code = statement->op_code;
  trgt->dst = statement->dst;
  trgt->src1 = statement->src1;
  trgt->src2 = statement->src2;
  trgt->code += statement->code;  
}

std::string 
get_alias_function(std::string const & function_identifier)
{
  return function_alias_map[function_identifier];
}

std::string
get_alias_variable(std::string const & variable_identifier)
{
  return function_map[function_stack.top()].alias_map[variable_identifier];
}

bool
do_parameters_match_function_identifier(std::vector<std::string> const & parameters,
                                        std::string const & function_identifier)
// returns true if all corresponding parameter types match for an 
// existing function identifier.
{
  std::string const & function_identifier_alias = get_alias_function(function_identifier);
  function_t & target = get_function(function_identifier_alias);
  if(parameters.size() != target.parameter_types.size())
  {
    return false;
  }
  size_t const SIZE_PARAMETER_TYPES = target.parameter_types.size();
  for(size_t i = 0; i < SIZE_PARAMETER_TYPES; ++i)
  {
    std::string parameter = parameters[i];
    variable_type_t parameter_type;
    if(function_map[function_stack.top()].alias_map.count(parameter))  
    // paramaters will be unaliased so we check the alias map of the current function
    {
      parameter = target.alias_map[parameter];
      parameter_type = target.symbol_table[parameter];	// use the aliased param to get the param type
    }
    else  // param is not aliased in this scope therefore it must be an expression which is integer type
    {
      parameter_type = variable_type_t::INTEGER;
    }
    if(parameter_type != target.parameter_types[i])
    {
      return false;
    }
  }
  return true;
}

bool
is_main_defined(std::vector<std::string> const & functions)
// returns true if a "main" function is defined
{
  return static_cast<bool>(function_alias_map.count("main"));
}

bool
is_keyword(std::string const & word)
// returns true if word is a language keyword
{
  static std::unordered_set<std::string> const language_keywords = { "function", "beginparams", "endparams", "beginlocals",
                                                                     "endlocals", "beginbody", "endbody", "integer",
                                                                     "array", "of", "if", "then",
                                                                     "endif", "else", "while", "do",
                                                                     "for", "beginloop", "endloop", "continue",
                                                                     "read", "write", "and", "or",
                                                                     "not", "true", "false", "return" };
  return static_cast<bool>(language_keywords.count(word));
}

bool
is_function_declared(std::string const & identifier)
// returns true if function is declared
{
  return static_cast<bool>(function_alias_map.count(identifier));
}

void
push_function_stack(std::string const & function_identifier_alias)
{
  function_stack.push(function_identifier_alias);
}

void
pop_function_stack()
{
 function_stack.pop();
}

variable_type_t
get_variable_type(std::string const & variable_identifier_alias)
{
  return function_map[function_stack.top()].symbol_table[variable_identifier_alias];
}

bool
is_in_main()
{
  return function_stack.top() == "main";
}
