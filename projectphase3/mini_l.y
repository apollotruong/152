/* CS152 Project Phase 2 */
/* Apollo Truong, Sidney Son */

/* A parser for the mini-L language using Bison */


/* C Declarations */
%{
#include <stdio.h>
#include <stdlib.h>	
#include <vector>
#include <string.h>

void yyerror(const char *msg);
extern int currLine;
extern int currPosition;
FILE * yyin;
extern int yylex();
vector<string> funcs;
vector<string> decs;
vector<string> decType;
vector<string> states;
vector<string> temps;
int tempCount = 0;
int labelCount = 0;

vector<string> functions;
vector<string> parameters;
vector<string> operand;
vector<string> symbols;
vector<string> statements;

vector<string> ifStatements;

vector<string> stack;

bool addParam = false;
int labelNumber = 0;
int varNumber = 0;
stringstream stream;



%}
/* Bison Declarations */
%union {
   string ident; // needed for name of identifier
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
function:      FUNCTION IDENT {funcs.push_back("func " + $2);}
               SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY 
               { 
                  for(unsigned i = 0; i < funcs.size(); i++){
                     // Print function name
                     cout << funcs[0] << endl;

                     // Print declarations
                     for(unsigned j = 0; j < decs.size(); j++){
                        if(decType[j] == "INT"){
                           cout << ". " << decs[i] << endl;
                        }else {
                           cout << ".[] " << decs[i] << ", " << decType[i] << endl;
                        }
                     }

                     // Print statements
                     for(unsigned k = 0; k < statements.size(); k++){
                        cout << statements[i] << endl;
                     }
                     cout << "endfunc" << endl;
                  }
               }
               ;

declarations:  
               |   declarations declaration SEMICOLON 
               ;

declaration:   identifiers COLON INTEGER 
               {
                  decType.push_back("INT");
               }
               |   identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
               { 
                  decType.push_back(to_string($5));
               }
               ;

identifiers:   IDENT 
               { 
                  decs.push_back(" " + $1);
               }
               |   IDENT COMMA identifiers 
               {
                  decs.push_back(" " + $1);
                  decs.push_back("INT");
               }
               ;

statements:    
               |   statement SEMICOLON statements 
               ;

statement:     var ASSIGN expr 
               {
                  statements.push_back("= " + temps.back());
                  temps.pop_back();
               }
               |   IF bool-expr THEN statements ENDIF 
               {
					labelNumber++;
					ifTrue = "IF_TRUE_LABEL_" + to_string(labelNumber);
					string endIf = "End_If_LABEL" + to_string(labelNumber);
					statements.push_back("?:= " + ifTrue + ", " + operand.back());
					operand.pop_back();
					statements.push_back(":= " + ifElse);
					statements.push_back(": " ++ endIf);
               }
               |   IF bool-expr THEN statements ELSE statements ENDIF {

					string ifTrue = "IF_TRUE_LABEL_" + to_string(labelNumber);
					string ifElse = "IF_ELSE_LABEL_" + to_string(labelNumber);
					string endIf = "END_IF_LABEL_" + to_string(labelNumber);
					statements.push_back("?:= " + ifTrue + ", " + operand.back();
					operand.pop_back();
					statements.push_back(":= " + ifElse);
					statements.push_back(":= + endIf);
				}

               |   WHILE bool-expr BEGINLOOP statements ENDLOOP {
					labelNumber++;
					string whileLabel = "WHILE_LOOP_ + t_string(labelNumber);
					statements.push_back(whileLabel);}
               |   DO BEGINLOOP statements ENDLOOP WHILE bool-expr { /*printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool-expr\n");*/}
               |   READ vars 
               {
                  statements.push_back(".< " + temps.back());
                  temps.pop_back();
               }
               |   WRITE vars 
               {
                  statements.push_back(".> " + temps.back());
                  temps.pop_back();
               }
               |   CONTINUE
               |   RETURN expr 
               ;

bool-expr:     rel-and-exprs { /*printf("bool-expr -> rel-and-exprs\n");*/}
               ;

rel-and-exprs:	rel-and-expr { /*printf("rel-and-exprs -> rel-and-expr\n");*/}
		         |	rel-and-expr OR rel-and-exprs { /*printf("rel-and-exprs -> rel-and-expr OR rel-and-exprs\n");*/}
		         ;

rel-and-expr:  rel-exprs { /*printf("rel-and-expr -> rel-exprs\n");*/}
               ;

rel-exprs:  	rel-expr { /*printf("rel-exprs -> rel-expr\n");*/}
		         |   rel-expr AND rel-exprs { /*printf("rel-and-exprs -> rel-expr AND rel-exprs\n");*/}
		         ;

rel-expr:      NOT expr comp expr { /*printf("rel-expr -> NOT expr comp expr\n");*/}
               |   NOT TRUE { /*printf("rel-expr -> NOT TRUE\n");*/}
               |   NOT FALSE { /*printf("rel-expr -> NOT FALSE\n");*/}
               |   NOT L_PAREN bool-expr R_PAREN { /*printf("rel-expr -> NOT L_PAREN bool-expr R_PAREN\n");*/}
               |   expr comp expr { /*printf("rel-expr -> expr comp expr\n");*/}
               |   TRUE { /*printf("rel-expr -> TRUE\n");*/}
               |   FALSE { /*printf("rel-expr -> FALSE\n");*/}
               |   L_PAREN bool-expr R_PAREN { /*printf("rel-expr -> L_PAREN bool-expr R_PAREN\n");*/}
               ;

comp:          EQ { /*printf("comp -> EQ\n");*/}
               |   NEQ { /*printf("comp -> NEQ\n");*/}
               |   LT { /*printf("comp -> LT\n");*/}
               |   GT { /*printf("comp -> GT\n");*/}
               |   LTE { /*printf("comp -> LTE\n");*/}
               |   GTE { /*printf("comp -> GTE\n");*/}
               ;

exprs:         expr { /*printf("exprs -> expr\n");*/}
               |   expr COMMA exprs { /*printf("exprs -> expr COMMA exprs\n");*/}
               ;

expr:           mult-expr expr-loop { /*printf("expr -> mult-expr expr-loop\n");*/}
		         ; 	
                
expr-loop:	   { /*printf("expr-loop -> epsilon \n");*/}
               |   ADD mult-expr expr-loop { /*printf("expr-loop -> ADD mult-expr expr-loop \n");*/}
               |   SUB mult-expr expr-loop { /*printf("expr-loop -> SUB mult-expr expr-loop \n");*/}
               ;

mult-expr:      term mult-expr-loop { /*printf("mult-expr -> term mult-expr-loop \n");*/}
		         ;

mult-expr-loop:	{ /*printf("mult-expr-loop -> epsilon\n");*/}
		         |   MULT term mult-expr-loop { /*printf("mult-expr -> MULT term mult-expr-loop \n");*/}
               |   DIV term mult-expr-loop { /*printf("mult-expr -> DIV term mult-expr-loop\n");*/}
               |   MOD term mult-expr-loop { /*printf("mult-expr -> MOD term mult-expr-loop \n");*/}
               ;

term:          SUB var { /*printf("term -> SUB var\n");*/}
               |   SUB number { /*printf("term -> SUB number\n");*/}
               |   SUB L_PAREN expr R_PAREN { /*printf("term -> SUB L_PAREN expr R_PAREN\n");*/}
               |   SUB ident L_PAREN exprs R_PAREN { /*printf("term -> SUB ident L_PAREN exprs R_PAREN\n");*/}
               |   var { /*printf("term -> var\n");*/}
               |   number { /*printf("term -> number\n");*/}
               |   L_PAREN expr R_PAREN { /*printf("term -> L_PAREN expr R_PAREN\n");*/}
               |   ident L_PAREN exprs R_PAREN { /*printf("term -> ident L_PAREN exprs R_PAREN\n");*/}
               ;

number:        NUMBER { /*printf("number -> NUMBER %d\n", $1);*/}
               ;

vars:          var { /*printf("vars -> var\n");*/}
               |   var COMMA vars { /*printf("vars -> var COMMA vars\n");*/}
               ;

var:           IDENT
               {
                  string temp = $1;
                  temps.push_back(temp);
               }
               | IDENT L_SQUARE_BRACKET expr R_SQUARE_BRACKET 
               {
                  
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
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPosition, msg);
}
