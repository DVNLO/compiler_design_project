#ifndef MINI_L_TYPES_H
#define MINI_L_TYPES_H

#include <string>
#include <vector>

struct identifier_t;
struct number_t;

struct function_t
{
  
};

struct declaration_t
{
  std::string code;
};

struct declarations_t
{
  std::vector<declaration_t> declarations;
};

struct expression_t
{
  char op_code;
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
  int val;
};

#endif  // MINI_L_TYPES_H
