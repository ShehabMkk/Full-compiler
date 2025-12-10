%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SyntaxTree.h"
#include "1.tab.h"

void yyerror(char *);
extern int yylineno;
extern SymbolTable* symbolTable;
extern FILE* yyError;

/* Token output file */
FILE* tokenFile;
%}

%option yylineno
%option nounput
%option noinput

%%

[0-9]+      {
                yylval.ival = atoi(yytext);
                fprintf(tokenFile, "TOKEN: INTEGER = %d (line %d)\n", yylval.ival, yylineno);
                return INTEGER;
            }

"int"       {
                fprintf(tokenFile, "TOKEN: TYPE_INT (line %d)\n", yylineno);
                return TYPE_INT;
            }

"float"     {
                fprintf(tokenFile, "TOKEN: TYPE_FLOAT (line %d)\n", yylineno);
                return TYPE_FLOAT;
            }

"if"        {
                fprintf(tokenFile, "TOKEN: IF (line %d)\n", yylineno);
                return IF;
            }

"else"      {
                fprintf(tokenFile, "TOKEN: ELSE (line %d)\n", yylineno);
                return ELSE;
            }

"end"       {
                fprintf(tokenFile, "TOKEN: END (line %d)\n", yylineno);
                return END;
            }

"print"     {
                fprintf(tokenFile, "TOKEN: PRINT (line %d)\n", yylineno);
                return PRINT;
            }

"true"      {
                yylval.ival = 1;
                fprintf(tokenFile, "TOKEN: TRUE = 1 (line %d)\n", yylineno);
                return BOOL_TRUE;
            }

"false"     {
                yylval.ival = 0;
                fprintf(tokenFile, "TOKEN: FALSE = 0 (line %d)\n", yylineno);
                return BOOL_FALSE;
            }

[a-zA-Z_][a-zA-Z0-9_]*  {
                yylval.sval = strdup(yytext);
                fprintf(tokenFile, "TOKEN: IDENTIFIER = %s (line %d)\n", yytext, yylineno);
                return IDENTIFIER;
            }

"=="        {
                yylval.sval = strdup(yytext);
                fprintf(tokenFile, "TOKEN: OP = %s (line %d)\n", yytext, yylineno);
                return OP;
            }

"<="        {
                yylval.sval = strdup(yytext);
                fprintf(tokenFile, "TOKEN: OP = %s (line %d)\n", yytext, yylineno);
                return OP;
            }

">="        {
                yylval.sval = strdup(yytext);
                fprintf(tokenFile, "TOKEN: OP = %s (line %d)\n", yytext, yylineno);
                return OP;
            }

"<"         {
                yylval.sval = strdup(yytext);
                fprintf(tokenFile, "TOKEN: OP = %s (line %d)\n", yytext, yylineno);
                return OP;
            }

">"         {
                yylval.sval = strdup(yytext);
                fprintf(tokenFile, "TOKEN: OP = %s (line %d)\n", yytext, yylineno);
                return OP;
            }

"="         {
                fprintf(tokenFile, "TOKEN: ASSIGN (line %d)\n", yylineno);
                return ASSIGN;
            }

":"         {
                fprintf(tokenFile, "TOKEN: COLON (line %d)\n", yylineno);
                return COLON;
            }

";"         {
                fprintf(tokenFile, "TOKEN: SEMICOLON (line %d)\n", yylineno);
                return SEMICOLON;
            }

"("         {
                fprintf(tokenFile, "TOKEN: LPAREN (line %d)\n", yylineno);
                return LPAREN;
            }

")"         {
                fprintf(tokenFile, "TOKEN: RPAREN (line %d)\n", yylineno);
                return RPAREN;
            }

"{"         {
                fprintf(tokenFile, "TOKEN: LBRACE (line %d)\n", yylineno);
                return LBRACE;
            }

"}"         {
                fprintf(tokenFile, "TOKEN: RBRACE (line %d)\n", yylineno);
                return RBRACE;
            }

"+"         {
                fprintf(tokenFile, "TOKEN: PLUS (line %d)\n", yylineno);
                return PLUS;
            }

"-"         {
                fprintf(tokenFile, "TOKEN: MINUS (line %d)\n", yylineno);
                return MINUS;
            }

"*"         {
                fprintf(tokenFile, "TOKEN: MULT (line %d)\n", yylineno);
                return MULT;
            }

"/"         {
                fprintf(tokenFile, "TOKEN: DIV (line %d)\n", yylineno);
                return DIV;
            }

[\n]        {
                /* newline */
                return NEWLINE;
            }

[ \t\r]     {
                /* skip whitespace */
            }

.           {
                fprintf(yyError, "SCANNER ERROR: Invalid character '%s' at line %d\n", yytext, yylineno);
                fprintf(tokenFile, "ERROR: Invalid character '%s' (line %d)\n", yytext, yylineno);
            }

%%

int yywrap(void) {
    return 1;
}