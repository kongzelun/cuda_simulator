#ifndef _SIMULATOR_H_CUDA
#define _SIMULATOR_H_CUDA

#include <string>
#include <list>
#include "resources.h"
#include "scheduler.h"

enum SCHEDULER {FIFO, EDF, ROLE_BASED};

class Simulator
{
public:
    Simulator(std::string name, std::list<Processor *> processors, std::list<task> tasks, int duration, SCHEDULER scheduler, bool preemptive , int overhead, bool sporadic)
    {
        _processors = processors;
        _tasks = tasks;
        _duration = duration;

        _preemptive = preemptive;
        _overhead = overhead;
        _sporadic = sporadic;

        _cycle = 0;
        _schedulibility = true;

        switch (scheduler)
        {
        case FIFO:
            _scheduler = new sched::FIFO();
            break;
        
        default:
            break;
        }
    }

    __device__ double total_utilization();
    __device__ void tick();
    __device__ void deadline_missed_handler();
    __device__ std::list<job *> _release();
    void run();
    __device__ void stop();

private:
    std::list<Processor *> _processors;
    std::list<task> _tasks;
    int _duration;
    bool _preemptive;
    int _overhead;
    bool _sporadic;
    bool _schedulibility;
    int _cycle;
    sched::Scheduler *_scheduler;


};

#endif //_SIMULATOR_H_CUDA