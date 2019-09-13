#ifndef _LIST_CU_CUDA
#define _LIST_CU_CUDA

template <typename T>
struct Node {
  T data;
  Node *next;
};

template <typename T> class List{
private:
    Node<T> *head;
    int count =0;
public:
    __device__ __host__ List(){
        head = NULL;
    }

    __device__ __host__ bool isEmpty()
    {
        return (count == 0);
    }

    __device__ __host__ void push(T val){
        Node<T> *n = new Node<T>();   
        n->data = val;             
        n->next = head;        
        head = n;   
        count++;    
    }

    __device__ __host__ T pop(){
        if(isEmpty())
        {
            return NULL;
        }
        else
        {
      if(head) {
        T p = head->data;
        head = head->next;
        count--;
        return p;
      }
    }
    }
    
    __device__ __host__ bool search(T val) {
      Node<T> *temp = head;
      while(temp->next) {
        if(temp->data == val) return true;
        else temp = temp->next;
      }
      delete temp;
      return false;
    }

    __device__ __host__ int size()
    {
        return count;
    }
};


#endif //_LIST_CU_CUDA