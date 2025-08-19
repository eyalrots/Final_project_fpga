#include <stdio.h>
#define M 10  

int arr1[M] = {1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10};
int arr2[M] = {100,99,98,97,96,95,94,93,92,91};	
int res1[M], res2[M], res3[M];
	
int main(){
	int i;
	
	for (i = 0; i < M; i++){
		res1[i] = arr1[i] + arr2[i];
		res2[i] = arr1[i] * arr2[i];
		res3[i] = arr1[i] - arr2[i];
	}
	
	while(1);
}

