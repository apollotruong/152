/* CS152 Project Phase 2 */
/* Apollo Truong, SIDENTney Son */

/* A parser for the mini-L language using Bison */


/* C Declarations */
%{
#include <stdio.h>
#include <stdlib.h>	
#include <ostream>
#include <iostream>
#include <fstream>
#include <cstdlib>

void yyerror(const char *msg);
int vectorSize;
string prefix;
string suffix;

extern int reductionCt;
extern int listCt;
extern ostringstream rules;
extern ostringstream decs;
extern ostringstream code;
extern ostringstream init;


extern int currLine;
extern int currPosition;


FILE * yyin;
extern int yylex();

struct expression_semval {
	std::string code;
	std::string result_IDENT; // aka 'place'
};

%}
/* Bison Declarations */

%union {
   int junk;
   char* ident; // needed for name of IDENTentifier
   int val;     // needed for value of number
}

// Start Symbol
%start prog_start

%type <code>   Program
%type <code>   Decl
%type <code>   statements
%type <code>   StmtList
%type <code>   ExpList
%type <code>   FunctionDecl
%type <code>   BoolExp
%type <code>   BoolExp
%type <ident>  Exp
%type <code>   Stmt
%type <code>   ReadStmt
%type <code>   WriteStmt

// Reserved Words
%token      <junk> 	LO
%left       <junk> 	FUNCTION 
%token      <junk> 	BEGIN_PARAMS 
%token      <junk> 	END_PARAMS 
%token      <junk> 	BEGIN_LOCALS 
%token      <junk> 	END_LOCALS 
%token      <junk> 	BEGIN_BODY 
%token      <junk> 	END_BODY
%token      <junk> 	ARRAY
%token      <junk> 	OF
%token      <junk> 	ASSIGN
%token      <junk> 	IF
%token      <junk> 	THEN
%token      <junk> 	ENDIF
%token      <junk> 	ELSE
%token		<junk<	ELSEIF
%token      <junk> 	WHILE
%token      <junk> 	BEGINLOOP
%token      <junk> 	ENDLOOP
%token      <junk> 	DO
%token      <junk> 	READ
%token      <junk> 	WRITE
%token      <junk> 	CONTINUE
%token      <junk> 	RETURN
%token		<junk>	INTEGER
%token      <junk> 	INTEGER
%token      <val> 	NUMBER
%token      <junk> 	IDENT
%token      <junk> 	TRUE
%token      <junk> 	FALSE
%token      <junk> 	ASMT
%left     			OR
%left     			AND
%right    			NOT
%nonassoc 			NE EQ LE GE LTE GTE
%left     			ADD SUB
%left			 	MULT DIV MOD
%left     			SEMICOLON
%left     			COLON
%left     			COMMA
%left     			R_PAREN
%left     			L_PAREN
%left     			R_SQUARE_BRACKET
%left     			L_SQUARE_BRACKET







/* Grammar Rules */
%%
Program:          /* EMPTY */    
                     { 
                        rules << "Program -> /* EMPTY */ \n"; 
                     }
                  |  Program FunctionDecl       
                     { 
                        rules << "Program -> ProgramFunctionDecl \n"; 
                     }
                  ;   

StmtList:         Stmt ';'          // nonempty, semicolon terminated. *
                     { 
                        rules << "StmtList -> Stmt \n"; 
                     }
                  |  StmtList Stmt ';'
                     { 
                        rules << "StmtList -> StmtList Stmt ';' \n"; 
                     }  
                   ;

ExpList:          /* EMPTY */      // possibly empty, comma separated. *
                     { 
                        rules << "ExpList -> /* EMPTY */ \n"; 
                     }                       
                  |  ExpList ',' Exp        
                     { 
                        rules << "ExpList -> Explist ',' Exp \n"; 
                     }     
                  ;

FunctionDecl:     FUNCTION IDENT ';' BEGINPARAMS DeclList  ENDPARAMS       
                  BEGINLOCALS DeclList  ENDLOCALS
                  BEGINBODY   StmtList  ENDBODY
                     {  
                        rules << "FunctionDecl -> FUNCTION IDENT ';' \n";
                        rules << "   BEGINPARAMS DeclList  ENDPARAMS \n"; // scalars
                        rules << "   BEGINLOCALS DeclList  ENDLOCALS \n";
                        rules << "   BEGINBODY   StmtList  ENDBODY \n";
                                                // for code, must expand lists
                     }
                  ;

Decl:             IDENT ':' INTEGER                      // A scalar variable *
                     { 
                        rules << "Decl -> IDENT ':' INTEGER \n"; 
                        code << ". " << *($1) << "\n";
                     }
                  |  IDENT ':' ARRAY '[' NUMBER ']' OF INTEGER   // A vector var *
                     { 
                        rules << "Decl -> IDENT ':' ARRAY '[' NUMBER ']' OF INTEGER \n"; 
                        vectorSize = $5; 
                        code  << ".[] " << *($1) << ", " << vectorSize << "\n";
	                  }
                  |  IDENT ',' Decl                           // right recursion *
    		            { 
                        rules << "VectorDec. ->  IDENT ',' VectorDecl \n"; 
                        code  << ".[] " << *($1) << ", " << vectorSize << "\n";
		               }
                  ; // vectorSize is global declared at the top of main.cc

DeclList:         /* EMPTY */   // possibly empty, semicolon terminated.
                     { 
                        rules << "DeclList -> EMPTY\n"; 
                     } 
                  |  DeclList Decl ';'                      // left recursion *
                     {
                        rules << "DeclList -> DeclList Decl ';' \n"; 
                     }
                  ;

BoolExp:          TRUE                   
                     { 
                        rules << " TRUE \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 	
                        code << "= " << $$ << ", " << 1 << "\n";     
	                  }
                  |  FALSE                  
                     { 
                        rules << " FALSE \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "= " << $$ << ", " << 0 << "\n";     
		               }                    
                  |  '(' BoolExp ')'
                     { 
                        rules << " '(' BoolExp ')' \n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "= " << *$$ << ", " << *$2 << "\n";
                     }     
                  |  NOT BoolExp
                     {
                        rules << " NOT BoolExp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "! " << *$$ << ", " << *$2 << "\n";
                     }
                  |  BoolExp AND BoolExp    
                     { 
                        rules << " BoolExp AND BoolExp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "&& " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
		               }
                  |  BoolExp OR BoolExp     
                     { 
                        rules << " BoolExp OR BoolExp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "|| " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
		               }
                  |  Exp EQ Exp           
                     { 
                        rules << " Exp EQ Exp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 	
                        code << "== " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
	                  }
                  |  Exp NE Exp           
                     { 
                        rules << " Exp NE Exp \n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "!= " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
		               }
                  |  Exp GE Exp           
                     { 
                        rules << " Exp GE Exp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << ">= " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
		               }
                  |  Exp LE Exp           
                     { 
                        rules << " Exp LE Exp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "<= " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
		               }
                  |  Exp '>' Exp           
                     { 
                        rules << " Exp '>' Exp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "> " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
		               }
                  |  Exp '<' Exp           
                     { 
                        rules << " Exp '<' Exp \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                        code << "< " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
		               }
                  ;

Exp:              IDENT                                 // scalar variable *
                     { rules << "Exp -> IDENT\n";
                       $$ = new string("_T" + itoa(reductionCt++)); 
                       code << "= " << *$$ << ", " << *$1 << "\n";
		               }
                  |  IDENT '[' Exp ']'       //  vector/subscripted variable *  
                     { 
                        rules << "Exp -> IDENT '[' Exp ']' \n"; 
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "=[] " << *$$ << ", " << *$1 << ", " << *$3 << "\n"; 
                     }
                  |  Exp '+' Exp	    
                     { 
                        rules << "Exp -> Exp '+' Exp\n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "+ " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
                     }
                  |  Exp '-' Exp	    
                     { 
                        rules << "Exp -> Exp '-' Exp\n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "- " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
                     }
                  |  Exp '*' Exp	    
                     { 
                        rules << "Exp -> Exp '*' Exp\n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "* " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
                     }
                  |  Exp '/' Exp	    
                     { 
                        rules << "Exp -> Exp '/' Exp\n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "/ " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
                     }
                  |  Exp '%' Exp	    
                     { 
                        rules << "Exp -> Exp '%' Exp\n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "% " << *$$ << ", " << *$1 << ", " << *$3 << "\n";
                     }
                  |  '-' Exp  %prec '('     
                     { 
                        rules << "Exp -> '-' Exp\n";
                        $$ = new string("_T" + itoa(reductionCt++));
                        code << "- " << *$$ << ", " << 0 << ", " << *$2 << "\n";
                     }
                  |  NUMBER                 
                     { 
                        $$ = new string("_T" + itoa(reductionCt++));
                        rules << "Exp -> NUMBER\n";
                        code << "= " << *$$ << ", " << $1 << "\n";
                     }
                  |  '(' Exp ')'             
                     { 
                        rules << "Exp -> '(' Exp ')' \n";
                        $$ = new string("_T" + itoa(reductionCt++));  
                        code << "= " << *$$ << ", " << *$2 << "\n";
                     }
                  |  IDENT '(' ExpList ')'      // function call         // ???
                     { 
                        rules << "Exp -> IDENT '(' Exp ')' \n";
                        $$ = new string("_T" + itoa(reductionCt++)); 
                     }
	               ;

ReadStmt:         READ IDENT                                            // *
                     { 
                        rules << "ReadStmt -> Read IDENT \n";
                        code  << ".< " << *$2 << "\n";
		               }
                  |  READ IDENT '[' Exp ']'                                
                     { 
                        rules << "ReadStmt -> READ IDENT '[' Exp ']' \n";
                        code  << ".[]< " << *$2 << ", " << *$4 << "\n";
                     }
                  |  ReadStmt ',' IDENT                     // left recursion *
		               { 
                        rules << "ReadStmt -> ReadStmt ',' IDENT \n";
                        code  << ".< " << *$3 << "\n";
                     }
                  |  ReadStmt ',' IDENT '[' Exp ']'         // left recursion *
		               { 
                        rules << "ReadStmt -> ReadStmt ',' IDENT '[' Exp ']'\n"; 
                        code  << ".[]< " << *$3 << ", " << $5 << "\n";
                     }
                  ;

WriteStmt:        WRITE Exp                                          // *
                     { 
                        rules << "WriteStmt -> WRITE Exp \n";
                        code << ".> " << *$2 << "\n";
                     }
                  |  WriteStmt ',' Exp                   // left recursion *
                     { 
                        rules << "WriteStmt -> WriteStmt ',' Exp \n";
                        code << ".> " << *$3 << "\n";
                     }
                  ;

Stmt:             IDENT ASMT Exp    // The desination can be either scalar *
                     { 
                        rules << "Stmt -> IDENT ASMT Exp\n";
                        code << "= " << *$1 << ", " << *$3 << "\n";
		               }
                  |  IDENT '[' Exp ']' ASMT Exp             // or subscripted *
		               { 
                        rules << "Stmt -> IDENT '[' Exp ']' ASMT Exp\n";
                        code << "[]= " << *$1 << ", " << *$3 << ", " << *$6 << "\n";
		               }
                  |  ReadStmt                                 // See above *
		               { 
                        rules << "Stmt -> ReadStmt" ; 
                     }                  // *
                  |  WriteStmt                                // see above *
		               { 
                        rules << "Stmt -> WriteStmt" ; 
                     }                 // *
                  |  IF BoolExp THEN StmtList ELSE StmtList ENDIF    // outline
		               { 
                        rules << "Stmt -> IF BoolExp THEN StmtList ELSE StmtList ENDIF\n";
                        code << "?:= THEN, BoolExp \n"        // if BoolExp goto THEN
		                  << ":= ELSE \n"                  // goto ELSE
                        << ":THEN \n"                    // THEN:
                        << "..."                         // dump StmtList
                        << ":= ENDIF \n"                 // goto ENDIF
                        << ":ELSE \n"                    // ELSE: 
			               << "..."                         // StmtList 
			               << ":ENDIF \n"                   // ENDIF:
		               }
                  |  IF BoolExp THEN StmtList ENDIF                  // outline
                     { 
                        rules << "Stmt -> IF BoolExp THEN StmtList ENDIF\n";
                        code << "?:= THEN, BoolExp \n"        // if BoolExp goto THEN
		                  << ":= ELSE \n"                  // goto ELSE
                        << ":THEN \n"                    // THEN:
                        << "..."                         // StmtList
                        << ":ELSE \n"                    // ELSE: 
		               }  
                  |  WHILE BoolExp BEGINLOOP StmtList ENDLOOP        // outline
		               { 
                        rules << "Stmt -> WHILE BoolExp BEGINLOOP StmtList ENDLOOP\n"; 
                        code << ": WHILE \n"                  // WHILE:
			               << "?:= BEGINLOOP, BoolExp \n"
			                           // if boolExp goto BEGINLOOP
                        << ":= EXIT \n"        // otherwise, goto EXIT
			               << ": BEGINLOOP \n"              // BEGINLOOP:
			               << "..."                         // StmtList
			               << ":= WHILE \n"                 // goto WHILE
			               << ": EXIT \n"                   // EXIT:
		               }
                  |  DO BEGINLOOP StmtList ENDLOOP WHILE BoolExp // outline
		               { 
                        rules << "Stmt -> DO BEGINLOOP StmtList ENDLOOP "
		                  << "WHILE BoolExp\n";           
                        code  << ": DO BEGINLOOP \n"          // BEGINLOOP:
                        << "..."                        // StmtList
			               << "?:=  << BEGINLOOP <<,  << BoolExp \n"
			               // if BoolExp goto BEGINLOOP
		               }
                  |  CONTINUE                                // outline
		               { 
                        rules << "Stmt -> CONTINUE\n";
                        code  << ":= BEGINLOOP\n"
		               }
                  |  RETURN Exp                                        // ???
		               { 
                        rules << "Stmt -> RETURN Exp\n";               
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
