class BoundingBox {
  PVector upVector = new PVector();
  PVector rightVector = new PVector();
  PVector centroid = new PVector();
  ArrayList<PVector> boundingPoints = new ArrayList<PVector>();

  BoundingBox (PVector normalIn, ArrayList<PVector> pointsIn) {
    boundingPoints = makeAdjustedBoundingBox(normalIn, pointsIn); 
    centroid = getCentroid(boundingPoints);
  } // end constructor

  ArrayList<PVector> makeAdjustedBoundingBox (PVector normalIn, ArrayList<PVector> pointsIn) {
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

  ArrayList<PVector> makeOrthagonalBoundingBox (ArrayList<PVector> pointsIn) {
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

  PVector getCentroid (ArrayList<PVector> pointsIn) {
    PVector result = new PVector();
    for (PVector p : pointsIn) result.add(p);
    result.div(pointsIn.size());
    return result;
  } // end getCentroid

  ArrayList<PVector> makePlaneVectors (PVector normalIn) {
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

  // drawBoundingBox will draw a simple bounding box based on the particular order of points specified in makeAdjustedBoundingBox() 
  void drawBox() {
    if (boundingPoints.size() > 0) {
      noFill();
      beginShape();
      for (int i = 0; i < 4; i++) vertex(boundingPoints.get(i).x, boundingPoints.get(i).y, boundingPoints.get(i).z);
      endShape(CLOSE);
      beginShape();
      for (int i = 4; i < 8; i++) vertex(boundingPoints.get(i).x, boundingPoints.get(i).y, boundingPoints.get(i).z);
      endShape(CLOSE);
      for (int i = 0; i < 4; i++) line(boundingPoints.get(i).x, boundingPoints.get(i).y, boundingPoints.get(i).z, boundingPoints.get(i + 4).x, boundingPoints.get(i + 4).y, boundingPoints.get(i + 4).z);
    }
  } // end drawBoundingBox

  // front face is defined as the first four points
  float getBoxWidth() {
    if (boundingPoints.size() > 0) return (boundingPoints.get(0).dist(boundingPoints.get(3)));
    return 0;
  } // end getBoundingBoxWidth
  float getBoxHeight() {
    if (boundingPoints.size() > 0) return (boundingPoints.get(0).dist(boundingPoints.get(1)));
    return 0;
  } // end getBoundingBoxHeight
  float getBoxDepth() {
    if (boundingPoints.size() > 0) return (boundingPoints.get(0).dist(boundingPoints.get(5)));
    return 0;
  } // end getBoundingBoxDepth

  PVector getBoxFrontPlaneCentroid() {
    PVector centroid = new PVector();
    if (boundingPoints.size() > 0) {
      for (int i = 0; i < 4; i++) centroid.add(boundingPoints.get(i));
      centroid.div(4);
    }
    return centroid;
  } // end getFrontCentroid

    void drawBoxCorners() {
    for (PVector p : boundingPoints) {
      drawPoint(p);
    }
  } // end drawBoundingCorners

  void drawPoint(PVector pointIn) {
    pushMatrix();
    translate(pointIn.x, pointIn.y, pointIn.z);
    sphere(4);
    popMatrix();
  } // end drawPoint

  // drawLineFromPointToPlane will draw a line from a point to a plane - note: specify color beforehand
  void drawLineFromPointToPlane (PVector normalIn, PVector planePoint, PVector questionPoint) {
    PVector directionalVector = getPointToPlaneVector(normalIn, planePoint, questionPoint);
    line(questionPoint.x, questionPoint.y, questionPoint.z, questionPoint.x + directionalVector.x, questionPoint.y + directionalVector.y, questionPoint.z + directionalVector.z);
  } // end drawLineFromPointToPlane

  // distanceFromPointToPlane will return a float describing how far a point is from a plane
  float distanceFromPointToPlane (PVector normalIn, PVector planePoint, PVector questionPoint) {
    float distanceDifference = ((normalIn.x * (planePoint.x - questionPoint.x) + normalIn.y * (planePoint.y - questionPoint.y) + normalIn.z *(planePoint.z - questionPoint.z)) / sqrt(normalIn.x * normalIn.x + normalIn.y * normalIn.y + normalIn.z * normalIn.z));
    return distanceDifference;
  } // end distanceFromPointToPlane

    // getPointToPlaneVector will return the vector direction from the input point to the plane
  PVector getPointToPlaneVector (PVector normalIn, PVector planePoint, PVector questionPoint) {
    normalIn = new PVector(normalIn.x, normalIn.y, normalIn.z);
    float distanceDifference = distanceFromPointToPlane(normalIn, planePoint, questionPoint);
    normalIn.normalize();
    normalIn.mult(distanceDifference);
    //PVector result = PVector.add(questionPoint, normalIn);
    //return result;
    return normalIn;
  } // end projectPointToPlane

  // getProjectedPoint will return a new point projected onto the target plane
  PVector getProjectedPoint (PVector normalIn, PVector planePoint, PVector questionPoint) {
    PVector projectedPoint = new PVector(questionPoint.x, questionPoint.y, questionPoint.z);
    projectedPoint.add(getPointToPlaneVector(normalIn, planePoint, questionPoint));
    return projectedPoint;
  } // end getProjectedPoint
} // end class NormalBoundingBox

