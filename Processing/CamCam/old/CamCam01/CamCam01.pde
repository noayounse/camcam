import ijeoma.geom.test.*;
import ijeoma.geom.*;
import ijeoma.geom.tween.*;
import ijeoma.math.*;
import ijeoma.motion.tween.*;
import ijeoma.motion.event.*;
import ijeoma.geom.tween.test.*;
import ijeoma.motion.*;
import ijeoma.motion.easing.*;
import ijeoma.motion.tween.test.*;

SimpleCamera simpleCam;

ArrayList<PVector> samplePoints;

void setup(){
  size(900, 400, P3D);
  Motion.setup(this);
  simpleCam = new SimpleCamera();
  
  samplePoints = new ArrayList<PVector>();
  for (int i = 0; i < 100; i++) samplePoints.add(new PVector(random(-100, 100), random(-100, 100), random(-100, 100)));
} // end setup


void draw(){
  simpleCam.useCamera();
  background(0);
  stroke(125, 0, 255);
  fill(100);
  box(55);
  
  for (PVector p : samplePoints){
    pushMatrix();
    translate(p.x, p.y, p.z);
    box(5);
    popMatrix();
  } 
  
  simpleCam.pauseCamera();
  fill(255);
  text("hello world", 40, 40);
  simpleCam.resumeCamera();
  
  noFill();
  stroke(255, 0, 0);
  box(100);
} // end draw

void keyReleased() {
  if (keyCode == UP) {
    if (simpleCam.cameraDist > 65) simpleCam.cameraDist -= 60;
  }
  if (keyCode == DOWN) {
    simpleCam.cameraDist += 60;
  }  
  if (key == '1') {
    simpleCam.toTopView();
  }
  if (key == '2') {
    simpleCam.toFrontView();
  }
  if (key == '3') {
    simpleCam.toRightView();
  } 
  if (key == '4') {
    simpleCam.toLeftView();
  } 
  if (key == '5') {
    simpleCam.toBottomView();
  } 
  if (key == '6') {
    simpleCam.toAxoView();
  }
  if (key == 'f') {
    simpleCam.toggleFreeControl();
  }
  if (key == 'z') {
    simpleCam.zoomToFit(samplePoints);
  } 
} // end keyReleased

