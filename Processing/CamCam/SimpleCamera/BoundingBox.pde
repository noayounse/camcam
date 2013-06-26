public class BoundingBox {
  public PVector upVector = new PVector();
  public PVector rightVector = new PVector();
  public PVector centroid = new PVector();
  public ArrayList<PVector> boundingPoints = new ArrayList<PVector>();

  public BoundingBox () {
  } // end blank constructor

  public BoundingBox (PVector normalIn, ArrayList<PVector> pointsIn) {
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
      float heightIncrease = .5 * (initialWidth / (aspectIn) - initialHeight);
      topAddition += heightIncrease;
      bottomAddition += heightIncrease;
      paddedPoints = makePaddedAdjustedBoundingBox(normalIn, pointsIn, topAddition, rightAddition, bottomAddition, leftAddition, frontAddition, rearAddition);
    } 
    else if (initialWidth / initialHeight < aspectIn) {
      // increase width
      float widthIncrease = .5 * (aspectIn * initialHeight - initialWidth);
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

  public PVector getCentroid() {
    return centroid;
  } // end getCentroid

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

    void drawBoxCorners() {
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
    // http://paulbourke.net/geometry/pointlineplane/
    // minimum distance = (A (xa - xb) + B (ya - yb) + C (za - zb)) / sqrt(A2 + B2 + C2)
    // Let Pa = (xa, ya, za) be the point in question.
    // Pb = any point on the plane:  (xb, yb, zb)
    // A plane can be defined by its normal n = (A, B, C)    
    float distanceDifference = ((normalIn.x * (planePoint.x - questionPoint.x) + normalIn.y * (planePoint.y - questionPoint.y) + normalIn.z *(planePoint.z - questionPoint.z)) / sqrt(normalIn.x * normalIn.x + normalIn.y * normalIn.y + normalIn.z * normalIn.z));
    return distanceDifference;
  } // end distanceFromPointToPlane

    // getPointToPlaneVector will return the vector direction from the input point to the plane
  public PVector getPointToPlaneVector (PVector normalIn, PVector planePoint, PVector questionPoint) {
    normalIn = new PVector(normalIn.x, normalIn.y, normalIn.z);
    float distanceDifference = distanceFromPointToPlane(normalIn, planePoint, questionPoint);
    normalIn.normalize();
    normalIn.mult(distanceDifference);
    return normalIn;
  } // end projectPointToPlane

  // getProjectedPoint will return a new point projected onto the target plane
  public PVector getProjectedPoint (PVector normalIn, PVector planePoint, PVector questionPoint) {
    PVector projectedPoint = new PVector(questionPoint.x, questionPoint.y, questionPoint.z);
    projectedPoint.add(getPointToPlaneVector(normalIn, planePoint, questionPoint));
    return projectedPoint;
  } // end getProjectedPoint
} // end class NormalBoundingBox

