%{
#include "heading.h"
int pos = 0;
%}

CHAR [a-zA-Z]
DIGIT [0-9]
DIGITS {DIGIT}+
IDENT {CHAR}(({CHAR}|{DIGIT}|_)*({CHAR}|{DIGIT}))*
WHITESPACE [ \t]
COMMENT ##.*$
NEWLINE \n

%%
function          fprintf(stdout, "FUNCTION\n"); pos += strlen(yytext);
beginparams       fprintf(stdout, "BEGIN_PARAMS\n");pos += strlen(yytext);
endparams         fprintf(stdout, "END_PARAMS\n");pos += strlen(yytext);
beginlocals       fprintf(stdout, "BEGIN_LOCALS\n");pos += strlen(yytext);
endlocals         fprintf(stdout, "END_LOCALS\n");pos += strlen(yytext);
beginbody         fprintf(stdout, "BEGIN_BODY\n");pos += strlen(yytext);
endbody           fprintf(stdout, "END_BODY\n");pos += strlen(yytext);
integer           fprintf(stdout, "INTEGER\n");pos += strlen(yytext);
array             fprintf(stdout, "ARRAY\n");pos += strlen(yytext);
of                fprintf(stdout, "OF\n");pos += strlen(yytext);
if                fprintf(stdout, "IF\n");pos += strlen(yytext);
then              fprintf(stdout, "THEN\n");pos += strlen(yytext);
endif             fprintf(stdout, "ENDIF\n");pos += strlen(yytext);
else              fprintf(stdout, "ELSE\n");pos += strlen(yytext);
while             fprintf(stdout, "WHILE\n");pos += strlen(yytext);
do                fprintf(stdout, "DO\n");pos += strlen(yytext);
for               fprintf(stdout, "FOR\n");pos += strlen(yytext);
beginloop         fprintf(stdout, "BEGINLOOP\n");pos += strlen(yytext);
endloop           fprintf(stdout, "ENDLOOP\n");pos += strlen(yytext);
continue          fprintf(stdout, "CONTINUE\n");pos += strlen(yytext);
read              fprintf(stdout, "READ\n");pos += strlen(yytext);
write             fprintf(stdout, "WRITE\n");pos += strlen(yytext);
and               fprintf(stdout, "AND\n");pos += strlen(yytext);
or                fprintf(stdout, "OR\n");pos += strlen(yytext);
not               fprintf(stdout, "NOT\n");pos += strlen(yytext);
true              fprintf(stdout, "TRUE\n");pos += strlen(yytext);
false             fprintf(stdout, "FALSE\n");pos += strlen(yytext);
return            fprintf(stdout, "RETURN\n");pos += strlen(yytext);
"-"               fprintf(stdout, "SUB\n");pos += strlen(yytext);
"+"               fprintf(stdout, "ADD\n");pos += strlen(yytext);
"*"               fprintf(stdout, "MULT\n");pos += strlen(yytext);
"/"               fprintf(stdout, "DIV\n");pos += strlen(yytext);
"%"               fprintf(stdout, "MOD\n");pos += strlen(yytext);
"=="              fprintf(stdout, "EQ\n");pos += strlen(yytext);
"<>"              fprintf(stdout, "NEQ\n");pos += strlen(yytext);
"<"               fprintf(stdout, "LT\n");pos += strlen(yytext);
">"               fprintf(stdout, "GT\n");pos += strlen(yytext);
"<="              fprintf(stdout, "LTE\n");pos += strlen(yytext);
">="              fprintf(stdout, "GTE\n");pos += strlen(yytext);
";"               fprintf(stdout, "SEMICOLON\n");pos += strlen(yytext);
":"               fprintf(stdout, "COLON\n");pos += strlen(yytext);
","               fprintf(stdout, "COMMA\n");pos += strlen(yytext);
"("               fprintf(stdout, "L_PAREN\n");pos += strlen(yytext);
")"               fprintf(stdout, "R_PAREN\n");pos += strlen(yytext);
"["               fprintf(stdout, "L_SQUARE_BRACKET\n");pos += strlen(yytext);
"]"               fprintf(stdout, "R_SQUARE_BRACKET\n");pos += strlen(yytext);
":="              fprintf(stdout, "ASSIGN\n");pos += strlen(yytext);
{IDENT}           fprintf(stdout, "IDENT %s\n", yytext);pos += strlen(yytext);
{DIGITS}          fprintf(stdout, "NUMBER %s\n", yytext);pos += strlen(yytext);
{COMMENT}         ;
{WHITESPACE}*     pos += strlen(yytext);
{NEWLINE}         yylineno++; pos = 0;
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
                          pos + 1,
                          yytext);
                  exit(EXIT_FAILURE);
                }
%%
/*
int
main(int argc, char **argv)
{
  if (argc > 1)
    yyin = fopen(argv[1], "r");
  yylex();
  return 0;
}
*/
