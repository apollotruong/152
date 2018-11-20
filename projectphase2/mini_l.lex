/* CS152 Fall 2018 */
/* Apollo Truong and Sidney Son */

%{
#include "y.tab.h"
int currLine = 1;
int currPosition = 1;
%}

letter		[a-zA-Z]
digit		[0-9]
number		{digit}+
identifier	[a-zA-Z]([a-zA-Z0-9_]*[a-zA-Z0-9])*

%%
"function"		{currPosition += yyleng; return FUNCTION;}
"beginparams"	{currPosition += yyleng; return BEGIN_PARAMS;}
"endparams"		{currPosition += yyleng; return END_PARAMS;}
"beginlocals"	{currPosition += yyleng; return BEGIN_LOCALS;}
"endlocals"		{currPosition += yyleng; return END_LOCALS;}
"beginbody"		{currPosition += yyleng; return BEGIN_BODY;}
"endbody"		{currPosition += yyleng; return END_BODY;}
"integer"		{currPosition += yyleng; return INTEGER;}
"array"			{currPosition += yyleng; return ARRAY;}
"of"			{currPosition += yyleng; return OF;}
"if"			{currPosition += yyleng; return IF;}
"then"			{currPosition += yyleng; return THEN;}
"endif"			{currPosition += yyleng; return ENDIF;}
"else"			{currPosition += yyleng; return ELSE;}
"elseif"		{currPosition += yyleng; return ELSEIF;}
"while"			{currPosition += yyleng; return WHILE;}
"do"			{currPosition += yyleng; return DO;}
"beginloop"		{currPosition += yyleng; return BEGINLOOP;}
"endloop"		{currPosition += yyleng; return ENDLOOP;}
"continue"		{currPosition += yyleng; return CONTINUE;}
"read"			{currPosition += yyleng; return READ;}
"write"			{currPosition += yyleng; return WRITE;}
"and"			{currPosition += yyleng; return AND;}
"or"			{currPosition += yyleng; return OR;}
"not"			{currPosition += yyleng; return NOT;}
"true"			{currPosition += yyleng; return TRUE;}
"false"			{currPosition += yyleng; return FALSE;}
"return"		{currPosition += yyleng; return RETURN;}
"program"		{currPosition += yyleng;} 
"endprogram"		{currPosition += yyleng; return END_PARAMS;}
"beginprogram"		{currPosition += yyleng; return BEGIN_PARAMS;}
"-"				{currPosition += yyleng; return SUB;}
"+"				{currPosition += yyleng; return ADD;}
"*"				{currPosition += yyleng; return MULT;}
"/"				{currPosition += yyleng; return DIV;}
"%"				{currPosition += yyleng; return MOD;}


"=="			{currPosition += yyleng; return EQ;}
"<>"			{currPosition += yyleng; return NEQ;}
"<"				{currPosition += yyleng; return LT;}
">"				{currPosition += yyleng; return GT;}
"<="			{currPosition += yyleng; return LTE;}
">="			{currPosition += yyleng; return GTE;}


{number}			{ yylval.val = atoi(yytext); return NUMBER;}
{identifier}		{ yylval.ident = yytext; return IDENT;}
[\t]*			;
[\n]			{currPosition = 1; currLine += 1;}
"##"[^\n]*		{currLine +=1; currPosition = 1;}
" "				{currPosition += yyleng;}

";"				{currPosition += yyleng; return SEMICOLON;}
":"				{currPosition += yyleng; return COLON;}
","				{currPosition += yyleng; return COMMA;}
"("				{currPosition += yyleng; return L_PAREN;}
")"				{currPosition += yyleng; return R_PAREN;}
"["				{currPosition += yyleng; return L_SQUARE_BRACKET;}
"]"				{currPosition += yyleng; return R_SQUARE_BRACKET;}
":="			{currPosition += yyleng; return ASSIGN;}


.			{printf("Error at line %d, column %d: did not recognize symbol \"%s\"\n", currLine, currPosition, yytext); exit(0);}
%%

