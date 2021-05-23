.global get_elemnt_from_matrix, multiplyMatrices
.extern set_elemnt_in_matrix

.section .text
get_elemnt_from_matrix:
	#TODO: STUDENTS NEED TO FILL
	pushq %rbp
	movq %rsp, %rbp
	# %rdi is pointer to the matrix
	# %esi is n - number of cols
	# %edx is row
	# %ecx is col
	mov %rsi, %rax
	mov %edx, %r8d # backup %rdx which will be writen over in mul
	mul %edx # how many "elements" we need to pass to get to the row
	sal $2, %ecx # multiply by 4, for the sizeof(int) in bytes
	lea (%rdi, %rax, 4), %rax
	mov (%rax,%rcx,1), %eax

	leaveq # pops the stack end return %rbp to its original state
	retq
	/*
	overall:
	We calculate the address using SIB : col*sizeof(int) + (matrix+n*row*sizeof(int))
	calculates into %rdx the index of the element first element of the row we need
	*/
# gets an integer n , and a prime number p 
# returns n%p
# %edi = n , %esi = p
modP:
	pushq %rbp
	movq %rsp , %rbp
	xor %rdx , %rdx
	mov  %edi , %eax
	div %esi
	# rdx now contains the remainder and thus our answer
	mov %edx,%eax

	leaveq
	retq
# gets a matrix mod p all of its elements
# %rdi - matrix
# %esi - number of elements
# %edx - p
modPmatrix:
	pushq %rbp
	movq %rsp, %rbp

	xor %r10d,%r10d # i=0
	cmp %r10d, %esi
	je endloopModP
loopModP:
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %r10
	mov (%rdi,%r10,4),%rdi
	mov %edx, %esi
	call modP
	pop %r10
	pop %rdx
	pop %rsi
	pop %rdi
	mov %eax,(%rdi,%r10,4)

	inc %r10d
	cmp %r10d, %esi
	jne loopModP
endloopModP:
	leaveq
	retq


# multiply row in A by col in B and returns a scalar
	# %rdi - matrix A (mxn)
	# %rsi - matrix B (nxr)
	# %rdx - row in A
	# %rcx - col in B
	# %r8  - n
	# %r9  - r
multiplyVecVec:
	pushq %rbp
	movq %rsp, %rbp 
	subq $16,%rsp
	movq %r12, (%rsp) # r12 will be used for A[row,i]
	movq %r13, 8(%rsp) # r13 will be used for B[i,col]

	xor %r11, %r11 # initialize sum=0
	xor %r10, %r10  # initialize i=0

	cmp %r10, %r8
	je endloopVecVec
loopVecVec:

	# get A[row,i]
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	# setting up parameters for get_elements_from_matrix
	# goal
	# %rdi is pointer to the matrix
	# %rsi is n - number of cols
	# %rdx is row
	# %rcx is col
	#
	# rdi already contains matrix A
	mov %r8 , %rsi
	# %rdx already conatins row
	mov %r10 , %rcx
before_A:
	call get_elemnt_from_matrix
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	mov %eax, %r12d

	# get B[i,col]
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	# setting up parameters for get_elements_from_matrix
	# goal
	# %rdi is pointer to the matrix
	# %rsi is n - number of cols
	# %rdx is row
	# %rcx is col
	#
	mov  %rsi ,%rdi
	mov %r9 , %rsi
	mov %r10, %rdx
	# %rcx already contains col
before_B:
	call get_elemnt_from_matrix
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	mov %eax, %r13d

	# multiple A[row,i]*B[i,col] , the resualt will be in EDX:EAX
	pushq %rdx
	mul %r12d
	popq %rdx
	add %eax , %r11d # sum+= result_of_multiply

	inc %r10 # i++
	cmp %r10, %r8 
	jne loopVecVec

endloopVecVec:
	mov %r11d ,%eax	

	movq (%rsp),%r12 
	movq 8(%rsp),%r13 
	addq $16,%rsp

	leaveq
	retq

# multiply row vector of A by Matrix B to its right and returns a row vector
	# %rdi - matrix A (mxn)
	# %rsi - matrix B (nxr)
	# %rdx - row in A
	# %rcx - result row pointer
	# %r8  - n
	# %r9  - r
multiplyVecByMatrix:
	pushq %rbp
	movq %rsp, %rbp

	xor %r11, %r11 # will be used for the address of the place in the row to put the current result 
	xor %r10, %r10 # init i=0

	cmp %r10, %r9
	je endloopVecMat
loopVecMat:

	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	# prepare arguments:
	# %rdi already contains matrix A
	# %rsi already contains matrix B
	# %rdx already contains row in A
	mov %r10, %rcx # %rcx <-- i
	call multiplyVecVec
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	# lea (%rcx,%r10,4),%r11
	mov %eax,(%rcx, %r10 ,4)
	
	inc %r10
	cmp %r10, %r9
	jne loopVecMat

endloopVecMat:

	leaveq
	retq
	



# multyply matrices A and B
	# %rdi - matrix A (mxn)
	# %rsi - matrix B (nxr)
	# %rdx - result matrix
	# %rcx - m
	# %r8  - n
	# %r9  - r
	# top of stack - p , an unsigned int
multiplyMatrices:
	#TODO: STUDENTS NEED TO FILL
	pushq %rbp
	movq %rsp ,%rbp
	subq $16,%rsp
	movq %r12, (%rsp)
	movq %r13, 8(%rsp)

	lea (,%r9,4),%r12 # result matrix row length in bytes 
	mov %rdx, %r11 # will be used as a pointer to the current row in result matrix
	xor %r10, %r10 # i=0
	cmp %r10, %rcx
	je endloopMatMat
loopMatMat:
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	# prepare arguments:
	# %rdi already contains matrix A ptr
	# %rsi already contains matrix B ptr
	mov %r10, %rdx # %rdx<-i
	mov %r11 ,%rcx # set up %rcs to hold current row pointer 
	# %r8 already is n
	# %r9 already is r

	call multiplyVecByMatrix
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi


	add %r12,%r11
	inc %r10
	cmp %r10, %rcx
	jne loopMatMat
endloopMatMat:

	mov %rdx, %rdi
	mov %rcx, %rax
	mul %r9
	mov %rax, %rsi
	mov 16(%rbp), %edx
	call modPmatrix
	movq (%rsp), %r12
	movq 8(%rsp), %r13
	addq $16,%rsp
	leaveq
	retq
	