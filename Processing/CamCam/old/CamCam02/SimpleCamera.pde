class SimpleCamera {
  // camera stuff
  float zoom = 1f;
  float startingCameraDist = 500f;
  FSTween leftFrustum, rightFrustum, cameraDist, cameraXYRotation, cameraZRotation;
  boolean freeControl = false;
  PVector cameraTarget = new PVector();
  PVector cameraLoc = new PVector();
  PVector cameraShift = new PVector();
  int cameraTweenTime = 140;
  float defaultMinCameraDist = 10f;

  //float leftEdge = 0;
  //float rightEdge = width;

  float fovy = radians(60); // frame of view for the y dir
  float aspect = (float)width / (1 * height);
  float cameraZ = 10000000;

  private PVector normal = new PVector();
  private PVector targetNormal = new PVector();

  SimpleCamera () {
    setupTweens();
  } // end constructor

  /*
  SimpleCamera (float leftIn, float rightIn, float fovyIn, float zDepthIn) {
   makeFrustum(leftIn, rightIn, fovyIn, 10000); 
   setupTweens();
   leftEdge = leftIn;
   rightEdge = rightIn;
   aspect = (rightIn - leftIn) / height;
   fovy = radians(fovyIn);
   cameraZ = zDepthIn;
   } // end 
   */

  void setupTweens () {
    cameraXYRotation = new FSTween(cameraTweenTime, 0, 0, 0);
    cameraZRotation = new FSTween(cameraTweenTime, 0, 0, 0);
    cameraDist = new FSTween(70, 0, startingCameraDist, startingCameraDist);
    leftFrustum = new FSTween(70, 0, 0f, 0f);
    leftFrustum.setModeQuadBoth();
    rightFrustum = new FSTween(70, 0, width, width);
    rightFrustum.setModeQuadBoth();
  } // end setupTweens

  void useCamera () {
    makeFrustum(leftFrustum.value(), rightFrustum.value(), fovy, cameraZ);

    if (freeControl) {
      cameraXYRotation.setBegin(map(mouseX, 0, width, -PI, PI));
      cameraZRotation.setBegin(map(mouseY, 0, height, -HALF_PI + .001, HALF_PI));
    } 
    cameraLoc = new PVector(cos(cameraXYRotation.value()) * cameraDist.value() *zoom * cos(cameraZRotation.value()), sin(cameraXYRotation.value()) * cos(cameraZRotation.value()) * cameraDist.value() *zoom, sin(cameraZRotation.value()) * cameraDist.value() *zoom);  
    camera(cameraLoc.x + cameraShift.x, cameraLoc.y + cameraShift.y, cameraLoc.z + cameraShift.z, cameraTarget.x + cameraShift.x, cameraTarget.y + cameraShift.y, cameraTarget.z + cameraShift.z, 0, 0, -1);
    normal = getNormal();
  } // end useCamera

  void zoomToFit(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, int durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, -1f, durationIn);
  }

  void zoomToFitX(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, int durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, false, -1f, durationIn);
  }

  void zoomToFitY(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, int durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, false, true, -1f, durationIn);
  }  

  void zoomToFitWithMinimumDistance(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, float minDistanceIn, int durationIn) {
    zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, minDistanceIn, durationIn);
  }

  void zoomToFitSpecific(ArrayList<PVector> pointsIn, PVector zoomTargetNormal, boolean onlyX, boolean onlyY, float minDistanceIn, int durationIn) {

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
    targetDist = targetDist < defaultMinCameraDist ? defaultMinCameraDist : targetDist; // default min 

    if (!cameraDist.isPlaying()) cameraDist.setDuration(durationIn);

    cameraDist.playLive(targetDist);
  } // end zoomToFit

    float getDistanceFromCameraPlane (PVector pointIn) {
    // http://paulbourke.net/geometry/pointlineplane/
    // minimum distance = (A (xa - xb) + B (ya - yb) + C (za - zb)) / sqrt(A2 + B2 + C2)
    // Let Pa = (xa, ya, za) be the point in question.
    // Pb = any point on the plane:  (xb, yb, zb)
    // A plane can be defined by its normal n = (A, B, C)
    float result = abs((normal.x * (cameraLoc.x - pointIn.x) + normal.y * (cameraLoc.y - pointIn.y) + normal.z *(cameraLoc.z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    return result;
  } // end getCameraPlane

  float getDistanceFromTargetPlane (PVector pointIn) {
    float result = abs((normal.x * (cameraTarget.x - pointIn.x) + normal.y * (cameraTarget.y - pointIn.y) + normal.z *(cameraTarget.z - pointIn.z)) / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z));
    return result;
  } // end getDistanceFromTargetPlane

  PVector getNormal () {
    PVector newNormal = new PVector(cameraTarget.x - cameraLoc.x, cameraTarget.y - cameraLoc.y, cameraTarget.z - cameraLoc.z);
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

  void toTopView(int durationIn) {
    float cameraXYTarget = HALF_PI;
    float cameraZTarget = HALF_PI - .0001;
    startupCameraTween(cameraXYTarget, cameraZTarget, durationIn);
  } // end toTopView

  void toTopView() {
    toTopView(cameraTweenTime);
  } // end toTopView

  void toFrontView(int durationIn) {
    float cameraXYTarget = HALF_PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, durationIn);
  } // end toFrontView

  void toFrontView() {
    toFrontView(cameraTweenTime);
  } // end toFrontView

  void toRightView(int durationIn) {
    float cameraXYTarget = 0;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, durationIn);
  } // end toRightView

  void toRightView() {
    toRightView(cameraTweenTime);
  } // end toRightView

  void toLeftView(int durationIn) {
    float cameraXYTarget = PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, durationIn);
  } // end toLeftView

  void toLeftView() {
    toLeftView(cameraTweenTime);
  } // end toLeftView

  void toBottomView(int durationIn) {
    float cameraXYTarget = -HALF_PI;
    float cameraZTarget = -HALF_PI + .0001;
    startupCameraTween(cameraXYTarget, cameraZTarget, durationIn);
  } // end toBottomView

  void toBottomView() {
    toBottomView(cameraTweenTime);
  } // end toBottomView

  void toAxoView(int durationIn) {
    float cameraXYTarget = 1.25f;
    float cameraZTarget = .75f;
    startupCameraTween(cameraXYTarget, cameraZTarget, durationIn);
  } // end toAxoView

  void toAxoView() {
    toAxoView(cameraTweenTime);
  } // end toAxoView

  void toCustomView(float xyTargetIn, float zTargetIn, int durationIn) {
    startupCameraTween(xyTargetIn, zTargetIn, durationIn);
  } // end toCustomView

  void toCustomView(float xyTargetIn, float zTargetIn) {
    toCustomView(xyTargetIn, zTargetIn, cameraTweenTime);
  } // end toCustomView

  void startupCameraTween(float cameraXYTarget, float cameraZTarget, int durationIn) {
    if (!freeControl) {
      if (!cameraXYRotation.isPlaying()) cameraXYRotation.setDuration(durationIn);
      if (!cameraZRotation.isPlaying()) cameraZRotation.setDuration(durationIn);
      cameraXYRotation.playLive(cameraXYTarget);
      cameraZRotation.playLive(cameraZTarget);
      targetNormal = new PVector(cos(cameraXYTarget) * cameraDist.value() * zoom * cos(cameraZTarget), sin(cameraXYTarget) * cos(cameraZTarget) * cameraDist.value() * zoom, sin(cameraZTarget) * cameraDist.value() *zoom);
      targetNormal.sub(cameraTarget);
      targetNormal.normalize();
    }
  } // end startupCameraTween

  void startFrustumTweens(float leftIn, float rightIn, int duration) {
    leftFrustum.setDuration(duration);
    rightFrustum.setDuration(duration);
    if (!leftFrustum.inRedirect) {
      leftFrustum.playLive(leftIn);
      rightFrustum.playLive(rightIn);
    }
  } // end startFrustumTweens

  void toggleFreeControl () {
    if (cameraXYRotation.isPlaying()) cameraXYRotation.pause();
    if (cameraZRotation.isPlaying()) cameraZRotation.pause();
    cameraXYRotation.resetProgress();
    cameraZRotation.resetProgress();
    freeControl = !freeControl;
  } // end toggleFreeControl

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
} // end SimpleCamera

