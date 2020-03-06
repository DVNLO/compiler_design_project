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

struct variable_t
{
  std::string name;
  expression_t expression;
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
