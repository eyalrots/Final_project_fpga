.globl main
.data

SIZE: .word  10
arr1: .word  1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,    
arr2: .word  100,99,98,97,96,95,94,93,92,91,
	      
res1: .space 40  # SIZE*4=40[Byte] - ADD result array
res2: .space 40  # SIZE*4=40[Byte] - MUL result array
res4: .space 40  # SIZE*4=40[Byte] - SUB result array

.text
main:
	la $s0,SIZE	# s0 points to SIZE
	lw $s0,0($s0)	# s0 = Mem[s0] = SIZE
	la $t1,arr1   	# t1 points to arr1
	la $t2,arr2	# t2 points to arr2
	la $s1,res1	# s1 points to res1
	la $s2,res2	# s2 points to res2
	la $s4,res4	# s4 points to res4
loop:
	lw $t3, 0($t1) 	# t3 = arr1[i] = Mem[t0]
	lw $t4, 0($t2)	# t4 = arr2[i] = Mem[t1]
	add $t5,$t3,$t4
	sw  $t5,0($s1)	# Mem[s1] = res1[i]= arr1[i]+arr2[i] 
	mul $t5,$t3,$t4
	sw  $t5,0($s2)	# Mem[s2] = res2[i]= arr1[i]*arr2[i]
	sub $t5,$t3,$t4
	sw  $t5,0($s4)	# Mem[s4] = res4[i]= arr1[i]-arr2[i]
	
	addi $t1,$t1,4
	addi $t2,$t2,4
	addi $s1,$s1,4
	addi $s2,$s2,4
	addi $s4,$s4,4
	addi $s0,$s0,-1
	bne  $s0,$zero,loop

finish:	beq $zero,$zero,finish
	 
