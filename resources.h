#ifndef _RESOURCES_H_CUDA
#define _RESOURCE_H_CUDA

#include <string>
#include "system.h"

class _Resource
{
public:
    _Resource(std::string name, int ratio)
    {
        _name = name;
        _ratio = ratio;
        _cycle = 0;
    }

    std::string get_name()
    {
        return _name;
    }

protected:
    std::string _name;
    int _ratio;
    int _cycle;
};

class Processor : _Resource
{
public:
    Processor(std::string name, int ratio, int overhead): _Resource(name, ratio)
    {
        _usage = 0;
        _overhead_cycle = overhead;
        _overhead = 0;
    }

    __device__ __host__ bool is_idle();
    int overhead();
    void load(job *_job);
    job* preempt(job *_job);
    __device__ __host__ void unload();
    __device__ void run(int ticks);
    void stop();

private:
    int _usage;
    job *jb;
    int _overhead_cycle;
    int _overhead;


};

#endif //_RESOURCE_H_CUDA