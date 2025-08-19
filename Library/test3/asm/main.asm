.data

arr1: .word  1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,   
arr2: .word  100,99,98,97,96,95,94,93,	      
res1: .space 32  # SIZE*4=32[Byte] - ADD result array
res2: .space 32  # SIZE*4=32[Byte] - SUB result array
res3: .space 32  # SIZE*4=32[Byte] - MUL result array
SIZE: .word  8


.text
.globl main

main:
	li $sp,0x01FC		# stack initial address is 200
	lw $s0,SIZE($0)		# s0 = SIZE	
	la $t1,arr1   		# t1 points to arr1
	la $t2,arr2		# t2 points to arr2
	la $s1,res1		# s1 points to res1
	la $s2,res2		# s2 points to res2
	la $s3,res3		# s3 points to res3
loop:
	addi $sp,$sp,-16
	sw   $s0,12($sp)	# push SIZE
	sw   $s1,8($sp)		# push res1 pointer
	sw   $t2,4($sp)		# push arr2 pointer
	sw   $t1,0($sp)		# push arr1 pointer
	jal  mat_add
	
	addi $sp,$sp,-16
	sw   $s0,12($sp)	# push SIZE
	sw   $s2,8($sp)		# push res2 pointer
	sw   $t2,4($sp)		# push arr2 pointer
	sw   $t1,0($sp)		# push arr1 pointer
	jal  mat_sub
	
	addi $sp,$sp,-16
	sw   $s0,12($sp)	# push SIZE
	sw   $s3,8($sp)		# push res3 pointer
	sw   $t2,4($sp)		# push arr2 pointer
	sw   $t1,0($sp)		# push arr1 pointer
	jal  mat_mul
	
finish:	beq $zero,$zero,finish

	
