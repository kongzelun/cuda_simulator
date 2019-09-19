#include "myqueue.cuh"
#include <iostream>
using namespace std;

template<class T>
MyQueue<T>::MyQueue() : frontPtr(NULL), backPtr(NULL), count(0)
{
}

template<class T>
__device__ __host__ bool MyQueue<T>::isEmpty() {
	return(count == 0);
}

template<class T>
__device__ __host__ void MyQueue<T>::push(T data) {
	Node *newOne = new Node;
	newOne->date = data;
	newOne->next = NULL;
	if (isEmpty()) {
		frontPtr = newOne;
	}
	else {
		backPtr->next = newOne;
	}
	backPtr = newOne;
	count++;
}

template<class T>
__device__ __host__ T MyQueue<T>::pop() {
	if (isEmpty()) {
		printf("Nothing inside\n");
	}
	else {
		Node *temp = frontPtr;
		T tr = temp->data;
		if (frontPtr == backPtr) {
			frontPtr = NULL;
			backPtr = NULL;
		}
		else {
			frontPtr = frontPtr->next;
		}
		delete temp;
		count--;
		return tr;
	}
}