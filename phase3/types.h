#ifndef __TYPES_H__
#define __TYPES_H__

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
  string code;
} code_t;

#endif
