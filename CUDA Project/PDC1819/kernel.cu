#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>


// To size tou pinaka
#define size 5

__global__ void average(int *a, int *b, int *c) {

	// Initialize 2 topikes metavlites gia na vro to sinolo kai meta to mean
	int totalA = 0, totalB = 0;

	// Loop gia na paroume to sinolo tou A,B
	for (int i = 0; i < size; i++) {
		totalA +=  a[threadIdx.x*size + i];		//Ypologizoume to sinolo tis ka8e stilis
		totalB +=  b[threadIdx.x*size + i];
	}
	c[threadIdx.x] = totalA / 5 + totalB / 5; //Epita ta diairoume /5 kai ta pername sto C
}

int main(void) {
	int A[size][size];      //Dimiourgo tous pinakes A,B,C
	int B[size][size];
	int C[size];
	int *dev_a;      //Dimiourgoume device copies tou a,b,c (pointers)
	int *dev_b;		//gia na stiloume ta dedomena stin GPU
	int *dev_c;

	// Gemizo tous Pinakes A & B
	for (int i = 0; i < size; i++) {
		printf("C[%i]=\n", i);
		for (int j = 0; j < size; j++) {
			A[i][j] = rand() % 10;
			B[i][j] = rand() % 10;
			printf("A:%i, ", A[i][j]);
			printf("B:%i,\n", B[i][j]);
		}
		printf("\n");
	}

	// Dilonoume to megethos tou pinaka pou 8a xriastoume
	int size_2d = size * size * sizeof(int);
	int size_c = size * sizeof(int);

	// Desmeuo mnimi sto sistima
	cudaMalloc(&dev_a, size_2d);
	cudaMalloc(&dev_b, size_2d);
	cudaMalloc(&dev_c, size_c);

	// Copy ton dedomenon stin mnimi tis GPU (meso pointers)
	cudaMemcpy(dev_a, A, size_2d, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, B, size_2d, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, C, size_c, cudaMemcpyHostToDevice);

	// Kalo tin kerner
	average <<< size, size >>> (dev_a, dev_b, dev_c);

	// Travao to output piso stin CPU
	cudaMemcpy(C, dev_c, size_c, cudaMemcpyDeviceToHost);

	// Ta emfanizo
	printf("\n");
	for (int i = 0; i < size; i++) {
		printf("C[%i]= %i\n", i, C[i]);
	}

	// Eleutherono tin mnimi
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
}