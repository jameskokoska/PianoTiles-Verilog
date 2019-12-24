# PianoTiles - Verilog
* A Piano Tiles game written entirely in the hardware based language, Verilog
## Features
* 2 gamemodes
* Pseudo random tiles
* Final scores
* PS2 Keyboard support
## Preview
Title Screen<br>
![Title](/Pictures/Title-Screen.png)
Random Tile Queue on Start<br>
![Random Start](/Pictures/Random-Queue-Start.png)
Incorrect Tile hit, progress bar shown on side<br>
![Fault](/Pictures/Progress-Bar-and-Incorrect-Tile.png)
Game Finished, final score displayed<br>
![Final](/Pictures/Final-Score-Screen.png)
## Game Details and Features
### The First Game Mode
In the first game mode, the player has to tap as many tiles as possible without mistapping the current black tile. The
score is timer-based, decrementing over time. The player with the highest score would be
at the top of the leaderboard.
To select this game mode press the [F1] key or the [shift] key at the start of the
program. The score counter will start counting down immediately. Use the keys [Q], [W],
[E], and [R] keys to select the first, second, third, or fourth columns of tiles respectively.
Tap the current black tile on the bottom row as quickly as possible without making a
mistake otherwise, the game will end. On a mispressed tile, a red tile is shown, hitting
[shift] will restart or another game mode can be chosen with [F1] or [F2] selecting game
mode 1 or 2 respectively. As the player progresses through the game, the progress bar
on the sidebars will fill up with green. When it is full of all green, the game is won and the
final score is displayed.
### The Second Game Mode
In the second game mode, the player must tap as many tiles as possible within a
set amount of time. If the player taps a white space, the queue resets but the player can
continue to tap away to increase their score until the timer is up. The timer is set to 30
seconds, and the final score is determined by the number of tiles tapped within this time.
A higher score would be at the top of the leaderboard.
To select this game mode press the [F2] key at the start of the program. The timer
will start to decrement as soon as the first tile is tapped. Use the [Q], [W], [E], and [R]
keys to select the first, second, third, or fourth columns of tiles respectively. Tap the
current black tiles as quickly as possible. On a mispressed tile, a red tile is shown and
hitting [shift] will reset the queue and allow the player to continue the game. As soon as
the timer hits 0 seconds, the game is won and the final score is displayed (number of tiles
tapped). At this point, hitting [shift] will restart this game mode or another game mode
can be chosen with [F1] or [F2].
### The State Diagram
![State](/Pictures/State-Diagram.jpg)
### Basic Block Diagram
![Block](/Pictures/Basic-Block-Diagram.jpg)
### Final Score Layout
![FinalLayout](/Pictures/Final-Score-Representation.jpg)
### Tile Layout
![TileLayout](/Pictures/Tile-Layout-and Queue.png)



