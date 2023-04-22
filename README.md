# notSoImpossibleGame
A very simplified version of the impossible game made in MIPS using the Bitmap Display 


The program cam be run by imorting the files into MARS and setting the bitmap to 512 x 512, unit height to 8x8, and Base Address to Display to ($gp)
The game requires you to use the keyboard and display mmio simulator as well

The game makes you, the player, a small red dot who must navigate through moving obstacles in order to reach the end of the game.

**Pseudocode:**
 

 - When the game begins the program will first build the background
	 - This is done through calling several mini functions
		 - DrawHorizontalLine
		 - DrawVerticalLine
			 - These then call drawpixel
		 -  This builds the box in which the player spawns and moves around in.
		 - It then draws the enemies that the player must avoid and the player himself
  
  **After this the main looped functions of the code begins:**
  
   
 1) The first part of the loop is responsible for continuously moving the enemies from side to side.
	 
	 - When the enemies reach one end of the box a bit will be flipped causing them to switch directions.
	 - Every time an enemy moves they check the color of the bit they will be moving into in order to make sure that the player is not there. 
		 - If the player is there it will reset his position and print that he died to the system console.
 2) The second part of the loop waits for user input to move the player, if no input is detected it will continue the program forward and return to the first loop.
 
	 - Every time the player moves it will check the area around him in order to find the color that replaces the bit he was just at. This prevents the player from leaving behind a random streak of whitespace.
	 - Everytime the players moves it will check the color of the bit he is moving into and if it is yellow will declare the player as the winer.
	 - When the player moves it will also check to make sure he is not moving against a wall, if he is it will not let him go through it.

Bugs:
  Don't enter too many keyboard inputs at once or the program will lockup.

![image](https://user-images.githubusercontent.com/84866980/233811232-89b675a5-e77e-4f13-b728-be4e45c1f940.png)
