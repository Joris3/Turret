import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

//TurretExampleV1_0

//program needs:
//header and comments
//a turret that is in the middle of the screen
//the turret aims
//the turret fires
//the turret firing has cooldown
//the turret uses PVectors
//the bullet uses PVectors
//the bullet travels

Minim minim; //Calls minim sound library
AudioPlayer[] song = new AudioPlayer[1]; //Declares audioplayer and how many songs
boolean paused; //Boolean for pause/play functionality
PVector buttonPos = new PVector(755, 25); //Position of pause/play button
PVector buttonSize = new PVector(80, 40); //Size of pause/play button

int i; //Array variable
float line = 40; //Used for instruction screen paragraph
int gameState = 0; //0 is pregame, 1 for instructions, 2 for gameplay, 3 for end screen

//Gameplay
PVector mouse; //Declares mouse PVector
int level = 1; //Level variable
int score = 0; //Displays a user score 
int lives = 3; //Lives variable
PImage image; //Background image
PImage Enemy; //Enemy image
PImage bullet; //bullet image 
PVector buttonPrePos = new PVector(400, 600); //Instructions button position 
PVector buttonPreSize = new PVector(300, 150); //Instructions button size

//Turret
PVector tPos; //Turret position
PVector tDir; //Turret cannon direction
float tSize = 100; //Turret size
int tSpeed = 2; //Turret movement speed
int tracks = 0; //controls turret tracks direction

//Bullet
//PVector bPos; //Bullet position (non array)
PVector bPos []; //Bullet position array
//PVector bVel; //Bullet velocity (non array)
PVector bVels []; //Bullet velocity array
float bSize = 20; //Bullet size
float bSpeed = 6; //Bullet speed
int fireRate = 15; //Frequency of bullet firing
int fireCount = 0; //Controls fire rate
int amBu = 5; //Amount of bullets that spawn

//Enemies
PVector ePos []; //Enemy position array
PVector eVels []; //Enemy velocity array
int amEm = 10; //Amount of enemies that spawn
float eSize = 80; //Enemy size
int spawnRate = 120; //Frequency of enemy spawning 
int aimRate = 60; //Frequency of enemies reestablishing their aim towards the turret 
float eSpeed = 2; //Enemy speed

void setup() {
  size(800, 800);
  imageMode(CENTER);
  textAlign(CENTER);
  strokeWeight(4);
  textSize(20);
  minim = new Minim(this);
  image = loadImage("map1.jpg"); //Loads images
  Enemy = loadImage("Enemy.png");
  bullet = loadImage("bullet1.png");
  for (i=0; i < song.length; i++) {
    song[i] = minim.loadFile("song.mp3"); //Loads song 
  }
  init();
}

void init() {

  mouse = new PVector(); 
  tPos = new PVector (width/2, height/2); //Beginning position of turret
  
  bPos = new PVector[amBu]; //Declares the size of the bullet array
  bVels = new PVector[amBu];

  ePos = new PVector[amEm]; //Declares the size of the enemy array
  eVels = new PVector[amEm];
}

void mousePressed() {
 
  if (gameState == 2 && fireCount > fireRate) { //Spawns in the bullets if game is on and fire rate is true 
    
    fireCount = 0; //Resets fire rate 
    for (int i = 0; i < bPos.length; i++) { //Bullet array
      
      if (bPos[i] == null) {

        bPos[i] = new PVector(tPos.x, tPos.y); //Initializes the bullet at turret pos
        bVels[i] = new PVector(tDir.x, tDir.y); //sets the direction of the bullet 
        bVels[i].normalize();
        bVels[i].mult(bSpeed); //Multiplies the direction by bullet speed
        return;
      }
    }
  }
}

PVector aim(PVector ePos, PVector tPos, PVector vel, int aimRate) { //Enemy adjustment of aim towards the turret

  if (frameCount%aimRate == 0) { //Only re aims when the aim rate is true

    PVector temp = PVector.sub(tPos, ePos);
    temp.normalize();
    return temp.mult(eSpeed);
  }
  return vel;
}

void spawnEnemy() { //Spawns in the enemies 

  if (frameCount%spawnRate == 0) { //Only spawns if the spawn rate is true 

    for (int i = 0; i < ePos.length; i++) { //Enemy array

      if (ePos[i] == null) {
        //random vector on the circle of the screen
        PVector temp = PVector.random2D();
        temp.mult(width);
        temp.add(tPos);
        ePos[i] = temp;

        //makes the enemy aim
        eVels[i] = aim(ePos[i], tPos, null, 1); //Moves the enemy in the direction of the turret
        return;
      }
    }
  }
}

boolean checkHit(PVector pos1, float size1, PVector pos2, float size2) { //Hit detection between two PVectors 

  return PVector.dist(pos1, pos2) < (size1 + size2)/2.;
}

void easterEgg() { //Added feature but also useful for testing later levels 

  if (keyPressed && keyCode == ALT) { //If alt is pressed lives is set to 10

    lives = 10;
  }

  if (mousePressed && (mouseX < (tPos.x + tSize/4)) && (mouseX > (tPos.x - tSize/4)) && (mouseY > (tPos.y - tSize/4)) && (mouseY < (tPos.y + tSize/4))) {

    score ++; //If the middle of the turret is pressed the score will climb as high as you like
  }
}

void moveTurret() { //Movement of turret function

  if (keyPressed && (key == 'w' || keyCode == UP)) { //Controls upwards movement

    tracks = 1; //Sets track direction
    tPos.y = tPos.y - tSpeed;
    if (tPos.y < tSize) { //Ensures the turret stays on the screen

      tPos.y = tSize; 
    }
  }

  else if (keyPressed && (key == 's' || keyCode == DOWN)) { //Controls downwards movement 

    tracks = 1;
    tPos.y = tPos.y + tSpeed;
    if (tPos.y > (height - tSize)) { //Ensures the turret stays on the screen

      tPos.y = (height - tSize);
    }
  }

  else if (keyPressed && (key == 'a' || keyCode == LEFT)) { //Controls leftward movement

    tracks = 2;
    tPos.x = tPos.x - tSpeed;
    if (tPos.x < tSize) { //Ensures the turret stays on the screen

      tPos.x = tSize;
    }
  }

  else if (keyPressed && (key == 'd' || keyCode == RIGHT)) { //Controls rightward movement

    tracks = 2;
    tPos.x = tPos.x + tSpeed;
    if (tPos.x > (width - tSize)) { //Ensures the turret stays on the screen

      tPos.x = (width - tSize);
    }
  }
}

public void mouseReleased(){

if ((abs(mouse.x - buttonPos.x) < buttonSize.x/2 && abs(mouse.y - buttonPos.y) < buttonSize.y/2)){ //Detects if the pause button was pressed

//Whether the boolean is true or false determines whether the song pauses or plays
if(!paused){
  pause();
}

else if(paused){
  play(); 
} 
}
}

void checkPause() { //Checks if the song is currently playing or not

 if(song[0].isPlaying()){
  paused = false; //Sets the boolean 
}

else if(!song[0].isPlaying()){
  paused = true;
}
}

void pause() { //Pause function

if(song[0].isPlaying()) {
song[0].pause();
}
}

void play(){ //Play function

if(gameState == 2){
  song[0].play();
}
}

void preGame() { //Initial gameState

  rectMode(CENTER);
  mouse = new PVector(mouseX, mouseY); //Mouse PVector
  background(0, 0, 0);
  fill(0, 255, 255);
  textSize(50);
  text("Turret Game", width/2, height*0.4); //Title
  fill(0, 255, 255);
  textSize(25);
  text("(Click anywhere to begin)", width/2, height*0.5); 
  rect(buttonPrePos.x, buttonPrePos.y, buttonPreSize.x, buttonPreSize.y); //Instruction button
  fill(0);
  text("Instructions", buttonPrePos.x, buttonPrePos.y + 5); //Button title
  if ((abs(mouse.x - buttonPrePos.x) < buttonPreSize.x/2 && abs(mouse.y - buttonPrePos.y) < buttonPreSize.y/2 && mousePressed)) { //Instructions button detection

    gameState = 1; //Sets to instructions gamestate
  } else if (mousePressed) {

    song[0].play(); //Plays song
    gameState = 2; //Begins gameplay
  }
}

void instructions() { //Instructions gameState

  background(0, 0, 0);
  textSize(30);
  fill(#03FF32);
  text("Instructions for this game are as follows: ", width/2, line*3); //Explains all the components of the game
  text("To win you must destroy the enemies that attack you, ", width/2, line*5);
  text("to kill them you must aim at them and then click", width/2, line*6);
  text("the left mouse button. You only have to hit them", width/2, line*7);
  text("once. You may also move by using the W, A, S, D keys", width/2, line*8);
  text("or by using the arrow keys. The game will become", width/2, line*9);
  text("progressively harder as you play, so more enemies", width/2, line*10);
  text("will spawn and they will move faster! If the music", width/2, line*11);
  text("is bothering you, click the button in the top right", width/2, line*12);
  text("to pause the song or play it. Finally, look out for", width/2, line*13);
  text("Easter Eggs!!!", width/2, line*14);
  text("Press the space bar to begin the game! Good luck!", width/2, line*16);
  
  if (keyPressed && key == ' ') { //If space bar is pressed the game begins 
   
    song[0].play(); //Plays song 
    gameState = 2; //Begins gameplay
  }
}

void gamePlay() { //Gameplay gameState
  
  fireCount ++; //Controls the bullet firing rate
  checkPause(); //Checks whether song is playing 
  mouse = new PVector(mouseX, mouseY); //Tracks mouse position
  
  image(image, width/2, height/2); //Background

  //update
  //get the new mouse position
  //get the aiming direction 
  tDir = PVector.sub(mouse, tPos);
  tDir.normalize();
  tDir.mult(tSize*0.8);

  for (int i = 0; i < bPos.length; i++) { //Bullet array

    if (bPos[i] != null) { //If bullet is not null draws the bullet

      bPos[i].add(bVels[i]); //Moves bullet 
      fill(255);
      noStroke();
      pushMatrix(); //Directs the bullet image in the direction it is travelling
      translate(bPos[i].x, bPos[i].y);
      rotate(bVels[i].heading());
      image(bullet, 0, 0, bSize*3, bSize*3); //Draws bullet 
      popMatrix();
      if (PVector.dist(tPos, bPos[i]) > width) { //If the bullet has travelled the length of the screen it resets

        bPos[i] = null;
      }
    }
  }

  spawnEnemy(); //Calls the enemy spawning function 

  //check 

  //draw
  fill(0);
  stroke(255);
  rect(buttonPos.x, buttonPos.y, buttonSize.x, buttonSize.y); //Draws the pause button
  fill(#19810C);
  textSize(12);
  text("PRESS ALT", 700, 520); //Easter egg clue 
  fill(0);
  noStroke();
  if (tracks == 1) { //Draws the tracks in the vertical direction 
    rect(tPos.x - tSize/2.5, tPos.y, tSize/4, tSize, 8);
    rect(tPos.x + tSize/2.5, tPos.y, tSize/4, tSize, 8);
  } else if (tracks == 2) { //Draws the tracks in the horizontal direction
    rect(tPos.x, tPos.y - tSize/2.5, tSize, tSize/4, 8);
    rect(tPos.x, tPos.y + tSize/2.5, tSize, tSize/4, 8);
  }
  fill(#00A52D);
  strokeWeight(4);
  stroke(0);
  ellipse(tPos.x, tPos.y, tSize, tSize); //Draws the turret body 
  pushMatrix(); //Aims the turret in the direction of the mouse
  translate(tPos.x, tPos.y);
  rotate(tDir.heading());
  //line(tPos.x, tPos.y, tPos.x + tDir.x, tPos.y + tDir.y);
  rect(0, 0, tDir.mag()*0.4, bSize*1.6, 5); //turret stand
  rect(28, 0, tDir.mag(), bSize*1.1, 10); //turret cannon
  popMatrix();

  moveTurret(); //Calls turret movement function 

  for (int i = 0; i < ePos.length; i++) { //Enemy array
    
    boolean dead = false; //Declares that the enemy is alive
    if (ePos[i] != null) {
      //update enemy velocity
      eVels[i] = aim(ePos[i], tPos, eVels[i], aimRate);
      ePos[i].add(eVels[i]); //Moves the enemy 
      pushMatrix(); //Aims the enemy image in the direction of the turret
      translate(ePos[i].x, ePos[i].y);
      rotate(eVels[i].heading());
      image(Enemy, 0, 0, eSize, eSize); //Draws the enemy
      popMatrix();

      if (checkHit(ePos[i], eSize, tPos, tSize)) { //Detects a hit between the enemy and the turret

        lives --; //reduces live count 
        dead = true; //Enemy will be destroyed at the end of the array
      }
      for (int j=0; j < bPos.length; j++) { //Nested for loop for bullet 
        
        if (bPos[j] != null) {

          if (checkHit(ePos[i], eSize, bPos[j], bSize)) { //Detects a hit between any bullet and any enemy

            bPos[j] = null; //Resets the bullet 
            score ++; //Adds to score 
            dead = true; //Detroys the enemy at the end of the array
          }
        }
      }
    }
    if (dead) { //If boolean is true 

      ePos[i] = null; //Resets the enemy
    }
  }

  if (lives < 1) { //If player runs out of lives this ends the game

    gameState = 3;
  }

  if (score > 20) { //Continues to level 2

    level = 2;
    spawnRate = 100; //Increases enemy spawn rate
    eSpeed = 2.5; //Increases enemy speed
  }

  if (score > 40) {

    level = 3;
    spawnRate = 80;
    eSpeed = 3;
  }

  if (score > 60) {

    level = 4;
    spawnRate = 60;
    eSpeed = 3.5;
  }

  if (score > 80) {

    level = 5;
    spawnRate = 40;
    eSpeed = 4;
  }
  
  if (score > 100) {
    
    level = 6;
    spawnRate = 20;
    eSpeed = 5;
  }

  textSize(30);

  if (level == 1) { 

    fill(255);
    text("Level 1", width*0.75, height*0.05); //Displays level on screen
  }

  if (level == 2) {

    fill(255);
    text("Level 2", width*0.75, height*0.05);
  }

  if (level == 3) {

    fill(255);
    text("Level 3", width*0.75, height*0.05);
  }

  if (level == 4) {

    fill(255);
    text("Level 4", width*0.75, height*0.05);
  }

  if (level == 5) {

    fill(255);
    text("Level 5", width*0.75, height*0.05);
  }
  
  if (level == 6) {
    
    fill(255);
    text("Final Level", width*0.75, height*0.05);
  }

  fill(255);
  text("Score: " + score, width*0.25, height*0.05); //Displays score on the screen
  text("Lives: " + lives, width*0.5, height*0.05); //Displys lives on the screen 
  stroke(255);
  strokeWeight(5);
  line(buttonPos.x + 5, buttonPos.y - 10, buttonPos.x + 5, buttonPos.y + 10); //Draws pause play icons
  line(buttonPos.x + 15, buttonPos.y - 10, buttonPos.x + 15, buttonPos.y + 10);
  triangle(buttonPos.x - 15, buttonPos.y - 8, buttonPos.x - 15, buttonPos.y + 8, buttonPos.x - 5, buttonPos.y);
  easterEgg(); //Calls easter egg function 
}

void endGame() { //Game over gameState

  background(255);
  textSize(50);
  fill(0);
  text("GAME OVER", width/2, height/2);
  textSize(20);
  text("Score: " + score, width/2, height/2 + 40); //Displays score
  song[0].pause(); //Ends the song
}

void draw() { //Draw function
 
  if (gameState == 0) { //Moves between gameStates

    preGame();
  } else if (gameState == 1) {

    instructions();
  } else if (gameState == 2) {

    gamePlay();
  } else if (gameState == 3) {

    endGame();
  } 
}
