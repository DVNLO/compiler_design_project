#ifndef MINI_L_SEMANTICS_H
#define MINI_L_SEMANTICS_H

#include "types.h"
#include <stack>

std::string generate_name();
std::string generate_alias_function();
std::string generate_alias_variable();
std::string generate_label();

std::string get_current_loop_label();
bool in_loop();
void entering_loop();
void leaving_loop();
void add_parameter_type(variable_type_t var_type);

void record_symbol(std::string symbol, 
                   variable_type_t variable);
void record_alias_function(std::string const & function_identifier, 
                           std::string const & function_identifier_alias);
void record_alias_variable(std::string const & variable_identifier, 
                           std::string const & variable_identifier_alias);


bool is_function_declared(std::string const & identifier);
bool is_symbol_declared(std::string const & symbol);
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
bool do_parameters_match_function_identifier(std::vector<std::string> const & parameters,
                                             std::string const & function_identifier);
bool is_main_defined(std::vector<std::string> const & functions);
bool is_keyword(std::string const & word);
std::string get_alias_variable(std::string const & variable_identifier);
std::string get_alias_function(std::string const & function_identifier);
function_t & get_function(std::string const & function_identifier_alias);

void push_function_stack(std::string const & function_identifier_alias);
void pop_function_stack();
variable_type_t get_variable_type(std::string const & variable_identifier_alias);

bool is_in_main();

#endif // MINI_L_SEMANTICS_h
