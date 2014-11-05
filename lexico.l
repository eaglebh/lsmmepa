%{
#include <stdio.h>
#include "_sintatico.h"
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
DISCARD 	[\t \n]+
PRINTED		'[^'\n]*'

%%
{DISCARD}
{PRINTED} 			 		{ return STRING;    }
"program"            		{ return PROGRAM;   }
{DIGIT}+             		{ return NUMBER;    }
"if"                 		{ return IF;        }
"while"              		{ return WHILE;     }
"do"                 		{ return DO;        }
"label"              		{ return LABEL;     }
"declare"            		{ return DECLARE;   }
"end"                		{ return END;       }
"integer"			 		{ return INTEGER;   } 
"real" 				 		{ return REAL; 	 	} 
"boolean" 			 		{ return BOOLEAN;   } 
"char" 				 		{ return CHAR; 	 	}
"array"              		{ return ARRAY;     }
"of"                 		{ return OF;        }
"procedure"          		{ return PROCEDURE; }
"then"               		{ return THEN;      }
"else"               		{ return ELSE;      }
"until" 					{ return UNTIL; 	}
"read"               		{ return READ;      }
"write"              		{ return WRITE;     }
"goto"               		{ return GOTO;      }
"not"                		{ return NOT;       }
"or"                 		{ return OR;        }
"and"                		{ return AND;       }
"false"              		{ return FALSE;     }
"true"               		{ return TRUE;      }
":="                 		{ return ASSIGNOP;  }
"="                  		{ return EQL;       }
"!="                 		{ return NEQ;       }
"<"                  		{ return LSS;       }
">"                  		{ return GTR;       }
"<="                 		{ return LEQ;       }
">="                 		{ return GEQ;       }
"+"                  		{ return PLUS;      }
"-"                  		{ return MINUS;     }
"*"                  		{ return TIMES;     }
"/"                  		{ return DIV;       }
"("                  		{ return LPAREN;    }
")"			                { return RPAREN;    }
";"                 		{ return SEMICOLON; }
","         		        { return COMMA;     }
"." 		                { return DOT;       }
":"                 		{ return COLON;     }
"["							{ return LBRACKET;  }
"]"          		        { return RBRACKET;  }

{LETTER}({LETTER}|{DIGIT})* { return IDENT; 	}

.                   { printf("Inválido: \"%s\"\n", yytext); return UNKNOWN; }

%%

int yywrap(){
  return 1;
}