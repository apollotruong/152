/* CS152 Project Phase 2 */
/* Apollo Truong, Sidney Son */

%{
	#include <string.h>
	#include <stdio.h>
	#include <stdlib.h>
    
    #include <string>
    #include <sstream>
    #include <vector>
	#include <iostream>
    using namespace std;

    int yylex(void);
    void yyerror(const char *msg);
    extern int currLine;
    extern int currPosition;
    extern FILE * yyin;

    
    string newTemp();
    string newLabel();


	vector<string> func;
    vector<string> ops;
    vector<string> symbols;
    vector<string> symbolTypes;
    vector<string> statements;
    vector<string> cross;

    int labelCount = 0;
    int tempCount = 0;

%}


%union {
   int val;
   char* ident;
}

%error-verbose
%start Program
%token <val> NUMBER
%token <ident> IDENT
%token FUNCTION 
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF 
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token FOREACH
%token IN
%token BEGINLOOP
%token ENDLOOP
%token CONTINUE
%token READ
%token WRITE
%token AND
%token OR
%token NOT
%token TRUE
%token FALSE
%token RETURN
%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token ASSIGN
%left SUB 
%left ADD
%left MULT
%left DIV
%left MOD
%left EQ NEQ LT GT LTE GTE '<' '>'


%%

Program:		functions
    			;

functions:
    			| function functions
    			;

function:		FUNCTION IDENT {func.push_back(string("func ") + $2);} SEMICOLON BEGIN_PARAMS declarations
	END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {
        		cout << func[0] << endl;
        		// Prints Variables
        		for(unsigned i = 0; i < symbols.size(); i++) {
            	if(symbolTypes[i] == "INT") {
                	cout << "." << " " << symbols[i] << endl;
            	}
            	else {
                		cout << ".[]" << symbols[i] << "," << " "  << symbolTypes[i] << endl;
            		}
        		}
        
        		// Prints Statements
        		for(unsigned i = 0; i < statements.size(); i++) {
            		cout << statements[i] << endl;
        		}
        		symbols.clear();
        		symbolTypes.clear();
       		statements.clear();
        		cout << "endfunc" << endl;
    			}
    			;

declarations:
				| declaration SEMICOLON declarations
    			;

declaration:	ids COLON push_symbol
    			;

ids:		IDENT {
        			symbols.push_back(string(" ") + $1);
    			}
    			| IDENT COMMA ids {
        			symbols.push_back(string(" ") + $1);
        			symbolTypes.push_back("INT");
    			}
    			;

push_symbol:		INTEGER { 
        			symbolTypes.push_back("INT");
    			}
    			| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
        			symbolTypes.push_back(to_string($3));
    			}
    			;
 
statements:
			    | statement SEMICOLON statements
    			;

statement:		var ASSIGN expr {
        			statements.push_back("= " + cross.back().substr(0,cross.back().length()-1));
        			cross.pop_back();
    			}
    			| IF bool_expr THEN statements ENDIF {
        			string label1 = newLabel();
        			string label2 = newLabel();
        			statements.push_back("?:= " + label1 + ", " + ops.back());
        			ops.pop_back();
        			statements.push_back(": " + label2);

    			}
    			| IF bool_expr THEN statements ELSE statements ENDIF {
        			string label1 = newLabel();
        			string label2 = newLabel();
        			string label3 = newLabel();
        			statements.push_back("?:= " + label1 + ", " + ops.back());
        			ops.pop_back();
        			statements.push_back(":= " + label2); //goto ifFalse statement
        			statements.push_back(": " + label3);

    			}
    			| WHILE bool_expr BEGINLOOP statements ENDLOOP {
        			string label = newLabel();
        			statements.push_back(label);

    			}
    			| DO BEGINLOOP statements ENDLOOP WHILE bool_expr {
        			string label = newLabel();
        			statements.push_back(label);
    			}
    			| READ var vars {
        			statements.push_back(".< " + cross.back());
        			cross.pop_back();
    			}
    			| WRITE var vars {
        			statements.push_back(".> " + cross.back());
        			cross.pop_back();
  				}
    			| CONTINUE
    			| RETURN expr
   				;

vars:
				| COMMA var vars {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");
    			}
    			;

bool_expr:		relation_and_expr
    			| bool_expr OR relation_and_expr {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");
        			
					string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("|| " + t + ", " + ops1 + ", " + ops2);
					ops.push_back(t);
    			}
    			;

relation_and_expr:relation_expr1
    			| relation_and_expr AND relation_expr1 {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("&& " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			;

relation_expr1:	relation_expr2
    			| NOT relation_expr2 {
        			string t = newTemp();
       				symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("! " + t + ", " + ops.back());
        			ops.pop_back();
       				ops.push_back(t);
    			}
    			;

relation_expr2:	expr comp expr
    			| TRUE {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("= " + t + ", 1");
        			ops.push_back(t);
   				}
    			| FALSE {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("= " + t + ", 0");
        			ops.push_back(t);
    			}
    			| L_PAREN bool_expr R_PAREN
    			;

comp:			EQ {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("== " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| NEQ {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("!= " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
   				}
    			| LT {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("< " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| GT {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("> " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| LTE {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

       	 			statements.push_back("<= " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| GTE {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back(">= " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			;

expr:		multiplicative_expr expr_loop
    			;

expr_loop:
			   | ADD multiplicative_expr expr_loop {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("+ " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| SUB multiplicative_expr expr_loop {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("- " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			;

multiplicative_expr: term1 multiplicative_expr_loop
    			;

multiplicative_expr_loop:
				| MULT term1 multiplicative_expr_loop {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("* " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| DIV term1 multiplicative_expr_loop {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("/ " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			| MOD term1 multiplicative_expr_loop {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string ops1 = ops.back();
        			ops.pop_back();
        			string ops2 = ops.back();
        			ops.pop_back();

        			statements.push_back("% " + t + ", " + ops1 + ", " + ops2);
        			ops.push_back(t);
    			}
    			;

term1:			term2
    			| SUB term2
    			| IDENT L_PAREN R_PAREN
    			| IDENT L_PAREN expr_comma_loop R_PAREN
    			;

term2:     		var
    			| NUMBER {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("= " + t + ", " + to_string($1));
        			ops.push_back(t);
    			}
    			| L_PAREN expr R_PAREN
    			;

expr_comma_loop:	expr
    			| expr COMMA expr_comma_loop
    			;

var:			IDENT {
        		string temp = $1;
        		ops.push_back(temp);
    			}
    			| IDENT L_SQUARE_BRACKET expr R_SQUARE_BRACKET {
        			string t = newTemp();
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");
        			statements.push_back(".< " + t);
        			statements.push_back(string("[]= ") + $1 + "," + to_string(tempCount));
        			ops.push_back(string("[] ") + $1 + ops.back());
    			}
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
   printf("** Line %d, position %d: %s\n", currLine, currPosition, msg);

}

string newTemp(){
   tempCount++;
   string t = "t" + to_string(tempCount);
   return t;
}

string newLabel(){
   labelCount++;
   string l = "l" + to_string(labelCount);
   return l;
}