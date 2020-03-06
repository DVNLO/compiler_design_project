#ifndef MINI_L_SEMANTICS_H
#define MINI_L_SEMANTICS_H

#include "types.h"

std::string generate_name();
bool is_array(variable_t const * const var);
expression_t * copy_expression(expression_t const * const exp);
expression_t * synthesize_arithmetic_expression(std::string const & op_code,
                                                expression_t const * const lhs,
                                                expression_t const * const rhs);


#endif // MINI_L_SEMANTICS_h
