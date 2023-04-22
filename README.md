# notSoImpossibleGame
A very simplified version of the impossible game made in MIPS using the Bitmap Display 


The program cam be run by imorting the files into MARS and setting the bitmap to 512 x 512, unit height to 8x8, and Base Address to Display to ($gp)
The game requires you to use the keyboard and display mmio simulator as well

The game makes you, the player, a small red dot who must navigate through moving obstacles in order to reach the end of the game.

Pseudocode:
  When the game begins the program will first build the background. This is done through calling several mini functions (drawVerticalLine and drawHorizontalLine) in order to build the box in which the player spawns and moves around in.
  It then draws the enemies that the player must avoid and the player himself
  
  After this the main looped functions of the code begins:
    The first part of the loop is responsible for moving the enemies from side to side.
    When the enmies reach one end of the box a bit will be flipped causing them to switch directions.
    Every time an enemy moves they check the color of the bit they will be moving into in order to make sure that the player is not there. If the player is   there it will reset his position and print that he died to the system console.

Every time the player moves it will check the area around him in order to find the color that replaces his past.
If the plaer moves into the opposite end zone he will win, a message will be printed to console and the game will end.
If the player tries to move through a wall it will not let him by checking the color there.
