/* CS152 Project Phase 2 */
/* Apollo Truong, Sidney Son */

/* A parser for the mini-L language using Bison */


/* C Declarations */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	#include <assert.h>

    #include <vector>
    #include <string>
    #include <sstream>
    #include <iostream>

    using namespace std;

    int yylex(void);
    void yyerror(const char *msg);
    extern int currLine;
    extern int currPosition;
    extern FILE * yyin;

    vector<string> functions;
    vector<string> parameters;
    vector<string> operand;
    vector<string> symbols;
    vector<string> symbolTypes;
    vector<string> statements;

    vector<string> ifStatements; //

    vector<string> crossGrammar;

    bool addParam = false;
    int labelNumber = 0;
    int varNumber = 0;
    stringstream stream;

%}


%union {
   int ival;
   char* charIdent;
}

%error-verbose
%start prog_start
%token <ival> NUMBER
%token <charIdent> IDENT
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP
%token CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%left SUB ADD MULT DIV MOD
%left EQ NEQ LT GT LTE GTE


%%

prog_start:
	function_loop
	;

function_loop:
	/*EPSILON*/
	| function function_loop
	;

function:
	FUNCTION IDENT {functions.push_back(string("func ") + $2);} SEMICOLON BEGIN_PARAMS {addParam = true;} declaration_loop END_PARAMS {addParam = false;} BEGIN_LOCALS declaration_loop END_LOCALS BEGIN_BODY statement_loop END_BODY {
		cout << functions[0] << endl;
		// Prints Variables
		for(unsigned i = 0; i < symbols.size(); i++) {
			if(symbolTypes[i] == "INT") {
	
				cout << ". " << symbols[i] << endl;
			}
			else {
				cout << ".[] " << symbols[i] << ", " << symbolTypes[i] << endl;
			}
		}
		
		// Prints Statements
		for(unsigned i = 0; i < statements.size(); i++) {
			cout << statements[i] << endl;
		}
		symbols.clear();
		symbolTypes.clear();
		statements.clear();
		parameters.clear();
		cout << "endfunc" << endl;
	}
	;

declaration_loop:
	/*EPSILON*/
	| declaration SEMICOLON declaration_loop
	;

declaration:
	id_loop COLON storing
	;

id_loop:
	IDENT {
		symbols.push_back(string(" ") + $1);
		// if(addParam) {
		// 	parameters.push_back(string(" ") + $1);
		// }
	}
	| IDENT COMMA id_loop {
		symbols.push_back(string(" ") + $1);
		symbolTypes.push_back("INT");
	}
	;

storing:
	INTEGER { 
		symbolTypes.push_back("INT");
	}
	| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
		symbolTypes.push_back(to_string($3));
	}
	;
 
statement_loop:
	/*EPSILON*/
	| statement SEMICOLON statement_loop
	;

statement:
	var ASSIGN expression {
		statements.push_back("= " + crossGrammar.back().substr(0,crossGrammar.back().length()-1));
		crossGrammar.pop_back();
	}
	| IF bool_expr THEN statement_loop ENDIF {
		labelNumber++;
		string ifTrue = "IF_TRUE_LABEL_" + to_string(labelNumber);
		string endIf = "END_IF_LABEL" + to_string(labelNumber);
		statements.push_back("?:= " + ifTrue + ", " + operand.back());
		operand.pop_back();
		statements.push_back(": " + endIf);

	}
	| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF {
		string ifTrue = "IF_TRUE_LABEL_" + to_string(labelNumber);
		string ifElse = "IF_ELSE_LABEL_" + to_string(labelNumber);
		string endIf = "END_IF_LABEL_" + to_string(labelNumber);
		statements.push_back("?:= " + ifTrue + ", " + operand.back());
		operand.pop_back();
		statements.push_back(":= " + ifElse); //goto ifFalse statement
		statements.push_back(": " + endIf);

	}
	| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP {
		labelNumber++;
		string whileLabel = "WHILE_LOOP_" + to_string(labelNumber);
		statements.push_back(whileLabel);

	}
	| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr {
		labelNumber++;
		string whileLabel = "DO_WHILE_LOOP_" + to_string(labelNumber);
		statements.push_back(whileLabel);
	}
	| FOREACH IDENT IN IDENT BEGINLOOP statement_loop ENDLOOP
	| READ var var_loop {
		statements.push_back(".< " + crossGrammar.back());
		crossGrammar.pop_back();
	}
	| WRITE var var_loop {
		statements.push_back(".> " + crossGrammar.back());
		crossGrammar.pop_back();
	}
	| CONTINUE
	| RETURN expression
	;

var_loop:
	/*EPSILON*/
	| COMMA var var_loop {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");
	}
	;

bool_expr:
	relation_and_expr
	| bool_expr OR relation_and_expr {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("|| " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	;

relation_and_expr:
	relation_expr1
	| relation_and_expr AND relation_expr1 {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("&& " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	;

relation_expr1:
	relation_expr2
	| NOT relation_expr2 {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		statements.push_back("! " + tempVar + ", " + operand.back());
		operand.pop_back();
		operand.push_back(tempVar);
	}
	;

relation_expr2:
	expression comp expression
	| TRUE {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		statements.push_back("= " + tempVar + ", 1");
		operand.push_back(tempVar);
	}
	| FALSE {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		statements.push_back("= " + tempVar + ", 0");
		operand.push_back(tempVar);
	}
	| L_PAREN bool_expr R_PAREN
	;

comp:
	EQ {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("== " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| NEQ {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("!= " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| LT {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("< " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| GT {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("> " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| LTE {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("<= " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| GTE {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back(">= " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	;

expression:
	multiplicative_expr expression_loop
	;

expression_loop:
	/*EPSILON*/
	| ADD multiplicative_expr expression_loop {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("+ " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| SUB multiplicative_expr expression_loop {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("- " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	;

multiplicative_expr:
	term1 multiplicative_expr_loop
	;

multiplicative_expr_loop:
	/*EPSILON*/
	| MULT term1 multiplicative_expr_loop {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("* " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| DIV term1 multiplicative_expr_loop {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("/ " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	| MOD term1 multiplicative_expr_loop {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		string operand1 = operand.back();
		operand.pop_back();
		string operand2 = operand.back();
		operand.pop_back();

		statements.push_back("% " + tempVar + ", " + operand1 + ", " + operand2);
		operand.push_back(tempVar);
	}
	;

term1:
	term2
	| SUB term2
	| IDENT L_PAREN R_PAREN
	| IDENT L_PAREN expr_comma_loop R_PAREN
	;

term2:
	var
	| NUMBER {
		varNumber++;
		string tempVar = "reg" + to_string(varNumber);
		symbols.push_back(tempVar);
		symbolTypes.push_back("INT");

		statements.push_back("= " + tempVar + ", " + to_string($1));
		operand.push_back(tempVar);
	}
	| L_PAREN expression R_PAREN
	;

expr_comma_loop:
	expression
	| expression COMMA expr_comma_loop
	;

var:
	IDENT {
		string temp = $1;
		crossGrammar.push_back(temp);
		operand.push_back(temp);
	}
	| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
		varNumber++;
		string regNumber = "regArray" + to_string(varNumber);
		symbols.push_back(regNumber);
		symbolTypes.push_back("INT");
		statements.push_back(".< " + regNumber);
		statements.push_back(string("[]= ") + $1 + "," + to_string(varNumber));
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