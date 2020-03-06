#ifndef MINI_L_ERRORS_H
#define MINI_L_ERRORS_H

#include <cstddef>
#include <cstring>
#include <cstdio>
#include <cstdlib>

extern int yylineno;

void partition(char * error_msg,
               char const delimiter,
               char * * error_msgs);

size_t count_delimiter(char const * str,
                       char const delimiter);

void yyerror(char const * s);

#endif  // MINI_L_ERRORS_H
