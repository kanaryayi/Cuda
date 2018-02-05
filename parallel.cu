#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#define MESSAGE_SIZE_PER_LINE 4+1
#define BUFSIZE 102
#define NUMBER_OF_LINES 15360
#define THREAD_NUMBER_PER_BLOCK 384
#define BLOCK_NUMBER 50
#define CHARACTER_AMOUNT_THREAD 100

//__device__ char* allMessage;
__device__ int allMessageSize = 0;
__global__ void decode(char* file, char* allMessage) {
	int globalid = blockIdx.x*blockDim.x + threadIdx.x;
	int messageSize = CHARACTER_AMOUNT_THREAD;
	int i = 0;
	int index = messageSize * globalid;
	int bound = index + CHARACTER_AMOUNT_THREAD;
	char* message = (char*) malloc(messageSize);
	for (; index < bound; index++) {
		if (file[index] == ',') {
			message[i++] = file[index+1];
			
		}
	}
	if (i == 0)return;

	for (index = globalid*CHARACTER_AMOUNT_THREAD; index < (globalid*CHARACTER_AMOUNT_THREAD)+i; index++) {

		allMessage[index] = message[index-(globalid*CHARACTER_AMOUNT_THREAD)];

	}

}
char *getFileLines() {
	char *allFile;
	allFile = (char*)malloc((NUMBER_OF_LINES*BUFSIZE)+1);
	FILE *file = fopen("encodedfile.txt", "rb");
	allFile[0] = '\0';
	if (file)
	{
		
		fread(allFile, NUMBER_OF_LINES*BUFSIZE,1,file);
		fclose(file);
	
		allFile[NUMBER_OF_LINES*BUFSIZE] = 0;
		
	}
	
	return allFile;
}
void writeFile(char* message) {
	FILE *file = fopen("decodedfile.txt", "w");
	
	int i;
	for (i = 0; i <  NUMBER_OF_LINES*BUFSIZE; i++) {
		if (message[i]) {
			
			fputc(message[i],file);
			
		}

	}
	
	
	fclose(file);
}
char* startGpuProcess(char * file) {

	int size = strlen(file);
	char* allFilesGpu, *message,*allMessage;
	
	message = (char*)malloc(1+NUMBER_OF_LINES*BUFSIZE);

	cudaMalloc((void**)&allFilesGpu, NUMBER_OF_LINES*BUFSIZE);
	cudaMalloc((void**)&allMessage, NUMBER_OF_LINES*BUFSIZE);

	clock_t start = clock(); 
	cudaMemcpy(allFilesGpu,file, NUMBER_OF_LINES*BUFSIZE,cudaMemcpyHostToDevice);
	printf("2\n");
	decode << < BLOCK_NUMBER, THREAD_NUMBER_PER_BLOCK >> >(allFilesGpu,allMessage);
	printf("3\n");
	cudaDeviceSynchronize();
	cudaMemcpy(message, allMessage, NUMBER_OF_LINES*BUFSIZE, cudaMemcpyDeviceToHost);
	printf("4\n");
	message[NUMBER_OF_LINES*BUFSIZE] = '\0';
	
	cudaDeviceReset();
	clock_t end = clock();
	clock_t millis = end - start;
	printf("Code executed in %f milliseconds.\n", millis / double(CLOCKS_PER_SEC) * 1000);
	return message;
}
int main(void)
{
	char* secret;
	
	
	secret = startGpuProcess(getFileLines());
	writeFile(secret);
	
}
