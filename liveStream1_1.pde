import processing.video.*;
import ddf.minim.*;
import javax.sound.sampled.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
Mixer.Info[] mixerInfo;

Movie filmReel;
Capture cam;
//int index;
String myText = "Type something";

BeatDetect beat;

float eRadius;


void setup() {
  //size(720, 480, P3D);
  fullScreen(P3D);
  filmReel = new Movie(this, "/Users/ws/Documents/fanVids/technology_nature.mp4");
  cam = new Capture(this, Capture.list()[6] );
  //AUDIO SETUP
  minim = new Minim(this);
  mixerInfo = AudioSystem.getMixerInfo();
  for (int i=0; i<mixerInfo.length; i++) {
    println(mixerInfo[i], i);
  }
  Mixer mixer = AudioSystem.getMixer(mixerInfo[4]);
  minim.setInputMixer(mixer);
  //Set the buffer to half the screen so the wave line draws only halfway
  in = minim.getLineIn(Minim.STEREO, width+2);
  cam.start();
  filmReel.loop();
  beat = new BeatDetect();
  eRadius = 20;
}
boolean initialize;
void draw() {
  if (initialize) {
    startMovie();
  }
  initialize = true;
}

void movieEvent(Movie m) {
  m.read();
}

void startMovie() {
  if (cam.available() == true) {
    cam.read();
  }
  if (filmReel.available() == true) {
    movieEvent(filmReel);
  }
  background(0);
  int skip = 8;
  filmReel.loadPixels();
  for (int x=0; x < filmReel.width; x+=skip) {
    for (int y=0; y < filmReel.height; y+=skip) {
      float wave = in.left.get(x)*500;
      int index = (x + y * filmReel.width);
      int col = filmReel.pixels[index];
      float waver = map(wave, -190, 190, -5, 10); 
      fill(col);
      pushMatrix();
      translate(0, 0, waver);
      noStroke();
      ellipse(x, y, 8, 8);
      popMatrix();
    }
  }
  image(cam, width/2, 0, width/2, height/2);
  textAlign(CENTER, CENTER);
  textSize(30);
  beat.detect(in.mix);
  float a = map(eRadius, 20, 80, 10, 233);
  fill(255, a);
  if ( beat.isOnset() ) eRadius = 80;
  //ellipse(width/2, height/2, eRadius, eRadius);
  translate(0, 0, a);
  text(myText, 0, 0, width, height);
  eRadius *= 0.95;
  if ( eRadius < 20 ) eRadius = 20;
}
void keyPressed() {
  if (keyCode == BACKSPACE) {
    if (myText.length() > 0) {
      myText = myText.substring(0, myText.length()-1);
    }
  } else if (keyCode == DELETE) {
    myText = "";
  } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
    myText = myText + key;
  }
}
