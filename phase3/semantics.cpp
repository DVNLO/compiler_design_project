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
declare_param(std::string const & name)
{
  static int param_num = 0;
  return "= " + name " $" + std::to_string(param_num++);
}

std::string
generate_params_code(declarations_t const * const decls)
{
  std::string code;
  for (int i = 0; i < decls->declarations.size(); i++) {
    for (int j = 0; j < decls->declarations[i].identifiers.size(); j++) {
      declare_name(decls->declarations[i][j].name);
      declare_param(decls->declarations[i][j].name);
    }
  }
}

std::string
generate_declaration_code(identifiers_t const * const ids)
// returns generated code for variable declarations
{
  std::string ret;
  for (int i = 0; i < ids->identifiers.size(); i++) {
    ret += ". ";
    ret += ids->identifiers[i];
    ret += '\n';
  }
  return ret;
}

std::string
generate_array_declaration_code(identifiers_t const * const ids, number_t const * const num)
// returns generated code for array declarations
{
  std::string ret;
  for (int i = 0; i < ids->identifiers.size(); i++) {
    ret += ".[] ";
    ret += ids->identifiers[i].name;
    ret += ' ';
    ret += std::to_string(num->val);
    ret += '\n';
  }
  return ret;
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

