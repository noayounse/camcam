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

  void setupScrollWheel() {
    parent.registerMethod("mouseEvent", this);
  } 

  void useRightMouseForControl() {
    rightMouseInControl = true;
  } // end useRightMouseForControl
  void useLeftMouseForControl() {
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


    void setupTweens () {
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
  void useCamera () {

    makeFrustum(leftFrustum.value(), rightFrustum.value(), fovy, cameraZ);

    updateCameraLoc();
    camera(cameraLoc.x + cameraShift.value().x, cameraLoc.y + cameraShift.value().y, cameraLoc.z + cameraShift.value().z, cameraTarget.x + cameraShift.value().x, cameraTarget.y + cameraShift.value().y, cameraTarget.z + cameraShift.value().z, 0, 0, -1);
    normal = getNormal();
  } // end useCamera

  void updateCameraLoc() {
    cameraLoc = new PVector(cos(cameraXYRotation.value()) * cameraDist.value() *zoom * cos(cameraZRotation.value()), sin(cameraXYRotation.value()) * cos(cameraZRotation.value()) * cameraDist.value() *zoom, sin(cameraZRotation.value()) * cameraDist.value() *zoom);
  } // end updateCameraLoc

  void pauseCamera() {
    perspective();
    camera();
  } // end pauseCamera

    void resumeCamera() {
  } // end resumeCamera

    void usePawPanning() {
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

  void usePawZooming() {
    float dy = mouseY - pmouseY;
    dy *= zoomSensitivity;
    float oldCameraDistance = cameraDist.value();
    if (oldCameraDistance + dy > minCamDist) {
      cameraDist.setCurrent(oldCameraDistance + dy);
    }
  } // end usePawZooming

  void usePawMove() {
    float dy = -(mouseY - pmouseY);
    dy *= forwardsSensitivity; 
    PVector newShift = getNormal().get();
    newShift.normalize();
    newShift.mult(dy);
    PVector currentShift = cameraShift.value().get();
    currentShift.add(newShift);
    cameraShift.setCurrent(currentShift);
  } // end usePawMove

  void usePawRotation() {
    float dx = mouseX - pmouseX;
    float dy = mouseY - pmouseY;
    float oldX = cameraXYRotation.value();
    float oldY = cameraZRotation.value();

    if (abs(dy) > 0) {
      dy /= height  / 4;
      float newY = oldY + dy;
      newY = constrain(newY, (float)(-Math.PI / 2 + .001), (float)(Math.PI / 2 - .001));
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

  void togglePawing() {
    pawingControlsOn = !pawingControlsOn;
  } // end togglePawing

  // ********************** // 


  float smartMod (float numIn, float modNum) {
    float result = numIn % modNum;
    if (numIn < 0) result = (modNum + result);
    return result;
  } // end smartMod

  void zoomToFit(ArrayList<PVector> pointsIn) {
    zoomToFitSpecific(pointsIn, getNormal(), true, true, -1f, defaultZoomTime);
  }

  void zoomToFit(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, -1f, durationIn);
  }

  void zoomToFitX(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, false, -1f, durationIn);
  }

  void zoomToFitY(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, false, true, -1f, durationIn);
  }  

  void zoomToFitWithMinimumDistance(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float minDistanceIn, float durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, minDistanceIn, durationIn);
  }

  void zoomToFitSpecific(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, boolean onlyX, boolean onlyY, float minDistanceIn, float durationIn) {

    float targetHeight = height;
    float targetWidth = rightFrustum.value() - leftFrustum.value();
    float newAspect = targetWidth / targetHeight;

    BoundingBox b = new BoundingBox(zoomTargetNormal, pointsIn);
    float targetFill = .9; // % of screen
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

  void setZoomIncrement(float incrementIn) {
    zoomIncrement = incrementIn;
  } // end setZoomIncrement

  float getZoomIncrement() {
    return zoomIncrement;
  }

  void setMinDistance(float minDistIn) {
    minCamDist = minDistIn;
  } // end setMinDistance 

  float getMinDistance() {
    return minCamDist;
  } // end getMinDistance

  void zoomOut() {
    cameraDist.playLive(cameraDist.value() + zoomIncrement, defaultManualZoomTime, 0);
  } // end zoomOut

  void zoomIn() {
    float targetZoom = cameraDist.value() - zoomIncrement;
    targetZoom = targetZoom < minCamDist ? minCamDist : targetZoom;
    cameraDist.playLive(targetZoom, defaultManualZoomTime, 0);
  } // end zoomIn

  float getDistanceFromCameraPlane (PVector pointIn) {
    // http://paulbourke.net/geometry/pointlineplane/
    // minimum distance = (A (xa - xb) + B (ya - yb) + C (za - zb)) / sqrt(A2 + B2 + C2)
    // Let Pa = (xa, ya, za) be the point in question.
    // Pb = any point on the plane:  (xb, yb, zb)
    // A plane can be defined by its normal n = (A, B, C)
    float result = abs((normal.x * (cameraLoc.x - pointIn.x) + normal.y * (cameraLoc.y - pointIn.y) + normal.z *(cameraLoc.z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    //float result = abs((normal.x * (cameraLoc.value().x - pointIn.x) + normal.y * (cameraLoc.value().y - pointIn.y) + normal.z *(cameraLoc.value().z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    return result;
  } // end getCameraPlane

  float getDistanceFromTargetPlane (PVector pointIn) {
    float result = abs((normal.x * (cameraTarget.x - pointIn.x) + normal.y * (cameraTarget.y - pointIn.y) + normal.z *(cameraTarget.z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    //float result = abs((normal.x * (cameraTarget.value().x - pointIn.x) + normal.y * (cameraTarget.value().y - pointIn.y) + normal.z *(cameraTarget.value().z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    return result;
  } // end getDistanceFromTargetPlane

  PVector getNormal () {
    PVector newNormal = new PVector(cameraTarget.x - cameraLoc.x, cameraTarget.y - cameraLoc.y, cameraTarget.z - cameraLoc.z);
    //PVector newNormal = new PVector(cameraTarget.value().x - cameraLoc.value().x, cameraTarget.value().y - cameraLoc.value().y, cameraTarget.value().z - cameraLoc.value().z);
    newNormal.normalize();
    return newNormal;
  } // end getNormal

    PVector getTargetNormal() {
    if (targetNormal == null || freeControl) return getNormal();
    return targetNormal;
  } // end getTargetNormal

    // getReverseRotation will find the reverse transform rotates to billboard the image.
  // NOTE: the reverse rotation must be transformed in this order: Z, X
  // IN THE FUTURE CREATE A BILLBOARD TRANSFORM HERE
  float[] getReverseRotation () {
    float[] reversed = new float[3];
    reversed[0] = cameraZRotation.value() + HALF_PI;
    reversed[1] = PI;
    reversed[2] = cameraXYRotation.value() + HALF_PI;
    return reversed;
  } // end getReverseRotation

  void makeBillboardTransforms() {
    makeBillboardTransforms(0f);
  } // end makeBillboardTransforms
  void makeBillboardTransforms(float spacing) {
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

  void undoBillboardTransforms() {
    float[] reversed = getReverseRotation();
    rotateX(-reversed[0]);
    rotateY(-reversed[1]);
    rotateZ(-reversed[2]);
    popMatrix();
  } // end undoBillboardTransforms

  void toTopView() {
    toTopView(null, cameraTweenTime);
  } // end toTopView
  void toTopView(float durationIn) {
    toTopView(null, durationIn);
  } // end toTopView
  void toTopView(ArrayList<PVector> ptsIn) {
    toTopView(ptsIn, cameraTweenTime);
  } // end toTopView
  void toTopView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = HALF_PI;  
    float cameraZTarget = HALF_PI - .0001;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toTopView

  void toFrontView() {
    toFrontView(null, cameraTweenTime);
  } // end toFrontView
  void toFrontView(float durationIn) {
    toFrontView(null, durationIn);
  } // end toFrontView
  void toFrontView(ArrayList<PVector> ptsIn) {
    toFrontView(ptsIn, cameraTweenTime);
  } // end toFrontView
  void toFrontView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = HALF_PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toFrontView

  void toRightView() {
    toRightView(null, cameraTweenTime);
  } // end toRightView
  void toRightView(float durationIn) {
    toRightView(null, durationIn);
  } // end toRightView
  void toRightView(ArrayList<PVector> ptsIn) {
    toRightView(ptsIn, cameraTweenTime);
  } // end toRightView
  void toRightView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = 0;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toRightView


  void toLeftView() {
    toLeftView(null, cameraTweenTime);
  } // end toLeftView
  void toLeftView(float durationIn) {
    toLeftView(null, durationIn);
  } // end toLeftView
  void toLeftView(ArrayList<PVector> ptsIn) {
    toLeftView(ptsIn, cameraTweenTime);
  } // end toLeftView
  void toLeftView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toLeftView


  void toBottomView() {
    toBottomView(null, cameraTweenTime);
  } // end toBottomView
  void toBottomView(float durationIn) {
    toBottomView(null, durationIn);
  } // end toBottomView
  void toBottomView(ArrayList<PVector> ptsIn) {
    toBottomView(ptsIn, cameraTweenTime);
  } // end toBottomView
  void toBottomView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = -HALF_PI;
    float cameraZTarget = -HALF_PI + .0001;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toBottomView

  void toAxoView() {
    toAxoView(null, cameraTweenTime);
  } // end toAxoView
  void toAxoView(float durationIn) {
    toAxoView(null, durationIn);
  } // end toAxoView
  void toAxoView(ArrayList<PVector> ptsIn) {
    toAxoView(ptsIn, cameraTweenTime);
  } // end toAxoView
  void toAxoView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = 1.25f;
    float cameraZTarget = .75f;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toAxoView

  void toCustomView(float xyTargetIn, float zTargetIn) {
    toCustomView(null, xyTargetIn, zTargetIn, cameraTweenTime);
  } // end toCustomView
  void toCustomView(float xyTargetIn, float zTargetIn, float durationIn) {
    toCustomView(null, xyTargetIn, zTargetIn, durationIn);
  } // end toCustomView
  void toCustomView(ArrayList<PVector> ptsIn, float xyTargetIn, float zTargetIn) {
    toCustomView(ptsIn, xyTargetIn, zTargetIn, cameraTweenTime);
  } // end toCustomView
  void toCustomView(ArrayList<PVector> ptsIn, float xyTargetIn, float zTargetIn, float durationIn) {
    startupCameraTween(xyTargetIn, zTargetIn, ptsIn, durationIn);
  } // end toCustomView

  void startupCameraTween(float cameraXYTarget, float cameraZTarget, ArrayList<PVector> ptsIn, float durationIn) {
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

    void startFrustumTweens(float leftIn, float rightIn, float duration) {
    leftFrustum.setDuration(duration);
    rightFrustum.setDuration(duration);

    leftFrustum.playLive(leftIn);
    rightFrustum.playLive(rightIn);
  } // end startFrustumTweens


  // leftIn - the left side of the frame
  // rightIn - the right side of the frame
  // frameOfViewIn - the frame of view - in radians
  // depthIn - the depth of the view
  void makeFrustum(float leftIn, float rightIn, float frameOfViewIn, float depthIn) {
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
  void centerCamera(ArrayList<PVector> ptsIn, float duration) {
    BoundingBox b = new BoundingBox(getNormal(), ptsIn);
    PVector centroid = b.centroid;
    cameraShift.playLive(centroid, duration, 0);
    println("trying to shift the cameraShift to : " + centroid.x + ", " + centroid.y + ", " + centroid.z + " from " + cameraShift.value().x + ", " + cameraShift.value().y + ", " + cameraShift.value().z);
  } // end centerCamera

  PVector getPosition() {
    PVector newPos = PVector.add(cameraShift.value(), cameraLoc);
    return newPos;
  } // end getPosition

  void setPosition(PVector posIn) {
    setPosition(posIn, cameraTarget.get());
  } // end setPosition
  void setPosition(PVector posIn, PVector targetIn) {
    startingCameraDist = posIn.dist(targetIn);
    startingCameraDist = startingCameraDist < minCamDist ? minCamDist : startingCameraDist;
    PVector diff = PVector.sub(targetIn, posIn);
    if (diff.x == 0) diff.x = .0001;
    startingCameraRotationXY = atan(diff.y / diff.x);
    if (diff.x > 0) startingCameraRotationXY += PI;
    float xyDist = (float)Math.sqrt(diff.x * diff.x + diff.y * diff.y);
    if (xyDist != 0) startingCameraRotationZ = -atan(diff.z / xyDist);
    else startingCameraRotationZ = -atan(diff.z / .0001);
    setupTweens();
  } // end setPosition
} // end SimpleCamera

