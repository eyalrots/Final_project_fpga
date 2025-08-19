.data

arr1: .word  1 ,2 ,3 ,4 ,5 ,6 ,7 ,8, 9,10,11, 12, 13, 14, 15, 16, 
arr2: .word  13, 14 ,15, 16, 9, 10, 11 ,12, 5 ,6, 7 ,8, 1, 2 ,3 ,4,
res1: .space 64  # SIZE*4=32[Byte] - ADD result array
SIZE: .word  16


.text
.globl main

main:
	li $sp,0x01FC		# stack initial address is 200
	lw $s0,SIZE($0)		# s0 = SIZE	
	la $t1,arr1   		# t1 points to arr1
	la $t2,arr2		# t2 points to arr2
	la $s1,res1		# s1 points to res
loop:
	addi $sp,$sp,-16
	sw   $s0,12($sp)	# push SIZE
	sw   $s1,8($sp)		# push res1 pointer
	sw   $t2,4($sp)		# push arr2 pointer
	sw   $t1,0($sp)		# push arr1 pointer
	jal  mat_add
	
finish:	beq $zero,$zero,finish

	
