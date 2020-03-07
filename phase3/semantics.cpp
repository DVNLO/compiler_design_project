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
// returns a generated label of the form "L#"
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
is_array(variable_t const * const var)
// returns true if the argument variable_t val is an array.
// Note that an array variable has a non-empty 
// expression associated with it.
{
  return var && var->type == variable_type_t::ARRAY;
}

void record_symbol(std::string symbol, 
                   variable_type_t variable_type,
                   std::unordered_map<std::string, variable_type_t> symbol_table)
{
  symbol_table[symbol] = variable_type; 
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
