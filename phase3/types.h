#ifndef __TYPES_H__
#define __TYPES_H__

const string tmp_id_name = "__tmp__";

typedef struct {
  string name;
} identifier_t;

typedef struct {
  vector<identifier_t *> ids;
} identifiers_t;

typedef struct {
  int val;
} number_t;

typedef struct {
  identifier_t * id;
  string code;
} expression_t;

typedef struct {
  identifier_t * id;
  string code;
  string idx;
  bool is_array;
} variable_t;

typedef struct {
  vector<variable_t *> vars;
} variables_t;

typedef struct {
  identifier_t * id;
  string code;
} term_t;

typedef struct {
  string code;
} code_t;


#endif
