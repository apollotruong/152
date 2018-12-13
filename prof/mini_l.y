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
string newLabel();
string newTemp();

ostringstream code;
int labelCount = 0;
int tempCount = 0;

struct semval {
   string code;
   string place;     
};

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

%type <sem> statement
%type <sem> statements
%type <sem> readstatement
%type <sem> writestatement
%type <sem> boolexp
%type <sem> expression
%type <sem> expressions

/* Grammar Rules */
%%
prog_start:    functions 
               ;

functions:      
               |   functions function
               ;

function:      FUNCTION IDENT { code << "function " << *$2 << "\n"; }
               SEMICOLON BEGIN_PARAMS declarations END_PARAMS 
               BEGIN_LOCALS declarations END_LOCALS 
               BEGIN_BODY statements END_BODY 
               { code << "endfunc" << "\n"; }
               ;

declarations:  
               |   declarations declaration SEMICOLON
	            ;

declaration:   IDENT COLON INTEGER {
	                  code << ". " << *$1 << "\n";   
	            }
	            |  IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
	                  code << ".[] " << *$1 << ", " << $5 << "\n";
	            }
               |  IDENT COMMA declaration {
	                  code << ". " << *$1 << "\n";
	            }
               ;

statements:    {
                     $$ = new semval;
                     $$->code = "";
               }
	            |   statement SEMICOLON statements {
                     code << $1->code << $3->code;
               }
	            ;

statement:     IDENT ASSIGN expression {
                     stringstream ss;
                     ss << "= " << *$1 << ", " << $3->place << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
	            }
               |  IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET ASSIGN expression {
                     stringstream ss;
                     ss << "= " << *$1 << ", " << $3->place << ", " << $6->place << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               |  readstatement
               |  writestatement
               |  RETURN expression {
                     stringstream ss;
                     ss << "ret " << $2->place << "\n"
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               |  IF boolexp THEN statements ENDIF {
                     stringstream ss;
                     string l = newLabel();
                     string m = newLabel();
                     ss << $2->code;
                     ss << "?:= " << $2->place << ", " << l << "\n";
                     ss << ":= " << m << "\n";
                     ss << ": " << l << "\n";
                     ss << $4->code;
                     ss << ": " << m << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
               }
               |  IF boolexp THEN statements ELSE statements ENDIF {
                     stringstream ss;
                     string l = newLabel();
                     string m = newLabel();
                     string n = newLabel();
                     ss << $2->code;
                     ss << "?:= " << $2->place << ", " << l << "\n";
                     ss << ":= " << m << "\n";
                     ss << ": " << l << "\n";
                     ss << $4->code;
                     ss << ": " << m << "\n";
                     ss << $6->code;
                     ss << ": " << n << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
               }
               |  WHILE boolexp BEGINLOOP statements ENDLOOP {
                     stringstream ss;
                     string l = newLabel();
                     string m = newLabel();
                     string n = newLabel();
                     ss << ": " << n << "\n";
                     ss << $2->code;
                     ss << "?:= " << $2->place << ", " << l << "\n";
                     ss << ":= " << m << "\n";
                     ss << ": " << l << "\n";
                     ss << $4->code;
                     ss << ":= " << n << "\n";
                     ss << ": " << m << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
               }
               |  DO BEGINLOOP statements ENDLOOP WHILE boolexp {
                     stringstream ss;
                     string l = newLabel();
                     string m = newLabel();
                     ss << ": " << l << "\n";
                     ss << $3->code;
                     ss << ": " << m << "\n";
                     ss << $6->code;
                     ss << "?:= " << $6->place << ", " << l << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
               }
               | CONTINUE
               ;

readstatement: READ IDENT {
                     stringstream ss;
                     ss << ".< " << *$2 << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
                     
               }
               |  READ IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
                     stringstream ss;
                     ss << ".< " << *$2 << ", " << $4->place << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               |  readstatement COMMA IDENT {
                     stringstream ss;
                     ss << ".< " << *$3 << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               |  readstatement COMMA IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
                     stringstream ss;
                     ss << ".[]< " << *$3 << ", " << $5->place << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               ;

writestatement:WRITE expression {
                     stringstream ss;
                     ss << ".> " << *$2 << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               |  writestatement COMMA expression {
                     stringstream ss;
                     ss << ".> " << $3->place << "\n";
                     $$ = new semval;
                     $$->code = ss.str();
                     //code << ss.str();
               }
               ;

boolexp:       TRUE {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "= " + $$->place + ", " + "1" + "\n";
               }
               | FALSE {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "= " + $$->place + ", " + "0" + "\n";
               }
               |  L_PAREN boolexp R_PAREN {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "= " + $$->place + ", " + $2->place + "\n";
               }
               |  NOT boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "! " + $$->place + ", " + $2->place + "\n";
               }
               |  boolexp AND boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "&& " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp OR boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "|| " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  expression EQ expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "== " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  expression NEQ expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "!= " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  expression GT expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "> " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  expression LT expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "< " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  expression GTE expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += ">= " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  expression LTE expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code += "<= " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               ;

expression:    IDENT {
                     $$ = new semval;
                     $$->place = newTemp();
                     code = ". " + $$->place + "\n";
                     code << "= " << $$->place << ", " << *$1 << "\n";
               }
               |  IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
                     $$ = new semval;
                     $$->place = newTemp();
                     code = ". " + $$->place + "\n";
                     code << "=[] " << $$->place << ", " << *$1 << "\n";
               }
               |  expression ADD expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << "\n";
                     code << "+ " << $$->place << ", " << $1->place << "\n";
               }
               |  expression SUB expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << "\n";
                     code << "- " << $$->place << ", " << $1->place << "\n";
               }
               |  expression MULT expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << "\n";
                     code << "* " << $$->place << ", " << $1->place << "\n";
               }
               |  expression DIV expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << "\n";
                     code << "/ " << $$->place << ", " << $1->place << "\n";
               }
               |  expression MOD expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << "\n";
                     code << "% " << $$->place << ", " << $1->place << "\n";
               }
               |  NUMBER {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code += ". " + $$->place + "\n";
                     $$->code += "= " + $$->place + ", " + $1 + "\n";
               }
               |  L_PAREN expression R_PAREN {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code += ". " + $$->place + "\n";
                     $$->code << "= " << $$->place << ", " << $2->place << "\n";
               }
               |  IDENT L_PAREN expressions R_PAREN {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << "\n";
                     code << "call " << *$1 << ", " << $$->place << "\n";
               }
               ;

expressions:   expression {
                     code << "param " << $$->place << "\n";
               }
               |  expressions COMMA expression {
                     code << "param " << $3->place << "\n";
               }
               ;

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

string newLabel(){
   string n = "l" + to_string(labelCount);
   labelCount++;
   return n;
}


string newTemp(){
   string n = "t" + to_string(tempCount);
   tempCount++;
   return n;
}