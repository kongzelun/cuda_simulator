#ifndef _SCHEDULER_H_CUDA
#define _SCHEDULER_H_CUDA

#include <queue>
#include <list>
#include "system.h"
#include "myqueue.h"
#include "resources.h"
#include "list.cu"


namespace sched
{
class Scheduler
{
public:
    Scheduler()
    {

    }

    __device__ virtual void schedule(int time, Processor ** processors, List<job*> jobs, int no_of_processors) {}
    __device__ virtual void run() {}

};

class FIFO : public Scheduler
{
public:
    FIFO(): Scheduler()
    {

    }
    __device__ void schedule(int time, Processor ** processors, List<job*> jobs, int no_of_processors);
    __device__ void run();

private:
    Queue<job *> _queue;

};
}

#endif //_SCHEDULER_H_CUDA