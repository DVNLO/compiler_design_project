#include "semantics.h"
#include "instructions.h"

std::string
generate_name()
// returns a generated temporary name of the form "__temp__#"
// where # is an counter.
{
  static unsigned id = 0;
  static std::string const NAME_PREFIX = "__temp__";
  return NAME_PREFIX + std::to_string(id++);
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
// Note that a variable with an empty expression is not 
// an array variable.
{
  return var && !is_empty_expression(&var->expression);
}

expression_t *
synthesize_arithmetic_expression(std::string const & op_code,
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
  ret->code += lhs->code;
  ret->code += rhs->code;
  ret->code += gen_ins_declare_variable(ret->dst);
  ret->code += gen_ins_arithmetic(ret->op_code, 
                                  ret->dst, 
                                  ret->src1, 
                                  ret->src2);
  return ret;
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

