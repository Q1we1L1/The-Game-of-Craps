# Craps

.data
rolling_info:	.asciiz "You have rolled "
plus_str:	.asciiz " + "
equals_str:	.asciiz " = "
new_line:	.asciiz "\n"
win_msg:	.asciiz "You Win!\n\n"
lose_msg:	.asciiz "You Lose!\n\n"
point_msg:	.asciiz "The point is now "
point_end:	.asciiz ".\n\n"
continue_msg:	.asciiz "Would you like to play again? (1 for yes, anything else to exit)"

.text
##############################################################################
# main entry
##############################################################################
	jal INIT_RAND_SEED		# init random number generator
ROUND_LOOP:
	jal ROLLING_ONCE		# roll one time, and show information

	beq	$v0, 2, USER_LOSE
	beq	$v0, 3, USER_LOSE
	beq	$v0, 12, USER_LOSE
	beq	$v0, 7, USER_WIN
	beq	$v0, 11, USER_WIN

	move 	$v1, $v0 		# save the point value in $v1

	la 	$a0, point_msg 		# show point information
	li	$v0, 4
	syscall

	move 	$a0, $v1
	li 	$v0, 1
	syscall

	la 	$a0, point_end 
	li	$v0, 4
	syscall

POINT_LOOP:				# loop until get point or 7
	jal 	ROLLING_ONCE
	beq 	$v0, $v1, USER_WIN
	beq 	$v0, 7, USER_LOSE
	j 	POINT_LOOP

USER_WIN:
	la 	$a0, win_msg 
	li	$v0, 4
	syscall
	j 	ROUND_END	

USER_LOSE:
	la 	$a0, lose_msg 
	li	$v0, 4
	syscall
	j 	ROUND_END	

ROUND_END:
	la 	$a0, continue_msg 	# ask user whether continue or nor?
	li	$v0, 4
	syscall

	li 	$v0, 5			# get number inputed by user
	syscall

	bne 	$v0, 1, EXIT 		# loop while user input 1, otherwise quit
	j 	ROUND_LOOP

##############################################################################
# Tell MARS to exit the program
##############################################################################
EXIT:
	li	$v0, 10		# exit syscall
	syscall

##############################################################################
# seed the random number generator
##############################################################################
INIT_RAND_SEED:
	# get the time
	li	$v0, 30		# get time in milliseconds (as a 64-bit value)
	syscall

	move	$t0, $a0	# save the lower 32-bits of time

	# seed the random generator (just once)
	li	$a0, 1		# random generator id (will be used later)
	move 	$a1, $t0	# seed from time
	li	$v0, 40		# seed random number generator syscall
	syscall

	jr	$ra

##############################################################################
# get one random number
##############################################################################
GET_RAND_NUMBER:
	# generate 1 random integer in the range [1, 6] from the 
	# seeded generator (whose id is 1)
	sub 	$sp, $sp, 4
	sw 	$ra, ($sp)

	li	$a0, 1		# as said, this id is the same as random generator id
	li	$a1, 6		# upper bound of the range
	li	$v0, 42		# random int range
	syscall

	# $a0 now holds the random number in the range [0, 5]
	# change it to [1, 6] and save to $t0
	addi	$a0, $a0, 1

	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr	$ra

##############################################################################
# rolling one time
##############################################################################
ROLLING_ONCE:
	# $v0 holds the number

	sub 	$sp, $sp, 4
	sw 	$ra, ($sp)

	jal	GET_RAND_NUMBER
	move	$t0, $a0		# get the first number

	jal	GET_RAND_NUMBER
	move	$t1, $a0		# get the second number

	add 	$t2, $t1, $t0		# get the sum

	la 	$a0, rolling_info	# show rolling message
	li	$v0, 4
	syscall

	move 	$a0, $t0
	li 	$v0, 1
	syscall

	la 	$a0, plus_str 
	li	$v0, 4
	syscall

	move 	$a0, $t1
	li 	$v0, 1
	syscall
	
	la 	$a0, equals_str 
	li	$v0, 4
	syscall

	move 	$a0, $t2
	li 	$v0, 1
	syscall
	
	la 	$a0, new_line 
	li	$v0, 4
	syscall

	move	$v0, $t2	# set the result

	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr	$ra


