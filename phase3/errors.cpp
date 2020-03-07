#include "errors.h"

void
emit_error_message(std::string const msg)
// emits a helpful error message
{
   fprintf(stderr,
       "Error line %d: %s\n", yylineno, msg.c_str());
}

void partition(char * error_msg,
               char const delimiter,
               char * * error_msgs)
// partitions error_msg on delimiter into error_msgs
// assumes sufficient space in error_msgs
{
  if(!error_msg || !error_msgs)
    return;
  size_t i = 0;
  char * lead = error_msg;
  char * follow = error_msg;
  while(true)
  {
    while(*lead != 0
          && *lead != delimiter)
      ++lead;
    error_msgs[i] = follow;
    ++i;
    if(*lead == 0)
      break;
    else
      *lead = 0;  // replace ','
    lead += 2;  // advance over ", " to first char of next word
    follow = lead;
  }
}

size_t count_delimiter(char const * str,
                       char const delimiter)
// returns a count of delimiter found in str
{
  size_t delimiter_count = 0;
  while(*str != 0)
  {
    if(*str == delimiter)
      ++delimiter_count;
    ++str;
  }
  return delimiter_count;
}

void
yyerror(char const * s)
{
  size_t const S_SIZE = strlen(s);
  size_t const COL_COUNT = count_delimiter(s, ',') + 1;
  char * error_msg = (char *)(calloc(S_SIZE + 1, sizeof(char)));
  char * * error_msgs = (char * *)(calloc(COL_COUNT, sizeof(char * *)));

  strcpy(error_msg, s);
  partition(error_msg, ',', error_msgs);
  fprintf(stderr,
          "Syntax error at line %d: %s %s\n",
          yylineno,
          error_msgs[1] ? error_msgs[1] : "",
          error_msgs[2] ? error_msgs[2] : "");

  free(error_msg);
  free(error_msgs);
}

