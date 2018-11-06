/* CS152 Project Phase 2 */
/* Apollo Truong, Sidney Son */

/* A parser for the mini-L language using Bison */


/* C Declarations */
%{
#include <stdio.h>
#include <stdlib.h>	
void yyerror(const char *msg);
extern int currLine;
extern int currPosition;
FILE * yyin;
extern int yylex();
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
prog_start:     functions {printf("prog_start -> functions\n");}
                ;

functions:      {printf("functions -> epsilon\n");}
                |   function functions {printf("functions -> function functions\n");}
                ;
function:       FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
                ;

declarations:   {printf("declarations -> epsilon\n");}
                |   declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");} 
                ;

declaration:    identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
                |   identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
                ;

identifiers:    ident {printf("identifiers -> ident \n");}
                |   ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");}
                ;

ident:          IDENT {printf("ident -> IDENT %s \n", $1);}
                ;

statements:     {printf("statements -> epsilon\n");}
                |   statement SEMICOLON statements {printf("statements -> statement SEMICOLON statemetns\n");}
                ;

statement:      var ASSIGN expr {printf("statement -> var ASSIGN expr\n");}
                |   IF bool-expr THEN statements ENDIF {printf("statement -> IF bool-expr THEN statements ENDIF\n");}
                |   IF bool-expr THEN statements ELSE statements ENDIF {printf("statement -> IF bool-expr THEN statements ELSE statements ENDIF\n");}
                |   WHILE bool-expr BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool-expr BEGINLOOP statements ENDLOOP\n");}
                |   DO BEGINLOOP statements ENDLOOP WHILE bool-expr {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool-expr\n");}
                |   READ vars {printf("statement -> READ vars\n");}
                |   WRITE vars {printf("statement -> WRITE vars\n");}
                |   CONTINUE {printf("statement -> CONTINUE\n");}
                |   RETURN expr {printf("statement -> RETURN expr\n");}
                ;

bool-expr:      rel-and-expr {printf("bool-expr -> rel-and-expr\n");}
                |   rel-and-expr OR rel-and-expr {printf("bool-expr -> rel-and-expr OR rel-and-expr\n");}
                ;

rel-and-expr:   rel-expr {printf("rel-and-expr -> rel-expr\n");}
                |   rel-expr AND rel-expr {printf("rel-and-expr -> rel-expr AND rel-expr\n");}
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

expr:           mult-expr {printf("expr -> mult-expr\n");}
                |   mult-expr SUB mult-expr {printf("expr -> mult-expr SUB mult-expr\n");}
                |   mult-expr ADD mult-expr {printf("expr -> mult-expr ADD mult-expr\n");}
                ;
                
mult-expr:      term {printf("mult-expr -> term\n");}
                |   term MULT term {printf("mult-expr -> term MULT term\n");}
                |   term DIV term {printf("mult-expr -> term DIV term\n");}
                |   term MOD term {printf("mult-expr -> term MOD term\n");}
                ;

term:           SUB var {printf("term -> SUB var\n");}
                |   SUB number {printf("term -> SUB number\n");}
                |   SUB L_PAREN expr R_PAREN {printf("term -> SUB L_PAREN expr R_PAREN\n");}
                |   SUB IDENT L_PAREN exprs R_PAREN {printf("term -> SUB IDENT L_PAREN exprs R_PAREN\n");}
                |   var {printf("term -> var\n");}
                |   number {printf("term -> number\n");}
                |   L_PAREN expr R_PAREN {printf("term -> L_PAREN expr R_PAREN\n");}
                |   IDENT L_PAREN exprs R_PAREN {printf("term -> IDENT L_PAREN exprs R_PAREN\n");}
                ;

number:         NUMBER {printf("number -> NUMBER %d\n", $1);}
                ;

vars:           var {printf("vars -> var\n");}
                |   var COMMA vars {printf("vars -> var COMMA vars\n");}
                ;

var:            IDENT {printf("IDENT %s\n", $1);}
                | IDENT L_SQUARE_BRACKET expr R_SQUARE_BRACKET {printf("IDENT %s L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n", $1);}

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
