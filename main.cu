//#include "simulator.h"
#include "system.cuh"
#include "resources.cuh"
#include "scheduler.cuh"
#include <iostream>
#include <stdlib.h>
#include <math.h>
#include <curand.h>
#include <curand_kernel.h>
#include <string>
#include "list.cu"
#include "util.h"

using namespace std;

#define LIGHT(x) (((float)curand_uniform(x)) * (0.2-0.05) + 0.05)
#define MEDIUM(x) (((float)curand_uniform(x)) * (0.5-0.2) + 0.2)
#define HEAVY(x) (((float)curand_uniform(x)) * (0.8-0.5) + 0.5)
#define MIXED(x) (((float)curand_uniform(x)) * (0.8-0.05) + 0.05)

#define TASK_MODE(x) LIGHT(x)

enum PER_TASK_UTILIZATION { light, medium, heavy, mixed };

#define NUMBER  100
#define PROCESSOR_NUMBER  4
#define TOTAL_UTILIZATION  0.1
#define MAX_PERIOD 200
#define MIN_PERIOD 50
#define DURATION 1000
#define OVERHEAD 0

enum SCHEDULER { FIFO, EDF, ROLE_BASED };

SCHEDULER _SCHEDULER = FIFO;

#define THREADS_PER_BLOCK 48
#define BLOCKS_PER_GRID ((NUMBER+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)

//std::list<task *> _tasks;
//std::list<Processor *> _processors;

__device__ List<Processor* > *_processors;
__device__ List<task* > *_tasks;



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
	double sum = 0;
	for (int i = 0; i< number_of_tasks; i++)
	{
		//task tsk = 
		sum += _tasks->get_index(i)->_execution_time / _tasks->get_index(i)->_period;
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
	for (int i = 0; i< number_of_tasks; i++)
	{
		if (((_cycle - _tasks->get_index(i)->_phase) % _tasks->get_index(i)->_period == 0) || (_cycle == _tasks->get_index(i)->_phase))
		{
			job *tmp_job = new job(_tasks->get_index(i));
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
__device__ int findlcm(List<task *> *arr, int n)
{
	// Initialize result 
	int ans = arr->get_index(0)->_period;

	// ans contains LCM of arr[0], ..arr[i] 
	// after i'th iteration, 
	for (int i = 1; i < n; i++)
	{
		//printf("%d, ", arr->get_index(i)->_period);
		ans = (((arr->get_index(i)->_period * ans)) / (gcd(arr->get_index(i)->_period, ans)));
	}

	return ans;
}




__device__ int hyperperiod()
{
	return findlcm(_tasks, number_of_tasks);
}





__global__ void kernel_run()
{
	number_of_tasks = _tasks->size();
	_duration = hyperperiod();
	_cycle = 0;
	_overhead = OVERHEAD;
	while (_cycle < _duration)
	{
		List<job *> released_jobs = _release();
		_scheduler->schedule(_cycle, *_processors, released_jobs, PROCESSOR_NUMBER);

		for (int i = 0; i<PROCESSOR_NUMBER; i++)
		{
			_processors->get_index(i)->run(_cycle);
		}

		tick();

	}

	for (int i = 0; i<PROCESSOR_NUMBER; i++)
	{
		_processors->get_index(i)->stop();
	}

}

__global__ void build_taskset(curandState *my_curandstate)
{

	_processors = new List<Processor* >();
	_tasks = new List<task* >();

	//List<task *> _tasks;
	curand_init(1234, 0, 0, &my_curandstate[0]);
	double total = 0.0;

	int i = 0;

	int counter = 0;
	double total_utilization = TOTAL_UTILIZATION * PROCESSOR_NUMBER;


	while ((total_utilization - total) > (1 / MAX_PERIOD))
	{
		float tmp_period = curand_uniform(my_curandstate);
		tmp_period *= (MAX_PERIOD - MIN_PERIOD + 1);
		tmp_period += MIN_PERIOD;

		int period = (int)truncf(tmp_period);

		//printf("%d\n", period);
		double util = TASK_MODE(my_curandstate);

		//printf("%f\n", util);

		if (total + util > total_utilization)
		{
			util = total_utilization - total;
		}

		int execution_time = floor(util * period);

		//std::cout << util << std::endl;
		if (execution_time < 1)
		{
			execution_time = 1;
			period = ceil(execution_time / util);


		}

		util = (double)execution_time / period;

		total += util;
		task *tsk = new task(0, period, period, execution_time);

		

		_tasks->push(tsk);


		//total_utilization = total;

		counter++;
		/*if ((counter % 10000) == 0)
		{
			std::cout << counter << std::endl;
		}*/
	}
	//printf("here\n");

	//std::cout << "here" << std::endl;
	for (int i = 0; i< PROCESSOR_NUMBER; i++)
	{
		Processor *p = new Processor(1, 0);
		_processors->push(p);
	}

	//printf("here\n");
	// std::cout << "here" << std::endl;

}


int main() {

	curandState *d_state;
	cudaMalloc(&d_state, sizeof(curandState));

	build_taskset << <1, 1 >> > (d_state);

	switch (_SCHEDULER)
	{
	case FIFO:
		cudaMalloc((void**)&_scheduler, sizeof(sched::FIFO));
		break;

	default:
		break;
	}


	kernel_run << <THREADS_PER_BLOCK, BLOCKS_PER_GRID >> >();
	gpuErrchk(cudaPeekAtLastError());
	gpuErrchk(cudaDeviceSynchronize());

	//cout << "Hello" << endl;
	getchar();
	getchar();
	return 0;
}
