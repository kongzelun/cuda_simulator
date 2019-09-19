#include "simulator.cuh"



__device__ void Simulator::run()
{
	//kernel_run<<<THREADS_PER_BLOCK,BLOCKS_PER_GRID>>>();
}
__device__ void Simulator::stop()
{
	_duration = _cycle + 1;
}