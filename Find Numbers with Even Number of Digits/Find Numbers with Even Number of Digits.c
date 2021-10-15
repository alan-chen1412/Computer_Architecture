int main()
{
	int n,output=0;
	int number_array[6]={12,345,1771,2,6,7896};
	for(int i = 0;i<6;i++)
	{
		int counter=0;
		while(number_array[i]>0)
		{
			counter++;
			number_array[i]/=10;
		}
		if(counter%2==0)
			output++;
	}
	printf("The number of even digits are: %d\n",output);
	return 0;
}
