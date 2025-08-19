.data

arr1: .word  1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,   
arr2: .word  100,99,98,97,96,95,94,93,	      
res1: .space 32  # SIZE*4=32[Byte] - ADD result array
res2: .space 32  # SIZE*4=32[Byte] - SUB result array
res3: .space 32  # SIZE*4=32[Byte] - MUL result array
SIZE: .word  8


.text
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
	jal  mat_or
	
	addi $sp,$sp,-16
	sw   $s0,12($sp)	# push SIZE
	sw   $s2,8($sp)		# push res2 pointer
	sw   $t2,4($sp)		# push arr2 pointer
	sw   $t1,0($sp)		# push arr1 pointer
	jal  mat_xor
	
	addi $sp,$sp,-16
	sw   $s0,12($sp)	# push SIZE
	sw   $s3,8($sp)		# push res3 pointer
	sw   $t2,4($sp)		# push arr2 pointer
	sw   $t1,0($sp)		# push arr1 pointer
	jal  mat_and
	
finish:	beq $zero,$zero,finish	 
#----------------------------------------------------------------------------------
mat_or:  lw   $t6,12($sp)		# push SIZE  
	  lw   $t5,8($sp)		# push res1 pointer
	  lw   $t4,4($sp)		# push arr2 pointer
	  lw   $t3,0($sp)		# push arr1 pointer
	  
add_l:	  lw   $t7,0($t3)
	  lw   $t8,0($t4)
	  lw   $t9,0($t5)
	  
	  or  $t0,$t7,$t8
	  sw   $t0,0($t5)		# Mem[s1] = res1[i]= arr1[i]+arr2[i]
	  
	  addi $t3,$t3,4
	  addi $t4,$t4,4
	  addi $t5,$t5,4
	  addi $t6,$t6,-1
	  bne  $t6,$zero,add_l
	  addi $sp,$sp,16
	  jr   $ra
#----------------------------------------------------------------------------------
mat_xor:  lw   $t6,12($sp)		# push SIZE  
	  lw   $t5,8($sp)		# push res2 pointer
	  lw   $t4,4($sp)		# push arr2 pointer
	  lw   $t3,0($sp)		# push arr1 pointer
	  
sub_l:	  lw   $t7,0($t3)
	  lw   $t8,0($t4)
	  lw   $t9,0($t5)
	  
	  xor  $t0,$t7,$t8
	  sw   $t0,0($t5)		# Mem[s1] = res1[i]= arr1[i]-arr2[i]
	  
	  addi $t3,$t3,4
	  addi $t4,$t4,4
	  addi $t5,$t5,4
	  addi $t6,$t6,-1
	  bne  $t6,$zero,sub_l
	  addi $sp,$sp,16
	  jr   $ra
#----------------------------------------------------------------------------------
mat_and:  lw   $t6,12($sp)		# push SIZE  
	  lw   $t5,8($sp)		# push res3 pointer
	  lw   $t4,4($sp)		# push arr2 pointer
	  lw   $t3,0($sp)		# push arr1 pointer
	  
mul_l:	  lw   $t7,0($t3)
	  lw   $t8,0($t4)
	  lw   $t9,0($t5)
	  
	  and  $t0,$t7,$t8
	  sw   $t0,0($t5)		# Mem[s1] = res1[i]= arr1[i]*arr2[i]
	  
	  addi $t3,$t3,4
	  addi $t4,$t4,4
	  addi $t5,$t5,4
	  addi $t6,$t6,-1
	  bne  $t6,$zero,mul_l
	  addi $sp,$sp,16
	  jr   $ra
#----------------------------------------------------------------------------------
	  	  	  
