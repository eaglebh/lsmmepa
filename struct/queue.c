#include "queue.h"

t_queue* queue_create() {
    return list_create();
}

void queue_destroy(t_queue *queue) {
    return list_destroy(queue);
}

t_object *queue_first(t_queue *queue) {
    return list_first(queue);
}

t_object *queue_last(t_queue *queue) {
    return list_last(queue);
}

t_object* queue_remove(t_queue *queue) {
    return list_remove_first(queue);
}

void queue_add(t_queue *queue, t_object *object) {
    return list_add_last(queue, object);
}

t_object *queue_find(t_queue *queue, t_object *object) {
    return list_find(queue, object);
}

int queue_empty(t_queue *queue) {
    return list_empty(queue);
}

void queue_write(t_queue *queue) {
    return list_write(queue);
}

