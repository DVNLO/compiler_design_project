#ifndef MINI_L_SEMANTICS_H
#define MINI_L_SEMANTICS_H

#include "types.h"

std::string generate_name();
std::string generate_code(expression_t const * const exp);
expression_t * synthesize_expression(char const op_code,
                                     expression_t const * const lhs,
                                     expression_t const * const rhs);

#endif // MINI_L_SEMANTICS_h
