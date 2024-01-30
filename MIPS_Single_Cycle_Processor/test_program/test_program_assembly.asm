	addi	$a0, $zero, 3	# Instruction 00
	addi	$t0, $zero, 10	# Instruction 01
	addi	$t1, $zero, 6	# Instruction 02
	and     $t2, $t1, $t0	# Instruction 03
	or      $t3, $t1, $t0	# Instruction 04
	nor     $t4, $t1, $t0	# Instruction 05
start:	slt     $t5, $t1, $t0	# Instruction 06
	sw	$t0,  0($sp)	# Instruction 07
	sw	$t1, -4($sp)	# Instruction 08
	lw	$s0,  0($sp)	# Instruction 09
	lw	$s1, -4($sp)	# Instruction 10
	beq	$s0, $s1, else	# Instruction 11
	add	$s3, $s0, $s1	# Instruction 12
	j	exit		# Instruction 13
else:	sub	$s3, $s0, $s1	# Instruction 14
exit:	add	$s0, $s0, $s3	# Instruction 15
	or	$s1, $s1, $s3	# Instruction 16
	addi	$t0, $t0,  3	# Instruction 17
	addi	$t1, $t1,  3	# Instruction 18
	addi	$sp, $sp, -8	# Instruction 19
	addi	$a0, $a0, -1	# Instruction 20
	slt     $a1, $zero, $a0	# Instruction 21
	beq	$a1, $zero, end # Instruction 22
        j	start		# Instruction 23
end:	j	end		# Instruction 24
