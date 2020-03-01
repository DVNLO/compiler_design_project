%{
#include "heading.h"
#include "types.h"

void yyerror(char const * s);
int yylex(void);

extern int yylineno; 
extern char * yytext; 
%}

%union{
  int int_val;
  string * op_val;
  
  identifier_t * id_semval;
  identifiers_t * ids_semval;
  number_t * num_semval;

  code_t * code_semval;
}

%define parse.error verbose
%define parse.lac full

%start program

%token <op_val> IDENT
%token <int_val> NUMBER 

%nterm <id_semval> identifier
%nterm <ids_semval> identifiers
%nterm <num_semval> number

%nterm <code_semval> program
%nterm <code_semval> functions function params locals body
%nterm <code_semval> declarations declaration

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN 

%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left MULT DIV MOD
%left ADD SUB

%left LT LTE GT GTE EQ NEQ 
%right NOT
%left AND 
%left OR
%right ASSIGN

%%

program
  : { puts("program -> epsilon"); }
  /*| functions { puts("program -> functions"); }*/
  | functions {
      puts("-- in program:");
      $$->code = $1->code;
      printf("%s", $$->code.c_str());
    }
  ;

functions
  : /*functions function { puts("functions -> functions function"); }
  | function { puts("functions -> function"); }
  : */
    functions function {
      ostringstream oss;
      oss << $1->code;
      oss << $2->code;
      $$ = new code_t();
      $$->code = oss.str();
    }
  | function {
      ostringstream oss;
      oss << $1->code;
      $$ = new code_t();
      $$->code = oss.str();
    }
  ;
  ;

function
  : function1 identifier semicolon params locals body {
      /* printf("func %s\n", $2->name.c_str()); */
      puts("-- in function:");

      ostringstream oss;
      oss << "func " << $2->name << endl;
      /*
      oss << $4->code << endl;
      oss << $5->code << endl;
      oss << $6->code << endl;
      */
      oss << "endfunc" << endl;
      $$ = new code_t();
      $$->code = oss.str();

      /* puts("function -> function1 identifier semicolon params locals body"); */
    }
  /*| error { puts("function -> error"); } */
  | error {}
  ;

function1
  : FUNCTION { /* puts("function1 -> FUNCTION"); */ }
  | error { /* puts("function1 -> error"); */ }
  ;

semicolon
  : SEMICOLON { /* puts("semicolon -> SEMICOLON"); */ }
  | error { /* puts("semicolon -> error"); */ }
  ;

params
  : begin_params declarations end_params {
      /* get declarations code */

      /* puts("params -> begin_params declarations end_params"); */
    }
  | begin_params end_params {
      /* puts("params -> begin_params end_params"); */
    }
  ;

begin_params
  : BEGIN_PARAMS { /* puts("begin_params -> BEGIN_PARAMS"); */ }
  | error { /* puts("begin_params -> error"); */ }
  ;

end_params
  : END_PARAMS { /* puts("end_params -> END_PARAMS"); */ }
  | error { /* puts("end_params -> error"); */ }
  ;

locals
  : begin_locals declarations end_locals {
      /* get declarations code */

      /* puts("locals -> begin_locals declarations end_locals"); */
    }
  | begin_locals end_locals {
      /* puts("locals -> begin_locals end_locals"); */
    }
  ;

begin_locals
  : BEGIN_LOCALS { /* puts("begin_locals -> BEGIN_LOCALS"); */ }
  | error { /* puts("begin_locals -> error"); */ }
  ;

end_locals
  : END_LOCALS { /* puts("end_locals -> END_LOCALS"); */ }
  | error { /* puts("end_locals -> error"); */ }
  ;

body
  : begin_body statements end_body {
      /* get statements code */

      /* puts("body -> begin_body statements end_body"); */
    }
  ;

begin_body
  : BEGIN_BODY { /* puts("begin_body -> BEGIN_BODY"); */ }
  | error { /* puts("begin_body -> error"); */ }
  ;

end_body
  : END_BODY { /* puts("end_body -> END_BODY"); */ }
  | error { /* puts("end_body -> error"); */ }
  ;

declarations
  : declarations declaration SEMICOLON { 
      /* get declarations code */
      /* get declaration code */

      /* puts("declarations -> declarations declaration SEMICOLON"); */
    }
  | declaration SEMICOLON { 
      /* get declaration code */

      /* puts("declarations -> declaration SEMICOLON"); */
    }
  ;

declaration
  : identifiers COLON INTEGER { 
      /* get identifiers names */
      /* set up integer code */

      $$ = new code_t();

      ostringstream oss;
      for (int i = 0; i < $1->ids.size(); i++)
        oss << ". " << $1->ids[i]->name.c_str() << endl;
      $$->code = oss.str();

      printf("%s", $$->code.c_str());

      /* puts("declaration -> identifiers COLON INTEGER"); */
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      /* get identifiers names */
      /* set up integer array code */

      $$ = new code_t();

      ostringstream oss;
      for (int i = 0; i < $1->ids.size(); i++)
        oss << ".[] " << $1->ids[i]->name.c_str() << " " << $5->val << endl;
      $$->code = oss.str();

      printf("%s", $$->code.c_str());

      /* puts("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET "
           "number R_SQUARE_BRACKET OF INTEGER"); */
    }
  | error { /* puts("declaration -> error"); */ }
  ;

statements
  : statements statement SEMICOLON { 
      /* get statements code */
      /* get statement code */

      /* puts("statements -> statements statement SEMICOLON"); */
    }
  | statement SEMICOLON {
      /* puts("statements -> statement SEMICOLON"); */
    }
  ;

statement
  : statement_assign   { /* puts("statement -> statement_assign"); */ }
  | statement_if       { /* puts("statement -> statement_if"); */ }
  | statement_while    { /* puts("statement -> statement_while"); */ }
  | statement_do_while { /* puts("statement -> statement_do_while"); */ }
  | statement_for      { /* puts("statement -> statement_for"); */ }
  | statement_read     { /* puts("statement -> statement_read"); */ }
  | statement_write    { /* puts("statement -> statement_write"); */ }
  | statement_continue { /* puts("statement -> statement_continue"); */ }
  | statement_return   { /* puts("statement -> statement_return"); */ }
  | error              { /* puts("statement -> error"); */ }
  ;

statement_assign
  : variable ASSIGN expression { 
      /* set up assignment code */

      /* puts("statement_assign -> variable ASSIGN expression"); */
    }
  ;

statement_if
  : IF bool_exp THEN statements ENDIF { 
      /* get bool_exp code */
      /* get statements code */
      /* set up conditional branching code */

      /* puts("statement_if -> IF bool_exp THEN statements ENDIF"); */
    }
  | IF bool_exp THEN statements ELSE statements ENDIF {
      /* get bool_exp code */
      /* get then statements code */
      /* get else statements code */
      /* set up 2 conditional branches code */

      /* puts("statement_if -> IF bool_exp THEN statements ELSE statements ENDIF"); */
    }
  ;

statement_while
  : WHILE bool_exp BEGINLOOP statements ENDLOOP { 
      /* get bool_exp code */
      /* set labels */
      /* get statements code */
      /* set branching */

      /* puts("statement_while -> WHILE bool_exp BEGINLOOP statements ENDLOOP"); */
    }
  ;

statement_do_while
  : DO BEGINLOOP statements ENDLOOP WHILE bool_exp {
      /* set labels */
      /* get statements code */
      /* get bool_exp code */
      /* set branching */

      /* puts("statement_do_while -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp"); */
    }
  ;

statement_for
  : FOR variable ASSIGN number SEMICOLON 
        bool_exp SEMICOLON 
        statement_assign 
        BEGINLOOP statements ENDLOOP {
      /* set assignment */
      /* get bool_exp code */
      /* get statement_assign code */
      /* set labels */
      /* get statements code */
      /* set branching */

      /* puts("statement_for -> FOR variable ASSIGN number SEMICOLON bool_exp "
           "SEMICOLON statement_assign BEGINLOOP statements ENDLOOP"); */
    }
  ;

statement_read
  : READ variables { /* puts("statement_read -> READ variables"); */ }
  ;

statement_write
  : WRITE variables { /* puts("statement_write -> WRITE variables"); */ }
  ;

statement_continue
  : CONTINUE { /* puts("statement_continue -> CONTINUE"); */ }
  ;

statement_return
  : RETURN expression { /* puts("statement_return -> RETURN expression"); */ }
  ;

bool_exp
  : bool_exp OR relation_and_exp { // || dst, bool_exp.result_id
      /* get bool_exp code */
      /* get relation_and_exp code */
      
      /* puts("bool_exp -> bool_exp OR relation_and_exp"); */
    }
  | relation_and_exp { /* puts("bool_exp -> relation_and_exp"); */ }
  ;

relation_and_exp
  : relation_and_exp AND relation_exp { 
      /* puts("relation_and_exp -> relation_and_exp AND relation_exp"); */
    }
  | relation_exp { /* puts("relation_and_exp -> relation_exp"); */ }
  ;

relation_exp
  : NOT relation_exp1 { /* puts("relation_exp -> NOT relation_exp1"); */ }
  | relation_exp1 { /* puts("relation_exp -> relation_exp1"); */ }
  ;

relation_exp1
  : expression comp expression { 
      /* puts("relation_exp1 -> expression comp expression"); */
    }
  | TRUE { /* puts("relation_exp1 -> TRUE"); */ }
  | FALSE { /* puts("relation_exp1 -> FALSE"); */ }
  | L_PAREN bool_exp R_PAREN { 
      /* puts("relation_exp1 -> L_PAREN bool_exp R_PAREN"); */
    }
  ;
 
comp
  : EQ { /* puts("comp -> EQ"); */ }
  | NEQ { /* puts("comp -> NEQ"); */ }
  | LT { /* puts("comp -> LT"); */ }
  | GT { /* puts("comp -> GT"); */ }
  | LTE { /* puts("comp -> LTE"); */ }
  | GTE { /* puts("comp -> GTE"); */ }
  ;

expression 
  : expression ADD multiplicative_exp  { 
      /* puts("expression -> expression ADD multiplicative_exp"); */
    }
  | expression SUB multiplicative_exp  { 
      /* puts("expression -> expression SUB multiplicative_exp"); */
    }
  | multiplicative_exp { /* puts("expression -> multiplicative_exp"); */ }
  ;

multiplicative_exp
  : multiplicative_exp MULT term  { 
      /* puts("multiplicative_exp -> multiplicative_exp MULT term"); */
    }
  | multiplicative_exp DIV term  { 
      /* puts("multiplicative_exp -> multiplicative_exp DIV term"); */
    }
  | multiplicative_exp MOD term  { 
      /* puts("multiplicative_exp -> multiplicative_exp MOD term"); */
    }
  | term
  ;

variables
  : variables COMMA variable { /* puts("variables -> variables COMMA variable"); */ }
  | variable { /* puts("variables -> variable"); */ }
  ; 

variable
  : identifier  { /* puts("variable -> identifier"); */ }
  | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET { 
      /* puts("variable -> identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET"); */
    }
  ;

term
  : SUB term1 { /* puts("term -> SUB term1"); */ }
  | term1 { /* puts("term -> term1"); */ }
  | identifier L_PAREN term2 R_PAREN  { /* puts("term -> identifier L_PAREN term2 R_PAREN"); */ }
  ;

term1
  : variable { /* puts("term1 -> variable"); */ }
  | number  { /* puts("term1 -> number"); */ }
  | L_PAREN expression R_PAREN { /* puts("term1 -> L_PAREN expression R_PAREN"); */ }
  ;

term2
  : expression COMMA term2 { /* puts("term2 -> term2 COMMA expression"); */ }
  | expression { /* puts("term2 -> expression"); */ }
  | { /* puts("term2 -> epsilon"); */ }
  ;

identifiers
  : identifiers COMMA identifier {
      $$->ids.push_back($3);

      /* puts("identifiers -> identifiers COMMA identifier"); */
    }
  | identifier { 
      $$ = new identifiers_t();
      $$->ids.push_back($1);

      /* puts("identifiers -> identifier"); */
    }
  ;

identifier
  : IDENT { 
      $$ = new identifier_t();
      $$->name = *yylval.op_val;
      /* printf("identifier -> IDENT %s\n", yylval.op_val->c_str()); */
    }
  ;

number
  : NUMBER {
      $$ = new number_t();
      $$->val = yylval.int_val;
      /* printf("number -> NUMBER %d\n", yylval.int_val); */
    }
  ;


%%

/*
int yyerror(string const s)
{
  extern int yylineno;  // defined and maintained in lex.c
  extern char *yytext;  // defined and maintained in lex.c
        
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(EXIT_FAILURE);
}
*/

// partitions error_msg on delimiter into error_msgs
// assuming sufficient space in error_msgs.
void partition(char * error_msg, 
               char const delimiter, 
               char * * error_msgs)
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

// returns a count of delimiter found in str
size_t count_delimiter(char const * str, 
                       char const delimiter)
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
