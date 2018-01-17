/*	Jamie Kirkwin
 *	V00875987
 *	CSc 230 Assignment 2 - Fall 2017
 */
#include <stdio.h>

#define SIZE_INT 16

unsigned short factorial(unsigned short num);
void toBits(unsigned short value, unsigned char intBits[SIZE_INT]);
void printBitArray(unsigned char theBits[SIZE_INT]);

int main() {
/*
 * This program reads in a positive integer from the user (stored as an 
 * unsigned short), calculates the number's factorial, stores each bit of the
 * factorial's binary representation in the elements of an array, and prints  
 * both the decimal and binary representations of the factorial.
 *
 * The program will repeat this process until the user gives the instruction 
 * to stop execution.
 */

	unsigned short num, fact;
	unsigned char bits[SIZE_INT];
	char repeat = 'y'; // User input flag
	
	while(repeat == 'y') {

		// The number is read in from the user
		printf("Input a positive integer ==> "); 
		scanf("%hu", &num);															

		// The factorial of the number is calculated and stored
		fact = factorial(num);

		// The binary representation of the factorial is stored in the array
		toBits(fact, bits);

		// The results are printed
		printf("\n%hu Factorial = %hu or ", num, fact);
		printBitArray(bits);
		printf("\n\n");

		/*
		 * The user is prompted to calculate another factorial or terminate
		 * the program
		 */
		printf("Do another (y/n)? ");
		scanf(" %c", &repeat);
		printf("\n");
		
	} // End while

	return 0;
}

void printBitArray(unsigned char theBits[SIZE_INT]) {
	/*
	 * A subroutine that prints the binary representation of a number 
	 * represented bit-by-bit in an unsigned char array.
	 * @param: the unsigned char array to be traversed and interpreted
	 * @return: none
	 */

	// The binary prefix is printed
	printf("0b");

	int i;
	for(i = 0; i < SIZE_INT; i++) {
		// Each element of the array is printed as a decimal value
		printf("%u", theBits[i]);
	}
}

void toBits(unsigned short value, unsigned char intBits[SIZE_INT]) {
	/*
	 * A subroutine that stores each of the 16 bits of a positive integer in
	 * the least significant bit locations of an array using a mask, the
	 * bitwise and operator, and the shift operator 
	 * @param: unsigned short value is the decimal number to be stored in the
	 *		   array
	 * @param: unsigned char intBits[SIZE_INT] is the array to contain the 
	 *		   binary representation of value
	 * @return: none
	 */

	int i;
	for(i = SIZE_INT - 1; i >= 0; i--) {
		/* 
		 * A mask is used to isolate the leftmost bit, which is then stored 
		 * in the current cell of the array.
		 */
		intBits[i] = value & 0b000000000001;
		
		/* Value is shifted right, moving the next bit into the rightmost
		 * position, readying the loop for successive iterations.
		 */
		value = value >> 1;
	} // End for
}

unsigned short factorial(unsigned short num) {
/* 
 * A recursive fuction that calclates the factorial of a postive integer
 * @param: unsigned char num, the value to calculate the factorial of
 * @return: the factorial of the parameter num
 */

	if(num == 0 || num == 1) {
		// Base case: num is either 0 or 1
		return 1;
	}else {
		// Recursive case: num > 1
		return num * factorial(num - 1);
	}
}