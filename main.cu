//#include "simulator.h"
#include "system.h"
#include "resources.h"
#include "scheduler.h"
#include <iostream>
#include <stdlib.h>
#include <math.h>
#include "list.cu"
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
#define DURATION 1000
#define OVERHEAD 0

enum SCHEDULER {FIFO , EDF, ROLE_BASED};

SCHEDULER _SCHEDULER = FIFO;

#define THREADS_PER_BLOCK 48
#define BLOCKS_PER_GRID ((NUMBER+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)

std::list<task *> _tasks;
std::list<Processor *> _processors;

__device__ Processor** gd_processors;
__device__ task** gd_tasks;

__device__ int number_of_tasks = 0;

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
    for(int i=0; i< number_of_tasks; i++)
    {
        //task tsk = 
        sum+= gd_tasks[i]->_execution_time / gd_tasks[i]->_period;
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
__device__ List<job *> _release()
{
   List<job *> jobs;
    for (int i=0; i< number_of_tasks; i++)
    {
        if(((_cycle - gd_tasks[i]->_phase)%gd_tasks[i]->_period ==0) || (_cycle == gd_tasks[i]->_phase))
        {
            job *tmp_job = new job(gd_tasks[i]);
            jobs.push(tmp_job);
            tmp_job->job_release(_cycle);
        }
    }
    return jobs;
}



__device__ int gcd(int a, int b) 
{ 
    if (b == 0) 
        return a; 
    return gcd(b, a % b); 
} 
  
// Returns LCM of array elements 
__device__ int findlcm(task** arr, int n) 
{ 
    // Initialize result 
    int ans = arr[0]->_period; 
  
    // ans contains LCM of arr[0], ..arr[i] 
    // after i'th iteration, 
    for (int i = 1; i < n; i++) 
        ans = (((arr[i]->_period * ans)) / 
                (gcd(arr[i]->_period, ans))); 
  
    return ans; 
} 




__device__ int hyperperiod()
{
    return findlcm(gd_tasks, number_of_tasks);
}





__global__ void kernel_run( Processor** d_processors, task** d_tasks, int no_tasks)
{
    number_of_tasks = no_tasks;
    _duration = hyperperiod();
    _cycle = 0;
    _overhead = OVERHEAD;
   while(_cycle < _duration)
    {
        List<job *> released_jobs = _release();
        _scheduler->schedule(_cycle, gd_processors, released_jobs, PROCESSOR_NUMBER);

        for (int i=0; i<PROCESSOR_NUMBER; i++)
        {
            gd_processors[i]->run(_cycle);
        }

        tick();

    }

    for (int i=0; i<PROCESSOR_NUMBER; i++)
    {
        gd_processors[i]->stop();
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

    switch (_SCHEDULER)
    {
    case FIFO:
        cudaMalloc((void**)&_scheduler, sizeof(sched::FIFO));
        break;
    
    default:
        break;
    }

    thrust::device_vector<Processor *> d_processors(_processors.begin(), _processors.end());
    thrust::device_vector<task *> d_tasks(_tasks.begin(), _tasks.end());
    gd_processors = thrust::raw_pointer_cast( &d_processors[0] );
    gd_tasks = thrust::raw_pointer_cast( &d_tasks[0] );


    kernel_run<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(gd_processors,gd_tasks, _tasks.size());


    cout << "Hello" << endl;
    return 0; }
