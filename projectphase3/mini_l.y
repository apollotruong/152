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
#include <iostream>
#include <cstdlib>
// #include "semVal.h"

using namespace std;
void yyerror(const char *msg);
extern int currLine;
extern int currPosition;
extern int yylex();
extern FILE * yyin;

ostringstream code;
vector<string> funcs;
vector<string> decs;
vector<string> decType;
vector<string> temps;
vector<string> labels;
vector<string> stmnts;

int tempCount = 0;
int labelCount = 0;

%}
/* Bison Declarations */
%union {
   char* ident; // needed for name of identifier
   int val;     // needed for value of number
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
function:      FUNCTION IDENT SEMICOLON {funcs.push_back("func " + string($2));}
               BEGIN_PARAMS declarations END_PARAMS 
               BEGIN_LOCALS declarations END_LOCALS 
               BEGIN_BODY statements END_BODY 
               {
                  // Output function name
                  cout << funcs[0] << endl;
                  // Output declarations
                  for(int i = 0; i < decs.size(); i++){
                     if(decType[i] == "0"){
                        cout << ". " << decs[i] << endl;
                     }else{
                        cout << ".[] " << decs[i] << ", " << decType[i] << endl;
                     }
                  }
                  // Output statements
                  // for(int j = 0; j < stmnts.size(); j++){
                  //    cout << stmnts[j] << endl;
                  // }
               }
               ;

declarations:  
               |   declaration SEMICOLON declarations 
               ;

declaration:   decID COLON INTEGER 
               {
                  decType.push_back("0"); // is an integer 
               }
               |   decID COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
               {
                  decType.push_back(to_string($5));
               }
               ;

decID:         IDENT 
               {
                  decs.push_back(string($1));
               }
               |  IDENT COMMA decID
               {
                  decs.push_back(string($1));
               }
               ;

statements:    
               |  statement SEMICOLON statements 
               ;


statement:     var ASSIGN exprs
               {
                  
               }
               |  IF bool-expr THEN statements ENDIF 
               {
                  
               }
               |  IF bool-expr THEN statements ELSE statements ENDIF 
               {
                  
               }
               |  WHILE bool-expr BEGINLOOP statements ENDLOOP 
               {
                  
               }
               |  DO BEGINLOOP statements ENDLOOP WHILE bool-expr
               |  READ vars {printf("statement -> READ vars\n");}
               |  WRITE vars {printf("statement -> WRITE vars\n");}
               |  CONTINUE {printf("statement -> CONTINUE\n");}
               |  RETURN expr {printf("statement -> RETURN expr\n");}
               ;

bool-expr:      rel-and-exprs {printf("bool-expr -> rel-and-exprs\n");}
                ;

rel-and-exprs:	rel-and-expr {printf("rel-and-exprs -> rel-and-expr\n");}
		|	rel-and-expr OR rel-and-exprs {printf("rel-and-exprs -> rel-and-expr OR rel-and-exprs\n");}
		;

rel-and-expr:   rel-exprs {printf("rel-and-expr -> rel-exprs\n");}
                ;

rel-exprs:	rel-expr {printf("rel-exprs -> rel-expr\n");}
		|   rel-expr AND rel-exprs {printf("rel-and-exprs -> rel-expr AND rel-exprs\n");}
		;

rel-expr:       NOT expr comp expr {printf("rel-expr -> NOT expr comp expr\n");}
                |   NOT TRUE {printf("rel-expr -> NOT TRUE\n");}
                |   NOT FALSE {printf("rel-expr -> NOT FALSE\n");}
                |   NOT L_PAREN bool-expr R_PAREN {printf("rel-expr -> NOT L_PAREN bool-expr R_PAREN\n");}
                |   expr comp expr {printf("rel-expr -> expr comp expr\n");}
                |   TRUE {printf("rel-expr -> TRUE\n");}
                |   FALSE {printf("rel-expr -> FALSE\n");}
                |   L_PAREN bool-expr R_PAREN {printf("rel-expr -> L_PAREN bool-expr R_PAREN\n");}
                ;

comp:           EQ {printf("comp -> EQ\n");}
                |   NEQ {printf("comp -> NEQ\n");}
                |   LT {printf("comp -> LT\n");}
                |   GT {printf("comp -> GT\n");}
                |   LTE {printf("comp -> LTE\n");}
                |   GTE {printf("comp -> GTE\n");}
                ;

exprs:          expr {printf("exprs -> expr\n");}
                |   expr COMMA exprs {printf("exprs -> expr COMMA exprs\n");}
                ;

expr:           mult-expr expr-loop {printf("expr -> mult-expr expr-loop\n");}
		; 	
                
expr-loop:	{printf("expr-loop -> epsilon \n");}
		|   ADD mult-expr expr-loop {printf("expr-loop -> ADD mult-expr expr-loop \n");}
		|   SUB mult-expr expr-loop {printf("expr-loop -> SUB mult-expr expr-loop \n");}
		;

mult-expr:      term mult-expr-loop {printf("mult-expr -> term mult-expr-loop \n");}
		;

mult-expr-loop:	{printf("mult-expr-loop -> epsilon\n");}
		|   MULT term mult-expr-loop {printf("mult-expr -> MULT term mult-expr-loop \n");}
                |   DIV term mult-expr-loop {printf("mult-expr -> DIV term mult-expr-loop\n");}
                |   MOD term mult-expr-loop {printf("mult-expr -> MOD term mult-expr-loop \n");}
                ;

term:           SUB var {printf("term -> SUB var\n");}
                |   SUB NUMBER {printf("term -> SUB number\n");}
                |   SUB L_PAREN expr R_PAREN {printf("term -> SUB L_PAREN expr R_PAREN\n");}
                |   SUB IDENT L_PAREN exprs R_PAREN {printf("term -> SUB ident L_PAREN exprs R_PAREN\n");}
                |   var {printf("term -> var\n");}
                |   NUMBER {printf("term -> number\n");}
                |   L_PAREN expr R_PAREN {printf("term -> L_PAREN expr R_PAREN\n");}
                |   IDENT L_PAREN exprs R_PAREN {printf("term -> ident L_PAREN exprs R_PAREN\n");}
                ;


vars:           var {printf("vars -> var\n");}
                |   var COMMA vars {printf("vars -> var COMMA vars\n");}
                ;

var:            IDENT{printf("var -> ident\n");}
                | IDENT L_SQUARE_BRACKET expr R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n");}
%%
/* Additional C Code */
int main(int argc, char **argv) {
   // Allow for command-line specification of MiniJava source file
   if ( argc > 1  &&  freopen( argv[1], "r", stdin) == NULL ) {
    cerr << argv[0] << ": file " << argv[1]; 
    cerr << " cannot be opened.\n";
    exit( 1 ); 
  }
  yyparse();                                
  return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPosition, msg);
}

string newTemp(){
   string temp = "t" + tempCount;
   tempCount++;
   return temp;
}

string newLabel(){
   string label = "l" + labelCount;
   labelCount++;
   return label;
}