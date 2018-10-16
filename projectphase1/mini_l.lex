/* CS152 Fall 2018 */
/* Apollo Truong and Sydney Son */

%{
int currLine = 1;
%}

letter		[a-zA-Z]
digit		[0-9]
number		{digit}+
identifier	{letter}({letter}|{digit}|[_]({letter}|{digit}))*
ERROR1		[0-9_]+[a-zA-Z0-9]+

%%
"function"		{printf("FUNCTION \n" , currLine++);}
"beginparams"	{printf("BEGIN_PARAMS \n" , currLine++);}
"endparams"		{printf("END_PARAMS \n" , currLine++);}
"beginlocals"	{printf("BEGIN_LOCALS \n" , currLine++);}
"endlocals"		{printf("END_LOCALS \n" , currLine++);}
"beginbody"		{printf("BEGIN_BODY \n" , currLine++);}
"endbody"		{printf("END_BODY \n" , currLine++);}
"integer"		{printf("INTEGER \n" , currLine++);}
"array"			{printf("ARRAY \n" , currLine++);}
"of"			{printf("OF \n" , currLine++);}
"if"			{printf("IF \n" , currLine++);}
"then"			{printf("THEN \n" , currLine++);}
"endif"			{printf("ENDIF \n" , currLine++);}
"else"			{printf("ELSE \n" , currLine++);}
"elseif"		{printf("ELSIF \n" , currLine++);}
"while"			{printf("WHILE \n" , currLine++);}
"do"			{printf("DO \n" , currLine++);}
"beginloop"		{printf("BEGINLOOP \n" , currLine++);}
"endloop"		{printf("ENDLOOP \n" , currLine++);}
"continue"		{printf("CONTINUE \n" , currLine++);}
"read"			{printf("READ \n" , currLine++);}
"write"			{printf("WRITE \n" , currLine++);}
"and"			{printf("AND \n" , currLine++);}
"or"			{printf("OR \n" , currLine++);}
"not"			{printf("NOT \n" , currLine++);}
"true"			{printf("TRUE \n" , currLine++);}
"false"			{printf("FALSE \n" , currLine++);}
"return"		{printf("RETURN \n" , currLine++);}
"program"		;
"endprogram"		{printf("END_PARAMS \n" , currLine++);}
"beginprogram"		{printf("BEGIN_PARAMS \n" , currLine++);}
"-"				{printf("SUB \n" , currLine++);}
"+"				{printf("ADD \n" , currLine++);}
"*"				{printf("MULT \n" , currLine++);}
"/"				{printf("DIV \n" , currLine++);}
"%"				{printf("MOD \n" , currLine++);}


"=="			{printf("EQ \n" , currLine++);}
"<>"			{printf("NEQ \n" , currLine++);}
"<"				{printf("LT \n" , currLine++);}
">"				{printf("GT \n" , currLine++);}
"<="			{printf("LTE \n" , currLine++);}
">="			{printf("GTE \n" , currLine++);}


{number}			{printf("NUMBER %s\n", yytext , currLine++);}
{identifier}		{printf("IDENT %s\n", yytext , currLine++);}
[\t]*			;
[\n]			;
"##"[^\n]*		;

";"				{printf("SEMICOLON \n" , currLine++);}
":"				{printf("COLON \n" , currLine++);}
","				{printf("COMMA \n" , currLine++);}
"("				{printf("L_PAREN \n" , currLine++);}
")"				{printf("R_PAREN \n" , currLine++);}
"["				{printf("L_SQUARE_BRACKET \n" , currLine++);}
"]"				{printf("R_SQUARE_BRACKET \n" , currLine++);}
":="			{printf("ASSIGN \n" , currLine++);}

{ERROR}			{printf("Error at line %d: input must start with a letter\n",currLine , currLine++);}

.			{printf("ERROR \n";}
%%


int yywrap(){}
int main(int argc, char ** argv){
	yylex();
	return 0;

}
