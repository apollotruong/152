/* MINI-L language */

%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  // declarations of union members for lexical vals of tokens
  char* charIdent;
  int ival;
  

}

%error-verbose
%start prog_start
%token <ival> number
%token <dval> number

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS ENG_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE ELSIF WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITES AND OR NOT TRUE FALSE RETURN
%token END_PARAMS BEGIN_PARAMS

%left SUB ADD MULT DIV MOD
%left EQ NEQ LT GT LTE GTE


%% 

prog_start: functions {printf("prog_start -> functions");}
  ;

functions: {printf("functions -> epsilon");}
  | function {}
  



// FROM CALCULATOR LANGUAGE //
input:	
			| input line
			;

line:		exp EQUAL END         { printf("\t%f\n", $1);}
			;

exp:		NUMBER                { $$ = $1; }
			| exp PLUS exp        { $$ = $1 + $3; }
			| exp MINUS exp       { $$ = $1 - $3; }
			| exp MULT exp        { $$ = $1 * $3; }
			| exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
			| MINUS exp %prec UMINUS { $$ = -$2; }
			| L_PAREN exp R_PAREN { $$ = $2; }
			;
%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}

