.text

.globl mat_add

mat_add:  lw   $t6,12($sp)		# push SIZE  
	  lw   $t5,8($sp)		# push res1 pointer
	  lw   $t4,4($sp)		# push arr2 pointer
	  lw   $t3,0($sp)		# push arr1 pointer
	  
add_l:	  lw   $t7,0($t3)
	  lw   $t8,0($t4)
	  lw   $t9,0($t5)
	  
	  add  $t0,$t7,$t8
	  sw   $t0,0($t5)		# Mem[s1] = res1[i]= arr1[i]+arr2[i]
	  
	  addi $t3,$t3,4
	  addi $t4,$t4,4
	  addi $t5,$t5,4
	  addi $t6,$t6,-1
	  bne  $t6,$zero,add_l
	  addi $sp,$sp,16
	  jr   $ra