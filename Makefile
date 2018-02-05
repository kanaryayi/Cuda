make: parallel.cu
	nvcc -arch=sm_30 -o mycodebin parallel.cu