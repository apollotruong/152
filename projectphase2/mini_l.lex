/* CS152 Fall 2018 */
/* Apollo Truong and Sydney Son */

%{
#include "y.tab.h"
int currLine;
int currPosition;
%}

letter		[a-zA-Z]
digit		[0-9]
number		{digit}+
identifier	{letter}({letter}|{digit}|[_]({letter}|{digit}))*

%%
"function"		{return FUNCTION;}
"beginparams"	{return BEGIN_PARAMS;}
"endparams"		{return END_PARAMS;}
"beginlocals"	{return BEGIN_LOCALS;}
"endlocals"		{return END_LOCALS;}
"beginbody"		{return BEGIN_BODY;}
"endbody"		{return END_BODY;}
"integer"		{return INTEGER;}
"array"			{return ARRAY;}
"of"			{return OF;}
"if"			{return IF;}
"then"			{return THEN;}
"endif"			{return ENDIF;}
"else"			{return ELSE;}
"elseif"		{return ELSEIF;}
"while"			{return WHILE;}
"do"			{return DO;}
"beginloop"		{return BEGINLOOP;}
"endloop"		{return ENDLOOP;}
"continue"		{return CONTINUE;}
"read"			{return READ;}
"write"			{return WRITE;}
"and"			{return AND;}
"or"			{return OR;}
"not"			{return NOT;}
"true"			{return TRUE;}
"false"			{return FALSE;}
"return"		{return RETURN;}
"program"		;
"endprogram"		{return END_PARAMS;}
"beginprogram"		{return BEGIN_PARAMS;}
"-"				{return SUB;}
"+"				{return ADD;}
"*"				{return MULT;}
"/"				{return DIV;}
"%"				{return MOD;}


"=="			{return EQ;}
"<>"			{return NEQ;}
"<"				{return LT;}
">"				{return GT;}
"<="			{return LTE;}
">="			{return GTE;}


{number}			{return NUMBER;}
{identifier}		{return IDENT;}
[\t]*			;
[\n]			;
"##"[^\n]*		;

";"				{return SEMICOLON;}
":"				{return COLON;}
","				{return COMMA;}
"("				{return L_PAREN;}
")"				{return R_PAREN;}
"["				{return L_SQUARE_BRACKET;}
"]"				{return R_SQUARE_BRACKET;}
":="			{return ASSIGN;}


.			;
%%

