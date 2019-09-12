#include "resources.h"

__device__ __host__ bool Processor::is_idle()
{
    return !(jb != NULL);
}

int Processor::overhead()
{
    return _overhead_cycle;
}

void Processor::load(job *_job)
{
    assert(is_idle());

    _overhead += _overhead_cycle;
    jb = _job;
    jb->activate();
}

job* Processor::preempt(job *_job)
{
    assert(!is_idle());


    job *preempted_job = jb;
    jb->preempt();
    unload();
    load(_job);
    return preempted_job; 
}

__device__ __host__ void Processor::unload()
{
    assert(!is_idle());

    _overhead = _overhead_cycle;
    jb = NULL;
}

__device__ void Processor::run(int ticks)
{
    if((ticks % _ratio) == 0)
    {
        _cycle +=1;
        if(_overhead >= 0)
        {
            _overhead -= 1;
        }
        else
        {
            if(is_idle())
            {
                jb->run();
                if(jb->completed())
                {
                    jb->terminate(ticks);
                    unload();
                }
            }
        }
    }
}