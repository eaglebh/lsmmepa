#ifndef _object_
#define _object_
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PARAMETERS 64
#define MAX_ID_SIZE 64

#define C_VARIABLE 0
#define C_PARAMETER 1
#define C_PROCEDURE 2
#define C_FUNCTION 3
#define C_LABEL 4

#define P_VALUE 0
#define P_ADDRESS 1

typedef struct t_object {
    char id[MAX_ID_SIZE];
    int nl;
    int offset;
    int label;
    int cat;
    int passage;
    int nParameter;
    int *parameters;
} t_object;

t_object* object_create(char *id, int nl, int offset);
t_object* object_create_procedure(char *id);
t_object* object_create_function(char *id);
t_object* object_create_label(int label);
t_object* object_cpy(t_object *object1, t_object *object2);
void object_write(void *p);
void object_destroy(t_object *object);
int object_cmp_id(t_object *object1, t_object *object2);
int object_cmp_nl(t_object *object1, t_object *object2);
int object_cmp(t_object *object1, t_object *object2);

#endif

