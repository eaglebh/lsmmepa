#include "stack.h"

t_stack* stack_create() {
    return list_create();
}

void stack_destroy(t_stack *stack) {
    return list_destroy(stack);
}

t_object *stack_first(t_stack *stack) {
    return list_first(stack);
}

t_object *stack_last(t_stack *stack) {
    return list_last(stack);
}

t_object* stack_pop(t_stack *stack) {
    return list_remove_first(stack);
}

void stack_push(t_stack *stack, t_object *object) {
    return list_add_first(stack, object);
}

t_object *stack_find(t_stack *stack, char* text) {
    return list_find(stack, text);
}

int stack_empty(t_stack *stack) {
    return list_empty(stack);
}

void stack_write(t_stack *stack) {
    return list_write(stack);
}

