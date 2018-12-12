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
int labelCount;
int tempCount;

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
	            |  IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
	                  code << ".[] " << *$1 << ", " << $5 << endl;
	            }
               |   IDENT COMMA declaration {
	                  code << ". " << *$1 << endl;
	            }
               ;

statements:    {
                     $$ = new semval;
                     $$->code = "";
               }
	            |   statement SEMICOLON statements {
                     $$->code = $1->code + $3->code;
               }
	            ;

statement:     IDENT ASSIGN expression {
                     code << "= " << *$1 << ", " << $3->place << endl;
                     $$ = new semval; 	       
	            }
               |  IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET ASSIGN expression {
                     code << "[]= " << *$1 << ", " << $3->place << ". " << $6->place << endl;
                     $$ = new semval;
               }
               |  readstatement
               |  writestatement
               |  RETURN expression {
                     code << "ret " << $2->place << endl;
                     $$ = new semval; 
               }
               |  IF boolexp THEN statements ENDIF {
                     ostringstream oss;
                     string l = newLabel();
                     string m = newLabel();
                     oss << $2->code;
                     oss << "?:= " << $2->place << ", " << l << endl;
                     oss << ":= " << m << endl;
                     oss << ": " << l << endl;
                     oss << $4->code;
                     oss << ": " << m << endl;
                     $$ = new semval;
                     $$->code = oss.str();
               }
               |  IF boolexp THEN statements ELSE statements ENDIF {
                     ostringstream oss;
                     string l = newLabel();
                     string m = newLabel();
                     string n = newLabel();
                     oss << $2->code;
                     oss << "?:= " << $2->place << ", " << l << endl;
                     oss << ":= " << m << endl;
                     oss << ": " << l << endl;
                     oss << $4->code;
                     oss << ": " << m << endl;
                     oss << $6->code;
                     oss << ": " << n << endl;
                     $$ = new semval;
                     $$->code = oss.str();
               }
               |  WHILE boolexp BEGINLOOP statements ENDLOOP {
                     ostringstream oss;
                     string l = newLabel();
                     string m = newLabel();
                     string n = newLabel();
                     oss << ": " << n << endl;
                     oss << $2->code;
                     oss << "?:= " << $2->place << ", " << l << endl;
                     oss << ":= " << m << endl;
                     oss << ": " << l << endl;
                     oss << $4->code;
                     oss << ":= " << n << endl;
                     oss << ": " << m << endl;
                     $$ = new semval;
                     $$->code = oss.str();
               }
               |  DO BEGINLOOP statements ENDLOOP WHILE boolexp {
                     ostringstream oss;
                     string l = newLabel();
                     string m = newLabel();
                     oss << ": " << l << endl;
                     oss << $3->code;
                     oss << ": " << m << endl;
                     oss << $6->code;
                     oss << "?:= " << $6->place << ", " << l << endl;
                     $$ = new semval;
                     $$->code = oss.str();
               }
               | CONTINUE
               ;

readstatement: READ IDENT {
                     code << ".< " << *$2 << endl;
                     $$ = new semval;
               }
               |  READ IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
                     code << ".[]< " << *$2 << ", " << $4->place << endl;
                     $$ = new semval;
               }
               |  readstatement COMMA IDENT {
                     code << ".< " << *$3 << endl;
                     $$ = new semval;
               }
               |  readstatement COMMA IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
                     code << ".[]< " << *$3 << ", " << $5->place << endl;
                     $$ = new semval;
               }
               ;

writestatement:WRITE expression {
                     code << ".> " << $2->place << endl;
                     $$ = new semval;
               }
               |  writestatement COMMA expression {
                     code << ".> " << $3->place << endl;
                     $$ = new semval;
               }
               ;

boolexp:       TRUE {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "= " + $$->place + ", " + "1" + "\n";
               }
               | FALSE {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "= " + $$->place + ", " + "0" + "\n";
               }
               |  L_PAREN boolexp R_PAREN {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "= " + $$->place + ", " + $2->place + "\n";
               }
               |  NOT boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "! " + $$->place + ", " + $2->place + "\n";
               }
               |  boolexp AND boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "&& " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp OR boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "|| " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp EQ boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "== " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp NEQ boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "!= " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp GT boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "> " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp LT boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "< " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp GTE boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = ">= " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               |  boolexp LTE boolexp {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     $$->code = "<= " + $$->place + ", " + $1->place + ", " + $3->place + "\n";
               }
               ;

expression:    IDENT {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     code << "= " << $$->place << ", " << *$1 << endl;
               }
               |  IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     code << "=[] " << $$->place << ", " << *$1 << endl;
               }
               |  expression ADD expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << endl;
                     code << "+ " << $$->place << ", " << $1->place << endl;
               }
               |  expression SUB expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << endl;
                     code << "- " << $$->place << ", " << $1->place << endl;
               }
               |  expression MULT expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << endl;
                     code << "* " << $$->place << ", " << $1->place << endl;
               }
               |  expression DIV expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << endl;
                     code << "/ " << $$->place << ", " << $1->place << endl;
               }
               |  expression MOD expression {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << endl;
                     code << "% " << $$->place << ", " << $1->place << endl;
               }
               |  NUMBER {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     code << "= " << $$->place << ", " << $1 << endl;
               }
               |  L_PAREN expression R_PAREN {
                     $$ = new semval;
                     $$->place = newTemp();
                     $$->code = ". " + $$->place + "\n";
                     code << "= " << $$->place << ", " << $2->place << endl;
               }
               |  IDENT L_PAREN expressions R_PAREN {
                     $$ = new semval;
                     $$->place = newTemp();
                     code << ". " << $$->place << endl;
                     code << "call " << *$1 << ", " << $$->place << endl;
               }
               ;

expressions:   
               |  expression {
                     code << "param " << $$->place << endl;
               }
               |  expressions COMMA expression {
                     code << "param " << $3->place << endl;
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
   string n = "l" + labelCount.toString(labelCount);
   labelCount++;
   return n;
}


string newTemp(){
   string n = "t" + toString(tempCount);
   labelCount++;
   return n;
}