%{
#include "heading.h"
#include "types.h"

#define DEBUG

void yyerror(char const * s);
int yylex(void);

extern int yylineno; 
extern char * yytext; 

identifier_t *
create_identifier(void)
{
  static int num = 0;

  ostringstream oss;
  oss << tmp_id_name << num++;

  identifier_t * id = new identifier_t();
  id->name = oss.str();

  return id;
}
%}

%union{
  int int_val;

  string * op_val;

  code_t * code_semval;
  
  identifier_t * id_semval;
  identifiers_t * ids_semval;

  number_t * num_semval;

  variable_t * var_semval;
  variables_t * vars_semval;

  term_t * term_semval;

  expression_t * exp_semval;
}

%define parse.error verbose
%define parse.lac full

%start program

%token <op_val> IDENT
%token <int_val> NUMBER 

%nterm <code_semval> program
%nterm <code_semval> functions function params locals body
%nterm <code_semval> declarations declaration
%nterm <code_semval> statements statement
%nterm <code_semval> statement_assign

%nterm <id_semval> identifier 
%nterm <ids_semval> identifiers
%nterm <num_semval> number
%nterm <var_semval> variable
%nterm <vars_semval> variables
%nterm <term_semval> expression multiplicative_exp term term1

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
  : {}
  | functions {
      $$->code = $1->code;
      printf("%s", $$->code.c_str());
    }
  ;

functions
  : functions function {
      ostringstream oss;
      oss << $1->code;
      oss << $2->code;
      $$ = new code_t();
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- functions -> functions function\n%s\n", $$->code.c_str());
#endif
    }
  | function {
      $$ = new code_t();
      $$->code = $1->code;
#ifdef DEBUG
      printf("-- functions -> function\n%s\n", $$->code.c_str());
#endif
    }
  ;

function
  : function1 identifier semicolon params locals body {
      ostringstream oss;
      oss << "func " << $2->name << endl;
      oss << $4->code;
      oss << $5->code;
      oss << $6->code;
      oss << "endfunc" << endl;
      oss << endl;
      $$ = new code_t();
      $$->code = oss.str();
    }
  | error {}
  ;

function1
  : FUNCTION {}
  | error {}
  ;

semicolon
  : SEMICOLON {}
  | error {}
  ;

params
  : begin_params declarations end_params {
      /**
       * May need to change the type of declarations
       * to a struct which holds an array of type 
       * declaration.
       * ---
       * example a param declarations:
       * . param0
       * = param0, $0
       * . param1
       * = param1, $1
       */
      $$ = $2;
#ifdef DEBUG
      printf("-- params -> beginparams declarations endparams\n%s\n", $$->code.c_str());
#endif
    }
  | begin_params end_params {
      $$->code = ""; // Fixes issue where params->code = function id
    }
  ;

begin_params
  : BEGIN_PARAMS {}
  | error {}
  ;

end_params
  : END_PARAMS {}
  | error {}
  ;

locals
  : begin_locals declarations end_locals {
      $$ = $2;
#ifdef DEBUG
      printf("-- locals -> beginlocals declarations endlocals\n%s\n", $$->code.c_str());
#endif
    }
  | begin_locals end_locals {
    }
  ;

begin_locals
  : BEGIN_LOCALS {}
  | error {}
  ;

end_locals
  : END_LOCALS {}
  | error {}
  ;

body
  : begin_body statements end_body {
      $$ = $2;
#ifdef DEBUG
      printf("-- body\n%s\n", $$->code.c_str());
#endif
    }
  ;

begin_body
  : BEGIN_BODY {}
  | error {}
  ;

end_body
  : END_BODY {}
  | error {}
  ;

declarations
  : declarations declaration SEMICOLON { 
      /*
      $$ = $1;
      ostringstream oss;
      oss << $$->code;
      oss << $2->code;
      $$->code = oss.str();
      */
      
#ifdef DEBUG
      printf("-- declarations -> declarations declaration ;\n%s\n", $$->code.c_str());
#endif
    }
  | declaration SEMICOLON { 
      $$ = $1;
      //$$ = new declarations_t();
      //$$->decls.push_back($1);
#ifdef DEBUG
      printf("-- declarations -> declaration ;\n%s\n", $$->code.c_str());
#endif
    }
  ;

declaration
  : identifiers COLON INTEGER { 
      $$ = new code_t();
      //$$ = new declaration_t();

      ostringstream oss;
      for (int i = 0; i < $1->ids.size(); i++) {
        // need to check if identifier already exists
        oss << ". " << $1->ids[i]->name.c_str() << endl;
      }
      //$$->ids = $1->ids;
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- declaration -> identifiers : integer\n%s\n", $$->code.c_str());
#endif
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      $$ = new code_t();

      ostringstream oss;
      for (int i = 0; i < $1->ids.size(); i++) {
        // need to check if identifier already exists
        oss << ".[] " << $1->ids[i]->name.c_str() << ", " << $5->val << endl;
      }
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- declaration -> identifiers : array [ number ] of integer\n%s\n", $$->code.c_str());
#endif
    }
  | error {}
  ;

statements
  : statements statement SEMICOLON { 
      $$ = $1;
      ostringstream oss;
      oss << $$->code;
      oss << $2->code;
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- statements -> statements statement ;\n%s\n", $$->code.c_str());
#endif
    }
  | statement SEMICOLON {
      $$ = new code_t();
      $$->code = $1->code;
#ifdef DEBUG
      printf("-- statements -> statement ;\n%s\n", $1->code.c_str());
#endif
    }
  ;

statement
  : statement_assign {
      $$ = $1;
#ifdef DEBUG
      printf("-- statement -> statement_assign\n%s\n", $$->code.c_str());
#endif
    }
  | statement_if       {
    }
  | statement_while    {
    }
  | statement_do_while {
    }
  | statement_for      {
    }
  | statement_read     {
    }
  | statement_write    {
    }
  | statement_continue {
    }
  | statement_return   {
    }
  | error              {}
  ;

statement_assign
  : variable ASSIGN expression { 
      ostringstream oss;
      oss << $1->code;
      oss << $3->code;
      if ($1->is_array) {
        oss << "[]= " << $1->id->name << ", " << $1->idx << ", " << $3->id->name << endl;
      } else {
        oss << "= " << $1->id->name << ", " << $3->id->name << endl;
      }
      $$ = new code_t();
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- statement_assign\n%s\n", $$->code.c_str());
#endif
    }
  ;

statement_if
  : IF bool_exp THEN statements ENDIF { 
      /* get bool_exp code */
      /* get statements code */
      /* set up conditional branching code */
    }
  | IF bool_exp THEN statements ELSE statements ENDIF {
      /* get bool_exp code */
      /* get then statements code */
      /* get else statements code */
      /* set up 2 conditional branches code */
    }
  ;

statement_while
  : WHILE bool_exp BEGINLOOP statements ENDLOOP { 
      /* get bool_exp code */
      /* set labels */
      /* get statements code */
      /* set branching */
    }
  ;

statement_do_while
  : DO BEGINLOOP statements ENDLOOP WHILE bool_exp {
      /* set labels */
      /* get statements code */
      /* get bool_exp code */
      /* set branching */
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
    }
  ;

statement_read
  : READ variables {}
  ;

statement_write
  : WRITE variables {}
  ;

statement_continue
  : CONTINUE {}
  ;

statement_return
  : RETURN expression {}
  ;

bool_exp
  : bool_exp OR relation_and_exp { // || dst, bool_exp.id, relation_and_exp.id
      /* get bool_exp code */
      /* get relation_and_exp code */
      
    }
  | relation_and_exp {}
  ;

relation_and_exp
  : relation_and_exp AND relation_exp {
    }
  | relation_exp {}
  ;

relation_exp
  : NOT relation_exp1 {}
  | relation_exp1 {}
  ;

relation_exp1
  : expression comp expression {
    }
  | TRUE {}
  | FALSE {}
  | L_PAREN bool_exp R_PAREN {
    }
  ;
 
comp
  : EQ {}
  | NEQ {}
  | LT {}
  | GT {}
  | LTE {}
  | GTE {}
  ;

expression 
  : expression ADD multiplicative_exp  { 
      $$ = new term_t();
      $$->id = create_identifier();

      ostringstream oss;
      oss << $1->code;
      oss << $3->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "+ " << $$->id->name << ", " << $1->id->name << ", " << $3->id->name << endl; // + dst, src1, src2
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- expression -> expression + multiplicative_exp\n%s\n", $$->code.c_str());
#endif
    }
  | expression SUB multiplicative_exp  {
      $$ = new term_t();
      $$->id = create_identifier();

      ostringstream oss;
      oss << $1->code;
      oss << $3->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "- " << $$->id->name << ", " << $1->id->name << ", " << $3->id->name << endl; // - dst, src1, src2
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- expression -> expression - multiplicative_exp\n%s\n", $$->code.c_str());
#endif
    }
  | multiplicative_exp {
      $$ = $1;
#ifdef DEBUG
      printf("-- expression -> multiplicative_exp\n%s\n", $$->code.c_str());
#endif
    }
  ;

multiplicative_exp
  : multiplicative_exp MULT term  {
      $$ = new term_t();
      $$->id = create_identifier();

      ostringstream oss;
      oss << $1->code;
      oss << $3->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "* " << $$->id->name << ", " << $1->id->name << ", " << $3->id->name << endl; // * dst, src1, src2
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- multiplicative_exp -> multiplicative_exp * term\n%s\n", $$->code.c_str());
#endif
    }
  | multiplicative_exp DIV term  {
      $$ = new term_t();
      $$->id = create_identifier();

      ostringstream oss;
      oss << $1->code;
      oss << $3->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "/ " << $$->id->name << ", " << $1->id->name << ", " << $3->id->name << endl; // / dst, src1, src2
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- multiplicative_exp -> multiplicative_exp / term\n%s\n", $$->code.c_str());
#endif

    }
  | multiplicative_exp MOD term  {
      $$ = new term_t();
      $$->id = create_identifier();

      ostringstream oss;
      oss << $1->code;
      oss << $3->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "% " << $$->id->name << ", " << $1->id->name << ", " << $3->id->name << endl; // % dst, src1, src2
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- multiplicative_exp -> multiplicative_exp %% term\n%s\n", $$->code.c_str());
#endif
    }
  | term {
      $$ = $1;
#ifdef DEBUG
      printf("-- multiplicative_exp -> term\n%s\n", $$->code.c_str());
#endif
    }
  ;

variables
  : variables COMMA variable {
      // Only used for reading/writing from/to stdin/stdout
      $$->vars.push_back($3); // TODO: May need to allocate mem for $$ (could cause probs.)
    }
  | variable {
      // Only used for reading/writing from/to stdin/stdout
      $$ = new variables_t();
      $$->vars.push_back($1);
    }
  ; 

variable
  : identifier  {
      $$ = new variable_t();
      $$->id = $1;
      $$->is_array = false;
      $$->code = "";
#ifdef DEBUG
      printf("-- variable -> identifier\n%s\n\n", $$->id->name.c_str());
#endif
    }
  | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
      // variable_t may need to contain a code field
      // since term_t (used by expression) does
      $$ = new variable_t();
      $$->id = $1;
      $$->idx = $3->id->name;
      $$->is_array = true;
      $$->code = $3->code;
      /*
      $$ = new variable_t();
      $$->id = create_identifier();
      ostringstream oss;
      oss << $3->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "=[] " << $$->id->name << ", " << $1->name << ", " << $3->id->name << endl; // =[] dst, src, index
      $$->code = oss.str();
      */
#ifdef DEBUG
      printf("-- variable -> array\n%s[%s]\n\n",$$->id->name.c_str(), $$->idx.c_str());
#endif
    }
  ;

term
  : SUB term1 { 
      $$ = new term_t();
      $$->id = create_identifier();

      ostringstream oss;
      oss << $2->code;
      oss << ". " << $$->id->name << endl; // Declare new identifier
      oss << "* " << $$->id->name << ", " << $2->id->name << ", " << "-1" << endl; // * dst, src1, src2
      $$->code = oss.str();
#ifdef DEBUG
      printf("-- term -> - term1\n%s\n\n", $2->id->name.c_str());
#endif
    }
  | term1 {
      $$ = $1;
#ifdef DEBUG
      printf("-- term -> term1\n%s\n\n", $1->id->name.c_str());
#endif
    }
  | identifier L_PAREN term2 R_PAREN  {
      // function call
#ifdef DEBUG
      printf("-- term -> identifier ( term2 )\n");
#endif
    }
  ;

term1
  : variable {
      $$ = new term_t();
      
      ostringstream oss;

      // If variable is array, assign value 
      // to tmp variable
      if ($1->is_array) {
        $$->id = create_identifier();
        oss << $1->code;
        oss << ". " << $$->id->name << endl; // Declare new id
        oss << "=[] "  << $$->id->name << ", " << $1->id->name << ", " << $1->idx << endl; // =[] dst, src, index
      }
      else {
        $$->id = $1->id;
        oss << $1->code;
      }
      $$->code = oss.str();

#ifdef DEBUG
      printf("-- term1 -> variable\n%s\n", $$->code.c_str());
#endif
    }
  | number  {
      $$ = new term_t();

      $$->id = new identifier_t();
      ostringstream oss;
      oss << $1->val;
      $$->id->name = oss.str();
      $$->code = "";
#ifdef DEBUG
      printf("-- term1 -> number\n");
#endif
    }
  | L_PAREN expression R_PAREN {
      $$ = $2;
#ifdef DEBUG
      printf("-- term1 -> ( expression )\n%s\n", $$->code.c_str());
#endif
    }
  ;

term2
  : expression COMMA term2 {
      // Only used in params of calling function
    }
  | expression {
      // Only used in params of calling function
    }
  | {}
  ;

identifiers
  : identifiers COMMA identifier {
      $$->ids.push_back($3);
    }
  | identifier { 
      $$ = new identifiers_t();
      $$->ids.push_back($1);
    }
  ;

identifier
  : IDENT { 
      $$ = new identifier_t();
      $$->name = *yylval.op_val;
    }
  ;

number
  : NUMBER {
      $$ = new number_t();
      $$->val = yylval.int_val;
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
