/* CS152 Fall 2018 */
/* Apollo Truong and Sydney Son */

%{

%}

letter		[a-zA-Z]
digit		[0-9]
number		{digit}+
identifier	{letter}({letter}|{digit}|[_]({letter}|{digit}))*

%%
"function"		{printf("FUNCTION \n");}
"beginparams"	{printf("BEGIN_PARAMS \n");}
"endparams"		{printf("END_PARAMS \n");}
"beginlocals"	{printf("BEGIN_LOCALS \n");}
"endlocals"		{printf("END_LOCALS \n");}
"beginbody"		{printf("BEGIN_BODY \n");}
"endbody"		{printf("END_BODY \n");}
"integer"		{printf("INTEGER \n");}
"array"			{printf("ARRAY \n");}
"of"			{printf("OF \n");}
"if"			{printf("IF \n");}
"then"			{printf("THEN \n");}
"endif"			{printf("ENDIF \n");}
"else"			{printf("ELSE \n");}
"elseif"		{printf("ELSIF \n");}
"while"			{printf("WHILE \n");}
"do"			{printf("DO \n");}
"beginloop"		{printf("BEGINLOOP \n");}
"endloop"		{printf("ENDLOOP \n");}
"continue"		{printf("CONTINUE \n");}
"read"			{printf("READ \n");}
"write"			{printf("WRITE \n");}
"and"			{printf("AND \n");}
"or"			{printf("OR \n");}
"not"			{printf("NOT \n");}
"true"			{printf("TRUE \n");}
"false"			{printf("FALSE \n");}
"return"		{printf("RETURN \n");}
"program"		;
"endprogram"		{printf("END_PARAMS \n");}
"beginprogram"		{printf("BEGIN_PARAMS \n");}
"-"				{printf("SUB \n");}
"+"				{printf("ADD \n");}
"*"				{printf("MULT \n");}
"/"				{printf("DIV \n");}
"%"				{printf("MOD \n");}


"=="			{printf("EQ \n");}
"<>"			{printf("NEQ \n");}
"<"				{printf("LT \n");}
">"				{printf("GT \n");}
"<="			{printf("LTE \n");}
">="			{printf("GTE \n");}


{number}			{printf("NUMBER %s\n", yytext);}
{identifier}		{printf("IDENT %s\n", yytext);}
[\t]*			;
[\n]			;
"##"[^\n]*		;

";"				{printf("SEMICOLON \n");}
":"				{printf("COLON \n");}
","				{printf("COMMA \n");}
"("				{printf("L_PAREN \n");}
")"				{printf("R_PAREN \n");}
"["				{printf("L_SQUARE_BRACKET \n");}
"]"				{printf("R_SQUARE_BRACKET \n");}
":="			{printf("ASSIGN \n");}

.			;
%%


int yywrap(){}
int main(int argc, char ** argv){
	yylex();
	return 0;

}
