import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import simpleTween.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CamCam extends PApplet {




SimpleCamera simpleCam;

PApplet parent;

ArrayList<Dot> samples;

// scene
float panelDividerLine = 600f; // where the two panels split


public void setup() {
  size(800, 400, P3D);
  parent = this;
  
  SimpleTween.begin(this);
  simpleCam = new SimpleCamera(this, new PVector(-150, 150, 150), new PVector(50, 50, 0));
  randomSeed(1);

  samples = new ArrayList<Dot>();
  for (int i = 0; i < 400; i++) samples.add(new Dot(new PVector(random(-50, 100), random(-50, 100), random(-10, 10))));
  
  textFont(createFont("Helvetica", 12));

  
} // end setup



public void draw() {
  
  
  simpleCam.useCamera();
  background(0);
  stroke(125, 0, 255);
  fill(100);
  box(55);


  for (Dot d : samples) d.display();


  // temp draw a bouding box around the points
  stroke(255, 255, 0);
  BoundingBox b = new BoundingBox(simpleCam.getNormal(), makeSamplePoints(samples));
  //b.drawBox();
  // temp draw a padded bounding box
  stroke(255, 0, 0, 150);
  ArrayList<PVector> paddedPoints = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), makeSamplePoints(samples), 50, 50, 50, 50, 50, 50);
  //b.drawBox(paddedPoints);
  // temp draw an aspect padded bounding box
  stroke(10, 50, 200, 150);
  paddedPoints = b.makePaddedAdjustedBoundingBoxForAspect(simpleCam.getNormal(), makeSamplePoints(samples), 50, 50, 50, 50, 50, 50, (float)width / height);
  //b.drawBox(paddedPoints);  
  
  rectMode(CENTER);

  PVector testBillboardPoint = new PVector(0, 0, 50);
  pushMatrix();
  translate(testBillboardPoint.x, testBillboardPoint.y, testBillboardPoint.z);
  fill(255, 255, 0);
  stroke(50);
  sphere(5);
  simpleCam.makeBillboardTransforms();
  fill(255, 0, 255, 100);
  noStroke();
  rect(0, 0, textWidth("hello world") + 20, 20);
  simpleCam.undoBillboardTransforms();
  simpleCam.makeBillboardTransforms(5f);
  fill(0);
  textAlign(CENTER, CENTER);
  text("hello world", 0, 0);
  simpleCam.undoBillboardTransforms();
  popMatrix();


  // draw the text for the active comparison instruction
  simpleCam.pauseCamera();
  strokeWeight(1);
  stroke(0, 255, 255, 100);
  line(panelDividerLine, 0, panelDividerLine, height);
  fill(255);
  textAlign(LEFT, BOTTOM);
  text(frameRate, 20, height - 20);
  simpleCam.useCamera();
  pushMatrix();
  translate(30, 30, 30);
  box(10);
  popMatrix();  
  
} // end draw


public ArrayList<PVector> makeSamplePoints(ArrayList<Dot> in){
  ArrayList<PVector> pts = new ArrayList<PVector>();
  for (Dot b : in) pts.add(b.pos.value());
  return pts;
} // end makeSamplePoints

public void keyReleased() {
  if (keyCode == UP) {
    simpleCam.zoomIn();
  }
  if (keyCode == DOWN) {
    simpleCam.zoomOut();
  }
  if (keyCode == RIGHT) {
    simpleCam.useRightMouseForControl();
  }
  if (keyCode == LEFT) {
    simpleCam.useLeftMouseForControl();
  }  
  
  if (key == '1') {
    //simpleCam.toTopView();
    simpleCam.toTopView(makeSamplePoints(samples));
  }
  if (key == 'q') {
    simpleCam.toTopView(25);
  } 
  if (key == '2') {
    //simpleCam.toFrontView();
    simpleCam.toFrontView(makeSamplePoints(samples));
  }
  if (key == 'w') {
    simpleCam.toFrontView(200);
  } 
  if (key == '3') {
    //simpleCam.toRightView();
    simpleCam.toRightView(makeSamplePoints(samples));
  } 
  if (key == 'e') {
    simpleCam.toRightView(400);
  } 
  if (key == '4') {
    //simpleCam.toLeftView();
    simpleCam.toLeftView(makeSamplePoints(samples));
  } 
  if (key == '5') {
    //simpleCam.toBottomView();
    simpleCam.toBottomView(makeSamplePoints(samples));
  } 
  if (key == '6') {
    //simpleCam.toAxoView();
    simpleCam.toAxoView(makeSamplePoints(samples));
  }
  
  if (key == 'z') {
    //simpleCam.zoomToFit(makeSamplePoints(samples), simpleCam.getNormal(), 100);
    simpleCam.zoomToFit(makeSamplePoints(samples));
  }
  if (key == 'x') {
    simpleCam.zoomToFitX(makeSamplePoints(samples), simpleCam.getNormal(), 100);
  }
  if (key == 'y') {
    simpleCam.zoomToFitY(makeSamplePoints(samples), simpleCam.getNormal(), 100);
  }
  if (key == 'a') {
    BoundingBox b = new BoundingBox(new PVector(), new ArrayList<PVector>());
    ArrayList<PVector> paddedBox = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), makeSamplePoints(samples), 50, 50, 50, 50, 50, 50);
    simpleCam.zoomToFit(paddedBox, simpleCam.getNormal(), 100);
  } 
  if (key == 's') {
    BoundingBox b = new BoundingBox(new PVector(), new ArrayList<PVector>());
    ArrayList<PVector> paddedBox = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), makeSamplePoints(samples), 50, 50, 50, 50, 50, 50);
    simpleCam.zoomToFitX(paddedBox, simpleCam.getNormal(), 100);
  } 
  if (key == 'd') {
    BoundingBox b = new BoundingBox(new PVector(), new ArrayList<PVector>());
    ArrayList<PVector> paddedBox = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), makeSamplePoints(samples), 50, 50, 50, 50, 50, 50);
    simpleCam.zoomToFitY(paddedBox, simpleCam.getNormal(), 100);
  } 
  if (key == '=') {
    println("going to right frustum");
    simpleCam.startFrustumTweens(panelDividerLine, width, 50);
  } 
  if (key == '0') {
    println("going to left frustum");
    simpleCam.startFrustumTweens(0, panelDividerLine, 50);
  }
  if (keyCode == '-') {
    println("going to center frustum");
    simpleCam.startFrustumTweens(0, width, 50);
  }
  
  if (key == 'c') {
   simpleCam.centerCamera(makeSamplePoints(samples), 100); 
  }
  if (key == 'r') {
    float flip = 1;
    if (frameCount % 2 == 0) flip = -1;
    flip *= random(.5f, 2); 
    for (int i = 0; i < samples.size(); i++) {
      samples.get(i).rot.playLive(samples.get(i).rot.value() + random(-TWO_PI, TWO_PI), random(100, 900), random(20, 30));
      samples.get(i).pos.playLive(new PVector(flip * random(-50, 100), flip * random(-50, 100), flip * random(-5, 10)));
    }
  } 
  if (key == 'i') println(simpleCam.cameraLoc);
  if (key == 'p') simpleCam.setPosition(new PVector(50, 150, 20), new PVector(50, 150, 0));
 
} // end keyReleased


class BoundingBox {
  PVector upVector = new PVector();
  PVector rightVector = new PVector();
  PVector centroid = new PVector();
  ArrayList<PVector> boundingPoints = new ArrayList<PVector>();

  BoundingBox () {
  } // end blank constructor

  BoundingBox (PVector normalIn, ArrayList<PVector> pointsIn) {
    boundingPoints = makeAdjustedBoundingBox(normalIn, pointsIn); 
    centroid = getCentroid(boundingPoints);
  } // end constructor

  public ArrayList<PVector> makeAdjustedBoundingBox (PVector normalIn, ArrayList<PVector> pointsIn) {
    ArrayList<PVector> newBoundingPoints = new ArrayList<PVector>();
    if (pointsIn.size() > 0) {
      ArrayList<PVector> orthagonalBoundingBox = makeOrthagonalBoundingBox(pointsIn);
      PVector orthangonalCentroid = getCentroid(orthagonalBoundingBox);
      normalIn = new PVector(normalIn.x, normalIn.y, normalIn.z);
      normalIn.normalize();
      ArrayList<PVector> planeVectors = makePlaneVectors(normalIn);
      upVector = planeVectors.get(0);
      rightVector = planeVectors.get(1);
      // find the extreme points
      PVector normalMin = pointsIn.get(0);
      float normalMinD = distanceFromPointToPlane(normalIn, orthangonalCentroid, normalMin);
      PVector normalMax = pointsIn.get(0);
      float normalMaxD = normalMinD;
      PVector upMin = pointsIn.get(0);
      float upMinD = distanceFromPointToPlane(upVector, orthangonalCentroid, upMin);
      PVector upMax = pointsIn.get(0);
      float upMaxD = upMinD;
      PVector rightMin = pointsIn.get(0);
      float rightMinD = distanceFromPointToPlane(rightVector, orthangonalCentroid, rightMin);
      PVector rightMax = pointsIn.get(0);
      float rightMaxD = rightMinD;
      for (int i = 1; i < pointsIn.size(); i++) {
        PVector p = pointsIn.get(i);
        float normalDist = distanceFromPointToPlane(normalIn, orthangonalCentroid, p);
        float upDist = distanceFromPointToPlane(upVector, orthangonalCentroid, p);
        float rightDist = distanceFromPointToPlane(rightVector, orthangonalCentroid, p);
        if (normalDist < normalMinD) {
          normalMin = p;
          normalMinD = normalDist;
        } 
        if (normalDist > normalMaxD) {
          normalMax = p;
          normalMaxD = normalDist;
        } 
        if (upDist < upMinD) {
          upMin = p;
          upMinD = upDist;
        } 
        if (upDist > upMaxD) {
          upMax = p;
          upMaxD = upDist;
        }
        if (rightDist < rightMinD) {
          rightMin = p;
          rightMinD = rightDist;
        } 
        if (rightDist > rightMaxD) {
          rightMax = p;
          rightMaxD = rightDist;
        }
      } 

      // find the corner points
      PVector frontRight = getProjectedPoint(rightVector, rightMax, normalMin);
      PVector frontRightTop = getProjectedPoint(upVector, upMax, frontRight);
      PVector frontRightBottom = getProjectedPoint(upVector, upMin, frontRight);
      PVector frontLeft = getProjectedPoint(rightVector, rightMin, normalMin);
      PVector frontLeftTop = getProjectedPoint(upVector, upMax, frontLeft);
      PVector frontLeftBottom = getProjectedPoint(upVector, upMin, frontLeft);
      PVector backRight = getProjectedPoint(rightVector, rightMax, normalMax);
      PVector backRightTop = getProjectedPoint(upVector, upMax, backRight);
      PVector backRightBottom = getProjectedPoint(upVector, upMin, backRight);    
      PVector backLeft = getProjectedPoint(rightVector, rightMin, normalMax);
      PVector backLeftTop = getProjectedPoint(upVector, upMax, backLeft);
      PVector backLeftBottom = getProjectedPoint(upVector, upMin, backLeft);

      newBoundingPoints.add(frontRightTop);
      newBoundingPoints.add(frontRightBottom);
      newBoundingPoints.add(frontLeftBottom);
      newBoundingPoints.add(frontLeftTop);
      newBoundingPoints.add(backRightTop);
      newBoundingPoints.add(backRightBottom);
      newBoundingPoints.add(backLeftBottom);
      newBoundingPoints.add(backLeftTop);
    }
    return newBoundingPoints;
  } // end makeAdjustedBoundingBox 

  public ArrayList<PVector> makePaddedAdjustedBoundingBox(PVector normalIn, ArrayList<PVector> pointsIn, float topAddition, float rightAddition, float bottomAddition, float leftAddition, float frontAddition, float rearAddition) {
    ArrayList<PVector> paddedBoundingPoints = makeAdjustedBoundingBox(normalIn, pointsIn); 
    ArrayList<PVector> planeVectors = makePlaneVectors(normalIn);
    if (pointsIn.size() > 0) {
      upVector = planeVectors.get(0).get();
      rightVector = planeVectors.get(1).get();
      PVector normalVector = normalIn.get();
      upVector.normalize();
      rightVector.normalize();
      normalVector.normalize();
      PVector negNormalVector = PVector.mult(normalVector, -1);
      PVector leftVector = PVector.mult(rightVector, -1);
      PVector downVector = PVector.mult(upVector, -1);
      PVector front = PVector.mult(negNormalVector, frontAddition);
      PVector rear = PVector.mult(normalVector, rearAddition);
      PVector top = PVector.mult(upVector, topAddition);
      PVector right = PVector.mult(rightVector, rightAddition);
      PVector bottom = PVector.mult(downVector, bottomAddition);
      PVector left = PVector.mult(leftVector, leftAddition);
      paddedBoundingPoints.get(0).sub(front);
      paddedBoundingPoints.get(0).sub(right);
      paddedBoundingPoints.get(0).sub(top);
      paddedBoundingPoints.get(1).sub(front);
      paddedBoundingPoints.get(1).sub(right);
      paddedBoundingPoints.get(1).sub(bottom);
      paddedBoundingPoints.get(2).sub(front);
      paddedBoundingPoints.get(2).sub(left);
      paddedBoundingPoints.get(2).sub(bottom);    
      paddedBoundingPoints.get(3).sub(front);
      paddedBoundingPoints.get(3).sub(left);
      paddedBoundingPoints.get(3).sub(top);    
      paddedBoundingPoints.get(4).sub(rear);
      paddedBoundingPoints.get(4).sub(right);
      paddedBoundingPoints.get(4).sub(top);
      paddedBoundingPoints.get(5).sub(rear);
      paddedBoundingPoints.get(5).sub(right);
      paddedBoundingPoints.get(5).sub(bottom);    
      paddedBoundingPoints.get(6).sub(rear);
      paddedBoundingPoints.get(6).sub(left);
      paddedBoundingPoints.get(6).sub(bottom);
      paddedBoundingPoints.get(7).sub(rear);
      paddedBoundingPoints.get(7).sub(left);
      paddedBoundingPoints.get(7).sub(top);
    }
    return paddedBoundingPoints;
  } // end makePaddedAdjustedBoundingBox

  public ArrayList<PVector> makePaddedAdjustedBoundingBoxForAspect(PVector normalIn, ArrayList<PVector> pointsIn, float topAddition, float rightAddition, float bottomAddition, float leftAddition, float frontAddition, float rearAddition, float aspectIn) {
    ArrayList<PVector> paddedPoints = makePaddedAdjustedBoundingBox(normalIn, pointsIn, topAddition, rightAddition, bottomAddition, leftAddition, frontAddition, rearAddition);
    BoundingBox b = new BoundingBox(normalIn, paddedPoints);
    float initialWidth = b.getBoxWidth();
    float initialHeight = b.getBoxHeight();
    if (initialWidth / initialHeight > aspectIn) {
      // increase height
      float heightIncrease = .5f * (initialWidth / (aspectIn) - initialHeight);
      topAddition += heightIncrease;
      bottomAddition += heightIncrease;
      paddedPoints = makePaddedAdjustedBoundingBox(normalIn, pointsIn, topAddition, rightAddition, bottomAddition, leftAddition, frontAddition, rearAddition);
    } 
    else if (initialWidth / initialHeight < aspectIn) {
      // increase width
      float widthIncrease = .5f * (aspectIn * initialHeight - initialWidth);
      rightAddition += widthIncrease;
      leftAddition += widthIncrease;
      paddedPoints = makePaddedAdjustedBoundingBox(normalIn, pointsIn, topAddition, rightAddition, bottomAddition, leftAddition, frontAddition, rearAddition);
    }
    return paddedPoints;
  } // end makePaddedAdjustedBoundingBoxForAspect

  public ArrayList<PVector> makeOrthagonalBoundingBox (ArrayList<PVector> pointsIn) {
    ArrayList<PVector> orthagonalBoundingCoords = new ArrayList<PVector>();
    if (pointsIn.size() > 0) {
      float minX = pointsIn.get(0).x;
      float maxX = minX;
      float minY = pointsIn.get(0).y;
      float maxY = minY;  
      float minZ = pointsIn.get(0).z;
      float maxZ = minZ;
      for (PVector p : pointsIn) {  
        float thisX = p.x;
        float thisY = p.y;
        float thisZ = p.z;
        minX = minX < thisX ? minX : thisX;
        maxX = maxX > thisX ? maxX : thisX;
        minY = minY < thisY ? minY : thisY;
        maxY = maxY > thisY ? maxY : thisY;
        minZ = minZ < thisZ ? minZ : thisZ;
        maxZ = maxZ > thisZ ? maxZ : thisZ;
      }
      orthagonalBoundingCoords.add(new PVector(minX, minY, minZ));
      orthagonalBoundingCoords.add(new PVector(maxX, minY, minZ));
      orthagonalBoundingCoords.add(new PVector(minX, maxY, minZ));
      orthagonalBoundingCoords.add(new PVector(maxX, maxY, minZ));
      orthagonalBoundingCoords.add(new PVector(minX, minY, maxZ));
      orthagonalBoundingCoords.add(new PVector(maxX, minY, maxZ));
      orthagonalBoundingCoords.add(new PVector(minX, maxY, maxZ));
      orthagonalBoundingCoords.add(new PVector(maxX, maxY, maxZ));
    }
    return orthagonalBoundingCoords;
  } // end makeOrthagonalBoundingBox

  public PVector getCentroid (ArrayList<PVector> pointsIn) {
    PVector result = new PVector();
    for (PVector p : pointsIn) result.add(p);
    result.div(pointsIn.size());
    return result;
  } // end getCentroid

  public ArrayList<PVector> makePlaneVectors (PVector normalIn) {
    ArrayList<PVector> planeVectors = new ArrayList<PVector>();
    PVector right =   new PVector(-normalIn.y, normalIn.x, 0);
    PVector up = new PVector();
    PVector.cross(normalIn, right, up);
    right.normalize();
    up.normalize();
    planeVectors.add(up);
    planeVectors.add(right);
    return planeVectors;
  } // end makeUpVector

  // drawBox will draw a simple bounding box based on the particular order of points specified in makeAdjustedBoundingBox() 
  public void drawBox() {
    drawBox(boundingPoints);
  } // end drawBox

  public void drawBox(ArrayList<PVector> pointsIn) {
    if (pointsIn.size() > 0) {
      noFill();
      beginShape();
      for (int i = 0; i < 4; i++) vertex(pointsIn.get(i).x, pointsIn.get(i).y, pointsIn.get(i).z);
      endShape(CLOSE);
      beginShape();
      for (int i = 4; i < 8; i++) vertex(pointsIn.get(i).x, pointsIn.get(i).y, pointsIn.get(i).z);
      endShape(CLOSE);
      for (int i = 0; i < 4; i++) line(pointsIn.get(i).x, pointsIn.get(i).y, pointsIn.get(i).z, pointsIn.get(i + 4).x, pointsIn.get(i + 4).y, pointsIn.get(i + 4).z);
    }
  } // end drawBox

  // front face is defined as the first four points
  public float getBoxWidth() {
    if (boundingPoints.size() > 0) return (boundingPoints.get(0).dist(boundingPoints.get(3)));
    return 0;
  } // end getBoundingBoxWidth
  public float getBoxHeight() {
    if (boundingPoints.size() > 0) return (boundingPoints.get(0).dist(boundingPoints.get(1)));
    return 0;
  } // end getBoundingBoxHeight
  public float getBoxDepth() {
    if (boundingPoints.size() > 0) return (boundingPoints.get(0).dist(boundingPoints.get(4)));
    return 0;
  } // end getBoundingBoxDepth

  public PVector getBoxFrontPlaneCentroid() {
    PVector centroid = new PVector();
    if (boundingPoints.size() > 0) {
      for (int i = 0; i < 4; i++) centroid.add(boundingPoints.get(i));
      centroid.div(4);
    }
    return centroid;
  } // end getFrontCentroid

    public void drawBoxCorners() {
    for (PVector p : boundingPoints) {
      drawPoint(p);
    }
  } // end drawBoundingCorners

  public void drawPoint(PVector pointIn) {
    pushMatrix();
    translate(pointIn.x, pointIn.y, pointIn.z);
    sphere(4);
    popMatrix();
  } // end drawPoint

  // drawLineFromPointToPlane will draw a line from a point to a plane - note: specify color beforehand
  public void drawLineFromPointToPlane (PVector normalIn, PVector planePoint, PVector questionPoint) {
    PVector directionalVector = getPointToPlaneVector(normalIn, planePoint, questionPoint);
    line(questionPoint.x, questionPoint.y, questionPoint.z, questionPoint.x + directionalVector.x, questionPoint.y + directionalVector.y, questionPoint.z + directionalVector.z);
  } // end drawLineFromPointToPlane

  // distanceFromPointToPlane will return a float describing how far a point is from a plane
  public float distanceFromPointToPlane (PVector normalIn, PVector planePoint, PVector questionPoint) {
    float distanceDifference = ((normalIn.x * (planePoint.x - questionPoint.x) + normalIn.y * (planePoint.y - questionPoint.y) + normalIn.z *(planePoint.z - questionPoint.z)) / sqrt(normalIn.x * normalIn.x + normalIn.y * normalIn.y + normalIn.z * normalIn.z));
    return distanceDifference;
  } // end distanceFromPointToPlane

    // getPointToPlaneVector will return the vector direction from the input point to the plane
  public PVector getPointToPlaneVector (PVector normalIn, PVector planePoint, PVector questionPoint) {
    normalIn = new PVector(normalIn.x, normalIn.y, normalIn.z);
    float distanceDifference = distanceFromPointToPlane(normalIn, planePoint, questionPoint);
    normalIn.normalize();
    normalIn.mult(distanceDifference);
    //PVector result = PVector.add(questionPoint, normalIn);
    //return result;
    return normalIn;
  } // end projectPointToPlane

  // getProjectedPoint will return a new point projected onto the target plane
  public PVector getProjectedPoint (PVector normalIn, PVector planePoint, PVector questionPoint) {
    PVector projectedPoint = new PVector(questionPoint.x, questionPoint.y, questionPoint.z);
    projectedPoint.add(getPointToPlaneVector(normalIn, planePoint, questionPoint));
    return projectedPoint;
  } // end getProjectedPoint
} // end class NormalBoundingBox

class Dot {
  PVSTween pos = new PVSTween(100, 0, new PVector(), new PVector());
  FSTween rot = new FSTween(100, 0, 0, 0); 
  
  Dot (PVector pos_){
    pos.setCurrent(pos_);
  } // end constructor
  
  public void display(){
    pushMatrix();
    translate(pos.value().x, pos.value().y, pos.value().z);
    rotate(rot.value());
    stroke(255);
    noFill();
    box(5);
    popMatrix();
  } // end display
  
} // end class Dot
public class SimpleCamera {
  PApplet parent;

  // camera stuff
  float zoom = 1f;
  float startingCameraDist = 500f;
  float startingCameraRotationXY = 0f;
  float startingCameraRotationZ = 0f;
  PVector initialPosition = new PVector();
  PVector initialTarget = new PVector();
  FSTween leftFrustum, rightFrustum, cameraDist, cameraXYRotation, cameraZRotation;

  PVector cameraTarget = new PVector();
  PVector cameraLoc = new PVector();
  PVSTween cameraShift;
  int cameraTweenTime = 140;
  float zoomIncrement = 150f;
  float defaultZoomTime = 90;
  float defaultManualZoomTime = 40;
  float minCamDist = 10f;

  float fovy = radians(60); // frame of view for the y dir
  float aspect = (float)width / (1 * height);
  float cameraZ = 10000000;

  private PVector normal = new PVector();
  private PVector targetNormal = new PVector();

  // control vars
  // ********************** // 
  boolean freeControl = false;
  boolean pawingControlsOn = true;
  boolean rightMouseInControl = true;
  float panSensitivity = .0025f;
  float zoomSensitivity = 1f;
  float forwardsSensitivity = 1f;

  int lastFrame = 0;

  SimpleCamera (PApplet parent_) {
    parent = parent_;
    setupTweens();
    setupScrollWheel();
  } // end constructor
  SimpleCamera (PApplet parent_, PVector initialPosition_, PVector initialTarget_) {
    parent = parent_;
    initialPosition = initialPosition_;
    initialTarget = initialTarget_;
    setPosition(initialPosition, initialTarget);
    setupScrollWheel();
  } // end constructor

  public void setupScrollWheel() {
    parent.registerMethod("mouseEvent", this);
  } 

  public void useRightMouseForControl() {
    rightMouseInControl = true;
  } // end useRightMouseForControl
  public void useLeftMouseForControl() {
    rightMouseInControl = false;
  } // end useLeftMouseForControl

  public void mouseEvent(MouseEvent event) {
    // see https://github.com/processing/processing/wiki/Library-Basics for info on getting the mouse stuff to work
    boolean pressedSpace = (keyPressed && key == ' ');
    boolean pressedShift = (keyPressed && keyCode == parent.SHIFT);


    if (pawingControlsOn && lastFrame != frameCount) {
      if (event.getAction() == MouseEvent.DRAG) {

        if (event.getButton() == RIGHT && rightMouseInControl) {
          if (pressedSpace) {
            usePawZooming();
          }
          else if (pressedShift) {
            usePawPanning();
          }
          else {
            usePawRotation();
          }
        }
        else if (event.getButton() == LEFT && !rightMouseInControl) {
          if (pressedSpace) {
            usePawZooming();
          }
          else if (pressedShift) {
            usePawPanning();
          } 
          else {
            usePawRotation();
          }
        }
      }
      else if (event.getAction() == MouseEvent.WHEEL) {
        int zoomAmount = event.getCount();
        float totalToZoom = -zoomAmount * zoomIncrement / 10;
        float targetZoom = cameraDist.value() - totalToZoom;
        targetZoom = targetZoom < minCamDist ? minCamDist : targetZoom;
        cameraDist.setCurrent(targetZoom);
      }
    }
    lastFrame = frameCount;
  } // end mouseEvent


    public void setupTweens () {
    cameraShift = new PVSTween(1, 0, initialTarget, initialTarget);
    cameraXYRotation = new FSTween(cameraTweenTime, 0, startingCameraRotationXY, startingCameraRotationXY);
    cameraZRotation = new FSTween(cameraTweenTime, 0, startingCameraRotationZ, startingCameraRotationZ);
    cameraDist = new FSTween(defaultZoomTime, 0, startingCameraDist, startingCameraDist);
    leftFrustum = new FSTween(70, 0, 0f, 0f);
    leftFrustum.setModeQuadBoth();
    rightFrustum = new FSTween(70, 0, width, width);
    rightFrustum.setModeQuadBoth();
    updateCameraLoc();
  } // end setupTweens


  // ********************** // 
  public void useCamera () {

    makeFrustum(leftFrustum.value(), rightFrustum.value(), fovy, cameraZ);

    updateCameraLoc();
    camera(cameraLoc.x + cameraShift.value().x, cameraLoc.y + cameraShift.value().y, cameraLoc.z + cameraShift.value().z, cameraTarget.x + cameraShift.value().x, cameraTarget.y + cameraShift.value().y, cameraTarget.z + cameraShift.value().z, 0, 0, -1);
    normal = getNormal();
  } // end useCamera

  public void updateCameraLoc() {
    cameraLoc = new PVector(cos(cameraXYRotation.value()) * cameraDist.value() *zoom * cos(cameraZRotation.value()), sin(cameraXYRotation.value()) * cos(cameraZRotation.value()) * cameraDist.value() *zoom, sin(cameraZRotation.value()) * cameraDist.value() *zoom);
  } // end updateCameraLoc

  public void pauseCamera() {
    perspective();
    camera();
  } // end pauseCamera

    public void resumeCamera() {
  } // end resumeCamera

    public void usePawPanning() {
    BoundingBox b = new BoundingBox();
    ArrayList<PVector> upRight = b.makePlaneVectors(getNormal());
    PVector oldCameraShift = cameraShift.value();
    PVector up = upRight.get(0);
    PVector right = upRight.get(1);
    float dx = mouseX - pmouseX;
    float dy = mouseY - pmouseY;
    dx *= panSensitivity * cameraDist.value();
    dy *= panSensitivity * cameraDist.value();
    up.normalize();
    up.mult(dy);
    right.normalize();
    right.mult(dx);
    oldCameraShift.add(up);
    oldCameraShift.sub(right);
    cameraShift.setCurrent(oldCameraShift);
  } // end usePawPanning

  public void usePawZooming() {
    float dy = mouseY - pmouseY;
    dy *= zoomSensitivity;
    float oldCameraDistance = cameraDist.value();
    if (oldCameraDistance + dy > minCamDist) {
      cameraDist.setCurrent(oldCameraDistance + dy);
    }
  } // end usePawZooming

  public void usePawMove() {
    float dy = -(mouseY - pmouseY);
    dy *= forwardsSensitivity; 
    PVector newShift = getNormal().get();
    newShift.normalize();
    newShift.mult(dy);
    PVector currentShift = cameraShift.value().get();
    currentShift.add(newShift);
    cameraShift.setCurrent(currentShift);
  } // end usePawMove

  public void usePawRotation() {
    float dx = mouseX - pmouseX;
    float dy = mouseY - pmouseY;
    float oldX = cameraXYRotation.value();
    float oldY = cameraZRotation.value();

    if (abs(dy) > 0) {
      dy /= height  / 4;
      float newY = oldY + dy;
      newY = constrain(newY, (float)(-Math.PI / 2 + .001f), (float)(Math.PI / 2 - .001f));
      //cameraZRotation.setBegin(newY);
      cameraZRotation.setCurrent(newY);
      //println(frameCount + " -- moved Y: " + newY);
    }

    if (abs(dx) > 0) {
      dx /= width / 4;
      float newX = oldX + dx;
      newX = smartMod(newX, TWO_PI);
      //cameraXYRotation.setBegin(newX);
      cameraXYRotation.setCurrent(newX);
      //println(frameCount + " -- moved X: " + newX + " is it playing? " + cameraXYRotation.isPlaying() + " isDone?: " + cameraXYRotation.isDone());
    }
  } // end usePawRotation

  public void togglePawing() {
    pawingControlsOn = !pawingControlsOn;
  } // end togglePawing

  // ********************** // 


  public float smartMod (float numIn, float modNum) {
    float result = numIn % modNum;
    if (numIn < 0) result = (modNum + result);
    return result;
  } // end smartMod

  public void zoomToFit(ArrayList<PVector> pointsIn) {
    zoomToFitSpecific(pointsIn, getNormal(), true, true, -1f, defaultZoomTime);
  }

  public void zoomToFit(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, -1f, durationIn);
  }

  public void zoomToFitX(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, false, -1f, durationIn);
  }

  public void zoomToFitY(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, false, true, -1f, durationIn);
  }  

  public void zoomToFitWithMinimumDistance(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float minDistanceIn, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, minDistanceIn, durationIn);
  }

  public void zoomToFitSpecific(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, boolean onlyX, boolean onlyY, float minDistanceIn, float durationIn) {

    float targetHeight = height;
    float targetWidth = rightFrustum.value() - leftFrustum.value();
    float newAspect = targetWidth / targetHeight;

    BoundingBox b = new BoundingBox(zoomTargetNormal, pointsIn);
    float targetFill = .9f; // % of screen
    float boundingBoxWidth = b.getBoxWidth();
    float boundingBoxHeight = b.getBoxHeight();

    float boxDepth = b.getBoxDepth();

    float boundingDistanceToUse = boundingBoxHeight; // force y
    if (onlyX && !onlyY) boundingDistanceToUse = boundingBoxWidth / newAspect; // force x
    // if both x and y are on, check for aspect
    else if (onlyX & onlyY) {
      if (boundingBoxWidth / boundingBoxHeight > newAspect) {
        boundingDistanceToUse = boundingBoxWidth / newAspect;
      }
    }

    float additionalDist = boxDepth / 2;
    //println("boxwidth: " + boundingBoxWidth + " boxheight:" + boundingBoxHeight + " boxdepth: " + boxDepth + " -- " + (boundingBoxWidth / boundingBoxHeight) + " newAspect: " + newAspect + " fovy: " + fovy + " degrees fovy: " + degrees(fovy));

    float targetDist =  additionalDist + (boundingDistanceToUse / 2f) / (targetFill * atan(fovy / 2f));
    targetDist = targetDist < minDistanceIn ? minDistanceIn : targetDist;
    targetDist = targetDist < minCamDist ? minCamDist : targetDist; // default min 

    cameraDist.playLive(targetDist, durationIn, 0);

    cameraShift.playLive(b.centroid, durationIn, 0);
  } // end zoomToFit

  public void setZoomIncrement(float incrementIn) {
    zoomIncrement = incrementIn;
  } // end setZoomIncrement

  public float getZoomIncrement() {
    return zoomIncrement;
  }

  public void setMinDistance(float minDistIn) {
    minCamDist = minDistIn;
  } // end setMinDistance 

  public float getMinDistance() {
    return minCamDist;
  } // end getMinDistance

  public void zoomOut() {
    cameraDist.playLive(cameraDist.value() + zoomIncrement, defaultManualZoomTime, 0);
  } // end zoomOut

  public void zoomIn() {
    float targetZoom = cameraDist.value() - zoomIncrement;
    targetZoom = targetZoom < minCamDist ? minCamDist : targetZoom;
    cameraDist.playLive(targetZoom, defaultManualZoomTime, 0);
  } // end zoomIn

  public float getDistanceFromCameraPlane (PVector pointIn) {
    // http://paulbourke.net/geometry/pointlineplane/
    // minimum distance = (A (xa - xb) + B (ya - yb) + C (za - zb)) / sqrt(A2 + B2 + C2)
    // Let Pa = (xa, ya, za) be the point in question.
    // Pb = any point on the plane:  (xb, yb, zb)
    // A plane can be defined by its normal n = (A, B, C)
    float result = abs((normal.x * (cameraLoc.x - pointIn.x) + normal.y * (cameraLoc.y - pointIn.y) + normal.z *(cameraLoc.z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    //float result = abs((normal.x * (cameraLoc.value().x - pointIn.x) + normal.y * (cameraLoc.value().y - pointIn.y) + normal.z *(cameraLoc.value().z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    return result;
  } // end getCameraPlane

  public float getDistanceFromTargetPlane (PVector pointIn) {
    float result = abs((normal.x * (cameraTarget.x - pointIn.x) + normal.y * (cameraTarget.y - pointIn.y) + normal.z *(cameraTarget.z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    //float result = abs((normal.x * (cameraTarget.value().x - pointIn.x) + normal.y * (cameraTarget.value().y - pointIn.y) + normal.z *(cameraTarget.value().z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    return result;
  } // end getDistanceFromTargetPlane

  public PVector getNormal () {
    PVector newNormal = new PVector(cameraTarget.x - cameraLoc.x, cameraTarget.y - cameraLoc.y, cameraTarget.z - cameraLoc.z);
    //PVector newNormal = new PVector(cameraTarget.value().x - cameraLoc.value().x, cameraTarget.value().y - cameraLoc.value().y, cameraTarget.value().z - cameraLoc.value().z);
    newNormal.normalize();
    return newNormal;
  } // end getNormal

    public PVector getTargetNormal() {
    if (targetNormal == null || freeControl) return getNormal();
    return targetNormal;
  } // end getTargetNormal

    // getReverseRotation will find the reverse transform rotates to billboard the image.
  // NOTE: the reverse rotation must be transformed in this order: Z, X
  // IN THE FUTURE CREATE A BILLBOARD TRANSFORM HERE
  public float[] getReverseRotation () {
    float[] reversed = new float[3];
    reversed[0] = cameraZRotation.value() + HALF_PI;
    reversed[1] = PI;
    reversed[2] = cameraXYRotation.value() + HALF_PI;
    return reversed;
  } // end getReverseRotation

  public void makeBillboardTransforms() {
    makeBillboardTransforms(0f);
  } // end makeBillboardTransforms
  public void makeBillboardTransforms(float spacing) {
    float[] reversed = getReverseRotation();
    PVector norm = getNormal().get();
    norm.normalize();
    norm.mult(-spacing);
    pushMatrix();
    translate(norm.x, norm.y, norm.z);
    rotateZ(reversed[2]);
    rotateY(reversed[1]);
    rotateX(reversed[0]);
  } // end makeBillbaordTransformsWithDepthSpacing

  public void undoBillboardTransforms() {
    float[] reversed = getReverseRotation();
    rotateX(-reversed[0]);
    rotateY(-reversed[1]);
    rotateZ(-reversed[2]);
    popMatrix();
  } // end undoBillboardTransforms

  public void toTopView() {
    toTopView(null, cameraTweenTime);
  } // end toTopView
  public void toTopView(float durationIn) {
    toTopView(null, durationIn);
  } // end toTopView
  public void toTopView(ArrayList<PVector> ptsIn) {
    toTopView(ptsIn, cameraTweenTime);
  } // end toTopView
  public void toTopView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = HALF_PI;  
    float cameraZTarget = HALF_PI - .0001f;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toTopView

  public void toFrontView() {
    toFrontView(null, cameraTweenTime);
  } // end toFrontView
  public void toFrontView(float durationIn) {
    toFrontView(null, durationIn);
  } // end toFrontView
  public void toFrontView(ArrayList<PVector> ptsIn) {
    toFrontView(ptsIn, cameraTweenTime);
  } // end toFrontView
  public void toFrontView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = HALF_PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toFrontView

  public void toRightView() {
    toRightView(null, cameraTweenTime);
  } // end toRightView
  public void toRightView(float durationIn) {
    toRightView(null, durationIn);
  } // end toRightView
  public void toRightView(ArrayList<PVector> ptsIn) {
    toRightView(ptsIn, cameraTweenTime);
  } // end toRightView
  public void toRightView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = 0;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toRightView


  public void toLeftView() {
    toLeftView(null, cameraTweenTime);
  } // end toLeftView
  public void toLeftView(float durationIn) {
    toLeftView(null, durationIn);
  } // end toLeftView
  public void toLeftView(ArrayList<PVector> ptsIn) {
    toLeftView(ptsIn, cameraTweenTime);
  } // end toLeftView
  public void toLeftView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toLeftView


  public void toBottomView() {
    toBottomView(null, cameraTweenTime);
  } // end toBottomView
  public void toBottomView(float durationIn) {
    toBottomView(null, durationIn);
  } // end toBottomView
  public void toBottomView(ArrayList<PVector> ptsIn) {
    toBottomView(ptsIn, cameraTweenTime);
  } // end toBottomView
  public void toBottomView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = -HALF_PI;
    float cameraZTarget = -HALF_PI + .0001f;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toBottomView

  public void toAxoView() {
    toAxoView(null, cameraTweenTime);
  } // end toAxoView
  public void toAxoView(float durationIn) {
    toAxoView(null, durationIn);
  } // end toAxoView
  public void toAxoView(ArrayList<PVector> ptsIn) {
    toAxoView(ptsIn, cameraTweenTime);
  } // end toAxoView
  public void toAxoView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = 1.25f;
    float cameraZTarget = .75f;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toAxoView

  public void toCustomView(float xyTargetIn, float zTargetIn) {
    toCustomView(null, xyTargetIn, zTargetIn, cameraTweenTime);
  } // end toCustomView
  public void toCustomView(float xyTargetIn, float zTargetIn, float durationIn) {
    toCustomView(null, xyTargetIn, zTargetIn, durationIn);
  } // end toCustomView
  public void toCustomView(ArrayList<PVector> ptsIn, float xyTargetIn, float zTargetIn) {
    toCustomView(ptsIn, xyTargetIn, zTargetIn, cameraTweenTime);
  } // end toCustomView
  public void toCustomView(ArrayList<PVector> ptsIn, float xyTargetIn, float zTargetIn, float durationIn) {
    startupCameraTween(xyTargetIn, zTargetIn, ptsIn, durationIn);
  } // end toCustomView

  public void startupCameraTween(float cameraXYTarget, float cameraZTarget, ArrayList<PVector> ptsIn, float durationIn) {
    if (cameraXYRotation.value() - cameraXYTarget > PI) cameraXYTarget = TWO_PI + cameraXYTarget;
    cameraXYRotation.playLive(cameraXYTarget, durationIn, 0);
    cameraZRotation.playLive(cameraZTarget, durationIn, 0);
    targetNormal = new PVector(cos(cameraXYTarget) * cameraDist.value() * zoom * cos(cameraZTarget), sin(cameraXYTarget) * cos(cameraZTarget) * cameraDist.value() * zoom, sin(cameraZTarget) * cameraDist.value() *zoom);
    targetNormal.sub(cameraTarget);
    //targetNormal.sub(cameraTarget.value());
    targetNormal.normalize();
    if (ptsIn != null) {
      zoomToFit(ptsIn, targetNormal, durationIn);
    }
  } // end startupCameraTween

    public void startFrustumTweens(float leftIn, float rightIn, float duration) {
    leftFrustum.setDuration(duration);
    rightFrustum.setDuration(duration);

    leftFrustum.playLive(leftIn);
    rightFrustum.playLive(rightIn);
  } // end startFrustumTweens


  // leftIn - the left side of the frame
  // rightIn - the right side of the frame
  // frameOfViewIn - the frame of view - in radians
  // depthIn - the depth of the view
  public void makeFrustum(float leftIn, float rightIn, float frameOfViewIn, float depthIn) {
    leftIn = constrain(leftIn, 0, width);
    rightIn = constrain(rightIn, 0, width);
    leftIn /= width;
    rightIn /= width;
    float fovy = frameOfViewIn;
    float aspect = (float)width / height;
    float left = leftIn + (rightIn - leftIn) / 2f;
    float right = (1 - left);
    frustum(-left * aspect, right * aspect, -(1f / 2), (1f / 2), .5f / (atan(fovy / 2)), depthIn);
  } // end makeFrustum

  // will play with the cameraShift to center the cameraTarget to the middle of the ptsIn
  public void centerCamera(ArrayList<PVector> ptsIn, float duration) {
    BoundingBox b = new BoundingBox(getNormal(), ptsIn);
    PVector centroid = b.centroid;
    cameraShift.playLive(centroid, duration, 0);
    println("trying to shift the cameraShift to : " + centroid.x + ", " + centroid.y + ", " + centroid.z + " from " + cameraShift.value().x + ", " + cameraShift.value().y + ", " + cameraShift.value().z);
  } // end centerCamera

  public PVector getPosition() {
    PVector newPos = PVector.add(cameraShift.value(), cameraLoc);
    return newPos;
  } // end getPosition

  public void setPosition(PVector posIn) {
    setPosition(posIn, cameraTarget.get());
  } // end setPosition
  public void setPosition(PVector posIn, PVector targetIn) {
    startingCameraDist = posIn.dist(targetIn);
    startingCameraDist = startingCameraDist < minCamDist ? minCamDist : startingCameraDist;
    PVector diff = PVector.sub(targetIn, posIn);
    if (diff.x == 0) diff.x = .0001f;
    startingCameraRotationXY = atan(diff.y / diff.x);
    if (diff.x > 0) startingCameraRotationXY += PI;
    float xyDist = (float)Math.sqrt(diff.x * diff.x + diff.y * diff.y);
    if (xyDist != 0) startingCameraRotationZ = -atan(diff.z / xyDist);
    else startingCameraRotationZ = -atan(diff.z / .0001f);
    setupTweens();
  } // end setPosition
} // end SimpleCamera

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CamCam" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
