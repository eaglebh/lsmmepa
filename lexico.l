%{
#include <stdio.h>
#include "_sintatico.h"
%}

digit         [0-9]
letter        [a-zA-Z_]

%%

"+"                  { return PLUS;       }
"-"                  { return MINUS;      }
"*"                  { return TIMES;      }
"("                  { return LPAREN;     }
")"                  { return RPAREN;     }
";"                  { return SEMICOLON;  }
","                  { return COMMA;      }
".."                 { return PERIOD2;    }
"."                  { return PERIOD;     }
":="                 { return BECOMES;    }
":"                  { return COLON;      }
"="                  { return EQL;        }
"<>"                 { return NEQ;        }
"<"                  { return LSS;        }
">"                  { return GTR;        }
"<="                 { return LEQ;        }
">="                 { return GEQ;        }
"["                  { return LBRACKET;   }
"]"                  { return RBRACKET;   }
"and"                { return AND;        }
"div"                { return DIV;        }
"or"                 { return OR;         }
"not"                { return NOT;        }

"goto"               { return GOTO;      }
"of"                 { return OF;        }
"array"              { return ARRAY;     }
"program"            { return PROGRAM;   }
"declare"            { return DECLARE;       }
"begin"              { return T_BEGIN;   }
"end"                { return END;       }
"function"           { return FUNCTION;  }
"procedure"          { return PROCEDURE; }
"if"                 { return IF;        }
"then"               { return THEN;      }
"else"               { return ELSE;      }
"while"              { return WHILE;     }
"do"                 { return DO;        }
"label"              { return LABEL;     }
"type"               { return TYPE;      }
"write"              { return WRITE;     }
"read"               { return READ;      }
"call"               { return CALL;      }

{digit}+             { return NUMBER;    }

{letter}({letter}|{digit})* { return IDENT; }

\(\*[^\*][^\)]*\*\) { printf("Comentário: \"%s\"\n", yytext); }

[ \t\n]+

.                   { printf("Inválido: \"%s\"\n", yytext); }

%%

int yywrap(){
  return 1;
}
