#ifndef _stack_
#include "list.h"
#define _stack_

typedef t_list t_stack;

t_stack* stack_create(void);
void stack_destroy(t_stack *stack);
t_object *stack_first(t_stack *stack);
t_object *stack_last(t_stack *stack);
t_object* stack_pop(t_stack *stack);
t_object *stack_find(t_stack *stack, char* text);
void stack_push(t_stack *stack, t_object *object);
int stack_empty(t_stack *stack);
void stack_write(t_stack *stack);

#endif

