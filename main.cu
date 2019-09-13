//#include "simulator.h"
#include "system.h"
#include "resources.h"
#include "scheduler.h"
#include <iostream>
#include <stdlib.h>
#include <math.h>
#include <list>
#include <thrust/device_vector.h>
#include <thrust/copy.h>

using namespace std;

#define LIGHT ((((float)rand())/(float) RAND_MAX) * (0.2-0.05) + 0.05)
#define MEDIUM ((((float)rand())/(float) RAND_MAX) * (0.5-0.2) + 0.2)
#define HEAVY ((((float)rand())/(float) RAND_MAX) * (0.8-0.5) + 0.5)
#define MIXED ((((float)rand())/(float) RAND_MAX) * (0.8-0.05) + 0.05)

#define TASK_MODE LIGHT

enum PER_TASK_UTILIZATION { light , medium , heavy, mixed};

#define NUMBER  100
#define PROCESSOR_NUMBER  4
#define TOTAL_UTILIZATION  0.1
#define MAX_PERIOD 200
#define MIN_PERIOD 50

#define SCHEDULER FIFO



#define THREADS_PER_BLOCK 48
#define BLOCKS_PER_GRID ((NUMBER+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)

std::list<task *> _tasks;
std::list<Processor *> _processors;

thrust::device_vector<Processor *> gd_processors;
thrust::device_vector<task *> gd_tasks;

__device__ int _duration;
__device__ bool _preemptive;
__device__ int _overhead;
__device__ bool _sporadic;
__device__ bool _schedulibility;
__device__ int _cycle;
__device__ sched::Scheduler *_scheduler;

__device__ double total_utilization()
{
    double sum=0;
    for ( task tsk : gd_tasks)
    {
        sum+= tsk._execution_time / tsk._period;
    }
    return sum;
}
__device__ void tick()
{
    _cycle++;
}
__device__ void deadline_missed_handler()
{
    _schedulibility = false;
}
__device__ std::list<job *> _release()
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

__global__ void kernel_run( thrust::device_vector<Processor *> d_processors, thrust::device_vector<task *> d_tasks)
{
   while(_cycle < _duration)
    {
        std::list<job *> released_jobs = _release();
        _scheduler->schedule(_cycle, _processors, released_jobs);

        for (Processor *p: _processors)
        {
            p->run(_cycle);
        }

        tick();

    }

    for (Processor *p: _processors)
    {
        p->stop();
    }

}


int main() { 

    std::list<task *> _tasks;
    srand(0);
    double total = 0.0;

    int i=0;

    double total_utilization = TOTAL_UTILIZATION * PROCESSOR_NUMBER;

    while ((total_utilization - total) > (1/MAX_PERIOD))
    {
        int period = rand()%(200-50+1) + 50;
        int util = TASK_MODE;
        
        if(total+util > total_utilization)
        {
            util = total_utilization - total;
        }

        int execution_time = floor(util * period);

        if(execution_time < 1)
        {
            execution_time = 1;
            period = ceil(execution_time/util);
        }

        util = execution_time/period;

        total += util;
        task *tsk = new task("task"+to_string(i++), 0 ,period, period, execution_time);

        _tasks.push_back(tsk);

        //total_utilization = total;
    }
    
    for (int i=0; i< PROCESSOR_NUMBER; i++)
    {
        Processor *p = new Processor("cpu"+to_string(i), 1, 0);
        _processors.push_back(p);
    }

    switch (SCHEDULER)
    {
    case FIFO:
        cudaMalloc((void**)&_scheduler, sizeof(sched::FIFO));
        break;
    
    default:
        break;
    }

    thrust::device_vector<Processor *> d_processors(_processors.begin(), _processors.end());
    thrust::device_vector<task *> d_tasks(_tasks.begin(), _tasks.end());
    gd_processors = d_processors;
    gd_tasks = d_tasks;

    kernel_run<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_processors,d_tasks);


    cout << "Hello" << endl;
    return 0; }
