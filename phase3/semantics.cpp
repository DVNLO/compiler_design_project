#include "semantics.h"
#include "instructions.h"

std::stack<std::string> function_stack;
std::unordered_map<std::string, function_t> function_map;
bool is_in_loop;

std::string
generate_name()
// returns a generated temporary name of the form "__temp__#"
// where # is a numerical counter.
{
  static unsigned id = 0;
  static std::string const NAME_PREFIX = "__temp__";
  return NAME_PREFIX + std::to_string(id++);
}

std::string
generate_label()
// returns a generated label of the form "__label__#"
// where # is a numerical count.
{
  static unsigned id = 0;
  static std::string const LABEL_PREFIX = "__label__";
  return LABEL_PREFIX + std::to_string(id++);
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
  function_map[function_stack.top()].parameter_types.push_back(var_type);
}

void
record_symbol(std::string symbol, 
              variable_type_t variable_type,
              std::unordered_map<std::string, variable_type_t> & symbol_table)
{
  symbol_table[symbol] = variable_type; 
}

bool
in_symbol_table(std::string const & symbol)
// returns true if symbol already exists within
// the local symbol table
{
  static std::unordered_map<std::string, variable_type_t> * symbol_table;
  symbol_table = &function_map[function_stack.top()].symbol_table;

  return symbol_table->find(symbol) != std::end(*symbol_table);
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
                variable_type_t::INTEGER, 
                function_map[function_stack.top()].symbol_table);
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

bool
parameters_match_function_identifier(std::vector<std::string> const & parameters,
                                     std::string const & function_identifier)
// returns true if all corresponding parameter types match for an 
// existing function identifier.
{
  if(!function_map.count(function_identifier))
    return false;
  function_t target = function_map[function_identifier];
  if(parameters.size() != target.parameter_types.size())
    return false;
  for(size_t i = 0; i < target.parameter_types.size(); ++i)
  {
    if(target.symbol_table[parameters[i]] != target.parameter_types[i])
      return false;
  }
  return true;
}

bool
is_variable_declared(std::string const name, 
                     std::unordered_map<std::string, variable_type_t> symbol_table)
// returns true if a variable is declared in the symbol table
{
  return static_cast<bool>(symbol_table.count(name));
}

bool
is_main_defined(std::vector<function_t> const & functions, 
                std::unordered_map<std::string, function_t> function_map)
// returns true if a "main" function is defined
{
  size_t const SIZE_FUNCTIONS = functions.size();
  for(size_t i = 0; i < SIZE_FUNCTIONS; ++i)
  {
    if(function_map.count(functions[i].name))
      return true;
  }
  return false;
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
