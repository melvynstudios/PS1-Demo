#include <stdio.h>

int main() {
	int num;
	int i;
	int j;
	int temp;
	int sum;

	num = 5;

	temp = 1;
	sum = 1;
	i = 1;
	while (i <= num) {
		sum = 0;
		j = 0;
		while (j < i) {
			sum += temp;
			j++;
		}
		temp = sum;
		i++;
	}

	printf("fac(%d) = %d\n", num, temp);
	return 0;
}