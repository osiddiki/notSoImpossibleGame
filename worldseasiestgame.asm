
# set up some constants
# width of screen in pixels
# 512 / 8 = 64
.eqv WIDTH 64
# height of screen in pixels
.eqv HEIGHT 64
# memory address of pixel (0, 0)
.eqv MEM 0x10008000 

# colors
.eqv    RED     0x00FF0000
.eqv    GREEN     0x0000FF00
.eqv    BLUE    0x000000FF
.eqv    WHITE    0x00FFFFFF
.eqv    YELLOW    0x00FFFF00
.eqv    CYAN    0x0000FFFF
.eqv    MAGENTA    0x00FF00FF


.data
colors: .word MAGENTA,CYAN,YELLOW,WHITE,BLUE,GREEN,RED
.align 2
enemyXPos: .word 13
enemyYPos: .word 12
mainCharacterXPos: .word 30
mainCharacterYPos: .word 55
tempHolderX: .word 4 #holders for getting correct replacemnt color
tempHolderY: .word 4
tempHolderX2: .word 4 #holders for when checking death
tempHolderY2: .word 4
deathString: .asciiz "You got hit and died \n"
winString: .asciiz "You win \n"

.text


main:
	jal 	drawLevel1Background
	la 	$s0,colors
	addi     $a0, $0, WIDTH
	sra     $a0, $a0, 1
	addi     $a1, $0, HEIGHT 
	sra    $a1, $a1, 1
#	addi 	$a2,$a2, WHITE


	
	li 	$t4,0
	li	$a0,13
	li 	$a1,9
	li	$s5,1

	

drawEnemyLoop:
	addi 	$t4,$t4,1
	addi	$a1,$a1,3
	jal 	drawEnemy
	bne 	$t4,14,drawEnemyLoop
	
	# draw a red  pixel 
	li	$a1,55
	li 	$a2, RED
	jal drawCharacter
	li $a1,12
	li $t8,0
	li $s5,0

loop:	

	li 	$t4,0
	lw 	$a0, enemyXPos
	lw 	$a1, enemyYPos

	beq	$t8,39,enemyDirectionChange
	
	beq	$s5,0,moveEnemyRight
	beq	$s5,1,moveEnemyLeft
loop2:
	addi 	$t8,$t8,1
	li 	$v0, 32
	move	$t2,$a0
	li 	$a0,5
	syscall
	move 	$a0,$t2
	syscall

	# check for input
	lw 	$t0, 0xffff0000  #t1 holds if input available
    	beq 	$t0, 0, loop   #If no input, keep displaying
	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit	# input space
	beq	$s1, 119, moveCharacterUp 	# input w
	beq	$s1, 115, moveCharacterDown  	# input s
	beq	$s1, 97, moveCharacterLeft  	# inp
	beq	$s1, 100, moveCharacterRight 	# input d

	
	
	j	loop
	
enemyDirectionChange:
	xori $s5, $s5, 1 #flips from 1 to 0/vice versa
	li $t8,0
	j 	loop2


moveEnemyRight:
	li 		$a2, WHITE #white out character before
	jal 	drawCharacter

	li		$a2, BLUE	#enemt color
	addi 	$a0, $a0, 1 #move right
	jal 	checkColorforDeath
	jal 	drawCharacter #draw


	lw 		$a0, enemyXPos #load enemy x pos
	addi	$a1,$a1,3 #move down to next enemy
	addi	$t4,$t4,1 	#counter +1
	blt	$t4,14,moveEnemyRight

	lw 	$t7, enemyXPos	
	addi	$t7,$t7,1	#add 1 to enemy position counter
	sw 	$t7, enemyXPos

	j 		loop2

moveEnemyLeft:	#opposite of moveEnemyRight
	li 	$a2, WHITE
	jal 	drawCharacter

	li	$a2, BLUE
	subi	$a0, $a0, 1
	jal 	checkColorforDeath
	jal 	drawCharacter
	lw 	$a0, enemyXPos
	addi	$a1,$a1,3
	addi	$t4,$t4,1
	blt	$t4,14,moveEnemyLeft

	lw 	$t7, enemyXPos
	subi	$t7,$t7,1
	sw 	$t7, enemyXPos

	j 		loop2

moveCharacterUp:
	
	lw $a0,mainCharacterXPos
	lw $a1,mainCharacterYPos	#load main character position

	jal		checkColorforReplacement
	#li	$a2, WHITE	#make pixel black
	jal	drawCharacter
	
	li 		$a2, RED
	addi		$a1, $a1, -1
	jal checkColorAtLocation
	jal checkWin
	sw $a0,mainCharacterXPos
	sw $a1,mainCharacterYPos	#save main character position
	jal 	drawCharacter
	j	loop

moveCharacterDown:

	lw $a0,mainCharacterXPos
	lw $a1,mainCharacterYPos

	jal		checkColorforReplacement
	#li	$a2, WHITE	#make pixel before white
	jal	drawCharacter
	
	li 	$a2, RED
	addi	$a1, $a1, 1
	sw $a0,mainCharacterXPos
	sw $a1,mainCharacterYPos
	jal 	drawCharacter
	j	loop


moveCharacterLeft:

	lw $a0,mainCharacterXPos
	lw $a1,mainCharacterYPos

	jal		checkColorforReplacement
	#li	$a2, WHITE	#make pixel black
	jal	drawCharacter
	
	li 	$a2, RED
	addi	$a0, $a0, -1
	jal 	checkColorAtLocation
	sw $a0,mainCharacterXPos
	sw $a1,mainCharacterYPos
	jal 	drawCharacter
	j	loop

moveCharacterRight:

	lw $a0,mainCharacterXPos
	lw $a1,mainCharacterYPos

	jal		checkColorforReplacement
	#li	$a2, WHITE	#make pixel black
	jal	drawCharacter
	
	li 	$a2, RED
	addi	$a0, $a0, 1
	jal 	checkColorAtLocation
	sw $a0,mainCharacterXPos
	sw $a1,mainCharacterYPos
	jal 	drawCharacter
	j	loop
exit:	
	li	$v0, 10
	syscall
drawCharacter:	

	addi 	$sp, $sp, -4
	sw 	$ra, ($sp)
	jal 	drawpixel
	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr 	$ra	


drawEnemy:
	addi 	$sp, $sp, -4
	sw 	$ra, ($sp)
	li	$a2, BLUE #enemy color
	jal 	drawpixel
	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr 	$ra
drawLevel1Background:
	addi 	$sp, $sp, -4
	sw 	$ra, ($sp)
	li 	$a0, 0 #x coordinate
	li 	$a1, -1 #height
	li 	$a2, WHITE
	li 	$t1, WIDTH
	li 	$t2, HEIGHT
	li 	$t3,0
	colorBackground:
		#colors the background one solid color
		addi 	$a1,$a1,1
		addi 	$t3,$t3,1
		jal 	drawHorizontalLine
		bne 	$t3,$t2,colorBackground
		#reset x and y
#draws top line
	li 	$a0,12
	li 	$a1, 5
	li 	$a2, 1
	li 	$t1, 42
	jal 	drawHorizontalLine
#draw bottom line
	li 	$a0, 12
	li 	$a1,59
	jal	 drawHorizontalLine
#draw left line
	li 	$a0,12
	li 	$a1, 6
	li 	$t2, 53
	jal 	drawVerticalLine
#draw right line
	li 	$a0,53
	li 	$a1, 6
	li 	$t2, 53
	jal	 drawVerticalLine
#fill bottom with GREEN
	li $t3,0
	li $a2, GREEN
	li $a0, 13
	li $a1, 53
	li $t1,40
	li $t4, 5
	fillBottom:
	#color the starting area green
		addi $a1,$a1,1
		addi $t3,$t3,1
		jal drawHorizontalLine
		bne $t3,5,fillBottom
#fill top with GREEN

	li 	$t3,0
	li	 $a2, YELLOW
	li	 $a0, 13
	li	 $a1, 5
	li	 $t1,40
	fillTopYellow:
	#color the ending area green
		addi	 $a1,$a1,1
		addi 	$t3,$t3,1
		jal 	drawHorizontalLine
		bne 	$t3,5,fillTopYellow

	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr 	$ra
drawHorizontalLine:
	# $a0 = x
	# set $t1 for length
	#draws horizontal line
	addi 	$sp, $sp, -4
	sw 	$ra, ($sp)
	li $t0,0 	#counter for draw line
	lineDrawLoopHor:
		jal 	drawpixel
		addi $t0, $t0, 1
		addi $a0, $a0, 1
		blt $t0, $t1, lineDrawLoopHor
		sub $a0, $a0, $t1  
		# reset x to start of line
	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
drawVerticalLine:
	#a1 = y
	#set $t2 for length
	#draws vertical line

	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t0,0 	#counter for draw line
	lineDrawLoopVer:
		jal 	drawpixel
		addi $a1, $a1, 1 #move y by one
		addi $t0, $t0, 1 #increment counter
		blt $t0, $t2, lineDrawLoopVer
		sub $a1, $a1, $t2
		# reset y to start of line
	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

checkColorAtLocation:
	addi 	$sp, $sp, -4
	sw 		$ra, ($sp)

	mul		$s1, $a1, WIDTH #check color at location
	add		$s1, $s1, $a0
	mul		$s1, $s1, 4
	add		$s1, $s1, MEM
	lw		$t5, 0($s1)	#load color at location into temp register


	beq		$t5, 1, dontMove
	#if color is black then dont let the player move



	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

dontMove:

	lw 		$a0,mainCharacterXPos

	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra


checkColorforReplacement:
	addi 	$sp, $sp, -4
	sw 		$ra, ($sp)

	sw 		$a0, tempHolderX
	sw 		$a1, tempHolderY

	addi 	$a0, $a0, 1 #check right

	mul		$s1, $a1, WIDTH #check color at location
	add		$s1, $s1, $a0
	mul		$s1, $s1, 4
	add		$s1, $s1, MEM
	lw		$a2, 0($s1)	#load color at right in.

	lw 		$a0, tempHolderX #load x back in
	lw 		$a1, tempHolderY #load y back in

	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra


checkColorforDeath:
	addi 	$sp, $sp, -4
	sw 		$ra, ($sp)
	
	sw 		$a0, tempHolderX2
	sw 		$a1, tempHolderY2

	mul		$s1, $a1, WIDTH #check color at location
	add		$s1, $s1, $a0
	mul		$s1, $s1, 4
	add		$s1, $s1, MEM
	lw		$t5, 0($s1)	#load color at right in.
	beq		$t5, RED, death


	
	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

death:

	li $a2, WHITE
	jal drawpixel

	li	$v0,4
	la	$a0, deathString
	syscall 
	
	li $a0, 30
	li $a1, 55
	li $a2, RED
	sw $a1, mainCharacterYPos
	sw $a0, mainCharacterXPos
	jal drawpixel
	#if color is red then reset player back to original position

	lw 		$a0, tempHolderX2
	lw 		$a1, tempHolderY2

	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	

checkWin:
	addi 	$sp, $sp, -4
	sw 		$ra, ($sp)


	mul		$s1, $a1, WIDTH #check color at location
	add		$s1, $s1, $a0
	mul		$s1, $s1, 4
	add		$s1, $s1, MEM
	lw		$t9, 0($s1)	#load color at right in.
	beq		$t9, YELLOW, win

	lw 	$ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

win:
	li	$v0,4
	la	$a0, winString
	syscall 


	li $a0, 30
	li $a1, 55
	li $a2, RED
	sw $a1, mainCharacterYPos
	sw $a0, mainCharacterXPos
	jal drawpixel	#reset position
	
	jr $ra


#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
drawpixel:
	# s1 = address = MEM + 4*(x + y*width)
	mul	$s1, $a1, WIDTH   # y * WIDTH
	add	$s1, $s1, $a0	  # add X
	mul	$s1, $s1, 4	  # multiply by 4 to get word offset
	add	$s1, $s1, MEM	  # add to base address
	sw	$a2, 0($s1)	  # store color at memory location
	#li 	$v0, 32
	#move	$t2,$a0å
	#li 	$a0,5
	#syscall
	#move 	$a0,$t2
	#syscall
	jr 	$ra
