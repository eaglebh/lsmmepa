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
t_symbol *symb_func = NULL;

int nl = -1;
int offset = 0;
int nvars;        // Número de variáveis locais
int nparam;        // Número do parâmetro
int label = 0;
int write = 0;  // Variável condicional para indicar o uso de write()

int write_label(void) {
    int l = label;
    printf("R%03d", label);
    label++;
    return l;
}
%}

%define parse.error verbose

%token PLUS;
%token MINUS;
%token TIMES;
%token SLASH;
%token LPAREN;
%token RPAREN;
%token SEMICOLON;
%token COMMA;
%token PERIOD;
%token BECOMES;
%token COLON;
%token EQL;
%token NEQ;
%token LSS;
%token GTR;
%token LEQ;
%token GEQ;
%token AND;
%token DIV;
%token OR;
%token NOT;
%token PERIOD2;
%token LBRACKET;
%token RBRACKET;
%token ARRAY
%token OF;
%token GOTO;
%token PROGRAM;
%token DECLARE;
%token T_BEGIN;
%token END;
%token FUNCTION;
%token PROCEDURE;
%token IF;
%token THEN;
%token ELSE;
%token WHILE;
%token DO;
%token LABEL;
%token TYPE;
%token WRITE;
%token READ;
%token CALL;
%token IDENT;
%token NUMBER;
%token TRUE;
%token FALSE;
%token STRING;

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%

programa:
    PROGRAM
    {
        printf("\tINPP\n");
    }
    identificador
    {
        symbol1 = symbol_create(strdup(yytext), nl, offset); stack_push(aux, symbol1);
    }
    bloco
    {
        printf("\tPARA\n");
    }
;

bloco:
    {nl++; }
    DECLARE
    decl_list    
    comando_composto
    {
        nvars = 0;

        while (symbol1 = stack_first(ts)) {
            if ((symbol1->cat == C_PROCEDURE || 
                symbol1->cat == C_FUNCTION) && 
                    symbol1->nl == nl) {
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
            printf("\tDMEM %d\n", nvars);
        if (symbol1) {
            printf("\tRTPR %d, %d\n", nl, symbol1->nParameter);
        }
        nl--;
    }
    |
    {nl++; }
    comando_composto
    {
        nvars = 0;

        while (symbol1 = stack_first(ts)) {
            if ((symbol1->cat == C_PROCEDURE || 
                symbol1->cat == C_FUNCTION) && 
                    symbol1->nl == nl) {
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
            printf("\tDMEM %d\n", nvars);
        if (symbol1) {
            printf("\tRTPR %d, %d\n", nl, symbol1->nParameter);
        }
        nl--;
    }
;

decl_list       : declaracoes_opcionais 
                | decl_list SEMICOLON declaracoes_opcionais ;

declaracoes_opcionais:
    |  
    parte_de_declaracoes_opcionais
    {
        printf("\tDSVS ");
        symbol1 = symbol_create_label(write_label());
        printf("\n");
        stack_push(labels, symbol1);
    }
    |   
    parte_de_declaracao_de_subrotinas_opcional
    {
        symbol1 = stack_pop(labels);
        if(symbol1)
            printf("R%03d:\tNADA\n", symbol1->label);
    }

parte_de_declaracoes_opcionais:
    parte_de_declaracao_de_labels
    | parte_de_declaracao_de_variaveis

parte_de_declaracao_de_subrotinas_opcional:
    { nl++; offset = 0; }
    declaracao_de_procedimento
    { nl--; }
;

parte_de_declaracao_de_labels:
    LABEL
    identificador
    {
        symbol1 = symbol_create_label(label);
        label++;
        strcpy(symbol1->id, strdup(yytext));
        stack_push(ts, symbol1);
    }
    parte_de_declaracao_de_labels_loop    
;

parte_de_declaracao_de_labels_loop:
    | COMMA    identificador
    {
        symbol1 = symbol_create_label(label);
        label++;
        strcpy(symbol1->id, strdup(yytext));
        stack_push(ts, symbol1);
    }
    parte_de_declaracao_de_labels_loop
;

tipo:
    identificador
    | ARRAY numero OF tipo
;

parte_de_declaracao_de_variaveis:
    {
        while (symbol1 = stack_pop(aux));
        offset = 0;
    }
    declaracao_de_variaveis
        {
        if (aux->size)
            printf("\tAMEM %d\n", aux->size);

        nvars = aux->size;
        while (symbol1 = stack_pop(aux)) {
            symbol1->cat = C_VARIABLE;
            stack_push(ts, symbol1);
        }
    }
;

declaracao_de_variaveis:
    tipo lista_de_identificadores
;

lista_de_identificadores:
    identificador
    {
        symbol1 = symbol_create(strdup(yytext), nl, offset);
        offset++;
        stack_push(aux, symbol1);
    }
    lista_de_identificadores_loop
;

lista_de_identificadores_loop:
    {
          if (symbol2 && symbol2->nl == nl)
              yyerror("Variável já declarada.");
    }
    |COMMA identificador
    {
        symbol1 = symbol_create(strdup(yytext), nl, offset);
        offset++;
        stack_push(aux, symbol1);
    }
    lista_de_identificadores_loop
;

declaracao_de_procedimento:
    PROCEDURE
    {
        write_label();
        printf(":\tENPR %d\n", nl);
    }
    identificador
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
    {nl--;}
    bloco
    {nl++;}
;

parametros_formais_opcional:
    | parametros_formais
;

parametros_formais:
    LPAREN secao_de_parametros_formais parametros_formais_loop RPAREN
;

parametros_formais_loop:
    {
        if (symbol2 && symbol2->nl == nl)
            yyerror("Variável já declarada.");
    }
    | SEMICOLON secao_de_parametros_formais parametros_formais_loop
;

secao_de_parametros_formais:
    parameter_type identificador
    {
        symbol1 = symbol_create(strdup(yytext), nl, offset);
        offset++;
        stack_push(aux, symbol1);

        symbol1->cat = C_PARAMETER;
        symbol1->passage = P_VALUE;
        stack_push(parameters, symbol1);
    }
;

parameter_type  : tipo 
                | proc_signature;

proc_signature  : PROCEDURE identificador LPAREN type_list RPAREN
                | PROCEDURE identificador;

type_list       : parameter_type 
                | type_list COMMA parameter_type;

comando_composto:
    DO comando comando_composto_loop END
;

comando_composto_loop:
    | SEMICOLON comando comando_composto_loop
;

comando:
    identificador
    {
//        symbol1 = stack_find(ts, yytext);
        symbol1->nl = nl;
        if (symbol1)
            printf("R%03d:\tENRT %d %d\n", symbol1->label, nl, nvars);
        else
            yyerror("label não declarado.\n");
    }
    COLON comando_sem_label
    | comando_sem_label
;

comando_sem_label:
    atribuicao
    | chamada_de_procedimento
    | desvio
    | comando_composto
    | comando_condicional
    | comando_repetitivo
    | comando_escrita
    | comando_leitura
    | bloco
;

comando_escrita:
    WRITE
    {
        write = 1;
    }
    LPAREN lista_de_expressoes RPAREN
    {
        write = 0;
    }
;

comando_leitura:
    READ LPAREN comando_leitura_1 RPAREN
;

comando_leitura_1:
    {
        printf("\tLEIT\n");
    }
    variavel
    {
        if (!symbol1)
            yyerror("variavel nao declarada.");
        if (symbol1->cat == C_PARAMETER && symbol1->passage == P_ADDRESS)
            printf("\tARMI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
        else
            printf("\tARMZ %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
    }
    comando_leitura_2
;

comando_leitura_2:
    | COMMA comando_leitura_1
;

atribuicao:
    variavel
    {
        symb_atr = symbol_cpy(symb_atr, symbol1);
    }
    BECOMES expressao
    {
        if (!symb_atr)
            yyerror("variavel nao declarada.");

        if (symb_atr->cat == C_PARAMETER && symb_atr->passage == P_ADDRESS)
            printf("\tARMI %d, %d # %s\n", symb_atr->nl, symb_atr->offset, symb_atr->id);
        else
            printf("\tARMZ %d, %d # %s\n", symb_atr->nl, symb_atr->offset, symb_atr->id);
    }
;

chamada_de_procedimento:
    identificador
    {
        if (!symbol1)
            yyerror("procedimento não declarado");

        symb_proc = symbol_cpy(symb_proc, symbol1);
        nparam = 0;
    }
    lista_de_expressoes_opcional
    {
        printf("\tCHPR R%03d, %d\n", symb_proc->label, nl);
        symb_proc = NULL;
    }
;

lista_de_expressoes_opcional:
    | LPAREN lista_de_expressoes RPAREN
;

desvio:
    GOTO identificador
    {
        //symbol1 = stack_find(ts, yytext);

        if (symbol1)
            printf("\tDSVR r%02d, %d, %d\n", symbol1->label, symbol1->nl, nl);
        else
            yyerror("label não declarado.\n");
    }
;

comando_condicional:
    IF expressao
    {
        symbol1 = symbol_create("", 0, 0);
        printf("\tDSVF ");
        symbol1->label = write_label();
        printf("\n");
        stack_push(labels, symbol1);
    }
    THEN comando_sem_label
    {
        symbol1 = symbol_create("", 0, 0);
        printf("\tDSVS ");
        symbol1->label = write_label();
        printf("\n");
        symbol2 = stack_pop(labels);
        printf("R%03d:\tNADA\n", symbol2->label);
        stack_push(labels, symbol1);
    }
    comando_condicional_else
    {
        symbol1 = stack_pop(labels);
        printf("R%03d:\tNADA\n", symbol1->label);
    }
    END
;

comando_condicional_else:
    %prec LOWER_THAN_ELSE
    | ELSE comando_sem_label
;

comando_repetitivo:
    WHILE
    {
        symbol1 = symbol_create("", 0, 0);
        symbol1->label = write_label();
        printf(":\tNADA\n");
        stack_push(labels, symbol1);
    }
    expressao
    {
        symbol1 = symbol_create("", 0, 0);
        printf("\tDSVF ");
        symbol1->label = write_label();
        printf("\n");
        stack_push(labels, symbol1);
    }
    DO comando_sem_label
    {
        symbol1 = stack_pop(labels);
        symbol2 = stack_pop(labels);
        printf("\tDSVS r%02d\n", symbol2->label);
        printf("R%03d:\tNADA\n", symbol1->label);
    }
    END
;

lista_de_expressoes:
    expressao
    {
        if (write)
            printf("\tIMPR\n");
    }
    lista_de_expressoes_loop
;

lista_de_expressoes_loop:
    | COMMA expressao
    {
        if ( write )
            printf("\tIMPR\n");
    }
    lista_de_expressoes_loop
;

expressao:
    expressao_simples
    | expressao_simples EQL expressao_simples { printf("\tCMIG\n"); }
    | expressao_simples NEQ expressao_simples { printf("\tCMDG\n"); }
    | expressao_simples LSS expressao_simples { printf("\tCMME\n"); }
    | expressao_simples GTR expressao_simples { printf("\tCMMA\n"); }
    | expressao_simples LEQ expressao_simples { printf("\tCMEG\n"); }
    | expressao_simples GEQ expressao_simples { printf("\tCMAG\n"); }
;

expressao_simples:
    termo expressao_simples_loop
    | PLUS  termo expressao_simples_loop
    | MINUS termo { printf("\tINVR\n"); } expressao_simples_loop
;

expressao_simples_loop:
    | PLUS  termo { printf("\tSOMA\n"); } expressao_simples_loop
    | MINUS termo { printf("\tSUBT\n"); } expressao_simples_loop
    | OR     termo { printf("\tDISJ\n"); } expressao_simples_loop
;

termo:
    fator termo_loop
;

termo_loop:
    | TIMES fator { printf("\tMULT\n"); } termo_loop
    | DIV    fator { printf("\tDIVI\n"); } termo_loop
    | AND    fator { printf("\tCONJ\n"); } termo_loop
;

fator:
    variavel
    {
        symbol1 = stack_find(ts, yytext);
        if (!symbol1)
            yyerror("variável não declarada %s.", yytext);

        if (symb_proc && nparam >= symb_proc->nParameter)
            yyerror("procedimento %s chamado com número inválido de parâmetros %d de %d.", symb_proc->id, nparam, symb_proc->nParameter);

        if (symb_proc && symb_proc->parameters[nparam] == P_ADDRESS) {
            if (symbol1->cat == C_VARIABLE)
                printf("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            else if (symbol1->cat == C_PARAMETER) {
                if (symbol1->passage == P_VALUE)
                    printf("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                else if (symbol1->passage == P_ADDRESS)
                    printf("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            }
            nparam++;
        } else if (symb_func && symb_func->parameters[nparam] == P_ADDRESS) {
            if (symbol1->cat == C_VARIABLE)
                printf("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            else if (symbol1->cat == C_PARAMETER) {
                if (symbol1->passage == P_VALUE)
                    printf("\tCREN %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                else if (symbol1->passage == P_ADDRESS)
                    printf("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            }
            nparam++;
        } else {
            if (symbol1->cat == C_VARIABLE)
                printf("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            else if (symbol1->cat == C_PARAMETER) {
                if (symbol1->passage == P_VALUE)
                    printf("\tCRVL %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
                else if (symbol1->passage == P_ADDRESS)
                    printf("\tCRVI %d, %d # %s\n", symbol1->nl, symbol1->offset, symbol1->id);
            }
        }
    }
    | numero
    {
        if (symb_proc && symb_proc->parameters[nparam] == P_ADDRESS)
            yyerror("parâmetro inteiro passado por referência.");
        if (symb_proc && nparam >= symb_proc->nParameter)
            yyerror("procedimento chamado com número inválido de parâmetros.");

        printf("\tCRCT %s\n", yytext);
    }
    | TRUE | FALSE | STRING
    //%prec LOWER_THAN_LPAREN
    | chamada_de_funcao
    | LPAREN expressao RPAREN
    | NOT fator { printf("\tNEGA\n"); }
;

variavel:
    identificador
;

chamada_de_funcao:
    CALL
    {
        printf("\tAMEM 1\n");
    }
    identificador
    {
        if (!symbol1)
            yyerror("procedimento não declarado");
        
        symb_func = symbol_cpy(symb_func, symbol1);
        nparam = 0;
    }
    lista_de_expressoes_opcional
    {
        printf("\tCHPR R%03d, %d\n", symb_func->label, nl);
        symb_func = NULL;
    }
;

numero:
    NUMBER
;

identificador:
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

    if (stdin)
      yyparse();
    else
      printf("Erro de leitura no arquivo de entrada ou arquivo inexistente\n");

    if (argc > 1 && stdin)
      fclose(stdin);
}
