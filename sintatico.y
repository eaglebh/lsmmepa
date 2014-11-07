%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "struct/symbol.h"
#include "struct/stack.h"

extern int yylex(void);
void yyerror(const char * format, ...);

extern char *yytext;

t_stack *ts;
t_stack *aux;
t_stack *parameters;
t_stack *labels;

t_symbol *symbol1 = NULL;
t_symbol *symbol2 = NULL;
t_symbol *symb_atr = NULL;
t_symbol *symb_proc = NULL;

int nl = -1;
int offset = 0;
int nvars;        // Número de variáveis locais
int nparam;        // Número do parâmetro
int label = 0;
int write = 0;  // Variável condicional para indicar o uso de write()
int read = 0;  // Variável condicional para indicar o uso de read()
int is_label = 0;

char *const_value = NULL;
int const_number = 0;
int integer_part = 0;
int fractional_part = 0;
int fractional_part_length = 0;
int coefficient = 0;
int exponent = 0;

#define MAXNUMSTR 10

int deb_line = 0;

#define gen_code(...) { deb_line = __LINE__; pgen_code(__VA_ARGS__); }

void pgen_code(const char * format, ...) {
    char buffer[256];
    va_list args;
    va_start (args, format);
    vsprintf (buffer,format, args);
    va_end (args);

    //printf ("%d %s",deb_line, buffer);
    printf ("%s", buffer);
}

int write_label(void) {
    int l = label;
    gen_code("R%03d", label);
    label++;
    return l;
}
%}

%define parse.error verbose

%start program
%token PLUS MINUS TIMES SLASH LPAREN RPAREN SEMICOLON COMMA DOT;
%token ASSIGNOP COLON EQL NEQ LSS GTR LEQ GEQ AND DIV OR NOT;
%token LBRACKET RBRACKET ARRAY OF GOTO PROGRAM DECLARE END;
%token PROCEDURE IF THEN ELSE UNTIL WHILE DO;
%token TYPE WRITE READ IDENT;
%token NUMBER TRUE FALSE STRING UNKNOWN;
%token INTEGER REAL BOOLEAN CHAR LABEL RETURN;

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%

program:
    PROGRAM
    {
        gen_code("\tINPP\n");
    }
    identifier
    {
        symbol1 = symbol_create(strdup(yytext), nl, offset); stack_push(aux, symbol1);
    }
    proc_body
    {
        gen_code("\tPARA\n");
    }
;

proc_body       : block_stmt ;

block_stmt:
    {nl++; }
    DECLARE
    decl_list
    DO
    stmt_list
    {
        nvars = 0;

        while (symbol1 = stack_first(ts)) {
            if (symbol1->cat == C_PROCEDURE && symbol1->nl == nl) {
                break;
            }
            if (symbol1->nl != nl) {
                break;
            }

            stack_pop(ts);
            if (symbol1->cat == C_VARIABLE)
                nvars++;
        }
        if (nvars)
            gen_code("\tDMEM %d\n", nvars);
        if (symbol1) {
            gen_code("\tRTPR %d, %d\n", nl, symbol1->nParameter);
        }
        nl--;
    }
    END
    |
    {nl++; }
    DO
    stmt_list
    {
        nvars = 0;

        while (symbol1 = stack_first(ts)) {
            if (symbol1->cat == C_PROCEDURE && symbol1->nl == nl) {
                break;
            }
            if (symbol1->nl != nl) {
                break;
            }

            stack_pop(ts);
            if (symbol1->cat == C_VARIABLE)
                nvars++;
        }
        if (nvars)
            gen_code("\tDMEM %d\n", nvars);
        if (symbol1) {
            gen_code("\tRTPR %d, %d\n", nl, symbol1->nParameter);
        }
        nl--;
    }
    END
;

decl_list   : decl 
            | decl_list SEMICOLON decl ;

decl        :
            {
                while (symbol1 = stack_pop(aux));
                offset = 0;
            } 
            variable_decl
            {
                gen_code("\tDSVS ");
                symbol1 = symbol_create_label(write_label());
                gen_code("\n");
                stack_push(labels, symbol1);
            }
            |   
            { 
                nl++; offset = 0; 
            }
            proc_decl
            { 
                nl--; 
                symbol1 = stack_pop(labels);
                if(symbol1)
                    gen_code("R%03d:\tNADA\n", symbol1->label);
            }

variable_decl:    
    type ident_list 
    {
        if (aux->size)
            gen_code("\tAMEM %d\n", aux->size);

        nvars = aux->size;
        while (symbol1 = stack_pop(aux)) {
            symbol1->cat = C_VARIABLE;
            stack_push(ts, symbol1);
        }
    }
    ;

ident_list:
    identifier
    {
        if (symbol2 && symbol2->nl == nl) {
            yyerror("Variável já declarada.");
        }

        if (is_label) {
            symbol1 = symbol_create_label(label);
            label++;
            strcpy(symbol1->id, strdup(yytext));
            stack_push(ts, symbol1);
        } else {
            symbol1 = symbol_create(strdup(yytext), nl, offset);
            offset++;
            stack_push(aux, symbol1);
        }
    }
    | ident_list COMMA 
        identifier 
        {
            if (symbol2 && symbol2->nl == nl)
                yyerror("Variável já declarada.");

            if (is_label) {
                symbol1 = symbol_create_label(label);
                label++;
                strcpy(symbol1->id, strdup(yytext));
                stack_push(ts, symbol1);
            } else {
                symbol1 = symbol_create(strdup(yytext), nl, offset);
                offset++;
                stack_push(aux, symbol1);
            }
        }
;

type            : { is_label = 0; } simple_type
                | { is_label = 0; } array_type
;

simple_type     : INTEGER
                | REAL
                | BOOLEAN
                | CHAR
                | { is_label = 1; } LABEL ;

array_type      : ARRAY unsigned_integer OF simple_type;

proc_decl   : proc_header
            {nl--;}
            block_stmt
            {nl++;}
;

proc_header: 
    PROCEDURE
    {
        write_label();
        gen_code(":\tENPR %d\n", nl);
    }
    identifier
    {
        if (symbol1 && symbol1->nl == nl)
             yyerror("Procedimento já declarado.");

        symb_proc = symbol_create_procedure(strdup(yytext));
        symb_proc->nl = nl;
        symb_proc->label = label - 1;
    }
    parametros_formais_opcional
    {
        symb_proc->nParameter = parameters->size;
        symb_proc->parameters = malloc(sizeof(int) * symb_proc->nParameter);
        int i;

        i = symb_proc->nParameter - 1;
        offset = -4;
        stack_push(ts, symb_proc);
        while (symbol1 = stack_pop(parameters)) {
            symbol1->offset = offset;
            offset--;
            stack_push(ts, symbol1);
            symb_proc->parameters[i] = symbol1->passage;
            i--;
        }
        symb_proc = NULL;
        offset = 0;
    }

/*proc_header     : PROCEDURE  identifier  
                | PROCEDURE identifier OPEN_PARENS formal_list CLOSE_PARENS ;

formal_list     : parameter_decl  
                | formal_list SEMI_COLON parameter_decl ;
*/

parametros_formais_opcional:
    | formal_list
;

formal_list:
    LPAREN parameter_decl parametros_formais_loop RPAREN
;

parametros_formais_loop:
    {
        if (symbol2 && symbol2->nl == nl)
            yyerror("Variável já declarada.");
    }
    | SEMICOLON parameter_decl parametros_formais_loop
;

parameter_decl:
    parameter_type identifier
    {
        symbol1 = symbol_create(strdup(yytext), nl, offset);
        offset++;
        stack_push(aux, symbol1);

        symbol1->cat = C_PARAMETER;
        symbol1->passage = P_VALUE;
        stack_push(parameters, symbol1);
    }
;

parameter_type  : type 
                | proc_signature ;

proc_signature  : PROCEDURE identifier LPAREN type_list RPAREN
                | PROCEDURE identifier ;

type_list       : parameter_type 
                | type_list COMMA parameter_type ;

stmt_list:      stmt
                | stmt_list SEMICOLON stmt ;

stmt:           identifier 
                {
            //        symbol1 = stack_find(ts, yytext);
                    symbol1->nl = nl;
                    if (symbol1) {
                        gen_code("R%03d:\tENRT %d %d\n", symbol1->label, nl, nvars);
                    } else {
                        yyerror("label não declarado.\n");
                    }
                } COLON unlabelled_stmt
                | unlabelled_stmt
;

label           : identifier;

unlabelled_stmt:assign_stmt
                | if_stmt
                | {
                    symbol1 = symbol_create("", 0, 0);
                    symbol1->label = write_label();
                    gen_code(":\tNADA\n");
                    stack_push(labels, symbol1);
                } loop_stmt 
                | read_stmt
                | write_stmt
                | goto_stmt
                | proc_stmt
                | return_stmt 
                | block_stmt
;

assign_stmt:
    variable
    {
        symb_atr = symbol_cpy(symb_atr, symbol1);
    }
    ASSIGNOP expression
    {
        if (!symb_atr)
            yyerror("variable nao declarada.");

        if (symb_atr->cat == C_PARAMETER && symb_atr->passage == P_ADDRESS) {
            gen_code("\tARMI %d, %d # %s\n", symb_atr->nl, symb_atr->offset, symb_atr->id);
        } else
            gen_code("\tARMZ %d, %d # %s\n", symb_atr->nl, symb_atr->offset, symb_atr->id);
    }
;

variable:
    identifier
    | array_element
;

variable_list   :
    {
        if (read) {
            gen_code("\tLEIT\n");
        }
    }
    variable
    {
        if (read) {
            if (!symbol1)
                yyerror("variable nao declarada.");
            if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS) {
                gen_code("\tARMI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            } else
                gen_code("\tARMZ %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
        }
    }
    | variable_list COMMA 
    {
        if (read) {
            gen_code("\tLEIT\n");
        }
    }
    variable
    {
        if (read) {
            if (!symbol1)
                yyerror("variable nao declarada.");
            if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS) {
                gen_code("\tARMI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            } else
                gen_code("\tARMZ %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
        }
    }
;

array_element   : identifier LBRACKET expression RBRACKET ;

if_stmt:
    IF condition
    THEN stmt_list
    {
        symbol1 = symbol_create("", 0, 0);
        gen_code("\tDSVS ");
        symbol1->label = write_label();
        gen_code("\n");
        symbol2 = stack_pop(labels);
        gen_code("R%03d:\tNADA\n", symbol2->label);
        stack_push(labels, symbol1);
    }
    %prec LOWER_THAN_ELSE
    {
        symbol1 = stack_pop(labels);
        gen_code("R%03d:\tNADA\n", symbol1->label);
    }
    END
    |
    IF condition
    THEN stmt_list
    {
        symbol1 = symbol_create("", 0, 0);
        gen_code("\tDSVS ");
        symbol1->label = write_label();
        gen_code("\n");
        symbol2 = stack_pop(labels);
        gen_code("R%03d:\tNADA\n", symbol2->label);
        stack_push(labels, symbol1);
    }
    ELSE stmt_list
    {
        symbol1 = stack_pop(labels);
        gen_code("R%03d:\tNADA\n", symbol1->label);
    }
    END
;

condition: 
    expression 
    {
        symbol1 = symbol_create("", 0, 0);
        gen_code("\tDSVF ");
        symbol1->label = write_label();
        gen_code("\n");
        stack_push(labels, symbol1);
    }
;

loop_stmt:  WHILE condition DO stmt_list 
            {
                symbol1 = stack_pop(labels);
                symbol2 = stack_pop(labels);
                gen_code("\tDSVS r%02d\n", symbol2->label);
                gen_code("R%03d:\tNADA\n", symbol1->label);
            } 
            END
            |
            DO stmt_list 
            {
                symbol1 = stack_pop(labels);
                symbol2 = stack_pop(labels);
                gen_code("\tDSVS r%02d\n", symbol2->label);
                gen_code("R%03d:\tNADA\n", symbol1->label);
            } 
            UNTIL condition;

read_stmt:      
    READ 
    {
        read = 1;
    }
    LPAREN variable_list RPAREN 
    {
        read = 0;
    }
;

write_stmt:
    WRITE
    {
        write = 1;
    }
    LPAREN expr_list RPAREN
    {
        write = 0;
    }
;

goto_stmt:
    GOTO label
    {
        if (symbol1) {
            gen_code("\tDSVR r%02d, %d, %d\n", symbol1->label, symbol1->nl, nl);
        } else {
            yyerror("label não declarado.\n");
        }
    }
;

proc_stmt:
    identifier
    {
        if (!symbol1)
            yyerror("procedimento não declarado");

        symb_proc = symbol_cpy(symb_proc, symbol1);
        nparam = 0;
    }
    lista_de_expressoes_opcional
    {
        gen_code("\tCHPR R%03d, %d\n", symb_proc->label, nl);
        symb_proc = NULL;
    }
;

lista_de_expressoes_opcional:
    | LPAREN expr_list RPAREN
;

return_stmt     : RETURN;

expr_list:
    expression
    {
        if (write)
            gen_code("\tIMPR\n");
    }
    |
    expr_list COMMA
    expression
    {
        if (write)
            gen_code("\tIMPR\n");
    }
;


expression:
    simple_expr
    | simple_expr EQL simple_expr { gen_code("\tCMIG\n"); }
    | simple_expr NEQ simple_expr { gen_code("\tCMDG\n"); }
    | simple_expr LSS simple_expr { gen_code("\tCMME\n"); }
    | simple_expr GTR simple_expr { gen_code("\tCMMA\n"); }
    | simple_expr LEQ simple_expr { gen_code("\tCMEG\n"); }
    | simple_expr GEQ simple_expr { gen_code("\tCMAG\n"); }
;

simple_expr:
    term simple_expr_loop
    | PLUS  term simple_expr_loop
    | MINUS term { gen_code("\tINVR\n"); } simple_expr_loop
;

simple_expr_loop:
    | PLUS  term { gen_code("\tSOMA\n"); } simple_expr_loop
    | MINUS term { gen_code("\tSUBT\n"); } simple_expr_loop
    | OR     term { gen_code("\tDISJ\n"); } simple_expr_loop
;

term:
    factor_a term_loop
;

term_loop:
    | TIMES factor_a { gen_code("\tMULT\n"); } term_loop
    | DIV    factor_a { gen_code("\tDIVI\n"); } term_loop
    | AND    factor_a { gen_code("\tCONJ\n"); } term_loop
;

factor_a:   factor 
            | NOT factor { gen_code("\tNEGA\n"); }
;

factor:
    variable
    {
//        symbol1 = stack_find(ts, yytext);
        if (!symbol1)
            yyerror("variável não declarada %s.", yytext);

        if (symb_proc && nparam >= symb_proc->nParameter)
            yyerror("procedimento %s chamado com número inválido de parâmetros %d de %d.", symb_proc->id, nparam, symb_proc->nParameter);

        if (symb_proc && symb_proc->parameters[nparam] == P_ADDRESS) {
            if (symbol1->cat == C_VARIABLE) {
                gen_code("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            }else if (symbol1->cat == C_PARAMETER) {
                if (symbol1->passage == P_VALUE) {
                    gen_code("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                } else { 
                    if (symbol1->passage == P_ADDRESS) {
                        gen_code("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                    }
                }
            }
            nparam++;
        } else {
            if (symbol1->cat == C_VARIABLE){
                gen_code("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            } else {
                if (symbol1->cat == C_PARAMETER) {
                    if (symbol1->passage == P_VALUE){
                        gen_code("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                    } else {
                        if (symbol1->passage == P_ADDRESS) {
                            gen_code("\tCRVI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                        }
                    }
                }
            }
        }
    }
    | constant
    {
        if (symb_proc && symb_proc->parameters[nparam] == P_ADDRESS)
            yyerror("parâmetro inteiro passado por referência.");
        if (symb_proc && nparam >= symb_proc->nParameter)
            yyerror("procedimento chamado com número inválido de parâmetros.");

        gen_code("\tCRCT %s\n", const_value);
    }
    | LPAREN expression RPAREN    
;

constant        : integer_constant 
                | real_constant 
                | char_constant 
                | boolean_constant ;

boolean_constant: FALSE { const_value = "0"; }
                | TRUE { const_value = "1"; } ;

integer_constant: unsigned_integer ;

unsigned_integer: NUMBER { const_value = strdup(yytext); const_number = strtol(const_value, NULL, 10); } ;

real_constant   : unsigned_real;

unsigned_real   : unsigned_integer 
                    DOT  
                    { 
                        integer_part = const_number; 
                    } 
                    unsigned_integer 
                    { 
                        fractional_part = const_number; 
                        fractional_part_length = strlen(const_value); 
                        coefficient = integer_part + (fractional_part/(10^fractional_part_length)); 
                    } 
                    scale_factor { snprintf(const_value, MAXNUMSTR, "%d", coefficient*(10^exponent)); }
                | unsigned_integer
                    DOT  
                    { 
                        integer_part = const_number; 
                    } 
                    unsigned_integer 
                    { 
                        fractional_part = const_number; 
                        fractional_part_length = strlen(const_value); 
                        coefficient = integer_part + (fractional_part/(10^fractional_part_length)); 
                        snprintf(const_value, MAXNUMSTR, "%d", coefficient);
                    }
                | unsigned_integer { coefficient = const_number; } 
                    scale_factor { snprintf(const_value, MAXNUMSTR, "%d", coefficient*(10^exponent)); } ;

scale_factor    : "E" PLUS unsigned_integer { exponent = const_number; }
                | "E" MINUS unsigned_integer { exponent = -const_number; } ;

char_constant   : STRING { const_value = strdup(yytext); } ;                

identifier:
    IDENT
    {
        symbol1 = stack_find(ts, yytext);
        symbol2 = stack_find(aux, yytext);
    }
;

%%

void yyerror(const char * format, ...) {
    char buffer[256];
    va_list args;
    va_start (args, format);
    vsprintf (buffer,format, args);
    va_end (args);

    fprintf (stderr, "erro: %s\n",buffer);

    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
    ts = stack_create();
    aux  = stack_create();
    parameters = stack_create();
    labels = stack_create();

    if (argc > 1)
        stdin = fopen(argv[1], "r");

    if (stdin) {
        yyparse();
    } else {
        printf("Erro de leitura no arquivo de entrada ou arquivo inexistente\n");
    }

    if (argc > 1 && stdin)
        fclose(stdin);
}
