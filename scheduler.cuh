#ifndef _SCHEDULER_H_CUDA
#define _SCHEDULER_H_CUDA

#include <queue>
#include <list>
#include "system.cuh"
#include "resources.cuh"
#include "list.cu"


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
		T data;
		Node *next;
	};

	Node *frontPtr;
	Node *backPtr;
	int count;

};



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
	newOne->data = data;
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
		printf("Nothing inside");
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


namespace sched
{
	class Scheduler
	{
	public:
		Scheduler()
		{

		}

		__device__ virtual void schedule(int time, List<Processor *> processors, List<job*> jobs, int no_of_processors) {}
		__device__ virtual void run() {}

	};

	class FIFO : public Scheduler
	{
	public:
		FIFO() : Scheduler()
		{

		}
		__device__ void schedule(int time, List<Processor *> processors, List<job*> jobs, int no_of_processors);
		__device__ void run();

	private:
		MyQueue<job *> _queue;

	};
}

#endif //_SCHEDULER_H_CUDA