#include "scheduler.cuh"

__device__ void sched::FIFO::schedule(int time, List<Processor *> processors, List<job*> jobs, int no_of_processors)
{
	for (int i = 0; i<jobs.size(); i++)
	{
		_queue.push(jobs.pop());
	}

	for (int i = 0; i<no_of_processors; i++)
	{
		if (processors[i]->is_idle())
		{
			if (!_queue.isEmpty())
			{
				job *jb = _queue.pop();
				processors[i]->load(jb);
			}
		}
	}

}

__device__ void sched::FIFO::run()
{
	//schedule();
}