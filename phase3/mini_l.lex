%{
#include <cstdio>
#include <cstring>
#include <string>
#include "tok.h"
int pos = 1;
%}

CHAR [a-zA-Z]
DIGIT [0-9]
DIGITS {DIGIT}+
IDENT {CHAR}(({CHAR}|{DIGIT}|_)*({CHAR}|{DIGIT}))*
WHITESPACE [ \t\r]
COMMENT ##.*$
NEWLINE \n

%%
function          { pos += strlen(yytext); return FUNCTION; }
beginparams       { pos += strlen(yytext); return BEGIN_PARAMS; }
endparams         { pos += strlen(yytext); return END_PARAMS; }
beginlocals       { pos += strlen(yytext); return BEGIN_LOCALS; }
endlocals         { pos += strlen(yytext); return END_LOCALS; }
beginbody         { pos += strlen(yytext); return BEGIN_BODY; }
endbody           { pos += strlen(yytext); return END_BODY; }
integer           { pos += strlen(yytext); return INTEGER; }
array             { pos += strlen(yytext); return ARRAY; }
of                { pos += strlen(yytext); return OF; }
if                { pos += strlen(yytext); return IF; }
then              { pos += strlen(yytext); return THEN; }
endif             { pos += strlen(yytext); return ENDIF; }
else              { pos += strlen(yytext); return ELSE; }
while             { pos += strlen(yytext); return WHILE; }
do                { pos += strlen(yytext); return DO; }
for               { pos += strlen(yytext); return FOR; }
beginloop         { pos += strlen(yytext); return BEGINLOOP; }
endloop           { pos += strlen(yytext); return ENDLOOP; }
continue          { pos += strlen(yytext); return CONTINUE; }
read              { pos += strlen(yytext); return READ; }
write             { pos += strlen(yytext); return WRITE; }
and               { pos += strlen(yytext); return AND; }
or                { pos += strlen(yytext); return OR; }
not               { pos += strlen(yytext); return NOT; }
true              { pos += strlen(yytext); return TRUE; }
false             { pos += strlen(yytext); return FALSE; }
return            { pos += strlen(yytext); return RETURN; }
"-"               { pos += strlen(yytext); return SUB; }
"+"               { pos += strlen(yytext); return ADD; }
"*"               { pos += strlen(yytext); return MULT; }
"/"               { pos += strlen(yytext); return DIV; }
"%"               { pos += strlen(yytext); return MOD; }
"=="              { pos += strlen(yytext); return EQ; }
"<>"              { pos += strlen(yytext); return NEQ; }
"<"               { pos += strlen(yytext); return LT; }
">"               { pos += strlen(yytext); return GT; }
"<="              { pos += strlen(yytext); return LTE; }
">="              { pos += strlen(yytext); return GTE; }
";"               { pos += strlen(yytext); return SEMICOLON; }
":"               { pos += strlen(yytext); return COLON; }
","               { pos += strlen(yytext); return COMMA; }
"("               { pos += strlen(yytext); return L_PAREN; }
")"               { pos += strlen(yytext); return R_PAREN; }
"["               { pos += strlen(yytext); return L_SQUARE_BRACKET; }
"]"               { pos += strlen(yytext); return R_SQUARE_BRACKET; }
":="              { pos += strlen(yytext); return ASSIGN; }
{IDENT}           { 
                    pos += strlen(yytext); 
                    yylval.op_val = new std::string(yytext); 
                    return IDENT;
                  }
{DIGITS}          { 
                    pos += strlen(yytext); 
                    yylval.int_val = std::atoi(yytext); 
                    return NUMBER;
                  }
{COMMENT}         { pos += strlen(yytext); }
{WHITESPACE}*     { pos += strlen(yytext); }
{NEWLINE}         { yylineno++; pos = 1; }
({DIGIT}|_)+({IDENT})?(_)* {
                  fprintf(stderr, 
                          "Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", 
                          yylineno, 
                          pos, 
                          yytext);
                  exit(EXIT_FAILURE);
                }

{IDENT}(_)+     {
                  fprintf(stderr, 
                          "Error at line %d , column %d: identifier \"%s\" cannot end with an underscore\n", 
                          yylineno,
                          pos,
                          yytext);
                  exit(EXIT_FAILURE);
                }
.               {
                  fprintf(stderr,
                          "Error at line %d, column %d: unrecognized symbol \"%s\"\n",
			  yylineno,
                          pos,
                          yytext);
                  exit(EXIT_FAILURE);
                }
%%
