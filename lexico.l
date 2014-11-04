%{
#include <stdio.h>
#include "_sintatico.h"
%}

DIGIT         [0-9]
LETTER        [a-zA-Z_]
DISCARD [\t \n]+
PRINTED '[^'\n]*'

%%
{DISCARD}
"program"            { return PROGRAM;   }
"declare"            { return DECLARE;   }
"end"                { return END;       }
"procedure"          { return PROCEDURE; }
"if"                 { return IF;        }
"then"               { return THEN;      }
"else"               { return ELSE;      }
"while"              { return WHILE;     }
"do"                 { return DO;        }
"integer"			 { return INTEGER;   } 
"real" 				 { return REAL; 	 } 
"boolean" 			 { return BOOLEAN;   } 
"char" 				 { return CHAR; 	 }
"label"              { return LABEL;     }
"+"                  { return PLUS;      }
"-"                  { return MINUS;     }
"*"                  { return TIMES;     }
"("                  { return LPAREN;    }
")"                  { return RPAREN;    }
";"                  { return SEMICOLON; }
","                  { return COMMA;     }
"."                  { return DOT;       }
":="                 { return ASSIGNOP;  }
":"                  { return COLON;     }
"="                  { return EQL;       }
"!="                 { return NEQ;       }
"<"                  { return LSS;       }
">"                  { return GTR;       }
"<="                 { return LEQ;       }
">="                 { return GEQ;       }
"["                  { return LBRACKET;  }
"]"                  { return RBRACKET;  }
"and"                { return AND;       }
"/"                  { return DIV;       }
"or"                 { return OR;        }
"not"                { return NOT;       }
"goto"               { return GOTO;      }
"of"                 { return OF;        }
"array"              { return ARRAY;     }
"write"              { return WRITE;     }
"read"               { return READ;      }
"false"              { return FALSE;     }
"true"               { return TRUE;      }

{DIGIT}+             { return NUMBER;    }

{PRINTED} 			 { return STRING;    }

{LETTER}({LETTER}|{DIGIT})* { return IDENT; }

.                   { printf("Inválido: \"%s\"\n", yytext); return UNKNOWN; }

%%

int yywrap(){
  return 1;
}
