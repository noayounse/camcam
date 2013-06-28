import simpleTween.*;


CamCam simpleCam;

ArrayList<Dot> samples;

// scene
float panelDividerLine = 600f; // where the two panels split


void setup() {
  size(900, 500, P3D);

  SimpleTween.begin(this);
  simpleCam = new CamCam(this, new PVector(-150, 150, 150), new PVector(50, 50, 0));
  simpleCam.useLeftMouseForControl();
  randomSeed(1);

  samples = new ArrayList<Dot>();
  for (int i = 0; i < 400; i++) samples.add(new Dot(new PVector(random(-50, 100), random(-50, 100), random(-10, 10))));

  textFont(createFont("Helvetica", 12));
} // end setup



void draw() {


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
  
  drawAxis();
} // end draw

void drawAxis() {
  strokeWeight(1);
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
} // end drawAxis


ArrayList<PVector> makeSamplePoints(ArrayList<Dot> in) {
  ArrayList<PVector> pts = new ArrayList<PVector>();
  for (Dot b : in) pts.add(b.pos.value());
  return pts;
} // end makeSamplePoints

void keyReleased() {
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

/*
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
  */

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
    flip *= random(.5, 2); 
    for (int i = 0; i < samples.size(); i++) {
      samples.get(i).rot.playLive(samples.get(i).rot.value() + random(-TWO_PI, TWO_PI), random(100, 900), random(20, 30));
      samples.get(i).pos.playLive(new PVector(flip * random(-50, 100), flip * random(-50, 100), flip * random(-5, 10)));
    }
  } 
  if (key == 'i') {
    println("normlized loc / target: ");
    println(simpleCam.cameraLoc);
    println(simpleCam.cameraTarget);
    println("actual loc / target: ");
    println(simpleCam.getCameraPosition());
    println(simpleCam.getCameraTarget());
  }
  if (key == 'p') simpleCam.setPosition(new PVector(0, 0, 120), new PVector());
  if (key == 'o') simpleCam.setPosition(new PVector(0, 0, 120), new PVector(220, 0, 0), 120);
  
  if (key == 't') simpleCam.setTarget(new PVector(100, 100, 100), 100);
  
  if (key == '\'') simpleCam.setZoomTweenTime(20);
  if (key == ';') simpleCam.setZoomTweenTime(200);
} // end keyReleased

