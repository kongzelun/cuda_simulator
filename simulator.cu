#include "simulator.h"




__device__ double Simulator::total_utilization()
{
    double sum=0;
    for ( task tsk : _tasks)
    {
        sum+= tsk._execution_time / tsk._period;
    }
    return sum;
}
__device__ void Simulator::tick()
{
    _cycle++;
}
__device__ void Simulator::deadline_missed_handler()
{
    _schedulibility = false;
}
__device__ std::list<job *> Simulator::_release()
{
    std::list<job *> jobs;
    for (task tsk : _tasks)
    {
        if(((_cycle - tsk._phase)%tsk._period ==0) || (_cycle == tsk._phase))
        {
            job *tmp_job = new job(tsk);
            jobs.push_back(tmp_job);
            tmp_job->release(_cycle);
        }
    }
    return jobs;
}
__device__ void Simulator::run()
{
    //kernel_run<<<THREADS_PER_BLOCK,BLOCKS_PER_GRID>>>();
}
__device__ void Simulator::stop()
{
    _duration = _cycle + 1;
}