#ifndef MINI_L_SEMANTICS_H
#define MINI_L_SEMANTICS_H

#include "types.h"
#include <stack>

extern std::stack<std::string> function_stack;
extern std::unordered_map<std::string, function_t> function_map;
extern bool is_in_loop;

std::string generate_name();
std::string generate_label();
void record_symbol(std::string symbol, 
                   variable_type_t variable,
                   std::unordered_map<std::string, variable_type_t> symbol_table);
bool is_array(variable_t const * const var);
expression_t * copy_expression(expression_t const * const exp);
expression_t * synthesize_arithmetic_expression(std::string const & op_code,
                                                expression_t const * const lhs,
                                                expression_t const * const rhs);
expression_t * synthesize_comparison_expression(std::string const & op_code,
                                                expression_t const * const lhs,
                                                expression_t const * const rhs);
statement_t * convert_expression_to_statement(expression_t const * const);

#endif // MINI_L_SEMANTICS_h
