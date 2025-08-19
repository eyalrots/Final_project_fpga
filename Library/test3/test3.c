#include <stdio.h>
#define M 10  


int arr1[M] = {1 ,2 ,3 ,4 ,5 ,6 ,7 ,8};
int arr2[M] = {100,99,98,97,96,95,94,93};
int res1[M], res2[M], res3[M];


void mat_add(int arr1_i[], int arr2_i[], int arr_o[], int size);
void mat_sub(int arr1_i[], int arr2_i[], int arr_o[], int size);
void mat_mul(int arr1_i[], int arr2_i[], int arr_o[], int size);


int main(){

	mat_add(arr1,arr2,res1,M);
	mat_sub(arr1,arr2,res2,M);
	mat_mul(arr1,arr2,res3,M);
	
	while(1);
}
//-----------------------------------------------------------------
void mat_add(int arr1_i[], int arr2_i[], int arr_o[], int size){
	int i;
	for (int i = 0; i < size; i++)
		arr_o[i] = arr1_i[i] + arr2_i[i];
	
	return;
}
//-----------------------------------------------------------------
void mat_sub(int arr1_i[], int arr2_i[], int arr_o[], int size){
	int i;
	for (int i = 0; i < size; i++)
		arr_o[i] = arr1_i[i] - arr2_i[i];
	
	return;
}
//-----------------------------------------------------------------
void mat_mul(int arr1_i[], int arr2_i[], int arr_o[], int size){
	int i;
	for (int i = 0; i < size; i++)
		arr_o[i] = arr1_i[i] * arr2_i[i];
	
	return;
}
//-----------------------------------------------------------------
