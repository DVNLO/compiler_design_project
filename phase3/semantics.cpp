#include "semantics.h"

std::string
generate_name()
// returns a generated temporary name of the form "__temp__#"
// where # is an counter.
{
  static unsigned id = 0;
  static std::string const NAME_PREFIX = "__temp__";
  return NAME_PREFIX + std::to_string(id++);
}

std::string
generate_code(expression_t const * const exp)
// returns a string of generated code from expression exp argument
{
  std::string ret = exp->code;
  ret += '\n';
  ret += exp->op_code;
  ret += ' ';
  ret += exp->dst;
  ret += ',';
  ret += ' ';
  ret += exp->src1;
  ret += ',';
  ret += ' ';
  ret += exp->src2;
  return ret;
}

expression_t *
synthesize_expression(char const op_code,
                      expression_t const * const lhs,
                      expression_t const * const rhs)
// returns a synthesized expression from op_code, expression
// lhs and rhs arguments.
{
  expression_t * ret = new expression_t;
  ret->op_code = op_code;
  ret->dst = generate_name();
  ret->src1 = lhs->dst;
  ret->src2 = rhs->dst;
  ret->code += generate_code(lhs);
  ret->code += generate_code(rhs);
  return ret;
}

