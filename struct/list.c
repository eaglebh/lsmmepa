#include "list.h"

t_node *node_create(t_object *object) {
    t_node *node;
    if(!(node =(t_node *) malloc(sizeof(t_node))))
        return NULL;
    node->object = *object;
    node->next = NULL;
    return node;
}

void node_destroy(t_node *node) {
    object_destroy(&node->object);
    node->next = NULL;
    free(node);
}

void node_write(t_node *node) {
    object_write(&node->object);
}

int node_cmp(t_node *node1, t_node *node2) {
    return object_cmp(&node1->object, &node2->object);
}

t_list *list_create() {
    t_list *list;
    if(!(list =(t_list *) malloc(sizeof(t_list))))
        return NULL;
    list->first = list->last = NULL;
    list->size = 0;
    return list;
}

int list_empty(t_list *list) {
    if(list->size == 0)
        return 1;
    return 0;
}

void list_destroy(t_list *list) {
    int i;
    t_node *node = list->first;
    for(i = 0; i < list->size - 1 ; i++) {
        t_node *aux = node;
        node = node->next;
        node_destroy(aux);
    }

    list->size = 0;
    free(list);
}

t_object *list_first(t_list *list) {
    if(list_empty(list))
        return NULL;
    return &list->first->object;
}

t_object *list_last(t_list *list) {
    if(list_empty(list))
        return NULL;
    return &list->last->object;
}

t_node* list_parent(t_list *list, t_node *node) {
    if(!list)
        return NULL;
    if(list->size < 2)
        return NULL;

    t_node *parent = list->first;

    while(node_cmp(parent->next, node) != 0) {
        parent = parent->next;
    }

    return parent;
}

t_object *list_remove_index(t_list *list, int index) {
    if(list_empty(list))
        return NULL;

    if(index >= list->size)
        return NULL;

    unsigned int loop;
    t_node *node = list->first;
    t_node *parent_of_node = NULL;

    for(loop = 0; loop < index; loop++) {
        parent_of_node = node;
        node = node->next;
    }

    parent_of_node->next = node->next;
    list->size--;

    return &node->object;
}

t_object *list_remove_first(t_list *list) {
    if(list_empty(list))
        return NULL;

    t_node *node = list->first;
    list->first = list->first->next;

    list->size--;
    return &node->object;
}

t_object *list_remove_last(t_list *list) {
    if(list_empty(list))
        return NULL;

    t_node *parent_of_last = list->first;
    t_node *node = list->last;

    if(list->size > 1) {
        while(parent_of_last->next->next) {
            parent_of_last = parent_of_last->next;
        }
    }

    parent_of_last->next = NULL;

    list->last = parent_of_last;
    list->size--;
    return &node->object;

}

t_object *list_find(t_list *list, char* text) {
    t_node *node;
    t_object* aux = NULL;
    for(node = list->first; node != NULL; node = node->next) {
        if(strcmp((node->object).id, text) == 0)
            if((aux == NULL) ||((node->object).nl > aux->nl))
                aux = &node->object;
    }
    return aux;
}

void list_add_node_index(t_list *list, t_node *node, int index) {
    return;
}

void list_add_node_first(t_list *list, t_node *node) {
    node->next = list->first;
    list->first = node;
    list->size++;
}

void list_add_node_last(t_list *list, t_node *node) {
    if(list_empty(list)) {
        list->first = node;
        list->last = node;
    } else {
        list->last->next = node;
        list->last = node;
        node->next = NULL;
    }

    list->size++;
}

void list_add_index(t_list *list, t_object *object, int index) {
    t_node *node = node_create(object);
    list_add_node_index(list, node, index);
}

void list_add_first(t_list *list, t_object *object) {
    t_node *node = node_create(object);
    list_add_node_first(list, node);
}

void list_add_last(t_list *list, t_object *object) {
    t_node *node = node_create(object);
    list_add_node_last(list, node);
}

void list_write(t_list *list) {

    printf("(");

    if(!list_empty(list)) {
        t_node *node;
        for(node = list->first; node && node->next; node = node->next) {
            node_write(node);
            printf(", ");
        }
        node_write(node);
    }
    printf(")\n");
}

