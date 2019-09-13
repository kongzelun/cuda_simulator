CXX=g++
NCXX=nvcc
CPPFLAGS=-std=c++11 
LDFLAGS=
RM=rm -f

SRCS=main.cu myqueue.cu resources.cu system.cu scheduler.cu
OBJS=$(subst .cu,.o,$(SRCS))

all: simulator

simulator: $(OBJS)
	$(NCXX) $(LDFLAGS) -o simulator $(OBJS)


%.o: %.cpp
	$(CXX)	$(CPPFLAGS)	-o	$@	-c	$<

%.o: %.cu
	$(NCXX) $(CPPFLAGS) -o $@ -c $<


clean:
	$(RM) $(OBJS)