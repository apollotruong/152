/* CS152 Project Phase 2 */
/* Apollo Truong, Sidney Son */

/* A parser for the mini-L language using Bison */


/* C Declarations */
%{

%}
/* Bison Declarations */
%union {
    char* ident; // needed for name of identifier
    int val;     // needed for value of number
}
// Start Symbol
%start prog_start
// Reserved Words
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
// Arithmetic Operators
%token SUB ADD MULT DIV MOD
// Comparison Operators
%token EQ NEQ LT GT LTE GTE
// Other Special Symbols
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUAREBRACKET R_SQUARE_BRACKET ASSIGN
// Identifiers and Numbers
%token <val> NUMBER
%token <ident> IDENT

/* Grammar Rules */
%%
prog_start:     functions
                ;

functions:      function
                |   function functions
                ;
function:       FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
                ;

declarations:   declaration SEMICOLON
                |   declaration SEMICOLON declarations 
                ;

declaration:    identifiers COLON INTEGER
                |   identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
                ;

identifiers:    IDENT
                |   IDENT COMMA identifiers
                ;

statements:     statement SEMICOLON
                |   statement SEMICOLON statements
                ;

statement:      var ASSIGN expression
                |   IF bool-expr THEN statements ENDIF
                |   IF bool-expr THEN statements ELSE statements ENDIF
                |   WHILE bool-expr BEGINLOOP statements ENDLOOP
                |   DO BEGINLOOP statements ENDLOOP WHILE bool-expr
                |   READ vars
                |   WRITE vars
                |   CONTINUE
                |   RETURN expr
                ;

bool-expr:      rel-and-exprs
                ;

rel-and-exprs:  rel-and-expr
                |   rel-and-expr OR rel-and-exprs
                ;

rel-and-expr:   rel-exprs
                ;

rel-exprs:      rel-expr
                |   rel-expr AND rel-exprs
                ;

rel-expr:       nots expr comp expr
                |   nots TRUE
                |   nots FALSE
                |   nots L_PAREN bool-expr R_PAREN
                ;

nots:           NOT
                |   NOT nots
                ;

comp:           EQ
                |   NEQ
                |   LT
                |   GT
                |   LTE
                |   GTE
                ;

exprs:          expr
                |   expr COMMA exprs
                ;

expr:           mult-expr
                |   mult-expr SUB mult-expr
                |   mult-expr ADD mult-expr
                ;
                
mult-expr:      term
                |   term MULT term
                |   term DIV term
                |   term MOD term
                ;

term:           subs var
                |   subs NUMBER
                |   subs L_PAREN expr R_PAREN
                |   IDENT L_PAREN exprs R_PAREN
                ;

subs:           
                |   SUB
                |   SUB subs
                ;

vars:           var
                |   var COMMA vars
                ;

var:            IDENT
                | IDENT L_SQUARE_BRACKET expr R_SQUARE_BRACKET

%%
/* Additional C Code */
