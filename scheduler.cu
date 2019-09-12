#include "scheduler.h"

__device__ void FIFO::schedule(int time, std::list<Processor *> processors, std::list<job *> jobs)
{
    for (std::list<job*>::iterator it=jobs.begin(); it !=jobs.end(); ++it)
    {
        _queue.push(*it);
    }

    for (Processor p : processors)
    {
        if(p->is_idle())
        {
            if(!_queue.empty())
            {
                job *jb = _queue.pop();
                p->load(jb); 
            }
        }
    }

}

__device__ void FIFO::run()
{
    schedule();
}