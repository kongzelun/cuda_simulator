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
public:
    __device__ __host__ List(){
        head = NULL;
    }

    __device__ __host__ void push(T val){
        Node<T> *n = new Node<T>();   
        n->data = val;             
        n->next = head;        
        head = n;              
    }

    __device__ __host__ T pop(){
      if(head) {
        T p = head->data;
        head = head->next;
        return p;
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
};


#endif //_LIST_CU_CUDA