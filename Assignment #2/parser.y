%{
#include <iostream>
#include <map>

#include "parser.hpp"

std::map<std::string, float> symbols;

bool _error = false;

std::string* code;


void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
%}

%union {
  float value;
  std::string* str;
  int token;
}

/* %define api.value.type { std::string* } */
%locations

%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER FLOAT
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> NEWLINE LPAREN RPAREN COLON INDENT DEDENT
%token <token> EQ NEQ GT GTE LT LTE NOT AND OR
%token <token> IF ELSE ELIF TRUE FALSE BREAK WHILE

%type <str> expression statement program condition else

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */
/* %precedence */

%start program

%%



program
  : program statement {$$ = new std::string(*$1 + *$2); code = $$;}
  | statement {$$ = new std::string(*$1); code = $$;}
  ;

statement
  : IDENTIFIER ASSIGN expression NEWLINE { symbols[*$1] = 1.0; $$ = new std::string(*$1 + "=" + *$3 + ";" + "\n");}
  | IF condition COLON NEWLINE INDENT program DEDENT else{ $$ = new std::string("if(" + *$2 + "){\n" + *$6 + "}\n" + *$8);}
  | WHILE condition COLON NEWLINE INDENT program DEDENT{$$ = new std::string("while(" + *$2 + "){\n" + *$6 + "}\n");}
  | BREAK NEWLINE {$$ = new std::string("break;\n");}
  | error NEWLINE { std::cerr << "Error: bad statement" << std::endl; _error = true; }
  ;

else
  : ELSE COLON NEWLINE INDENT program DEDENT {$$ = new std::string("else{\n" + *$5 + "}\n");}
  | ELIF condition COLON NEWLINE INDENT program DEDENT else {$$ = new std::string("else if(" + *$2 + "){\n" + *$6 + "}\n");}
  | %empty {$$ = new std::string("");}
  ;

condition
  : LPAREN condition RPAREN {$$ = new std::string( "(" + *$2 + ")" );}
  | condition EQ condition {$$ = new std::string(*$1 + "==" + *$3);}
  | condition NEQ condition {$$ = new std::string(*$1 + "!=" + *$3);}
  | condition GT condition {$$ = new std::string(*$1 + ">" + *$3);}
  | condition GTE condition {$$ = new std::string(*$1 + ">=" + *$3);}
  | condition LT condition {$$ = new std::string(*$1 + "<" + *$3);}
  | condition LTE condition {$$ = new std::string(*$1 + "<=" + *$3);}
  | condition AND condition {$$ = new std::string(*$1 + "&&" + *$3);}
  | condition OR condition {$$ = new std::string(*$1 + "||" + *$3);}
  | NOT condition {$$ = new std::string("!" + *$2);}
  | FLOAT {$$ = new std::string(*$1);}
  | IDENTIFIER {$$ = new std::string(*$1);}
  | TRUE {$$ = new std::string("true");}
  | FALSE {$$ = new std::string("false");}
  ;

expression
  : LPAREN expression RPAREN { $$ = new std::string( "(" + *$2 + ")" ); }
  | expression PLUS expression { $$ = new std::string(*$1 + "+" + *$3); }
  | expression MINUS expression { $$ = new std::string(*$1 + "-" + *$3); }
  | expression TIMES expression { $$ = new std::string(*$1 + "*" + *$3); }
  | expression DIVIDEDBY expression { $$ = new std::string(*$1 + "/" + *$3); }
  | FLOAT { $$ = new std::string(*$1); }
  | IDENTIFIER { $$ = new std::string(*$1); } 
  | TRUE{$$ = new std::string("true");}
  | FALSE{$$ = new std::string("false");}
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;
}
