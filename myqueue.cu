#include "Queue.h"
#include <iostream>
using namespace std;


template<class T>
Queue<T>::Queue(): frontPtr(NULL), backPtr(NULL), count(0)
{
}

template<class T>
__device__ __host__ bool Queue<T>::isEmpty(){
    return(count == 0);
}

template<class T>
__device__ __host__ void Queue<T>::enqueue(T data){
    Node *newOne = new Node;
    newOne->date = data;
    newOne->next = NULL;
    if(isEmpty()){
        frontPtr = newOne;
    }
        else{
            backPtr->next = newOne;
        }
        backPtr = newOne;
        count++;
}

template<class T>
__device__ __host__ void Queue<T>::dequeue(){
    if(isEmpty()){
        cout << "Nothing inside" << endl;
    }
        else{
            Node *temp = frontPtr;
            if(frontPtr == backPtr){
                frontPtr = NULL;
                backPtr = NULL;
            }
            else{
                frontPtr = frontPtr->next;
            }
            delete temp;
            count--;
        }
}