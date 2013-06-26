class SimpleCamera {
  // camera stuff
  float cameraXYRotate = 0;
  float cameraZRotate = 0;
  float zoom = 1f;
  float cameraDist = 260f;
  Tween cameraTween;
  Tween zoomTween;
  boolean freeControl = false;
  PVector cameraTarget = new PVector();
  PVector cameraLoc = new PVector();
  PVector cameraShift = new PVector();
  int cameraTweenTime = 100;

  float fovy = radians(60);
  float aspect = (float)width / height;
  float cameraZ = (((float)height/2.0) / tan(radians(60)));

  PVector normal = new PVector();

  SimpleCamera () {
    perspective(fovy, aspect, cameraZ/10.0, 20 * cameraZ*10.0);
    cameraTween = new Tween(cameraTweenTime, 0, Tween.CUBIC_BOTH).add(this, "cameraXYRotate", 0).add(this, "cameraZRotate", 0);
    zoomTween = new Tween(70, 0, Tween.CUBIC_BOTH).add(this, "cameraDist", 0);
  }

  void useCamera () {
    if (freeControl) {
      cameraXYRotate = map(mouseX, 0, width, -PI, PI);
      cameraZRotate = map(mouseY, 0, height, -HALF_PI + .001, HALF_PI);
    } 
    cameraLoc = new PVector(cos(cameraXYRotate) * cameraDist*zoom * cos(cameraZRotate), sin(cameraXYRotate) * cos(cameraZRotate) * cameraDist*zoom, sin(cameraZRotate) * cameraDist*zoom);  
    camera(cameraLoc.x + cameraShift.x, cameraLoc.y + cameraShift.y, cameraLoc.z + cameraShift.z, cameraTarget.x + cameraShift.x, cameraTarget.y + cameraShift.y, cameraTarget.z + cameraShift.z, 0, 0, -1);
    normal = getNormal();
  } // end useCamera

  void pauseCamera() {
    beginCamera();
    camera();
    endCamera();
  } // end pauseCamera

  void resumeCamera() {
    beginCamera();
    useCamera();
    endCamera();
  } // end resumeCamera
  
  void zoomToFit(ArrayList<PVector> pointsIn) {
    PVector targetNormal = getNormal();
    BoundingBox b = new BoundingBox(targetNormal, pointsIn);
    float targetFill = 1; // % of screen
    float boundingBoxWidth = b.getBoxWidth();
    float boundingBoxHeight = b.getBoxHeight();
    float boxDepth = b.getBoxDepth();
    float boundingDistanceToUse = boundingBoxHeight;
    //if (boundingBoxWidth / boundingBoxHeight > aspect) boundingDistanceToUse = boundingBoxWidth * (aspect * .5);
    if (boundingBoxWidth / boundingBoxHeight > aspect) boundingDistanceToUse = boundingBoxWidth / aspect;
    float calculatedDistance = (boundingDistanceToUse / 2) / (targetFill * tan(fovy / 2));
    float additionalDist = boxDepth / 2;
    float targetDist =  calculatedDistance + additionalDist;
    zoomTween.getNumber(0).setEnd(targetDist);
    zoomTween.play();
    //new Tween(70, 0, Tween.CUBIC_BOTH).addVector(simpleCam.cameraTarget, newTarget).play();
    //new Tween(70, 0, Tween.CUBIC_BOTH).addVector(simpleCam.cameraShift, frontCentroid).play();
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

    void toTopView() {
    //prinlnt("setting camera to top view");
    float cameraXYTarget = HALF_PI;
    float cameraZTarget = HALF_PI - .0001;
    startupCameraTween(cameraXYTarget, cameraZTarget);
  } // end toTopView

  void toFrontView() {
    //prinlnt("setting camera to front view");
    float cameraXYTarget = HALF_PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget);
  } // end toFrontView

  void toRightView() {
    //prinlnt("setting camera to right view");
    float cameraXYTarget = 0;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget);
  } // end toRightView

  void toLeftView() {
    //prinlnt("setting camera to left view");
    float cameraXYTarget = PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget);
  } // end toLeftView

  void toBottomView() {
    //prinlnt("setting camera to bottom view");
    float cameraXYTarget = -HALF_PI;
    float cameraZTarget = -HALF_PI + .0001;
    startupCameraTween(cameraXYTarget, cameraZTarget);
  } // end toBottomView

  void toAxoView() {
    //prinlnt("setting camera to axo view");
    float cameraXYTarget = 1.25f;
    float cameraZTarget = .75f;
    startupCameraTween(cameraXYTarget, cameraZTarget);
  } // end toAxoView

  void startupCameraTween(float cameraXYTarget, float cameraZTarget) {
    cameraTween.getNumber(0).setEnd(cameraXYTarget);
    cameraTween.getNumber(1).setEnd(cameraZTarget);
    cameraTween.play();
    PVector targetNormal = new PVector(cos(cameraXYTarget) * cameraDist*zoom * cos(cameraZTarget), sin(cameraXYTarget) * cos(cameraZTarget) * cameraDist*zoom, sin(cameraZTarget) * cameraDist*zoom);
    targetNormal.sub(cameraTarget);
  } // end startupCameraTween

  void toggleFreeControl () {
    freeControl = !freeControl;
  } // end toggleFreeControl
} 

