//#include "simulator.h"
#include "system.h"
#include "resources.h"
#include <iostream>
#include <stdlib>
#include <math.h>
#include <list>

using namespace std;

#define LIGHT rand()%(0.2-0.05+1) + 0.05;
#define MEDIUM rand()%(0.5-0.2+1) + 0.2;
#define HEAVY rand()%(0.8-0.5+1) + 0.5;
#define MIXED rand()%(0.8-0.05+1) + 0.05;

#define TASK_MODE LIGHT

enum PER_TASK_UTILIZATION { light , medium , heavy, mixed};

#define NUMBER  100
#define PROCESSOR_NUMBER  4
#define TOTAL_UTILIZATION  0.1
#define MAX_PERIOD 200
#define MIN_PERIOD 50



#define THREADS_PER_BLOCK 48
#define BLOCKS_PER_GRID ((NUMBER+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)

__global__ void kernel_run()
{
   while(_cycle < _duration)
    {
        std::list<job *> released_jobs = _release();
        _scheduler->run(_cycle, _processors, released_jobs);

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
        task *tsk = new task("task"+to_string(i++),period, period, execution_time);

        _tasks.push_back(tsk);

        //total_utilization = total;
    }
    
    kernel_run<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>();


    cout << "Hello" << endl;
    return 0; }