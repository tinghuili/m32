

void main(void)
{
	int array1[3] = {1,2,3};
  int array2[3] = {4,5,6};
  int ans=0;
  int i;
  for(i =0; i < 3; i++){
    ans = ans + array1[i] * array2[i];
  }
}
