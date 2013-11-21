public class CamCam {
  public PApplet parent;

  private STween base;

  // camera stuff
  private float startingCameraDist = 500f;
  private float startingCameraRotationXY = 0f;
  private float startingCameraRotationZ = 0f;
  private float startingLeftEdge = 0f;
  private float startingRightEdge = 0f;
  private PVector initialPosition = new PVector();
  private PVector initialTarget = new PVector();
  private FSTween leftFrustum, rightFrustum, cameraDist, cameraXYRotation, cameraZRotation;

  private float lastCamX = .0001f;
  private float lastCamY = 0f;
  private float lastCameraZRotation = 0f;
  private int upDirection = 1; 

  private float xyRotationInertia = 0f;
  private float zRotationInertia = 0f;
  private float distInertia = 0f;
  private PVector shiftInertia = new PVector();
  private float inertiaFriction = (float).85;

  private PVector cameraTarget = new PVector();
  private PVector cameraLoc = new PVector();
  private PVSTween cameraShift;
  // **** //
  private PVSTween manualShift; // // when manually moving will just cumulatively add up.  When a new playLive is recorded, this will playLive back to 0 unless interrupted 
  private float cameraTweenTimeSeconds = 1.5f;
  private float cameraTweenTimeFrames = 140f;
  private float cameraTweenTime = cameraTweenTimeFrames;  
  private float zoomIncrement = 150f;
  private float zoomToFitFill = .9; // % of screen
  private float defaultZoomtimeFrames = 90;
  private float defaultZoomtimeSeconds = 1.5;
  private float defaultZoomTime = defaultZoomtimeFrames;
  private float defaultManualZoomTime = defaultZoomtimeFrames / 2;
  private float minCamDist = 10f;

  private float fovy = (float)(Math.PI * (60f) / 180f); // frame of view for the y dir
  private float aspect = (float)width / (1 * height);
  private float cameraZ = 10000000;

  private PVector normal = new PVector();
  private PVector targetNormal = new PVector();

  // control vars
  private boolean mouseIsPressed = false;
  public boolean pawingControlsOn = true;
  public boolean disablePawingOrbit = false;
  public boolean disablePawingZooming = false;
  public boolean disablePawingPanning = false;  
  private boolean keyControlsOn = true;
  private boolean rightMouseInControl = true;
  private float panSensitivity = 1f;
  private float zoomSensitivity = 1f;
  private float forwardsSensitivity = 1f;

  private final int CONTROL_SCHEMA_A = 0;
  private final int CONTROL_SCHEMA_B = 1;
  private int currentControlSchema = CONTROL_SCHEMA_A;

  private boolean setRestrictionPanningZ = false;


  private int lastFrame = 0;

  public CamCam (PApplet parent_) {
    parent = parent_;
    startingLeftEdge = 0f;
    startingRightEdge = parent.width;
    setupTweens();
    setupEvents();
  } // end constructor
  public CamCam (PApplet parent_, PVector initialPosition_, PVector initialTarget_) {
    parent = parent_;
    startingLeftEdge = 0f;
    startingRightEdge = parent.width;
    initialPosition = initialPosition_;
    initialTarget = initialTarget_;
    setPosition(initialPosition, initialTarget);
    setupEvents();
  } // end constructor

  private void setupEvents() {
    parent.registerMethod("mouseEvent", this);
    parent.registerMethod("keyEvent", this);
  } 



  private void setupTweens () {
    SimpleTween.begin(parent);

    base = new STween(13, 0, 0, 1);
    base.setTimeMode(SimpleTween.baseTimeMode);
    base.setEase(SimpleTween.getEasing());

    cameraShift = new PVSTween(1, 0, initialTarget, initialTarget);
    // **** //
    manualShift = new PVSTween(1, 0, new PVector(), new PVector());
    cameraXYRotation = new FSTween(cameraTweenTime, 0, startingCameraRotationXY, startingCameraRotationXY);
    cameraZRotation = new FSTween(cameraTweenTime, 0, startingCameraRotationZ, startingCameraRotationZ);
    cameraDist = new FSTween(defaultZoomTime, 0, startingCameraDist, startingCameraDist);
    leftFrustum = new FSTween(70, 0, startingLeftEdge, startingLeftEdge);
    //leftFrustum.setModeQuadBoth();
    //leftFrustum.setEaseInOut();
    rightFrustum = new FSTween(70, 0, startingRightEdge, startingRightEdge);
    //rightFrustum.setModeQuadBoth();
    //rightFrustum.setEaseInOut();
    setTimeMode(base.getTimeMode());
    setEase(base.getEase());
    updateCameraLoc();
  } // end setupTweens


  public void setEaseLinear() {
    base.setEaseLinear();
    setEase();
  } // end setModeLinear

  public void setEaseIn() {
    base.setEaseIn();
    setEase();
  } // end setEaseIn

  public void setEaseOut() {
    base.setEaseOut();
    setEase();
  } // end setEaseOut()

  public void setEaseInOut() {
    base.setEaseInOut();
    setEase();
  } // end setEaseInOut()


  public void setEase(float x1, float y1, float x2, float y2) {
    base.setEase(x1, y1, x2, y2);
    setEase();
  } // end setEase

    public void setEase(float[] easeIn) {
    base.setEase(easeIn);
    cameraShift.setEase(base.getEase());
    // **** //
    manualShift.setEase(base.getEase());
    cameraXYRotation.setEase(base.getEase());
    cameraXYRotation.setEase(base.getEase());
    cameraZRotation.setEase(base.getEase());
    cameraDist.setEase(base.getEase());
    leftFrustum.setEase(base.getEase());
    rightFrustum.setEase(base.getEase());
  } // end setMode

    public void setEase() {
    setEase(base.getEase());
  } // end setMode

    public void setTimeToFrames() {
    cameraTweenTime = cameraTweenTimeFrames;
    defaultZoomTime = defaultZoomtimeFrames;
    defaultManualZoomTime = defaultZoomtimeFrames / 2;
    setTimeMode(SimpleTween.FRAMES_MODE);
    SimpleTween.setTimeToFrames();
  } // end setTimeToFrames

    public void setTimeToSeconds() {
    cameraTweenTime = cameraTweenTimeSeconds;
    defaultZoomTime = defaultZoomtimeSeconds;
    defaultManualZoomTime = defaultZoomtimeSeconds / 2;
    setTimeMode(SimpleTween.SECONDS_MODE);
    SimpleTween.setTimeToSeconds();
  } // end setTimeToSeconds

    public void setTimeMode(int modeIn) {
    cameraShift.setTimeMode(modeIn);
    // **** //
    manualShift.setTimeMode(modeIn);
    cameraXYRotation.setTimeMode(modeIn);
    cameraXYRotation.setTimeMode(modeIn);
    cameraZRotation.setTimeMode(modeIn);
    cameraDist.setTimeMode(modeIn);
    leftFrustum.setTimeMode(modeIn);
    rightFrustum.setTimeMode(modeIn);
    base.setTimeMode(modeIn);
  } // end setTimeMode

  public int getTimeMode() {
    return base.getTimeMode();
  } // end getTimeMode


    public void setControlSchemaA () {
    currentControlSchema = CONTROL_SCHEMA_A;
  } // end setControlSchemaA
  public void setControlSchemaB () {
    currentControlSchema = CONTROL_SCHEMA_B;
  } // end setControlSchemaB
  public int getCurrentControlSchema() {
    return currentControlSchema;
  } // end getCurrentControlSchema


    public void setRestrictPanningZ() {
    setRestrictionPanningZ = true;
  } // end setRestricPanningZ();
  public void releasePanningRestrictions() {
    setRestrictionPanningZ = false;
  } // end releasePanningRestrictions


  public void useCamera () {

    makeFrustum(leftFrustum.value(), rightFrustum.value(), fovy, cameraZ);
    // deal with inertia

    dealWithPawingAndInertia();


    updateCameraLoc();

    // **** //
    float camX = cameraLoc.x + cameraShift.value().x + manualShift.value().x;
    float camY = cameraLoc.y + cameraShift.value().y + manualShift.value().y;
    float camZ = cameraLoc.z + cameraShift.value().z + manualShift.value().z;


    if (lastCameraZRotation < (float)(Math.PI / 2f) || lastCameraZRotation > (float)(3 * Math.PI / 2f)) {
      if (cameraZRotation.value() <= (float)(Math.PI / 2f) || cameraZRotation.value() >= (float)(3 * Math.PI / 2f)) upDirection = -1;
      else upDirection = 1;
    }
    else {
      if (cameraZRotation.value() < (float)(Math.PI / 2f) || cameraZRotation.value() > (float)(3 * Math.PI / 2f)) upDirection = -1;
      else upDirection = 1;
    }
    if (cameraZRotation.value() != (float)(Math.PI / 2f) && cameraZRotation.value() != (float)(3 * Math.PI / 2f)) {
      lastCamX = camX;
      lastCamY = camY;
      lastCameraZRotation = cameraZRotation.value();
    }
    else {
      camX = lastCamX;
      camY = lastCamY;
    }      



    //parent.camera(camX, camY, camZ, cameraTarget.x + cameraShift.value().x, cameraTarget.y + cameraShift.value().y, cameraTarget.z + cameraShift.value().z, 0, 0, upDirection);
    // **** // 
    parent.camera(camX, camY, camZ, cameraTarget.x + cameraShift.value().x + manualShift.value().x, cameraTarget.y + cameraShift.value().y + manualShift.value().y, cameraTarget.z + cameraShift.value().z + manualShift.value().z, 0, 0, upDirection);
    //normal = getNormal();
    lastFrame = parent.frameCount;
  } // end useCamera

  private void updateCameraLoc() {
    cameraLoc = new PVector((float)(Math.cos(cameraXYRotation.value()) * cameraDist.value() * Math.cos(cameraZRotation.value())), (float)(Math.sin(cameraXYRotation.value()) * Math.cos(cameraZRotation.value()) * cameraDist.value()), (float)(Math.sin(cameraZRotation.value()) * cameraDist.value()));
  } // end updateCameraLoc

  public void pauseCamera() {
    // quick way to reset things to the default
    parent.perspective();
    parent.camera();
  } // end pauseCamera

    public void pauseCameraMovement() {
    cameraShift.pause();
    // **** //
    manualShift.pause();
    cameraXYRotation.pause();
    cameraZRotation.pause();
    cameraDist.pause();
    leftFrustum.pause();        
    rightFrustum.pause();
  } // endpauseCameraMovement

  public boolean isPaused() {
    if (cameraShift.isPaused())
      return true;
    // **** //
    if (manualShift.isPaused()) 
      return true;
    if (cameraXYRotation.isPaused())
      return true;
    if (cameraZRotation.isPaused())
      return true;
    if (cameraDist.isPaused())
      return true;
    if (leftFrustum.isPaused())
      return true;
    if (rightFrustum.isPaused())
      return true;
    return false;
  } // end isPaused

  public void resumeCameraMovement() {
    if (cameraShift.isPlaying() && cameraShift.isPaused())
      cameraShift.play();
    if (manualShift.isPlaying() && manualShift.isPaused()) manualShift.play();
    if (cameraXYRotation.isPlaying() && cameraXYRotation.isPaused())
      cameraXYRotation.play();
    if (cameraZRotation.isPlaying() && cameraZRotation.isPaused())
      cameraZRotation.play();
    if (cameraDist.isPlaying() && cameraDist.isPaused())
      cameraDist.play();
    if (leftFrustum.isPlaying() && leftFrustum.isPaused())
      leftFrustum.play();
    if (rightFrustum.isPlaying() && rightFrustum.isPaused())
      rightFrustum.play();
  } // end resumeCameraMovement  

  // pawing controls

  private void dealWithPawingAndInertia() {
    boolean pressedSpace = (parent.keyPressed && parent.key == ' ');
    boolean pressedShift = (parent.keyPressed && parent.keyCode == parent.SHIFT);
    boolean pawZoomingActive = false;
    boolean pawPanningActive = false;
    boolean pawRotationActive = false;

    // active
    if (lastFrame != parent.frameCount) {
      switch (currentControlSchema) {
      case CONTROL_SCHEMA_A:
        if ((mouseIsPressed && pressedSpace && !disablePawingZooming)) {
          pawZoomingActive = true;
          usePawZooming(pawZoomingActive, false);
        } 
        else if ((mouseIsPressed && pressedShift && !disablePawingPanning)) {
          pawPanningActive = true;
          usePawPanning(pawPanningActive, false);
        } 
        else if (mouseIsPressed && !disablePawingOrbit) {
          pawRotationActive = true;
          usePawRotation(pawRotationActive, false);
        }
        break;
      case CONTROL_SCHEMA_B: 
        if ((mouseIsPressed && pressedSpace && !disablePawingZooming)) {
          pawZoomingActive = true;
          usePawZooming(pawZoomingActive, false);
        } 
        else if (mouseIsPressed && pressedShift && !disablePawingOrbit) {
          pawRotationActive = true;
          usePawRotation(pawRotationActive, false);
        }        
        else if ((mouseIsPressed && !disablePawingPanning)) {
          pawPanningActive = true;
          usePawPanning(pawPanningActive, false);
        } 
        break;
      } // end switch 

      if (distInertia != 0) {
        usePawZooming(!pawZoomingActive, true);
      } 
      if (shiftInertia.mag() != 0) {
        usePawPanning(!pawPanningActive, true);
      }  
      if ((zRotationInertia != 0 || xyRotationInertia != 0)) {
        usePawRotation(!pawRotationActive, true);
      }
    }
  } // end dealWithPawing

  private void usePawPanning(boolean active, boolean inertiaMovement) {
    if (active) {
      BoundingBox b = new BoundingBox();
      ArrayList<PVector> upRight = b.makePlaneVectors(getNormal());

      PVector up = upRight.get(0);
      PVector right = upRight.get(1);
      float dx = parent.mouseX - parent.pmouseX;
      float dy = parent.mouseY - parent.pmouseY;

      PVector result;

      shiftInertia.mult((float)(inertiaFriction * .9));
      if (Math.abs(shiftInertia.x) < .001) shiftInertia.x = 0;
      if (Math.abs(shiftInertia.y) < .001) shiftInertia.y = 0;
      if (Math.abs(shiftInertia.z) < .001) shiftInertia.z = 0;
      if ((dx == 0 && dy == 0) || inertiaMovement) {
        result = shiftInertia.get();
      }
      else {
        float multiplier = (float)(1.5 * cameraDist.value() * Math.atan(fovy / 2f));
        dx *= panSensitivity * (-upDirection) * multiplier / parent.height;
        if (setRestrictionPanningZ) {
          float dist = (float)Math.sqrt(cameraLoc.y * cameraLoc.y + cameraLoc.x * cameraLoc.x);          
          float angle = ((float)Math.abs((float)Math.atan(dist / cameraLoc.z)));
          println("angle: "+ angle);
          multiplier = multiplier * (1 + (1.5 * (angle)) * (1.5 * (angle)));
        }
        dy *= panSensitivity * (-upDirection) * multiplier / parent.height;
        up.normalize();
        up.mult(dy);
        right.normalize();
        right.mult(dx);
        result = up.get();
        result.sub(right);
      }

      actOnPawPanning(result);

      shiftInertia = result.get();
    }
  } // end usePawPanning

  private void actOnPawPanning(PVector directionIn) {
    PVector oldCameraShift = cameraShift.value();
    if (setRestrictionPanningZ) directionIn.z = 0;

    oldCameraShift.add(directionIn);
    cameraShift.setCurrent(oldCameraShift);
  } // end actOnPawPanning

  private void usePawZooming(boolean active, boolean inertiaMovement) {
    if (active) {
      float dy = parent.mouseY - parent.pmouseY;
      dy *= zoomSensitivity;
      distInertia *= inertiaFriction;
      if (Math.abs(distInertia) < .001) distInertia = 0;
      if (dy == 0 || inertiaMovement) dy = distInertia;    

      actOnPawZooming(dy);
      distInertia = dy;
    }
  } // end usePawZooming

  private void actOnPawZooming(float zoomingIn) {
    float oldCameraDistance = cameraDist.value();
    if (oldCameraDistance + zoomingIn > minCamDist) {
      cameraDist.setCurrent(oldCameraDistance + zoomingIn);
    }
  } // end actOnPawZooming

  private void usePawMove() {
    float dy = -(parent.mouseY - parent.pmouseY);
    dy *= forwardsSensitivity; 
    PVector newShift = getNormal().get();
    newShift.normalize();
    newShift.mult(dy);

    actOnPawMove(newShift);
  } // end usePawMove

  private void actOnPawMove(PVector moveIn) {
    PVector currentShift = cameraShift.value().get();
    currentShift.add(moveIn);
    cameraShift.setCurrent(currentShift);
  } // end actOnPawMove

  private void usePawRotation(boolean active, boolean inertiaMovement) {
    if (active) {
      float dx = parent.mouseX - parent.pmouseX;
      float dy = parent.mouseY - parent.pmouseY;

      xyRotationInertia *= inertiaFriction;
      zRotationInertia *= inertiaFriction;
      if (Math.abs(xyRotationInertia) < .001) xyRotationInertia = 0;
      if (Math.abs(zRotationInertia) < .001) zRotationInertia = 0;
      if (dx == 0 || inertiaMovement) dx = xyRotationInertia;
      if (dy == 0 || inertiaMovement) dy = zRotationInertia;

      actOnPawRotation(dx, dy);

      xyRotationInertia = dx;
      zRotationInertia = dy;
    }
  } // end usePawRotation

  private void actOnPawRotation(float dxIn, float dyIn) {
    float oldX = cameraXYRotation.value();
    float oldY = cameraZRotation.value();

    if (Math.abs(dyIn) > 0) {
      dyIn /= parent.height  / 4;
      float newY = oldY + dyIn;
      newY = smartMod(newY, (float)(Math.PI * 2));
      cameraZRotation.setCurrent(newY);
    }

    if (Math.abs(dxIn) > 0) {
      dxIn /= parent.width / 4;
      float newX = oldX + dxIn;
      newX = smartMod(newX, (float)(Math.PI * 2));
      cameraXYRotation.setCurrent(newX);
    }
  } // end actOnPawRotation



  // zooming things

  public void setZoomToFitFillPercentage(float percentIn) {
    zoomToFitFill = percentIn;
  } // end setZoomToFitFillPercentage

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
    float targetHeight = parent.height;
    float targetWidth = rightFrustum.value() - leftFrustum.value();
    float newAspect = targetWidth / targetHeight;

    BoundingBox b = new BoundingBox(zoomTargetNormal, pointsIn);
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

    float targetDist =  (float)(additionalDist + (boundingDistanceToUse / 2f) / (zoomToFitFill * Math.atan(fovy / 2f)));
    targetDist = targetDist < minDistanceIn ? minDistanceIn : targetDist;
    targetDist = targetDist < minCamDist ? minCamDist : targetDist; // default min 

    cameraDist.playLive(targetDist, durationIn, 0);

    cameraShift.playLive(b.centroid, durationIn, 0);

    // **** //
    manualShift.playLive(new PVector(), durationIn, 0);
  } // end zoomToFit

  public void zoomOut() {
    cameraDist.playLive(cameraDist.value() + zoomIncrement, defaultManualZoomTime, 0);
  } // end zoomOut

  public void zoomIn() {
    float targetZoom = cameraDist.value() - zoomIncrement;
    targetZoom = targetZoom < minCamDist ? minCamDist : targetZoom;
    cameraDist.playLive(targetZoom, defaultManualZoomTime, 0);
  } // end zoomIn



  // billboarding fun

  // getReverseRotation will find the reverse transform rotates to billboard the image.
  // NOTE: the reverse rotation must be transformed in this order: Z, X
  // IN THE FUTURE CREATE A BILLBOARD TRANSFORM HERE
  public float[] getReverseRotation () {
    float[] reversed = new float[3];
    reversed[0] = cameraZRotation.value() + (float)(Math.PI / 2f); // x rotation
    reversed[1] = (float)(Math.PI); // y rotation
    reversed[2] = cameraXYRotation.value() + (float)(Math.PI / 2f); // z rotation
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
    popMatrix();
  } // end undoBillboardTransforms



  // changing the views

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
    float cameraXYTarget = (float)(Math.PI / 2);  
    float cameraZTarget = (float)(Math.PI / 2 - .0001);
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
    float cameraXYTarget = (float)(Math.PI / 2);
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
    float cameraXYTarget = (float)Math.PI;
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toLeftView


  public void toRearView() {
    toRearView(null, cameraTweenTime);
  } // end toRearView
  public void toRearView(float durationIn) {
    toRearView(null, durationIn);
  } // end toRearView
  public void toRearView(ArrayList<PVector> ptsIn) {
    toRearView(ptsIn, cameraTweenTime);
  } // end toRearView
  public void toRearView(ArrayList<PVector> ptsIn, float durationIn) {
    float cameraXYTarget = (float)(3 * Math.PI / 2);
    float cameraZTarget = 0;
    startupCameraTween(cameraXYTarget, cameraZTarget, ptsIn, durationIn);
  } // end toRearView

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
    float cameraXYTarget = -(float)(Math.PI / 2);
    float cameraZTarget = -(float)(Math.PI / 2 - .0001);
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

  private void startupCameraTween(float cameraXYTarget, float cameraZTarget, ArrayList<PVector> ptsIn, float durationIn) {
    resetInertias();
    cameraXYTarget = adjustForNearestRotation(cameraXYTarget % (float)(Math.PI * 2), cameraXYRotation.value());
    cameraZTarget = adjustForNearestRotation(cameraZTarget % (float)(Math.PI * 2), cameraZRotation.value());
    cameraXYRotation.playLive(cameraXYTarget, durationIn, 0);
    cameraZRotation.playLive(cameraZTarget, durationIn, 0);
    targetNormal = new PVector((float)(Math.cos(cameraXYTarget) * cameraDist.value() * Math.cos(cameraZTarget)), (float)(Math.sin(cameraXYTarget) * Math.cos(cameraZTarget) * cameraDist.value()), (float)(Math.sin(cameraZTarget) * cameraDist.value()));
    targetNormal.sub(cameraTarget);
    //targetNormal.sub(cameraTarget.value());
    targetNormal.normalize();
    if (ptsIn != null) {
      zoomToFit(ptsIn, targetNormal, durationIn);
    }
  } // end startupCameraTween



    // frustum fun
  public void shiftFrustum(float leftIn, float rightIn, 
  float durationIn) {
    startingLeftEdge = leftIn;
    startingRightEdge = rightIn;
    leftFrustum.playLive(leftIn, durationIn, 0);
    rightFrustum.playLive(rightIn, durationIn, 0);
  } // end shiftFrustum

  // leftIn - the left side of the frame
  // rightIn - the right side of the frame
  // frameOfViewIn - the frame of view - in radians
  // depthIn - the depth of the view
  public void makeFrustum(float leftIn, float rightIn, float frameOfViewIn, float depthIn) {
    leftIn = parent.constrain(leftIn, 0, parent.width);
    rightIn = parent.constrain(rightIn, 0, parent.width);
    leftIn /= parent.width;
    rightIn /= parent.width;
    float fovy = frameOfViewIn;
    float aspect = (float)parent.width / parent.height;
    float left = leftIn + (rightIn - leftIn) / 2f;
    float right = (1 - left);
    parent.frustum(-left * aspect, right * aspect, -(1f / 2), (1f / 2), .5f / (float)(Math.atan(fovy / 2)), depthIn);
  } // end makeFrustum



  // moving the camera

  // will play with the cameraShift to center the cameraTarget to the middle of the ptsIn
  public void centerCamera(ArrayList<PVector> ptsIn) {
    centerCamera(ptsIn, cameraTweenTime);
  } // end centerCamear
  public void centerCamera(ArrayList<PVector> ptsIn, float duration) {
    BoundingBox b = new BoundingBox(getNormal(), ptsIn);
    PVector centroid = b.centroid;
    cameraShift.playLive(centroid, duration, 0);
    // **** //
    manualShift.playLive(new PVector(), duration, 0);
    println("trying to shift the cameraShift to : " + centroid.x + ", " + centroid.y + ", " + centroid.z + " from " + cameraShift.value().x + ", " + cameraShift.value().y + ", " + cameraShift.value().z);
  } // end centerCamera

  public PVector getCameraPosition() {
    //PVector newPos = PVector.add(cameraShift.value(), cameraLoc);
    // **** //
    PVector newPos = PVector.add(cameraShift.value(), cameraLoc);
    newPos.add(manualShift.value());
    return newPos;
  } // end getPosition

  public PVector getCameraTarget() {
    //PVector newPos = PVector.add(cameraShift.value(), cameraTarget);
    PVector newPos = PVector.add(cameraShift.value(), cameraTarget);
    newPos.add(manualShift.value());
    return newPos;
  } // end getCameraTarget  

  public float getDistance() {
    PVector camPos = getCameraPosition();
    PVector camTarget = getCameraTarget();
    return camPos.dist(camTarget);
  } // end getDistance

  public void setPosition(PVector posIn) {
    setPosition(posIn, cameraTarget.get(), 0);
  } // end setPosition
  public void setPosition(PVector posIn, PVector targetIn) {
    setPosition(posIn, targetIn, 0);
  }
  public void setTarget(PVector targetIn) {
    setPosition(getCameraPosition(), targetIn, 0);
  } // end setTarget
  public void setTarget(PVector targetIn, float durationIn) {
    setPosition(getCameraPosition(), targetIn, durationIn);
  } // end setTarget
  public void setPosition(PVector posIn, PVector targetIn, float durationIn) {
    resetInertias();
    float targetDist = posIn.dist(targetIn);
    targetDist = targetDist < minCamDist ? minCamDist : targetDist;
    PVector diff = PVector.sub(targetIn, posIn);
    if (diff.x == 0) diff.x = (float).0001;
    float targetCameraRotationXY = (float)Math.atan(diff.y / diff.x);
    if (diff.x > 0) targetCameraRotationXY += (float)Math.PI;
    float xyDist = (float)Math.sqrt(diff.x * diff.x + diff.y * diff.y);
    float targetCameraRotationZ = -(float)(Math.atan(diff.z / .0001));
    if (xyDist != 0) targetCameraRotationZ = -(float)Math.atan(diff.z / xyDist);

    if (cameraXYRotation != null) targetCameraRotationXY = adjustForNearestRotation(targetCameraRotationXY % (float)(Math.PI * 2), cameraXYRotation.value());
    if (cameraZRotation != null) targetCameraRotationZ = adjustForNearestRotation(targetCameraRotationZ % (float)(Math.PI * 2), cameraZRotation.value());    

    PVector newShift = targetIn.get();
    if (durationIn <= 0) {
      startingCameraRotationXY = targetCameraRotationXY;
      startingCameraRotationZ = targetCameraRotationZ;
      startingCameraDist = targetDist;
      setupTweens();
      cameraShift.setCurrent(newShift);
      // **** //
      manualShift.setCurrent(new PVector());
    } 
    else {         
      targetCameraRotationXY = adjustForNearestRotation(targetCameraRotationXY, cameraXYRotation.value());

      cameraXYRotation.playLive(targetCameraRotationXY, durationIn, 0);
      cameraZRotation.playLive(targetCameraRotationZ, durationIn, 0);
      cameraDist.playLive(targetDist, durationIn, 0);
      cameraShift.playLive(newShift, durationIn, 0);
      // **** //
      manualShift.playLive(new PVector(), durationIn, 0);
    }
  } // end setPosition

  // **** //
  public void addManualOffset(PVector offsetIn) {
    BoundingBox b = new BoundingBox();
    ArrayList<PVector> upRight = b.makePlaneVectors(getNormal());

    PVector up = upRight.get(0);
    PVector right = upRight.get(1);
    float dx = offsetIn.x;
    float dy = offsetIn.y;

    PVector result = new PVector();
    up.normalize();
    up.mult(dy);
    right.normalize();
    right.mult(dx);
    result = up.get();
    result.sub(right);

    if (setRestrictionPanningZ) result.z = 0;

    PVector currentManualShiftValue = manualShift.value().get();
    currentManualShiftValue.add(result);
    // add to manual if cameraShift is playing
    if (cameraShift.isPlaying()) manualShift.setCurrent(currentManualShiftValue);
    else {
      PVector currentShiftValue = cameraShift.value().get();
      currentShiftValue.add(result);
      cameraShift.setCurrent(currentShiftValue);
    }
  } // end addManualOffset


  public void setDistance(float distIn) {
    setDistance(distIn, 0);
  } // end setDistance
  public void setDistance(float distIn, float durationIn) {
    PVector reverseNormal = getNormal().get();
    reverseNormal.mult(-1);
    reverseNormal.normalize();
    reverseNormal.mult(distIn);
    PVector startingPoint = getCameraTarget();
    startingPoint.add(reverseNormal);
    setPosition(startingPoint, getCameraTarget(), durationIn);
  } // end setDistance


  private void resetInertias() {
    xyRotationInertia = 0f;
    zRotationInertia = 0f;
    distInertia = 0f;
    shiftInertia = new PVector();
  } // end resetInertias



  // calculations and such
  public float getDistanceFromCameraPlane (PVector pointIn) {
    //float result = (float)(Math.abs((normal.x * (cameraLoc.x - pointIn.x) + normal.y * (cameraLoc.y - pointIn.y) + normal.z *(cameraLoc.z - pointIn.z)) / Math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)));
    //float result = distanceFromPointToPlane(getNormal(), PVector.add(cameraShift.value(), cameraLoc), pointIn);
    // **** //
    float result = distanceFromPointToPlane(getNormal(), getCameraPosition(), pointIn);
    return result;
  } // end getCameraPlane

  public float getDistanceFromTargetPlane (PVector pointIn) {
    //float result = (float)(Math.abs((normal.x * (cameraTarget.x - pointIn.x) + normal.y * (cameraTarget.y - pointIn.y) + normal.z *(cameraTarget.z - pointIn.z)) / Math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)));
    // **** //
    float result = distanceFromPointToPlane(getNormal(), getCameraTarget(), pointIn);
    return result;
  } // end getDistanceFromTargetPlane

  private float distanceFromPointToPlane (PVector normalIn, PVector planePoint, PVector questionPoint) {
    BoundingBox b = new BoundingBox();
    return Math.abs(b.distanceFromPointToPlane(normalIn, planePoint, questionPoint));
  } // end distanceFromPointToPlane 

  public PVector getNormal () {
    PVector newNormal = new PVector(cameraTarget.x - cameraLoc.x, cameraTarget.y - cameraLoc.y, cameraTarget.z - cameraLoc.z);
    newNormal.normalize();
    return newNormal;
  } // end getNormal

    public PVector getTargetNormal() {
    if (targetNormal == null) return getNormal();
    return targetNormal;
  } // end getTargetNormal

    public float smartMod (float numIn, float modNum) {
    float result = numIn % modNum;
    if (numIn < 0) result = (modNum + result);
    return result;
  } // end smartMod


  public float adjustForNearestRotation(float angleIn, float currentAngle) {
    if (currentAngle - angleIn > (float)Math.PI) angleIn = (float)(Math.PI * 2) + angleIn;
    return angleIn;
  } // end adjustForNearestRotation





    public boolean pointInView(PVector ptIn) {
    PVector in2dSpace = new PVector(parent.screenX(ptIn.x, ptIn.y, ptIn.z), parent.screenY(ptIn.x, ptIn.y, ptIn.z));
    if (in2dSpace.x >= leftFrustum.value() && in2dSpace.x <= rightFrustum.value() && in2dSpace.y >= 0 && in2dSpace.y <= parent.height) return true;
    return false;
  } // end pointInView




  // keyPress stuff
  public void keyEvent(KeyEvent event) {
    if (keyControlsOn && event.getAction() == KeyEvent.RELEASE) {
      if (parent.key == '1') toTopView();
      else if (parent.key == '2') toFrontView();
      else if (parent.key == '3') toLeftView();
      else if (parent.key == '4') toRightView();
      else if (parent.key == '5') toRearView();
      else if (parent.key == '6') toBottomView();
    }
  } // end keyEvent


  // mouse thing
  public void mouseEvent(MouseEvent event) {
    // see https://github.com/processing/processing/wiki/Library-Basics for info on getting the mouse stuff to work
    if (pawingControlsOn) {
      if (event.getAction() == MouseEvent.PRESS && event.getButton() == parent.RIGHT && rightMouseInControl) {
        mouseIsPressed = true;
      }
      else if (event.getAction() == MouseEvent.PRESS && event.getButton() == parent.LEFT && !rightMouseInControl) {
        mouseIsPressed = true;
      }
      else if (event.getAction() == MouseEvent.RELEASE) {
        mouseIsPressed = false;
      } 
      else if (event.getAction() == MouseEvent.WHEEL && !disablePawingZooming) {
        int zoomCount = event.getCount();
        float zoomAmount = -zoomCount * zoomIncrement * cameraDist.value() / (10000);
        float totalToZoom = zoomAmount;
        distInertia = -zoomAmount;
        float targetZoom = cameraDist.value() - totalToZoom;
        targetZoom = targetZoom < minCamDist ? minCamDist : targetZoom;
        cameraDist.setCurrent(targetZoom);
      }
    }
  } // end mouseEvent



  // togglers and setters and such for basic vars

  public void togglePawing() {
    pawingControlsOn = !pawingControlsOn;
  } // end togglePawing

  public void disableOrbit() {
    disablePawingOrbit = true;
  } // end disableOrbit
  public void enableOrbit() {
    disablePawingOrbit = false;
  } // end enableOrbit

  public void disableZooming() {
    disablePawingZooming = true;
  } // end disableZooming
  public void enableZooming() {
    disablePawingZooming = false;
  } // end enable zooming

  public void disablePanning() {
    disablePawingPanning = true;
  } // end disablePanning
  public void enablePanning() {
    disablePawingPanning = false;
  } // end enablePanning

  public void toggleKeyControls() {
    keyControlsOn = !keyControlsOn;
  } // end toggleKeyControls

  public void useRightMouseForControl() {
    rightMouseInControl = true;
  } // end useRightMouseForControl
  public void useLeftMouseForControl() {
    rightMouseInControl = false;
  } // end useLeftMouseForControl  

  public void setZoomIncrement(float incrementIn) {
    zoomIncrement = incrementIn;
  } // end setZoomIncrement

  public float getZoomIncrement() {
    return zoomIncrement;
  } // end getZoomIncrement

    public void setCameraTweenTime(float timeIn) {
    cameraTweenTime = timeIn;
  } // end setCameraTweenTime

  public float getCameraTweenTime() {
    return cameraTweenTime;
  } // end getCameraTweenTime


    public void setMinDistance(float minDistIn) {
    minCamDist = minDistIn;
  } // end setMinDistance 

  public float getMinDistance() {
    return minCamDist;
  } // end getMinDistance

  public void setZoomTweenTime(float timeIn) {
    defaultManualZoomTime = timeIn;
  } // end setZoomTweenTime

  public float getZoomTweenTime() {
    return defaultManualZoomTime;
  } // end getZoomTweenTime

    public void setFovy(float fovyIn) {
    fovy = fovyIn;
  } // end setFovy

  public float getFovy() {
    return fovy;
  } // end getFovy
} // end CamCam

