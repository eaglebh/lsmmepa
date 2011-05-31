#ifndef _queue_
#include "list.h"
#define _queue_

typedef t_list t_queue;

t_queue* queue_create(void);
void queue_destroy(t_queue *queue);
t_object *queue_first(t_queue *queue);
t_object *queue_last(t_queue *queue);
t_object* queue_remove(t_queue *queue);
t_object *queue_find(t_queue *queue, t_object *object);
void queue_add(t_queue *queue, t_object *object);
int queue_empty(t_queue *queue);
void queue_write(t_queue *queue);

#endif

