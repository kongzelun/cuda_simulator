#ifndef _SCHEDULER_H_CUDA
#define _SCHEDULER_H_CUDA

#include <queue>
#include <list>
#include "system.h"


namespace sched
{
class Scheduler
{
public:
    Scheduler()
    {

    }

    __device__ virtual void schedule() {}
    __device__ virtual void run() {}

};

class FIFO : public Scheduler
{
public:
    FIFO(): Scheduler()
    {

    }
    __device__ void schedule();
    __device__ void run();

private:
    std::queue<job*> _queue;

};
}

#endif //_SCHEDULER_H_CUDA