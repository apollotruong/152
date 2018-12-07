
%{
  #define YY_NO_UNPUT
  #include <iostream>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string>
  #include <string.h>
  #include <fstream>
  #include <sstream>
  #include <map>
  #include <stack>
  #include <vector>

  using namespace std;

  //#define YYDEBUG 1
  //#define YYPRINT(file, type, value) yyprint (file, type value)
  //yydebug = 1;
  enum symbol_type {INT, INTARRAY, FUNC};

  struct Func {
    string name;
    Func(): name() {}
    Func(string n) 
    : name(n){}
  };

  struct Sym {
    int val;
    int size;
    string name;
    symbol_type type; 
    Sym():val(0),size(0),name(),type() {}
    Sym(int v, int s, string n, symbol_type t) 
    :val(v), size(s), name(n), type(t)
    {}
  };

  extern FILE *yyin;
  int yylex(void);
  void yyerror(const char *message);
  extern int currLine;
  extern int currPos;

  stack<string> ident_stack; // using
  stack<string> var_stack; // using
  stack<string> exp_stack; // using
  stack<string> param_stack; //using
  stack<string> label_stack; //using
  
  void add_symbol(Sym sym);
  void add_func(Func func);
  void check_symbol(string name);
  void check_func(string name);
  void print_declarations();
  string make_temp();
  string make_label();
  map<string, Sym> symbol_table;
  map<string, Func> func_table;

  stringstream milhouse;
  ostringstream out_code;

  int temp_cnt = 0;
  int label_cnt = 0;
  int param_cnt = 0;
  bool main_exists = 0;
  
%}

%union{
  char* ident_str;
  int num_val;

  struct attributes {
    char name[255];
    char index[255];
    int type; //0 = int, 1 = int array, 2 = function
    int val;
    int size_attr;
  } attr;
}

%error-verbose
%debug
%start start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY
%token END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP
%token CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN NUMBER IDENT 

%token SUB ADD MULT DIV MOD UMINUS

%token EQ NEQ LT GT LTE GTE

%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN

%type <ident_str> IDENT
%type <num_val> NUMBER

%right ASSIGN
%left OR
%left AND
%right NOT
%right UMINUS
%left ADD SUB
%left MULT DIV
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN

//%type<ident_str> comma_ident
//%type<ident_str> declaration

%type<attr> var expression term declaration statement multiplicative_expr bool_expr relation_and_expr relation_expr rel_expr
%type<ident_str> comp

%%

start: program {if(!main_exists){yyerror("error: main not declared");}}
     ;

program: 
       | function program 
       ;

function: FUNCTION IDENT {milhouse << "func " << string($2) << endl;} SEMICOLON BEGIN_PARAMS 
          declaration_block { 
            while (!param_stack.empty()){
              milhouse << "= " << param_stack.top() << ", " << "$" << param_cnt++ << endl;
              param_stack.pop();
            }
          } 
          END_PARAMS  BEGIN_LOCALS declaration_block END_LOCALS BEGIN_BODY statement SEMICOLON statement_block END_BODY {

            out_code << "endfunc\n";
            symbol_table.clear();
            if (strcmp($2, "main")==0) {
              main_exists = 1;      
            }
            Func f($2);
            add_func(f);
            while (!param_stack.empty()) {
              param_stack.pop();
            }
          }
        ;

declaration_block:  
                 | declaration SEMICOLON declaration_block 
                 ;

statement_block: 
               | statement SEMICOLON statement_block 
               ;

declaration: IDENT comma_ident COLON INTEGER {
               ident_stack.push($1);
               param_stack.push($1);
               while(!ident_stack.empty()) {
                 string temp = ident_stack.top();
                 Sym sym(0,0,temp,INT); 
                 add_symbol(sym);
                 milhouse << ". " << temp << endl;
                 ident_stack.pop(); 
               }
             }
           | IDENT comma_ident COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
               ident_stack.push($1);
               param_stack.push($1);
               while(!ident_stack.empty()) {
                 string temp = ident_stack.top();
                 Sym sym(0,$6,temp,INTARRAY);
                 add_symbol(sym);
                 milhouse << ".[] " << temp << ", " << $6 << endl;
                 ident_stack.pop(); 
               }
             }
           ;

comma_ident: 
            | COMMA IDENT comma_ident {
               ident_stack.push($2);
               param_stack.push($2);
             }
           ;

statement: var ASSIGN expression {
             if ($1.type == 0) { //Check if var is an int
                 milhouse << "= " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
              
             }
             else { //Check if var is an int array
                 milhouse << "[]= " << const_cast<char*>($1.name) << ", " << const_cast<char*>($1.index) << ", " << const_cast<char*>($3.name) << endl;
             } 
             out_code << milhouse.rdbuf();
             milhouse.clear();
             milhouse.str(" ");
          }
         | IF bool_expr THEN {
             string start = make_label();
             string endif = make_label();
             label_stack.push(endif); 
             milhouse << "?:= " << start << ", " << const_cast<char*>($2.name) << endl;
             milhouse << ":= " << endif << endl;
             milhouse << ": " << start << endl;
           } 
           statement SEMICOLON statement_block else_block ENDIF {
             milhouse << ": " << label_stack.top() << endl;
             label_stack.pop();
             
             out_code << milhouse.rdbuf();
             milhouse.clear();
             milhouse.str(" ");

           }
          | WHILE bool_expr BEGINLOOP {

              string conditional = make_label();
              string endlabel = make_label();
              string start = make_label();
              out_code << ": " << start << endl;

              out_code << milhouse.rdbuf();
              milhouse.clear();
              milhouse.str(" ");
            
              milhouse << "?:= " << conditional << ", " << const_cast<char*>($2.name) << endl;
              milhouse << ":= " << endlabel << endl;
              milhouse << ": " << conditional << endl;

              label_stack.push(start);
              label_stack.push(endlabel);

            } statement SEMICOLON statement_block ENDLOOP {
                out_code << milhouse.rdbuf();
                milhouse.clear();
                milhouse.str(" ");

                string endlabel = label_stack.top();
                label_stack.pop();
                string start = label_stack.top();
                label_stack.pop();

                milhouse << ":= " << start << endl;
                milhouse << ": " << endlabel << endl;
 

                out_code << milhouse.rdbuf();
                milhouse.clear();
                milhouse.str(" ");
           }
          | DO BEGINLOOP {
             string start = make_label();
             label_stack.push(start);
             out_code << ": " << start << endl;
             out_code << milhouse.rdbuf();
             milhouse.clear();
             milhouse.str(" ");

            }
           statement SEMICOLON statement_block ENDLOOP WHILE bool_expr {
             string start = label_stack.top();
             milhouse << "?:= " << start << ", " << const_cast<char*>($9.name) << endl;
             label_stack.pop(); 
             
             out_code << milhouse.rdbuf();
             milhouse.clear();
             milhouse.str(" ");
           }
         | READ var var_block {
             var_stack.push($2.name);
             while (!var_stack.empty()) {
                if ($2.type == 0) {
                    milhouse << ".< " << var_stack.top() << endl;
                    var_stack.pop();
                }
                else {
                    milhouse << ".[]< " << var_stack.top() << ", "  <<  const_cast<char*>($2.index) << endl;
                    var_stack.pop();
                }
             }
             out_code << milhouse.rdbuf();
             milhouse.clear();
             milhouse.str(" ");
          } 
         | WRITE var var_block {
            var_stack.push($2.name);
            while (!var_stack.empty()) {
                if ($2.type == 0) {
                    milhouse << ".> " << var_stack.top() << endl;
                    var_stack.pop();
                }
                else {
                    milhouse << ".[]> " << var_stack.top() << ", "  <<  const_cast<char*>($2.index) << endl;
                    var_stack.pop();
                }
            }
            out_code << milhouse.rdbuf();
            milhouse.clear();
            milhouse.str(" ");
         }
         | CONTINUE {
             if (!label_stack.empty()) {
               milhouse << ":= " << label_stack.top() << endl;
               out_code << milhouse.rdbuf();
               milhouse.clear();
               milhouse.str(" ");
             }
             else {
               yyerror("error: cannot use continue outside a loop");
             }
           }
         | RETURN expression {
             $$.val = $2.val;
             strcpy($$.name,$2.name);
             milhouse << "ret " << const_cast<char*>($2.name) << endl;
             out_code << milhouse.rdbuf();
             milhouse.clear();
             milhouse.str(" ");
         }
         ;

else_block: 
          | ELSE {
              string label = make_label(); 
              milhouse << ":= " << label << endl;
              milhouse << ": " << label_stack.top() << endl;
              label_stack.pop();
              label_stack.push(label);
          } statement SEMICOLON statement_block           // need to finish shit
          ;

var_block:  
         | COMMA var var_block {
             var_stack.push($2.name);
           } 
         ;

bool_expr: bool_expr OR relation_and_expr {
             string temp = make_temp();
             strcpy($$.name, temp.c_str());
             milhouse << ". " << temp << endl;
             milhouse << "|| " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
           }
         | relation_and_expr {
             strcpy($$.name, $1.name);
           }
         ;

relation_and_expr: relation_and_expr AND relation_expr {
                    string temp = make_temp();
                    strcpy($$.name, temp.c_str());
                    milhouse << ". " << temp << endl;
                    milhouse << "&& " << temp << ", " << const_cast<char*>($1.name) << ", " <<  const_cast<char*>($3.name) << endl;
                   }
                 | relation_expr {
                       strcpy($$.name, $1.name);
                    }
                 ;

relation_expr: rel_expr {
                    strcpy($$.name, $1.name);
                } 
             | NOT rel_expr {
                    string temp = make_temp();
                    strcpy($$.name, temp.c_str());
                    milhouse << "! " << temp << const_cast<char*>($2.name) << endl;
                }
             ;

rel_expr: expression comp expression {
          string temp = make_temp();
          strcpy($$.name, temp.c_str());
          milhouse << ". " << temp << endl;
          milhouse << $2 << " " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
            }
        | TRUE {
            string temp = make_temp();
            strcpy($$.name, temp.c_str());
            milhouse << ". " << temp << endl;
            milhouse << "= " << temp << ", " << "1" << endl;
          }
        | FALSE {
            string temp = make_temp();
            strcpy($$.name, temp.c_str());
            milhouse << ". " << temp << endl;
            milhouse << "= " << temp << ", " << "0" << endl;
          }
        | L_PAREN bool_expr R_PAREN {
                strcpy($$.name, $2.name);
            }
        ;

comp: EQ { $$ = const_cast<char*>("=="); } 
    | NEQ { $$ = const_cast<char*>("!="); }
    | LT { $$ = const_cast<char*>("<"); }
    | GT { $$ = const_cast<char*>(">"); }
    | LTE { $$ = const_cast<char*>("<="); }
    | GTE { $$ = const_cast<char*>(">="); }
    ;

expression: expression ADD multiplicative_expr {
              string temp = make_temp();
              milhouse << ". " << temp << endl;
              milhouse << "+ " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
              strcpy($$.name, temp.c_str());
            }
          | expression SUB multiplicative_expr {
              string temp = make_temp();
              milhouse << ". " << temp << endl;
              milhouse << "- " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
              strcpy($$.name, temp.c_str());
            }
          |  multiplicative_expr {
              strcpy($$.name,$1.name);
              $$.type = $1.type;
             }
          ;

multiplicative_expr: multiplicative_expr MULT term {
                       string temp = make_temp();
                       milhouse << ". " << temp << endl;
                       milhouse << "* " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
                       strcpy($$.name, temp.c_str());
                     }
                   | multiplicative_expr DIV term {
                       string temp = make_temp();
                       milhouse << ". " << temp << endl;
                       milhouse << "/ " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
                       strcpy($$.name, temp.c_str());
                    }
                   | multiplicative_expr MOD term {
                       string temp = make_temp();
                       milhouse << ". " << temp << endl;
                       milhouse << "% " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
                       strcpy($$.name, temp.c_str());
                    }
                   | term{
                       strcpy($$.name,$1.name);
                       $$.type = $1.type;
                     }
                   ;

term: SUB var {
        $$.val = $2.val*-1;
        $$.type = $2.type;
        if ($2.type != 1) {// if int
          string zero = make_temp();
          string num = make_temp();
          milhouse << ". " << zero << endl;
          milhouse << "= " << zero << ", " << "0" << endl;
          milhouse << ". " << num << endl;
          milhouse << "= " << num << ", " << const_cast<char*>($2.name) << endl;
          strcpy($$.name,make_temp().c_str());
          milhouse << ". " << const_cast<char*>($$.name) << endl;
          milhouse << "- " << const_cast<char*>($$.name) <<  ", " << zero << ", " << num << endl;
         }        
        else if ($2.type == 1) { // if array
          //b = make_temp();
          string zero = make_temp();
          string num = make_temp();
          milhouse << ". " << zero << endl;
          milhouse << "= " << zero << ", " << "0" << endl;
          milhouse << ". " << num << endl;
          milhouse << ". " << num << endl;
          milhouse << "=[] " << num << ", " << const_cast<char*>($2.name) <<  ", " << const_cast<char*>($2.index) << endl;
          strcpy($$.name,make_temp().c_str());
          milhouse << ". " <<  const_cast<char*>($$.name)<< endl;
          milhouse << "- " << const_cast<char*>($$.name) << ", " << zero <<  ", " << num << endl;
        }

      }
    | var {
        $$.val = $1.val;
        $$.type = $1.type;
        if ($1.type != 1) {
          strcpy($$.name,make_temp().c_str());
          strcpy($$.index,$$.name);
          milhouse << ". " << const_cast<char*>($$.name) << endl;
          milhouse << "= " << const_cast<char*>($$.name) <<  ", " << const_cast<char*>($1.name) << endl;
        }
        else if ($1.type == 1) { // if array
          //b = make_temp();
          strcpy($$.name,make_temp().c_str());
          milhouse << ". " <<  const_cast<char*>($$.name)<< endl;
          milhouse << "=[] " << const_cast<char*>($$.name) << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($1.index) << endl;
        }

      }
    | SUB NUMBER {
        $$.val = $2*-1;
        // $$.type = 3;
        $$.type = 0;
        string zero = make_temp();
        string num = make_temp();
        milhouse << ". " << zero << endl;
        milhouse << "= " << zero << ", " << "0" << endl;
        milhouse << ". " << num << endl;
        milhouse << "= " << num << ", " << $2 << endl;

        strcpy($$.name, make_temp().c_str());
        milhouse << ". " << const_cast<char*>($$.name) << endl;
        milhouse << "- " << const_cast<char*>($$.name) <<  ", " << zero << ", "<< num << endl;
     }
    | NUMBER  {
        $$.val = $1;
        // $$.type = 3;
        $$.type = 0;

        strcpy($$.name, make_temp().c_str());
        strcpy($$.index,$$.name);
        milhouse << ". " << const_cast<char*>($$.name) << endl;
        milhouse << "= " << const_cast<char*>($$.name) <<  ", " << $$.val << endl;
      }
     | SUB L_PAREN expression R_PAREN {

       string zero = make_temp();

       milhouse << ". " << zero << endl;
       milhouse << "= " << zero << ", " << "0"<< endl;
        
       strcpy($$.name, make_temp().c_str());
       milhouse << ". " << const_cast<char*>($$.name) << endl;
       milhouse << "- " << const_cast<char*>($$.name) <<  ", " << zero << ", "<< const_cast<char*>($3.name) << endl;
      }
    | L_PAREN expression R_PAREN {
        strcpy($$.name, $2.name);
    }
    | IDENT L_PAREN expression exp_comma_block R_PAREN {
        check_func(const_cast<char*>($1));
        exp_stack.push($3.name); 
        while (!exp_stack.empty()){
          milhouse << "param " << exp_stack.top() << endl;
          exp_stack.pop();
        }
        string temp = make_temp();
        milhouse << ". " << temp << endl;
        milhouse << "call " << const_cast<char*>($1) << ", " << temp << endl;
        strcpy($$.name,temp.c_str());
      }
    | IDENT L_PAREN R_PAREN {
        check_func(const_cast<char*>($1));
        string temp = make_temp();
        milhouse << ". " << temp << endl;
        milhouse << "call " << const_cast<char*>($1) << ", " << temp << endl;
        strcpy($$.name,temp.c_str());
      }
    ;

exp_comma_block: COMMA expression exp_comma_block {
                   exp_stack.push($2.name); 
                 }
               |
               ;

var: IDENT {
       check_symbol($1);
       if(symbol_table[$1].type == INTARRAY) {
         yyerror("Symbol is of type int array");
       }
       else {
         strcpy($$.name,$1);
         $$.type = 0;
         //$$.val = symbol_table[$1].val;
       }
     }
   | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
       check_symbol($1);
       if(symbol_table[$1].type == INT) {
         yyerror("Symbol is of type int");
       }
       else {
         if ($3.type == 1) {
           string temp = make_temp();
           $$.type = 1;
           //strcpy($$.name, temp.c_str());
           strcpy($$.index, temp.c_str());
           strcpy($$.name, $1);

           milhouse << ". " << temp << endl; 
           milhouse << "=[] " << temp << ", " << const_cast<char*>($3.name) << ", " << const_cast<char*>($3.index) << endl;
         }
         else {
           strcpy($$.name, $1);
           $$.type = 1;
           //$$.val = symbol_table[$1].val;
           strcpy($$.index, $3.name);
         }
       }
     }
   ;

%%

int main (int argc, char **argv) {
  if (argc > 1) {
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
      printf("syntax: %s filename\n", argv[0]);
    }
  }
  yyparse();
  ofstream file;
  file.open("mil_code.mil");
  file << out_code.str();
  file.close();
  return 0;
}

void yyerror(const char *message) {
  printf("Syntax error on line %d: \"%s\" \n", currLine, message);
}

void yyerror(string message) {
  cout << "Syntax error on line " << currLine << ": " << message << endl;
}

void add_symbol(Sym s) {
  if (symbol_table.find(s.name) == symbol_table.end()) {
    symbol_table[s.name] = s;
  }
  else {
    string error = "Symbol already declared: " + s.name;
    yyerror(error);
  }
}

void add_func(Func f) {
  if (func_table.find(f.name) == func_table.end()) {
    func_table[f.name] = f;
  }
  else {
    string error = "error: function already declared: " + f.name;
    yyerror(error);
  }
}

void check_symbol(string name) {
  if(symbol_table.find(name) == symbol_table.end()) {
    string error = "Symbol not declared: " + name;
    yyerror(error);
  }
}

void check_func(string name) {
  if(func_table.find(name) == func_table.end()) {
    string error = "Function not declared: " + name;
    yyerror(error);
  }
}

void print_declarations() {
  for(map<string,Sym>::iterator it = symbol_table.begin(); it!=symbol_table.end();++it){
    if (it->second.type == INT) {
      milhouse << ". " << it->second.name << endl;
    }
    else {
      milhouse << ".[] " << it->second.name << ", " << it->second.size << endl;
    }
  }
}

string make_temp() {
  stringstream ss;
  ss << temp_cnt++;
  string temp = "__temp__" + ss.str();
  return temp;
}

string make_label() {
  stringstream ss;
  ss << label_cnt++;
  string temp = "__label__" + ss.str();
  return temp;
}
