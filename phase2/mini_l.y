%{
#include "heading.h"

void yyerror(char const * s);
int yylex(void);

extern int yylineno; 
extern char * yytext; 
%}

%union{
  int   int_val;
  string * op_val;
}

%define parse.error verbose
%define parse.lac full
%start program
%token <op_val> IDENT
%token <int_val> NUMBER 
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
  : functions { puts("program -> functions"); }
  ;

functions 
  : functions function { puts("functions -> functions function"); }
  | function { puts("functions -> function"); }
  ;

function
  : FUNCTION identifier SEMICOLON params locals body {
      puts("function -> FUNCTION identifier SEMICOLON params locals body"); 
    }
  ;

params
  : BEGIN_PARAMS declarations END_PARAMS { 
      puts("params -> BEGIN_PARAMS declarations END_PARAMS"); 
    }
  | BEGIN_PARAMS END_PARAMS { puts("params -> BEGIN_PARAMS END_PARAMS"); }
  ;

locals
  : BEGIN_LOCALS declarations END_LOCALS { 
      puts("locals -> BEGIN_LOCALS declarations END_LOCALS"); 
    }
  | BEGIN_LOCALS END_LOCALS { puts("locals -> BEGIN_LOCALS END_LOCALS"); }
  ;

body
  : BEGIN_BODY statements END_BODY { 
      puts("body -> BEGIN_BODY statements END_BODY"); 
    }

declarations
  : declarations declaration SEMICOLON { 
      puts("declarations -> declarations declaration SEMICOLON"); 
    }
  | declaration SEMICOLON { puts("declarations -> declaration SEMICOLON"); }
  ;

declaration
  : identifiers COLON INTEGER { 
      puts("declaration -> identifiers COLON INTEGER"); 
    }
  | identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER { 
      puts("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET "
           "number R_SQUARE_BRACKET OF INTEGER"); 
    }
  ;

statements
  : statements statement SEMICOLON { 
      puts("statements -> statements statement SEMICOLON"); 
    }
  | statement SEMICOLON {
      puts("statements -> statement SEMICOLON");
    }
  | statements error SEMICOLON {
      puts("statements -> statements error SEMICOLON");
    }
  ;

statement
  : statement_assign { puts("statement -> statement_assign"); }
  | statement_if { puts("statement -> statement_if"); }
  | statement_while { puts("statement -> statement_while"); }
  | statement_do_while { puts("statement -> statement_do_while"); }
  | statement_for { puts("statement -> statement_for"); }
  | statement_read { puts("statement -> statement_read"); }
  | statement_write { puts("statement -> statement_write"); }
  | statement_continue { puts("statement -> statement_continue"); }
  | statement_return { puts("statement -> statement_return"); }
  ;

statement_assign
  : variable ASSIGN expression { 
      puts("statement_assign -> variable ASSIGN expression"); 
    }
  ;

statement_if
  : IF bool_exp THEN statements ENDIF { 
      puts("statement_if -> IF bool_exp THEN statements ENDIF"); 
    }
  | IF bool_exp THEN statements ELSE statements ENDIF {
      puts("statement_if -> IF bool_exp THEN statements ELSE statements ENDIF");
    }
  ;

statement_while
  : WHILE bool_exp BEGINLOOP statements ENDLOOP { 
      puts("statement_while -> WHILE bool_exp BEGINLOOP statements ENDLOOP"); 
    }
  ;

statement_do_while
  : DO BEGINLOOP statements ENDLOOP WHILE bool_exp {
      puts("statement_do_while -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp");
    }
  ;

statement_for
  : FOR variable ASSIGN number SEMICOLON 
        bool_exp SEMICOLON 
        statement_assign 
        BEGINLOOP statements ENDLOOP {
      puts("statement_for -> FOR variable ASSIGN number SEMICOLON bool_exp "
           "SEMICOLON statement_assign BEGINLOOP statements ENDLOOP");
    }
  ;

statement_read
  : READ variables { puts("statement_read -> READ variables"); }
  ;

statement_write
  : WRITE variables { puts("statement_write -> WRITE variables"); }
  ;

statement_continue
  : CONTINUE { puts("statement_continue -> CONTINUE"); }
  ;

statement_return
  : RETURN expression { puts("statement_return -> RETURN expression"); }
  ;

bool_exp
  : bool_exp OR relation_and_exp { 
      puts("bool_exp -> bool_exp OR relation_and_exp"); 
    }
  | relation_and_exp { puts("bool_exp -> relation_and_exp"); }
  ;

relation_and_exp
  : relation_and_exp AND relation_exp { 
      puts("relation_and_exp -> relation_and_exp AND relation_exp"); 
    }
  | relation_exp { puts("relation_and_exp -> relation_exp"); }
  ;

relation_exp
  : NOT relation_exp1 { puts("relation_exp -> NOT relation_exp1"); }
  | relation_exp1 { puts("relation_exp -> relation_exp1"); }
  ;

relation_exp1
  : expression comp expression { 
      puts("relation_exp1 -> expression comp expression"); 
    }
  | TRUE { puts("relation_exp1 -> TRUE"); }
  | FALSE { puts("relation_exp1 -> FALSE"); }
  | L_PAREN bool_exp R_PAREN { 
      puts("relation_exp1 -> L_PAREN bool_exp R_PAREN"); 
    }
  ;
 
comp
  : EQ { puts("comp -> EQ"); }
  | NEQ { puts("comp -> NEQ"); }
  | LT { puts("comp -> LT"); }
  | GT { puts("comp -> GT"); }
  | LTE { puts("comp -> LTE"); }
  | GTE { puts("comp -> GTE"); }
  ;

expression 
  : expression ADD multiplicative_exp  { 
      puts("expression -> expression ADD multiplicative_exp"); 
    }
  | expression SUB multiplicative_exp  { 
      puts("expression -> expression SUB multiplicative_exp"); 
    }
  | multiplicative_exp { puts("expression -> multiplicative_exp"); }
  ;

multiplicative_exp
  : multiplicative_exp MULT term  { 
      puts("multiplicative_exp -> multiplicative_exp MULT term"); 
    }
  | multiplicative_exp DIV term  { 
      puts("multiplicative_exp -> multiplicative_exp DIV term"); 
    }
  | multiplicative_exp MOD term  { 
      puts("multiplicative_exp -> multiplicative_exp MOD term"); 
    }
  | term
  ;

variables
  : variables COMMA variable { puts("variables -> variables COMMA variable"); }
  | variable { puts("variables -> variable"); }
  ; 

variable
  : identifier  { puts("variable -> identifier"); }
  | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET { 
      puts("variable -> identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET"); 
    }
  ;

term
  : SUB term1 { puts("term -> SUB term1"); }
  | term1 { puts("term -> term1"); }
  | identifier L_PAREN term2 R_PAREN  { puts("term -> identifier L_PAREN term2 R_PAREN"); }
  ;

term1
  : variable { puts("term1 -> variable"); }
  | number  { puts("term1 -> number"); }
  | L_PAREN expression R_PAREN { puts("term1 -> L_PAREN expression R_PAREN"); }
  ;

term2
  : term2 COMMA expression { puts("term2 -> term2 COMMA expression"); }
  | expression { puts("term2 -> expression"); }
  ;

identifiers
  : identifiers COMMA identifier { puts("identifiers -> identifiers COMMA identifier"); }
  | identifier { puts("identifiers -> identifier"); }
  ;

identifier
  : IDENT { printf("identifier -> IDENT %s\n", yylval.op_val->c_str()); }
  ;

number
  : NUMBER { printf("number -> NUMBER %d\n", yylval.int_val); }
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
  char * error_msg = (char *)(malloc((S_SIZE + 1) * sizeof(char)));
  char * * error_msgs = (char * *)(malloc(COL_COUNT * sizeof(char * *)));

  strcpy(error_msg, s);
  partition(error_msg, ',', error_msgs);
  fprintf(stderr, "Syntax error at line %d: %s %s\n", yylineno, error_msgs[1], error_msgs[2]);

  free(error_msg);
  free(error_msgs);
  yyclearin;
}
