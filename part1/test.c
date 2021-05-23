#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <time.h>

/* Parameters M,N,R,P can change from one test to another */
#define M 3
#define N 4
#define R 2
#define P 5


/* Auxilarry function to print the result. Use it to test yourselves. */
void print_result_matrix(int* matrix, int row, int col) {
  for(int i=0; i<row; i++) {
    for(int j=0; j<col; j++) {
      if(j<col-1) printf("%d, ",*(matrix +i*col+j));
      else printf("%d",*(matrix +i*col+j));
    }
    printf("\n");
  }
}


/* This function takes the pointer "matrix" to a matrix(2D array) and changing the matrix element in
 * the [row][col] location to the "value" parameter. For its implementation, the function needs also
 * the number of columns "num_of_columns" in the matrix.
 * 
 * NOTICE 1: It assumes you sent valid "row" and "col" values. If you don't do that, the behaviour
 * will be unexpected.
 * 
 * NOTICE 2: This function's specific implementation can change from one test to another (although it
 * will always do what it should, of course).
 */
void set_elemnt_in_matrix(int* matrix, int num_of_columns, int row, int col, int value) {
   *((matrix + row*num_of_columns) + col) = value;
}



/* The next 2 functions are YOUR responsibility. Do not let us down :) */ 
int get_elemnt_from_matrix(int* matrix, int num_of_columns, int row, int col);
void multiplyMatrices(int* first, int* second, int* result, int m, int n, int r, unsigned int field_size);

void my_mul(int* first, int* second, int* result, int m, int n, int r, unsigned int field_size)
{
  for(int row=0; row < m; row++)
  {
    for(int col=0; col < r; col++)
    {
      int sum = 0;
      for(int i =0; i< n; i++)
      {
        sum += (*(first + n*row + i))*(*(second + r*i + col));
        sum = sum % field_size;
      }
      set_elemnt_in_matrix(result, r,  row,  col, sum);
    }
  }
}

void fill_random_matrix(int* matrix, int row, int col)
{
  srand(time(NULL));
  for (int i = 0; i<row; i++)
  {
    for(int j = 0;j <col; j++)
    {
      *(matrix + col*i + j) = (rand()%P);
    }
  }
}

int test_get(int* matrix, int row, int col)
{
  for (int i = 0; i<row; i++)
  {
    for(int j = 0;j <col; j++)
    {
      if(*(matrix + col*i + j) != get_elemnt_from_matrix(matrix,col,i,j))
      {
        printf("\nTest faild! matrix[%d][%d]=%d and your fucntion returned: %d\n The matrix:\n",i,j,*(matrix + col*i + j),get_elemnt_from_matrix(matrix,col,i,j));
        print_result_matrix(matrix,row,col);
        putchar('\n');
        return 1;
      }
      
    }
  }
  return 0;
}

int test_mult(int* first,int row1,int col1, int* second, int row2, int col2)
{
  int* True_result[M][R];
  int result[M][R];
  my_mul((int*)first,(int*)second,(int*)True_result,row1,col1,col2,P);
  multiplyMatrices((int*)first,(int*)second,(int*)result,row1,col1,col2,P);

  for (int i = 0; i<row1; i++)
  {
    for(int j = 0;j <col2; j++)
    {
      if(*((int*)True_result + col2*i + j) != *((int*)result + col2*i + j))
      {
        printf("\nTest faild! first matrix:\n");
        print_result_matrix((int*)first,row1,col1);
        printf("\nsecond matrix:\n");
        print_result_matrix((int*)second,row2,col2);
        printf("\nresult matrix:\n");
        print_result_matrix((int*)True_result,row1,col2);
        printf("\nyour result matrix:\n");
        print_result_matrix((int*)result,row1,col2);
        return 1;
      }
      
    }
  }
  return 0;
}


/* The main function is also test zone. Go wild while testing */
int main() {
  printf("Hello!\nPlease enter the number of tests you would like to run:");
  int number_of_tests;
  int number_of_fails = 0;
  scanf("%d",&number_of_tests);
  for (int i =0; i<number_of_tests; i++)
  {
    // printf("runngin test num:%d\n",i);
    int matrix1[M][N];
    int matrix2[N][R];
    fill_random_matrix((int*)matrix1,M,N);
    fill_random_matrix((int*)matrix2,N,R);
    number_of_fails += test_get((int*)matrix1,M,N);
    number_of_fails += test_get((int*)matrix2,N,R);
    number_of_fails += test_mult((int*)matrix1,M,N,(int*)matrix2,N,R);
  }
  if(number_of_fails==0)
  {
    printf("\nCongrats!! All tests passed!\n");
  }
  else
  {
    printf("You have faild %d tests\nGood luck next time!\n",number_of_fails);
  }
  
  return 0;
}
