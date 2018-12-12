/* CS152 Project Phase 2 */
/* Apollo Truong, Sidney Son */

/* A parser for the mini-L language using Bison */


/* C Declarations */
%{
#include <stdio.h>
#include <stdlib.h>	
#include <vector>
#include <string>
#include <sstream>
#include "parser.h"
#include <iostream>
using namespace std;
void yyerror(const char *msg);
extern int currLine;
extern int currPosition;
extern FILE * yyin;
extern int yylex();

ostringstream code;

struct semval {
   string code;
   string place;     
}

%}
/* Bison Declarations */
%union {
   char* ident; // needed for name of identifier
   int val;     // needed for value of number
   struct semval *sem;
}


// Start Symbol
%start prog_start
// Reserved Words
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE ELSEIF WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
// Arithmetic Operators
%left SUB ADD MULT DIV MOD
// Comparison Operators
%left EQ NEQ LT GT LTE GTE
// Other Special Symbols
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
// Identifiers and Numbers
%token <val> NUMBER
%token <ident> IDENT

/* Grammar Rules */
%%
prog_start:    functions 
               ;

functions:      
               |   function functions 
               ;

function:      FUNCTION IDENT { code << "function " << $2 << endl; }
               SEMICOLON BEGIN_PARAMS declarations END_PARAMS 
               BEGIN_LOCALS declarations END_LOCALS 
               BEGIN_BODY statements END_BODY 
               ;

declarations:  
               |   declarations declaration SEMICOLON
	       ;

declaration:   IDENT COLON INTEGER {
	          code << ". " << *$1 << endl;   
	       }
	       |   IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
	          code << ".[] " << *$1 << ", " << $5 << endl;
	       }
               |   IDENT COMMA declaration {
	          code << ". " << *$1 << endl;
	       }
               ;

statements:    
	       |   statement SEMICOLON statments
	       ;

statement:     IDENT ASSIGN expression {
	     	  code << "= " << *$1 << ", " << $3->place << "\n";
	  	  $$ = new semVal; 	       
	       }


expression:

%%
/* Additional C Code */
int main(int argc, char **argv) {
   //yylex();
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   cout << code.str();
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPosition, msg);
}
