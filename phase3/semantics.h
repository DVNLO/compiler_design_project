#ifndef MINI_L_SEMANTICS_H
#define MINI_L_SEMANTICS_H

#include "types.h"
#include <stack>

extern std::stack<std::string> function_stack;
extern std::unordered_map<std::string, function_t> function_map;
extern bool is_in_loop;

std::string generate_name();
std::string generate_label();
void add_parameter_type(variable_type_t var_type);
void record_symbol(std::string symbol, 
                   variable_type_t variable,
                   std::unordered_map<std::string, variable_type_t> & symbol_table);
bool in_symbol_table(std::string const & symbol);
bool is_array(variable_type_t const var_type);
bool is_array(variable_t const * const var);
bool is_integer(variable_t const * const var);
bool is_integer(variable_type_t const var_type);
expression_t * copy_expression(expression_t const * const exp);
expression_t * synthesize_arithmetic_expression(std::string const & op_code,
                                                expression_t const * const lhs,
                                                expression_t const * const rhs);
expression_t * synthesize_comparison_expression(std::string const & op_code,
                                                expression_t const * const lhs,
                                                expression_t const * const rhs);
statement_t * convert_expression_to_statement(expression_t const * const);
statement_t * copy_statement(statement_t const * const statement);
void append_statement(statement_t const * const src,
                      statement_t * const trgt);
bool parameters_match_function_identifier(std::vector<std::string> const & parameters,
                                          std::string const & function_identifier);
bool is_main_defined(std::vector<function_t> const & functions,
                     std::unordered_map<std::string, function_t> function_map);
bool is_keyword(std::string const & word);

#endif // MINI_L_SEMANTICS_h
