
%{
	#include <string.h>
	#include <stdio.h>
	#include <stdlib.h>
    #include <vector>
    #include <string>
    #include <sstream>
    #include <iostream>
	#include <stack>
    using namespace std;

    int yylex(void);
    void yyerror(const char *msg);
    extern int currLine;
    extern int currPosition;
    extern FILE * yyin;

    vector<string> func;
    vector<string> param;
    vector<string> operand;
    vector<string> symbols;
    vector<string> symbolTypes;
    vector<string> statements;

    vector<string> ifStatements; //

    vector<string> param_;
	stringstream milhouse;

    bool addParam = false;
    int labelCount = 0;
    int tempCount = 0;

%}


%union {
   int val;
   char* ident;
}

%error-verbose
%start prog_start
%token <val> NUMBER
%token <ident> IDENT
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP
%token CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%left SUB ADD MULT DIV MOD
%left EQ NEQ LT GT LTE GTE


%%

prog_start:		function_loop
    			;

function_loop:
    			| function function_loop
    			;

function:		FUNCTION IDENT {func.push_back(string("func ") + $2);} SEMICOLON BEGIN_PARAMS {addParam = true;} 
			declaration_block{
				 while9!param_stack.empty()){
	END_PARAMS {addParam = false;} BEGIN_LOCALS declaration_loop END_LOCALS BEGIN_BODY statement_loop END_BODY {
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
        		param.clear();
        		cout << "endfunc" << endl;
    			}
    			;

declaration_loop:
				| declaration SEMICOLON declaration_loop
    			;

declaration:	id_loop COLON storing
    			;

id_loop:		IDENT {
        			symbols.push_back(string(" ") + $1);
    			}
    			| IDENT COMMA id_loop {
        			symbols.push_back(string(" ") + $1);
        			symbolTypes.push_back("INT");
    			}
    			;

storing:		INTEGER { 
        			symbolTypes.push_back("INT");
    			}
    			| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
        			symbolTypes.push_back(to_string($3));
    			}
    			;
 
statement_loop:
			    | statement SEMICOLON statement_loop
    			;

statement:		var ASSIGN expression {
        			statements.push_back("= " + stack.back().substr(0,stack.back().length()-1));
        			stack.pop_back();
    			}
    			| IF bool_expr THEN statement_loop ENDIF {
        			labelCount++;
        			string label1 = "label1" + to_string(labelCount);
        			string label2 = "lable2" + to_string(labelCount);
        			statements.push_back("?:= " + label1 + ", " + operand.back());
        			operand.pop_back();
        			statements.push_back(": " + label2);

    			}
    			| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF {
        			string label1 = "label1" + to_string(labelCount);
        			string label2 = "label2" + to_string(labelCount);
        			string label3 = "label3" + to_string(labelCount);
        			statements.push_back("?:= " + label1 + ", " + operand.back());
        			operand.pop_back();
        			statements.push_back(":= " + label2); //goto ifFalse statement
        			statements.push_back(": " + label3);

    			}
    			| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP {
        			labelCount++;
        			string label = "label" + to_string(labelCount);
        			statements.push_back(label);

    			}
    			| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr {
        			labelCount++;
        			string label = "label" + to_string(labelCount);
        			statements.push_back(label);
    			}
    			| READ var var_loop {
        			statements.push_back(".< " + stack.back());
        			stack.pop_back();
    			}
    			| WRITE var var_loop {
        			statements.push_back(".> " + stack.back());
        			stack.pop_back();
  				}
    			| CONTINUE
    			| RETURN expression
   				;

var_loop:
				| COMMA var var_loop {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");
    			}
    			;

bool_expr:		relation_and_expr
    			| bool_expr OR relation_and_expr {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");
        			
					string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("|| " + t + ", " + operand1 + ", " + operand2);
					operand.push_back(t);
    			}
    			;

relation_and_expr:relation_expr1
    			| relation_and_expr AND relation_expr1 {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("&& " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			;

relation_expr1:	relation_expr2
    			| NOT relation_expr2 {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
       				symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("! " + t + ", " + operand.back());
        			operand.pop_back();
       				operand.push_back(t);
    			}
    			;

relation_expr2:	expression comp expression
    			| TRUE {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("= " + t + ", 1");
        			operand.push_back(t);
   				}
    			| FALSE {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("= " + t + ", 0");
        			operand.push_back(t);
    			}
    			| L_PAREN bool_expr R_PAREN
    			;

comp:			EQ {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("== " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| NEQ {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("!= " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
   				}
    			| LT {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("< " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| GT {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("> " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| LTE {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

       	 			statements.push_back("<= " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| GTE {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back(">= " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			;

expression:		multiplicative_expr expression_loop
    			;

expression_loop:
			   | ADD multiplicative_expr expression_loop {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("+ " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| SUB multiplicative_expr expression_loop {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("- " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			;

multiplicative_expr: term1 multiplicative_expr_loop
    			;

multiplicative_expr_loop:
				| MULT term1 multiplicative_expr_loop {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("* " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| DIV term1 multiplicative_expr_loop {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("/ " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			| MOD term1 multiplicative_expr_loop {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			string operand1 = operand.back();
        			operand.pop_back();
        			string operand2 = operand.back();
        			operand.pop_back();

        			statements.push_back("% " + t + ", " + operand1 + ", " + operand2);
        			operand.push_back(t);
    			}
    			;

term1:			term2
    			| SUB term2
    			| IDENT L_PAREN R_PAREN
    			| IDENT L_PAREN expr_comma_loop R_PAREN
    			;

term2:     		var
    			| NUMBER {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");

        			statements.push_back("= " + t + ", " + to_string($1));
        			operand.push_back(t);
    			}
    			| L_PAREN expression R_PAREN
    			;

expr_comma_loop:	expression
    			| expression COMMA expr_comma_loop
    			;

var:			IDENT {
        		string temp = $1;
        		stack.push_back(temp);
        		operand.push_back(temp);
    			}
    			| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
        			tempCount++;
        			string t = "t" + to_string(tempCount);
        			symbols.push_back(t);
        			symbolTypes.push_back("INT");
        			statements.push_back(".< " + t);
        			statements.push_back(string("[]= ") + $1 + "," + to_string(tempCount));
        			operand.push_back(string("[] ") + $1 + operand.back());
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

