#include "symbol.h"

t_symbol *symbol_create(char *id, int nl, int offset) {
    return object_create(id, nl, offset);
}

t_symbol *symbol_create_procedure(char *id) {
    return object_create_procedure(id);
}

t_symbol *symbol_create_function(char *id) {
    return object_create_function(id);
}

t_symbol *symbol_create_label(int label) {
    return object_create_label(label);
}

t_symbol *symbol_cpy(t_symbol *symbol1, t_symbol *symbol2) {
    return object_cpy(symbol1, symbol2);
}

void symbol_write(void *p) {
    object_write(p);
}

void symbol_destroy(t_symbol *symbol) {
    object_destroy(symbol);
}

int symbol_cmp_id(t_symbol *symbol1, t_symbol *symbol2) {
    return object_cmp_id(symbol1, symbol2);
}

int symbol_cmp_nl(t_symbol *symbol1, t_symbol *symbol2) {
    return object_cmp_nl(symbol1, symbol2);
}

int symbol_cmp(t_symbol *symbol1, t_symbol *symbol2) {
    return object_cmp(symbol1, symbol2);
}

