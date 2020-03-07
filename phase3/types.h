#ifndef MINI_L_TYPES_H
#define MINI_L_TYPES_H

#include <string>
#include <vector>
#include <unordered_map>

enum class variable_type_t
{
  INTEGER,
  ARRAY
};

struct parameter_t
{
  variable_type_t variable_type;
};

struct paramaters_t
{
  std::vector<parameter_t> parameters;
};

// TODO : Function has name, paramaters, statements
struct function_t
{
  std::string name;
  paramaters_t paramaters;
  std::unordered_map<std::string, variable_type_t> symbol_table;
};

struct statement_t
{
  std::string op_code;
  std::string dst;
  std::string src1;
  std::string src2;
  std::string code;
};

struct expression_t
{
  std::string op_code;
  std::string dst;
  std::string src1;
  std::string src2;
  std::string code;
};

struct variable_t
{
  std::string name;
  expression_t expression;
  variable_type_t type; 
};

struct variables_t
{
  std::vector<variable_t> variables; 
};

struct comparison_t
{
  std::string op_code;
};

struct identifier_t
{
  std::string name;
};

struct identifiers_t
{
  std::vector<identifier_t> identifiers;
};

struct number_t
{
  std::string val;
};

#endif  // MINI_L_TYPES_H
