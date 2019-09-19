#ifndef MYQUEUE_H
#define MYQUEUE_H
#include <cstddef>

template<class T>
class MyQueue
{
public:
	MyQueue();
	__device__ __host__ bool isEmpty();
	__device__ __host__ void push(T data);
	__device__ __host__ T pop();


private:
	struct Node {
		T date;
		Node *next;
	};

	Node *frontPtr;
	Node *backPtr;
	int count;

};

#endif // MYQUEUE_H 