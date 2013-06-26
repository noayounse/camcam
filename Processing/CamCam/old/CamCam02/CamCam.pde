SimpleCamera simpleCam;

ArrayList<PVector> samplePoints;

// scene
float panelDividerLine = 600f; // where the two panels split

void setup() {
  size(800, 400, P3D);
  simpleCam = new SimpleCamera();
  randomSeed(1);

  samplePoints = new ArrayList<PVector>();
  for (int i = 0; i < 100; i++) samplePoints.add(new PVector(random(-100, 100), random(-100, 100), random(-10, 10)));
} // end setup


void draw() {
  simpleCam.useCamera();
  background(0);
  stroke(125, 0, 255);
  fill(100);
  box(55);

  for (PVector p : samplePoints) {
    pushMatrix();
    translate(p.x, p.y, p.z);
    box(5);
    popMatrix();
  } 


  // temp draw a bouding box around the points
  stroke(255, 255, 0);
  BoundingBox b = new BoundingBox(simpleCam.getNormal(), samplePoints);
  b.drawBox();
  // temp draw a padded bounding box
  stroke(255, 0, 0, 150);
  ArrayList<PVector> paddedPoints = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), samplePoints, 50, 50, 50, 50, 50, 50);
  b.drawBox(paddedPoints);
  // temp draw an aspect padded bounding box
  stroke(10, 50, 200, 150);
  paddedPoints = b.makePaddedAdjustedBoundingBoxForAspect(simpleCam.getNormal(), samplePoints, 50, 50, 50, 50, 50, 50, (float)width / height);
  b.drawBox(paddedPoints);  
  

  // draw the text for the active comparison instruction
  beginCamera();
  camera();
  perspective();
  strokeWeight(1);
  stroke(0, 255, 255, 100);
  line(panelDividerLine, 0, panelDividerLine, height);
  endCamera();
} // end draw

void keyReleased() {
  if (keyCode == UP) {
    if (simpleCam.cameraDist.value() > 65) {
      if (simpleCam.cameraDist.isPlaying()) simpleCam.cameraDist.pause();
      simpleCam.cameraDist.setBegin(simpleCam.cameraDist.value() - 60);
      simpleCam.cameraDist.resetProgress();
    }
    println("moving in, cameraDist: " + simpleCam.cameraDist.value());
  }
  if (keyCode == DOWN) {
    if (simpleCam.cameraDist.isPlaying()) simpleCam.cameraDist.pause();
    simpleCam.cameraDist.setBegin(simpleCam.cameraDist.value() + 60);
    simpleCam.cameraDist.resetProgress();        
    println("moving out, cameraDist: " + simpleCam.cameraDist.value());
  }
  if (key == '1') {
    simpleCam.toTopView();
  }
  if (key == 'q') {
    simpleCam.toTopView(25);
  } 
  if (key == '2') {
    simpleCam.toFrontView();
  }
  if (key == 'w') {
    simpleCam.toFrontView(200);
  } 
  if (key == '3') {
    simpleCam.toRightView();
  } 
  if (key == 'e') {
    simpleCam.toRightView(400);
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
    simpleCam.zoomToFit(samplePoints, simpleCam.getNormal(), 100);
  }
  if (key == 'x') {
    simpleCam.zoomToFitX(samplePoints, simpleCam.getNormal(), 100);
  }
  if (key == 'y') {
    simpleCam.zoomToFitY(samplePoints, simpleCam.getNormal(), 100);
  }
  if (key == 'a') {
    BoundingBox b = new BoundingBox(new PVector(), new ArrayList<PVector>());
    ArrayList<PVector> paddedBox = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), samplePoints, 50, 50, 50, 50, 50, 50);
    simpleCam.zoomToFit(paddedBox, simpleCam.getNormal(), 100);
  } 
  if (key == 's') {
    BoundingBox b = new BoundingBox(new PVector(), new ArrayList<PVector>());
    ArrayList<PVector> paddedBox = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), samplePoints, 50, 50, 50, 50, 50, 50);
    simpleCam.zoomToFitX(paddedBox, simpleCam.getNormal(), 100);
  } 
  if (key == 'd') {
    BoundingBox b = new BoundingBox(new PVector(), new ArrayList<PVector>());
    ArrayList<PVector> paddedBox = b.makePaddedAdjustedBoundingBox(simpleCam.getNormal(), samplePoints, 50, 50, 50, 50, 50, 50);
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
} // end keyReleased

