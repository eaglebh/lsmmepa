#ifndef _list_
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "object.h"
#define _list_

typedef struct t_node {
    struct t_object object;
    struct t_node *next;
} t_node;

typedef struct t_list {
    t_node *first;
    t_node *last;
    unsigned int size;
} t_list;

t_node *node_create(t_object *obeject);
void node_destroy(t_node *node);
int node_cmp(t_node *node1, t_node *node2);
void node_write(t_node *node);
t_list *list_create(void);
int list_empty(t_list *list);
void list_destroy(t_list *list);
t_object *list_first(t_list *list);
t_object *list_last(t_list *list);
t_node *list_parent(t_list *list, t_node *node);
t_object *list_remove_index(t_list *list, int index);
t_object *list_remove_first(t_list *list);
t_object *list_remove_last(t_list *list);
t_object *list_find(t_list *list, char* text);
void list_add_node_index(t_list *list, t_node *node, int index);
void list_add_node_first(t_list *list, t_node *node);
void list_add_node_last(t_list *list, t_node *node);
void list_add_index(t_list *list, t_object *obeject, int index);
void list_add_first(t_list *list, t_object *obeject);
void list_add_last(t_list *list, t_object *obeject);
void list_write(t_list *list);

#endif
