%{
#include <iostream>
#include <vector>
#include <stack>
#include <math.h>
#include <iomanip>

struct _word {
  std::string lexeme;
  std::string category;
};

std::vector<struct _word> _words;
std::stack<std::size_t> _indent;
bool _error = false;
bool _linestart = true;




void _save_word(const std::string& lexeme, const std::string& category) {
  struct _word _word = {
    .lexeme = lexeme,
    .category = category
  };
  _words.push_back(_word);
}

%}

%option noyywrap
%option yylineno

%%

%{
  _indent.push(0);
  /* No code to put at the top of yylex(). */
%}

([ \t]*)?#[^\n]*\n {}

[ \t]*     {
            if(_linestart){
              size_t top_leng = _indent.top();
              if(yyleng > top_leng){
                  _indent.push(yyleng);
                  _save_word("", "INDENT");
                }
              else if(yyleng < top_leng){
                while(yyleng < top_leng){
                  _indent.pop();
                  _save_word("", "DEDENT");
                  top_leng = _indent.top();
                }
              }
            }
              _linestart = false;
            } 

^\n         {


            }
            

"\n"       { 
            if(_linestart){
              size_t top_leng = _indent.top();
              if(yyleng < top_leng){
                  while(yyleng < top_leng){
                  _indent.pop();
                  _save_word("", "DEDENT");
                  top_leng = _indent.top();
                }
              }
            }
            else{
                  _save_word("", "NEWLINE"); 
                  _linestart = true;
                }
            }

"True"        { _save_word("1", "BOOLEAN");
                _linestart = false;
               }
"False"        { _save_word("0", "BOOLEAN"); 
                _linestart = false;
                }

"and"           { _save_word(yytext, "AND"); 
                _linestart = false;
                }
"break"           { _save_word(yytext, "BREAK"); 
                    _linestart = false;
                    }
"def"           { _save_word(yytext, "DEF"); 
                  _linestart = false;
                  }
"elif"           { _save_word(yytext, "ELIF"); 
                  _linestart = false;
                  }
"else"           { _save_word(yytext, "ELSE"); 
                  _linestart = false;
                  }
"for"           { _save_word(yytext, "FOR"); 
                  _linestart = false;
                  }
"if"            { 
                  if(_linestart){
                  size_t top_leng = _indent.top();
                  while(top_leng != 0){
                    _indent.pop();
                    _save_word("", "DEDENT");
                    top_leng = _indent.top();
                  }
                }
                  _save_word(yytext, "IF"); 
                  _linestart = false;
                  }
"not"           { _save_word(yytext, "NOT"); 
                  _linestart = false;
                  }
"or"           { _save_word(yytext, "OR"); 
                  _linestart = false;
                  }
"return"           { _save_word(yytext, "RETURN"); 
                    _linestart = false;
                    }
"while"           { 
                  if(_linestart){
                  size_t top_leng = _indent.top();
                  while(top_leng != 0){
                    _indent.pop();
                    _save_word("", "DEDENT");
                    top_leng = _indent.top();
                  }
                  }
                  _save_word(yytext, "WHILE"); 
                  _linestart = false;
                  
                  }

(_|[a-z])+(_*[a-z]*)*[0-9]*   {
                if(_linestart){
                  size_t top_leng = _indent.top();
                  while(top_leng != 0){
                    _indent.pop();
                    _save_word("", "DEDENT");
                    top_leng = _indent.top();
                  }
                }
                _save_word(yytext, "IDENTIFIER");
                _linestart = false;
              }

-*([0-9])+      { _save_word(yytext, "INTEGER"); 
                  _linestart = false;
                  }



-*([0-9])+"."([0-9])* { _save_word(yytext, "FLOAT"); 
                        _linestart = false;
                        }




"="           { _save_word(yytext, "ASSIGN"); 
                _linestart = false;
                }
"=="           { _save_word(yytext, "EQ");
                _linestart = false;
                 }
"!="           { _save_word(yytext, "NEQ"); 
                _linestart = false;
                }
">"           { _save_word(yytext, "GT"); 
                _linestart = false;
                }
">="           { _save_word(yytext, "GTE"); 
                _linestart = false;
                }
"<"           { _save_word(yytext, "LT"); 
                _linestart = false;
                }
"<="           { _save_word(yytext, "LTE"); 
                _linestart = false;
                }
"+"           { _save_word(yytext, "PLUS"); 
                _linestart = false;
                }
"-"           { _save_word(yytext, "MINUS"); 
                _linestart = false;
                }
"*"           { _save_word(yytext, "TIMES"); 
                  _linestart = false;
              }
"/"           { _save_word(yytext, "DIVIDEDBY"); 
                _linestart = false;
                }
"("           { _save_word(yytext, "LPAREN"); 
                _linestart = false;
                }
")"           { _save_word(yytext, "RPAREN"); 
                _linestart = false;
                }
","           { _save_word(yytext, "COMMA"); 
                _linestart = false;
                }
":"           { _save_word(yytext, "COLON"); 
              _linestart = false;
              }

.             {
                std::cerr << "Invalid symbol on line " << yylineno
                  << ": " << yytext << std::endl;
                _error = true;
              }

<<EOF>>       {
              size_t top_leng = _indent.top();
              if(yyleng < top_leng){
                  while(yyleng < top_leng){
                  _indent.pop();
                  _save_word("", "DEDENT");
                  top_leng = _indent.top();
                }
              }
                if (_error) {
                  return 1;
                }
                return 0;
              }


%%

int main() {
  if (!yylex()) {
    std::vector<struct _word>::iterator wit;
    for (wit = _words.begin(); wit != _words.end(); ++wit) {
      std::cout << std::left << std::setw(20) << wit->category << std::setw(20) << wit->lexeme << std::endl;
    }
  }
}
