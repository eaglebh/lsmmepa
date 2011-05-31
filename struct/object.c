#include "object.h"

t_object *object_create(char *id, int nl, int offset) {
    t_object *o = malloc(sizeof(t_object));
    if(!o) return NULL;
    strcpy(o->id, id);
    o->nl = nl;
    o->offset = offset;
    return o;
}

t_object *object_create_procedure(char *id) {
    t_object *o = malloc(sizeof(t_object));
    if(!o) return NULL;
    strcpy(o->id, id);
    o->cat = C_PROCEDURE;
    return o;
}

t_object *object_create_function(char *id) {
    t_object *o = malloc(sizeof(t_object));
    if(!o) return NULL;
    strcpy(o->id, id);
    o->cat = C_FUNCTION;
    return o;
}

t_object *object_create_label(int label) {
    t_object *o = malloc(sizeof(t_object));
    if(!o) return NULL;
    o->label = label;
    o->cat = C_LABEL;
    return o;
}

t_object *object_cpy(t_object *object1, t_object *object2) {
    if(!object1)
        object1 = malloc(sizeof(t_object));
    if(!object1 || !object2)
        return NULL;

    strcpy(object1->id, strdup(object2->id));
    object1->nl = object2->nl;
    object1->offset = object2->offset;
    object1->cat = object2->cat;
    object1->passage = object2->passage;
    object1->nParameter = object2->nParameter;
    object1->parameters = object2->parameters;

    object1->label = object2->label;
    return object1;
}

void object_write(void *p) {
    t_object *object =(t_object *) p;
    printf("\n");
    printf("id: %s " , object->id);
    printf("cat: %d ", object->cat);
    printf("NL: %d ", object->nl);
    printf("offset: %d ", object->offset);
    printf("passage: %d ", object->passage);
    printf("#parameter: %d ", object->nParameter);
    int i;
    for(i = 0; i < object->nParameter; i++) {
        printf("p[%d]: %d ", i, object->parameters[i]);
    }
}

void object_destroy(t_object *object) {
    free(object);
}

int object_cmp_id(t_object *object1, t_object *object2) {
    return strcmp(object1->id, object2->id);
}

int object_cmp_nl(t_object *object1, t_object *object2) {
    return(object1->nl == object2->nl);
}

int object_cmp(t_object *object1, t_object *object2) {
    return(object_cmp_id(object1, object2));
}

