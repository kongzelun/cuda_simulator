#include "system.cuh"
#include <assert.h>
#include <string>

__device__ __host__ void job::job_release(int time) {
	assert(_state == Created);
	_release_time = time;
	_state = Ready;
}

__device__ __host__ void job::activate() {
	assert(_state == Ready);
	_state = Running;
}

__device__ __host__ void job::preempt() {
	assert(_state == Running);
	_state = Ready;
}

__device__ __host__ void job::terminate(int time)
{
	assert(_state == Completed);
	_response_time = time;
	if (missed())
	{
		//TODO: add simulator funciton
	}
}

__device__ __host__ int job::get_deadline() {
	return _task->_relative_deadline + _release_time;
}

__device__ __host__ int job::get_remain() { return _task->_execution_time - _executed_cycle; }

__device__ __host__ bool job::completed() { return _state == Completed; }

__device__ __host__ bool job::missed() {
	if (completed()) {
		return _response_time > get_deadline();
	}
	return false;
}

__device__ void job::run()
{
	assert(_state == Running);
	_executed_cycle++;
	if (get_remain() == 0)
	{
		_state = Completed;
	}
}

STATE job::get_state() { return _state; }