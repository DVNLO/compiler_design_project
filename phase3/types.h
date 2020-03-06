#ifndef MINI_L_TYPES_H
#define MINI_L_TYPES_H

#include <string>
#include <vector>

struct expression_t
{
  std::string op_code;
  std::string dst;
  std::string src1;
  std::string src2;
  std::string code;
};

enum class variable_type_t
{
  INTEGER,
  ARRAY
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
