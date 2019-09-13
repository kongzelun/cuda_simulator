#ifndef QUEUE_H
#define QUEUE_H
#include <cstddef>

template<class T>
class Queue
{
    public:
        Queue();
        __device__ __host__ bool isEmpty();
        __device__ __host__ void enqueue(T data);
        __device__ __host__ void dequeue();
     

    private:
        struct Node{
            T date;
            Node *next;
        };

        Node *frontPtr;
        Node *backPtr;
        int count;

};

#endif // QUEUE_H 