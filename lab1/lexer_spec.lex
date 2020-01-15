/* 
 * Sample Scanner1: 
 * Description: Replace the string "username" from standard input 
 *              with the user's login name (e.g. lgao)
 * Usage: (1) $ flex sample1.lex
 *        (2) $ gcc lex.yy.c -lfl
 *        (3) $ ./a.out
 *            stdin> username
 *	      stdin> Ctrl-D
 * Question: What is the purpose of '%{' and '%}'?
 *           What else could be included in this section?
 */

%{
/* need this for the call to getlogin() below */
#include <stdio.h>
%}

CHAR [a-zA-Z]
DIGIT [0-9]
IDENT {CHAR}+({CHAR}|{DIGIT})*
DIG_CHAR {DIGIT}+{CHAR}+
WHITESPACE [\ ]
NOT_IN_ALPH [^+-*/{CHAR}{DIGIT}\ ]

%%
function 			fprintf(stdout, "FUNCTION\n");
beginparams 			fprintf(stdout, "BEGIN_PARAMS\n");
endparams 			fprintf(stdout, "END_PARAMS\n");
beginlocals 			fprintf(stdout, "BEGIN_LOCALS\n");
endlocals 			fprintf(stdout, "END_LOCALS\n");
beginbody 			fprintf(stdout, "BEGIN_BODY\n");
endbody 			fprintf(stdout, "END_BODY\n");
integer 			fprintf(stdout, "INTEGER\n");
array 				fprintf(stdout, "ARRAY\n");
of 				fprintf(stdout, "OF\n");
if 				fprintf(stdout, "IF\n");
then 				fprintf(stdout, "THEN\n");
endif 				fprintf(stdout, "ENDIF\n");
else 				fprintf(stdout, "ELSE\n");
while 				fprintf(stdout, "WHILE\n");
do 				fprintf(stdout, "DO\n");
for 				fprintf(stdout, "FOR\n");
beginloop 			fprintf(stdout, "BEGINLOOP\n");
endloop 			fprintf(stdout, "ENDLOOP\n");
continue 			fprintf(stdout, "CONTINUE\n");
read 				fprintf(stdout, "READ\n");
write 				fprintf(stdout, "WRITE\n");
and 				fprintf(stdout, "AND\n");
or 				fprintf(stdout, "OR\n");
not 				fprintf(stdout, "NOT\n");
true 				fprintf(stdout, "TRUE\n");
false 				fprintf(stdout, "FALSE\n");
return 				fprintf(stdout, "RETURN\n");
"-" 				fprintf(stdout, "SUB\n");
"+" 				fprintf(stdout, "ADD\n");
"*" 				fprintf(stdout, "MULT\n");
"/" 				fprintf(stdout, "DIV\n");
"%" 				fprintf(stdout, "MOD\n");
"==" 				fprintf(stdout, "EQ\n");
"<>" 				fprintf(stdout, "NEQ\n");
"<"				fprintf(stdout, "LT\n");
">"				fprintf(stdout, "GT\n");
"<=" 				fprintf(stdout, "LTE\n");
">=" 				fprintf(stdout, "GTE\n");
";"			 	fprintf(stdout, "SEMICOLON\n");
":" 				fprintf(stdout, "COLON\n");
"," 				fprintf(stdout, "COMMA\n");
"(" 				fprintf(stdout, "L_PAREN\n");
")" 				fprintf(stdout, "R_PAREN\n");
"[" 				fprintf(stdout, "L_SQUARE_BRACKET\n");
"]" 				fprintf(stdout, "R_SQUARE_BRACKET\n");
":=" 				fprintf(stdout, "ASSIGN\n");
{IDENT}				fprintf(stdout, "IDENT %s\n", yytext);
{DIGIT}+			fprintf(stdout, "NUMBER %s\n", yytext);
{WHITESPACE}*
{DIG_CHAR}			fprintf(stderr, "ERROR: Identifier cannot start with a number.\n"); exit(EXIT_FAILURE);
.				fprintf(stderr, "ERROR\n"); exit(EXIT_FAILURE);
%%

main(int argc, char **argv)
{
  if (argc > 1)
    yyin = fopen(argv[1], "r");
  yylex();
}
