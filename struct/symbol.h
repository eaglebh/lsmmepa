#ifndef _symbol_
#define _symbol_
#include "object.h"

typedef t_object t_symbol;

t_symbol* symbol_create(char *name, int nl, int offset);
t_symbol* symbol_create_procedure(char *id);
t_symbol* symbol_create_function(char *id);
t_symbol* symbol_create_label(int label);
t_symbol* symbol_cpy(t_symbol *symbol1, t_symbol *symbol2);
void symbol_write(void *p);
void symbol_destroy(t_symbol *symbol);
int symbol_cmp_id(t_symbol *symbol1, t_symbol *symbol2);
int symbol_cmp_nl(t_symbol *symbol1, t_symbol *symbol2);
int symbol_cmp(t_symbol *symbol1, t_symbol *symbol2);

#endif

