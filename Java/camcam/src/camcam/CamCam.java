/**
 * ##library.name##
 * ##library.sentence##
 * ##library.url##
 *
 * Copyright ##copyright## ##author##
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author      ##author##
 * @modified    ##date##
 * @version     ##library.prettyVersion## (##library.version##)
 */

package camcam;

import processing.core.*;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import simpleTween.*;
import java.util.ArrayList;
import java.awt.geom.*;

public class CamCam {
	public PApplet parent;

	public STween base;

	// camera stuff
	private float startingCameraDist = 500f;
	private float startingCameraRotationXY = 0f;
	private float startingCameraRotationZ = 0f;
	private float startingLeftEdge = 0f;
	private float startingRightEdge = 0f;

	private PVector initialPosition = new PVector();
	private PVector initialTarget = new PVector();
	private FSTween cameraDist, cameraXYRotation, cameraZRotation;
	public FSTween leftFrustum, rightFrustum;
	private Line2D[] screenLines = new Line2D[4];

	private float lastCamX = .0001f;
	private float lastCamY = 0f;
	private float lastCameraZRotation = 0f;
	private int upDirection = 1;

	private float xyRotationInertia = 0f;
	private float zRotationInertia = 0f;
	private float distInertia = 0f;
	private PVector shiftInertia = new PVector();
	private float inertiaFriction = (float) .85;

	private PVector cameraTarget = new PVector();
	private PVector cameraLoc = new PVector();
	public PVSTween cameraShift;
	private PVSTween manualShift; // // when manually moving will just
									// cumulatively add up. When a new playLive
									// is recorded, this will playLive back to 0
									// unless interrupted

	private float cameraTweenTimeSeconds = 1.5f;
	private float cameraTweenTimeFrames = 140f;
	private float cameraTweenTime = cameraTweenTimeFrames;
	private float zoomIncrement = 150f;
	private float zoomToFitFill = .9f; // % of screen
	private float defaultZoomtimeFrames = 90f;
	private float defaultZoomtimeSeconds = 1.5f;
	private float defaultZoomTime = defaultZoomtimeFrames;
	private float defaultManualZoomTime = defaultZoomtimeFrames / 2;
	private float minCamDist = 10f;

	private float fovy = (float) (Math.PI * (60f) / 180f); // frame of view for
															// the y dir
	// private float aspect = (float)parent.width / (1 * parent.height);
	private float cameraZ = 10000000;
	private float heightScale = 1f; // in case a manual override of scale is
									// needed...

	// private PVector normal = new PVector();
	private PVector targetNormal = new PVector();

	// control vars
	public boolean pawingControlsOn = true;
	public boolean disablePawingOrbit = false;
	public boolean disablePawingZooming = false;
	public boolean disablePawingPanning = false;
	private boolean mouseIsPressed = false;
	private boolean keyControlsOn = true;
	private boolean rightMouseInControl = true;
	private float panSensitivity = 1f;
	private float zoomSensitivity = 1f;
	private float forwardsSensitivity = 1f;
	private boolean shiftWasPressed = false;

	private final int CONTROL_SCHEMA_A = 0;
	private final int CONTROL_SCHEMA_B = 1;
	private int currentControlSchema = CONTROL_SCHEMA_A;

	private boolean setRestrictionPanningZ = false;

	private int lastFrame = 0;

	public CamCam(PApplet parent_) {
		parent = parent_;
		startingLeftEdge = 0f;
		startingRightEdge = parent.width;
		setupTweens();
		setupEvents();
		makeScreenLines(getLeftFrustum(), getRightFrustum(), 0, parent.height);

	} // end constructor

	public CamCam(PApplet parent_, PVector initialPosition_,
			PVector initialTarget_) {
		parent = parent_;
		startingLeftEdge = 0f;
		startingRightEdge = parent.width;
		setupTweens();
		initialPosition = initialPosition_;
		initialTarget = initialTarget_;
		setView(initialPosition, initialTarget);
		setupEvents();
		makeScreenLines(getLeftFrustum(), getRightFrustum(), 0, parent.height);
	} // end constructor

	private void setupEvents() {
		parent.registerMethod("mouseEvent", this);
		parent.registerMethod("keyEvent", this);
	}

	private void setupTweens() {
		SimpleTween.begin(parent);

		base = new STween(13, 0, 0, 1);
		base.setTimeMode(SimpleTween.getTimeMode());
		base.setEase(SimpleTween.getEasing());

		cameraShift = new PVSTween(1, 0, initialTarget, initialTarget);
		manualShift = new PVSTween(1, 0, new PVector(), new PVector());
		cameraXYRotation = new FSTween(cameraTweenTime, 0,
				startingCameraRotationXY, startingCameraRotationXY);
		cameraZRotation = new FSTween(cameraTweenTime, 0,
				startingCameraRotationZ, startingCameraRotationZ);
		cameraDist = new FSTween(defaultZoomTime, 0, startingCameraDist,
				startingCameraDist);

		leftFrustum = new FSTween(defaultZoomTime, 0, startingLeftEdge,
				startingLeftEdge);
		// leftFrustum.setEaseInOut();
		rightFrustum = new FSTween(defaultZoomTime, 0, startingRightEdge,
				startingRightEdge);
		// rightFrustum.setEaseInOut();

		setTimeMode(base.getTimeMode());
		setEase(base.getEase());
		updateCameraLoc();

		makeScreenLines(leftFrustum.value(), rightFrustum.value(),
				parent.height, 0);
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

	public void setControlSchemaA() {
		currentControlSchema = CONTROL_SCHEMA_A;
	} // end setControlSchemaA

	public void setControlSchemaB() {
		currentControlSchema = CONTROL_SCHEMA_B;
	} // end setControlSchemaB

	public int getCurrentControlSchema() {
		return currentControlSchema;
	} // end getCurrentControlSchema

	public void setRestrictionPanningZ() {
		setRestrictionPanningZ = true;
	} // end setRestricPanningZ();

	public void releasePanningRestrictions() {
		setRestrictionPanningZ = false;
	} // end releasePanningRestrictions

	public void useCamera() {

		makeFrustum(leftFrustum.value(), rightFrustum.value(), fovy, cameraZ);
		// deal with inertia
		dealWithPawingAndInertia();

		updateCameraLoc();

		float camX = cameraLoc.x + cameraShift.value().x
				+ manualShift.value().x;
		float camY = cameraLoc.y + cameraShift.value().y
				+ manualShift.value().y;
		float camZ = cameraLoc.z + cameraShift.value().z
				+ manualShift.value().z;

		if (lastCameraZRotation < (float) (Math.PI / 2f)
				|| lastCameraZRotation > (float) (3 * Math.PI / 2f)) {
			if (cameraZRotation.value() <= (float) (Math.PI / 2f)
					|| cameraZRotation.value() >= (float) (3 * Math.PI / 2f))
				upDirection = -1;
			else
				upDirection = 1;
		} else {
			if (cameraZRotation.value() < (float) (Math.PI / 2f)
					|| cameraZRotation.value() > (float) (3 * Math.PI / 2f))
				upDirection = -1;
			else
				upDirection = 1;
		}
		if (cameraZRotation.value() != (float) (Math.PI / 2f)
				&& cameraZRotation.value() != (float) (3 * Math.PI / 2f)) {
			lastCamX = camX;
			lastCamY = camY;
			lastCameraZRotation = cameraZRotation.value();
		} else {
			camX = lastCamX;
			camY = lastCamY;
		}

		parent.camera(camX, camY, camZ, cameraTarget.x + cameraShift.value().x
				+ manualShift.value().x, cameraTarget.y + cameraShift.value().y
				+ manualShift.value().y, cameraTarget.z + cameraShift.value().z
				+ manualShift.value().z, 0, 0, upDirection);
		// normal = getNormal();
		lastFrame = parent.frameCount;
	} // end useCamera

	private void updateCameraLoc() {
		cameraLoc = new PVector(
				(float) (Math.cos(cameraXYRotation.value())
						* cameraDist.value() * Math.cos(cameraZRotation.value())),
				(float) (Math.sin(cameraXYRotation.value())
						* Math.cos(cameraZRotation.value()) * cameraDist
						.value()),
				(float) (Math.sin(cameraZRotation.value()) * cameraDist.value()));
	} // end updateCameraLoc

	public void pauseCamera() {
		// quick way to reset things to the default
		parent.perspective();
		parent.camera();
	} // end pauseCamera

	public void pauseCameraMovement() {
		// System.out.println("in pauseCameraMovement");
		cameraShift.pause();
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
					usePawZooming(pawZoomingActive, false, pressedShift);
				} else if ((mouseIsPressed && pressedShift && !disablePawingPanning)) {
					pawPanningActive = true;
					usePawPanning(pawPanningActive, false);
				} else if (mouseIsPressed && !disablePawingOrbit) {
					pawRotationActive = true;
					usePawRotation(pawRotationActive, false);
				}
				break;
			case CONTROL_SCHEMA_B:
				if ((mouseIsPressed && pressedSpace && !disablePawingZooming)) {
					pawZoomingActive = true;
					usePawZooming(pawZoomingActive, false, pressedShift);
				} else if (mouseIsPressed && pressedShift
						&& !disablePawingOrbit) {
					pawRotationActive = true;
					usePawRotation(pawRotationActive, false);
				} else if ((mouseIsPressed && !disablePawingPanning)) {
					pawPanningActive = true;
					usePawPanning(pawPanningActive, false);
				}
				break;
			} // end switch

			if (distInertia != 0) {
				// shift was pressed is defined in the mouse event
				usePawZooming(!pawZoomingActive, true, shiftWasPressed);
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

			dx *= heightScale;
			dy *= heightScale;

			PVector result;

			shiftInertia.mult((float) (inertiaFriction * .9));
			if (Math.abs(shiftInertia.x) < .001)
				shiftInertia.x = 0;
			if (Math.abs(shiftInertia.y) < .001)
				shiftInertia.y = 0;
			if (Math.abs(shiftInertia.z) < .001)
				shiftInertia.z = 0;
			if ((dx == 0 && dy == 0) || inertiaMovement) {
				result = shiftInertia.get();
			} else {
				float multiplier = (float) (1.5 * cameraDist.value() * Math
						.atan(fovy / 2f));
				dx *= panSensitivity * (-upDirection) * multiplier
						/ parent.height;
				if (setRestrictionPanningZ) {
					float dist = (float) Math.sqrt(cameraLoc.y * cameraLoc.y
							+ cameraLoc.x * cameraLoc.x);
					float angle = ((float) Math.abs((float) Math.atan(dist
							/ cameraLoc.z)));
					multiplier = (float) (multiplier * (1 + (1.5 * (angle))
							* (1.5 * (angle))));
				}
				dy *= panSensitivity * (-upDirection) * multiplier
						/ parent.height;
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
		if (setRestrictionPanningZ)
			directionIn.z = 0;
		oldCameraShift.add(directionIn);
		cameraShift.setCurrent(oldCameraShift);
	} // end actOnPawPanning

	private void usePawZooming(boolean active, boolean inertiaMovement,
			boolean shiftCamera) {
		if (active) {
			float dy = parent.mouseY - parent.pmouseY;
			dy *= zoomSensitivity;
			distInertia *= inertiaFriction;
			if (Math.abs(distInertia) < .001)
				distInertia = 0;
			if (dy == 0 || inertiaMovement)
				dy = distInertia;

			actOnPawZooming(dy, shiftCamera);
			distInertia = dy;
		}
	} // end usePawZooming

	// 2013_11_21 changing to make it move the shift
	private void actOnPawZooming(float zoomingIn, boolean shiftCamera) {
		if (shiftCamera) { // will shift the camera
			PVector normal = getNormal();
			normal.mult(-zoomingIn);
			PVector oldCameraShift = cameraShift.value();
			oldCameraShift.add(normal);
			cameraShift.setCurrent(oldCameraShift);
		} else { // will only zoom the camera while keeping the same camera
					// target
			float oldCameraDistance = cameraDist.value();
			if (oldCameraDistance + zoomingIn > minCamDist) {
				cameraDist.setCurrent(oldCameraDistance + zoomingIn);
			}
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

			dx *= heightScale;
			dy *= heightScale;

			xyRotationInertia *= inertiaFriction;
			zRotationInertia *= inertiaFriction;
			if (Math.abs(xyRotationInertia) < .001)
				xyRotationInertia = 0;
			if (Math.abs(zRotationInertia) < .001)
				zRotationInertia = 0;
			if (dx == 0 || inertiaMovement)
				dx = xyRotationInertia;
			if (dy == 0 || inertiaMovement)
				dy = zRotationInertia;

			actOnPawRotation(dx, dy);

			xyRotationInertia = dx;
			zRotationInertia = dy;
		}
	} // end usePawRotation

	private void actOnPawRotation(float dxIn, float dyIn) {
		float oldX = cameraXYRotation.value();
		float oldY = cameraZRotation.value();

		if (Math.abs(dyIn) > 0) {
			dyIn /= parent.height / 4;
			float newY = oldY + dyIn;
			newY = smartMod(newY, (float) (Math.PI * 2));
			cameraZRotation.setCurrent(newY);
		}

		if (Math.abs(dxIn) > 0) {
			dxIn /= parent.width / 4;
			float newX = oldX + dxIn;
			newX = smartMod(newX, (float) (Math.PI * 2));
			cameraXYRotation.setCurrent(newX);
		}
	} // end actOnPawRotation

	// zooming things

	private void resetInertias() {
		xyRotationInertia = 0f;
		zRotationInertia = 0f;
		distInertia = 0f;
		shiftInertia = new PVector();
	} // end resetInertias

	public void setZoomToFitFillPercentage(float percentIn) {
		zoomToFitFill = percentIn;
	} // end setZoomToFitFillPercentage

	public void zoomToFit(ArrayList<PVector> pointsIn) {
		zoomToFitSpecific(pointsIn, getNormal(), true, true, -1f,
				defaultZoomTime);
	}

	public void zoomToFit(ArrayList<PVector> pointsIn,
			PVector zoomTargetNormal, float durationIn) {
		zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true, -1f,
				durationIn);
	}

	public void zoomToFitX(ArrayList<PVector> pointsIn,
			PVector zoomTargetNormal, float durationIn) {
		zoomToFitSpecific(pointsIn, zoomTargetNormal, true, false, -1f,
				durationIn);
	}

	public void zoomToFitY(ArrayList<PVector> pointsIn,
			PVector zoomTargetNormal, float durationIn) {
		zoomToFitSpecific(pointsIn, zoomTargetNormal, false, true, -1f,
				durationIn);
	}

	public void zoomToFitWithMinimumDistance(ArrayList<PVector> pointsIn,
			PVector zoomTargetNormal, float minDistanceIn, float durationIn) {
		zoomToFitSpecific(pointsIn, zoomTargetNormal, true, true,
				minDistanceIn, durationIn);
	}

	private void zoomToFitSpecific(ArrayList<PVector> pointsIn,
			PVector zoomTargetNormal, boolean onlyX, boolean onlyY,
			float minDistanceIn, float durationIn) {
		float targetHeight = parent.height;
		float targetWidth = rightFrustum.value() - leftFrustum.value();
		float newAspect = targetWidth / targetHeight;

		BoundingBox b = new BoundingBox(zoomTargetNormal, pointsIn);
		float boundingBoxWidth = b.getBoxWidth();
		float boundingBoxHeight = b.getBoxHeight();

		float boxDepth = b.getBoxDepth();

		float boundingDistanceToUse = boundingBoxHeight; // force y
		if (onlyX && !onlyY)
			boundingDistanceToUse = boundingBoxWidth / newAspect; // force x
		// if both x and y are on, check for aspect
		else if (onlyX & onlyY) {
			if (boundingBoxWidth / boundingBoxHeight > newAspect) {
				boundingDistanceToUse = boundingBoxWidth / newAspect;
			}
		}

		float additionalDist = boxDepth / 2;

		float targetDist = (float) (additionalDist + (boundingDistanceToUse / 2f)
				/ (zoomToFitFill * Math.atan(fovy / 2f)));
		targetDist = targetDist < minDistanceIn ? minDistanceIn : targetDist;
		targetDist = targetDist < minCamDist ? minCamDist : targetDist; // default
																		// min

		cameraDist.playLive(targetDist, durationIn, 0);

		cameraShift.playLive(b.centroid, durationIn, 0);
		manualShift.playLive(new PVector(), durationIn, 0);
	} // end zoomToFit

	public void zoomOut() {
		cameraDist.playLive(cameraDist.value() + zoomIncrement,
				defaultManualZoomTime, 0);
	} // end zoomOut

	public void zoomIn() {
		float targetZoom = cameraDist.value() - zoomIncrement;
		targetZoom = targetZoom < minCamDist ? minCamDist : targetZoom;
		cameraDist.playLive(targetZoom, defaultManualZoomTime, 0);
	} // end zoomIn

	// billboarding fun

	// getReverseRotation will find the reverse transform rotates to billboard
	// the image.
	// NOTE: the reverse rotation must be transformed in this order: Z, X
	// IN THE FUTURE CREATE A BILLBOARD TRANSFORM HERE
	public float[] getReverseRotation() {
		float[] reversed = new float[3];
		reversed[0] = cameraZRotation.value() + (float) (Math.PI / 2f); // x
																		// rotation
		reversed[1] = (float) (Math.PI); // y rotation
		reversed[2] = cameraXYRotation.value() + (float) (Math.PI / 2f); // z
																			// rotation
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
		parent.pushMatrix();
		parent.translate(norm.x, norm.y, norm.z);
		parent.rotateZ(reversed[2]);
		parent.rotateY(reversed[1]);
		parent.rotateX(reversed[0]);
	} // end makeBillbaordTransformsWithDepthSpacing

	public void undoBillboardTransforms() {
		parent.popMatrix();
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
		float cameraXYTarget = (float) (Math.PI / 2);
		float cameraZTarget = (float) ((float) (Math.PI / 2) - .0001);
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
		float cameraXYTarget = (float) (Math.PI / 2);
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
		float cameraXYTarget = (float) Math.PI;
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
		float cameraXYTarget = (float) (3 * Math.PI / 2);
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
		float cameraXYTarget = -(float) (Math.PI / 2);
		float cameraZTarget = -(float) (Math.PI / 2 - .0001);
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

	public void toCustomView(ArrayList<PVector> ptsIn, float xyTargetIn,
			float zTargetIn) {
		toCustomView(ptsIn, xyTargetIn, zTargetIn, cameraTweenTime);
	} // end toCustomView

	public void toCustomView(ArrayList<PVector> ptsIn, float xyTargetIn,
			float zTargetIn, float durationIn) {
		startupCameraTween(xyTargetIn, zTargetIn, ptsIn, durationIn);
	} // end toCustomView

	private void startupCameraTween(float cameraXYTarget, float cameraZTarget,
			ArrayList<PVector> ptsIn, float durationIn) {
		resetInertias();
		cameraXYTarget = adjustForNearestRotation(cameraXYTarget
				% (float) (Math.PI * 2), cameraXYRotation.value());
		cameraZTarget = adjustForNearestRotation(cameraZTarget
				% (float) (Math.PI * 2), cameraZRotation.value());
		cameraXYRotation.playLive(cameraXYTarget, durationIn, 0);
		cameraZRotation.playLive(cameraZTarget, durationIn, 0);
		targetNormal = new PVector(
				(float) (Math.cos(cameraXYTarget) * cameraDist.value() * Math
						.cos(cameraZTarget)),
				(float) (Math.sin(cameraXYTarget) * Math.cos(cameraZTarget) * cameraDist
						.value()),
				(float) (Math.sin(cameraZTarget) * cameraDist.value()));
		targetNormal.sub(cameraTarget);
		// targetNormal.sub(cameraTarget.value());
		targetNormal.normalize();
		if (ptsIn != null) {
			zoomToFit(ptsIn, targetNormal, durationIn);
		}
	} // end startupCameraTween

	// frustum fun

	public void shiftFrustum(float leftIn, float rightIn, float durationIn) {
		startingLeftEdge = leftIn;
		startingRightEdge = rightIn;
		leftFrustum.playLive(leftIn, durationIn, 0);
		rightFrustum.playLive(rightIn, durationIn, 0);
		makeScreenLines(leftIn, rightIn, parent.height, 0);
	} // end startFrustumTween

	// leftIn - the left side of the frame
	// rightIn - the right side of the frame
	// frameOfViewIn - the frame of view - in radians
	// depthIn - the depth of the view
	public void makeFrustum(float leftIn, float rightIn, float frameOfViewIn,
			float depthIn) {
		leftIn = parent.constrain(leftIn, 0, parent.width);
		rightIn = parent.constrain(rightIn, 0, parent.width);
		leftIn /= parent.width;
		rightIn /= parent.width;
		float fovy = frameOfViewIn;
		float aspect = (float) parent.width / parent.height;
		float left = leftIn + (rightIn - leftIn) / 2f;
		float right = (1 - left);

		// parent.frustum(-left * aspect, right * aspect, -(1f / 2), (1f / 2),
		// .5f / (float) (Math.atan(fovy / 2)), depthIn);
		parent.frustum(-left * aspect * heightScale, right * aspect
				* heightScale, -(1f / 2) * heightScale, (1f / 2) * heightScale,
				.5f / (float) (Math.atan(fovy / 2)), depthIn);
	} // end makeFrustum

	public void makeScreenLines(float leftIn, float rightIn, float topIn,
			float bottomIn) {
		screenLines = new Line2D[4];
		screenLines[0] = new Line2D.Float(leftIn, bottomIn, leftIn, topIn);
		screenLines[1] = new Line2D.Float(leftIn, bottomIn, rightIn, bottomIn);
		screenLines[2] = new Line2D.Float(rightIn, bottomIn, rightIn, topIn);
		screenLines[3] = new Line2D.Float(leftIn, topIn, rightIn, topIn);
	} // end makeScreenLines

	public Line2D[] getScreenLines() {
		return screenLines;
	} // end getScreenLines

	public float getLeftFrustum() {
		return leftFrustum.getEnd();
	} // end getLeftFrustum

	public float getRightFrustum() {
		return rightFrustum.getEnd();
	} // end getRightFrustum

	// moving the camera

	// will play with the cameraShift to center the cameraTarget to the middle
	// of the ptsIn
	public void centerCamera(ArrayList<PVector> ptsIn) {
		centerCamera(ptsIn, cameraTweenTime);
	} // end centerCamera

	public void centerCamera(ArrayList<PVector> ptsIn, float duration) {
		BoundingBox b = new BoundingBox(getNormal(), ptsIn);
		PVector centroid = b.centroid;
		cameraShift.playLive(centroid, duration, 0);
		manualShift.playLive(new PVector(), duration, 0);
		// System.out.println("trying to shift the cameraShift to : " +
		// centroid.x + ", " + centroid.y + ", " + centroid.z + " from " +
		// cameraShift.value().x + ", " + cameraShift.value().y + ", " +
		// cameraShift.value().z);
	} // end centerCamera

	public PVector getCameraPosition() {
		PVector newPos = PVector.add(cameraShift.value(), cameraLoc);
		newPos.add(manualShift.value());
		return newPos;
	} // end getPosition

	public PVector getCameraTarget() {
		PVector newPos = PVector.add(cameraShift.value(), cameraTarget);
		newPos.add(manualShift.value());
		return newPos;
	} // end getCameraTarget

	public float getDistance() {
		return cameraLoc.dist(cameraTarget);
	} // end getDistance

	public void setView(PVector posIn) {
		setView(posIn, cameraTarget.get(), 0);
	} // end setView

	public void setView(PVector posIn, PVector targetIn) {
		setView(posIn, targetIn, 0);
	}

	public void setTarget(PVector targetIn) {
		setView(getCameraPosition(), targetIn, 0);
	} // end setTarget

	public void setTarget(PVector targetIn, float durationIn) {
		setView(getCameraPosition(), targetIn, durationIn);
	} // end setTarget

	public void setView(PVector posIn, PVector targetIn, float durationIn) {
		resetInertias();

		float targetDist = posIn.dist(targetIn);
		targetDist = targetDist < minCamDist ? minCamDist : targetDist;
		PVector diff = PVector.sub(targetIn, posIn);
		if (diff.x == 0)
			diff.x = (float) .0001;
		float targetCameraRotationXY = (float) Math.atan(diff.y / diff.x);
		if (diff.x > 0)
			targetCameraRotationXY += (float) Math.PI;
		float xyDist = (float) Math.sqrt(diff.x * diff.x + diff.y * diff.y);
		float targetCameraRotationZ = -(float) (Math.atan(diff.z / .0001));
		if (xyDist != 0)
			targetCameraRotationZ = -(float) Math.atan(diff.z / xyDist);

		/*
		 * System.out.println("at START of setView.  targetCameraRotationXY: " +
		 * targetCameraRotationXY + " and current: " +
		 * cameraXYRotation.value());
		 */

		if (cameraXYRotation != null)
			targetCameraRotationXY = adjustForNearestRotation(
					targetCameraRotationXY % (float) (Math.PI * 2),
					cameraXYRotation.value());
		if (cameraZRotation != null)
			targetCameraRotationZ = adjustForNearestRotation(
					targetCameraRotationZ % (float) (Math.PI * 2),
					cameraZRotation.value());

		PVector newShift = targetIn.get();
		if (durationIn <= 0) {
			startingCameraRotationXY = targetCameraRotationXY;
			startingCameraRotationZ = targetCameraRotationZ;
			startingCameraDist = targetDist;
			setupTweens();
			cameraShift.setCurrent(newShift);
			manualShift.setCurrent(new PVector());
		} else {
			// targetCameraRotationXY =
			// adjustForNearestRotation(targetCameraRotationXY,
			// cameraXYRotation.value());
			cameraXYRotation.playLive(targetCameraRotationXY, durationIn, 0);
			cameraZRotation.playLive(targetCameraRotationZ, durationIn, 0);
			cameraDist.playLive(targetDist, durationIn, 0);
			cameraShift.playLive(newShift, durationIn, 0);
			manualShift.playLive(new PVector(), durationIn, 0);

			/*
			 * System.out.println("at END of setView.  targetCameraRotationXY: "
			 * + targetCameraRotationXY + " and current: " +
			 * cameraXYRotation.value());
			 */
		}
	} // end setView

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

		if (setRestrictionPanningZ)
			result.z = 0;

		PVector currentManualShiftValue = manualShift.value().get();
		currentManualShiftValue.add(result);
		// add to manual if cameraShift is playing
		if (cameraShift.isPlaying())
			manualShift.setCurrent(currentManualShiftValue);
		else {
			PVector currentShiftValue = cameraShift.value().get();
			currentShiftValue.add(result);
			cameraShift.setCurrent(currentShiftValue);
		}
	} // end addManualOffset

	/**
	 * This will simply add the offsetIn value to the manual shift Note: not
	 * thoroughly tested - might be an issue for winding down the
	 * cameraShift.value()
	 * 
	 * @param offsetIn
	 *            The PVector offset to be added
	 */
	public void addManualOffsetXYZ(PVector offsetIn) {
		PVector currentManualShiftValue = manualShift.value().get();
		currentManualShiftValue.add(offsetIn);
		// add to manual if cameraShift is playing
		if (cameraShift.isPlaying())
			manualShift.setCurrent(currentManualShiftValue);
		else {
			PVector currentShiftValue = cameraShift.value().get();
			currentShiftValue.add(offsetIn);
			cameraShift.setCurrent(currentShiftValue);
		}

	} // end addManualOffsetXYZ

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
		setView(startingPoint, getCameraTarget(), durationIn);
	} // end setDistance

	// calculations and such
	public float getDistanceFromCameraPlane(PVector pointIn) {
		float result = distanceFromPointToPlane(getNormal(),
				getCameraPosition(), pointIn);
		return result;
	} // end getCameraPlane

	public float getDistanceFromTargetPlane(PVector pointIn) {
		float result = distanceFromPointToPlane(getNormal(), getCameraTarget(),
				pointIn);
		return result;
	} // end getDistanceFromTargetPlane

	private float distanceFromPointToPlane(PVector normalIn,
			PVector planePoint, PVector questionPoint) {
		BoundingBox b = new BoundingBox();
		return Math.abs(b.distanceFromPointToPlane(normalIn, planePoint,
				questionPoint));
	} // end distanceFromPointToPlane

	public PVector getNormal() {
		PVector newNormal = new PVector(cameraTarget.x - cameraLoc.x,
				cameraTarget.y - cameraLoc.y, cameraTarget.z - cameraLoc.z);
		newNormal.normalize();
		return newNormal;
	} // end getNormal

	public PVector getTargetNormal() {
		if (targetNormal == null)
			return getNormal();
		return targetNormal;
	} // end getTargetNormal

	public float smartMod(float numIn, float modNum) {
		float result = numIn % modNum;
		if (numIn < 0)
			result = (modNum + result);
		return result;
	} // end smartMod

	public float adjustForNearestRotation(float angleIn, float currentAngle) {
		float oldRotations = (float) Math.floor(currentAngle
				/ (float) (Math.PI * 2));
		angleIn += oldRotations * (float) (Math.PI * 2);
		float angleLower = angleIn - (float) (Math.PI * 2);
		float angleHigher = angleIn + (float) (Math.PI * 2);
		float diffOriginal = (float) (Math.abs(currentAngle - angleIn));
		float diffLower = (float) (Math.abs(currentAngle - angleLower));
		float diffHigher = (float) (Math.abs(currentAngle - angleHigher));
		if (diffOriginal <= diffLower && diffOriginal <= diffHigher)
			angleIn = angleIn;
		else if (diffLower < diffOriginal)
			angleIn = angleLower;
		else
			angleIn = angleHigher;
		return angleIn;
	} // end adjustForNearestRotation

	private boolean pointOutOfBounds(PVector pointIn) {
		float distFromCamPlane = getDistanceFromCameraPlane(pointIn);
		float distFromTargetPlane = getDistanceFromTargetPlane(pointIn);
		if (distFromTargetPlane > distFromCamPlane) {
			if (distFromTargetPlane > getDistance()) {
				return true;
			}
		}
		return false;
	} // end pointOutOfBounds

	public boolean pointInView(PVector p) {
		return pointInView(p, 0, parent.height);
	} // end pointInView

	public boolean pointInView(PVector p, float newLow, float newHigh) {
		if (pointOutOfBounds(p))
			return false;
		PVector in2dSpace = new PVector(parent.screenX(p.x, p.y, p.z),
				parent.screenY(p.x, p.y, p.z));
		if (in2dSpace.x >= leftFrustum.value()
				&& in2dSpace.x <= rightFrustum.value() && in2dSpace.y >= newLow
				&& in2dSpace.y <= newHigh)
			return true;
		return false;
	} // end pointInView

	public boolean rectInView(ArrayList<PVector> ptsIn) {
		return rectInView(ptsIn, 0, parent.height);
	} // end rectInView

	public boolean rectInView(ArrayList<PVector> ptsIn, float newLow,
			float newHigh) {
		for (PVector p : ptsIn)
			if (pointInView(p, newLow, newHigh))
				return true;
		// if no point is found in view, then look for lines intersecting
		ArrayList<PVector> corners = makeRect2dCorners(ptsIn);
		if (corners == null)
			return false; // null = all pts out of bounds
		for (int i = 0; i < ptsIn.size(); i++) {
			Line2D thisLine = new Line2D.Float(corners.get(i).x,
					corners.get(i).y, corners.get(i - 1 > 0 ? i - 1 : corners
							.size() - 1).x, corners.get(i - 1 > 0 ? i - 1
							: corners.size() - 1).y);
			for (Line2D ln : screenLines) {
				if (thisLine.intersectsLine(ln)) {
					return true;
				}
			}
		}
		// check that the rect does not surround the view
		if (screenLines.length >= 1) {
			PVector screenCorner = new PVector((float) screenLines[0].getX1(),
					(float) screenLines[0].getY1());
			if (isInsidePolygon(screenCorner, corners))
				return true;
		}
		return false;
	} // end rectInView

	public boolean isInsidePolygon(PVector pos, ArrayList<PVector> verticesIn) {
		PVector[] temp = new PVector[verticesIn.size()];
		for (int i = 0; i < temp.length; i++)
			temp[i] = verticesIn.get(i);
		return isInsidePolygon(pos, temp);
	} // end isInsidePolygon

	public boolean isInsidePolygon(PVector pos, PVector[] verticesIn) {
		int i, j = verticesIn.length - 1;
		int sides = verticesIn.length;
		boolean oddNodes = false;
		for (i = 0; i < sides; i++) {
			if ((verticesIn[i].y < pos.y && verticesIn[j].y >= pos.y || verticesIn[j].y < pos.y
					&& verticesIn[i].y >= pos.y)
					&& (verticesIn[i].x <= pos.x || verticesIn[j].x <= pos.x)) {
				oddNodes ^= (verticesIn[i].x + (pos.y - verticesIn[i].y)
						/ (verticesIn[j].y - verticesIn[i].y)
						* (verticesIn[j].x - verticesIn[i].x) < pos.x);
			}
			j = i;
		}
		return oddNodes;
	} // end isInsidePolygon

	// makeRectCorners will take in the 3d points, adjust them, then return the
	// four adjusted 2d screen points
	// note: returns null if all points are off the screen
	public ArrayList<PVector> makeRect2dCorners(ArrayList<PVector> ptsIn) {
		ArrayList<PVector> new2dCorners = new ArrayList<PVector>();
		boolean remake3dPoints = false;
		int outOfBoundsPoints = 0;
		int[] obIndices = new int[ptsIn.size()];
		for (int i = 0; i < ptsIn.size(); i++) {
			boolean pointIsOutOfBounds = pointOutOfBounds(ptsIn.get(i));
			if (pointIsOutOfBounds) {
				remake3dPoints = true;
				outOfBoundsPoints++;
				obIndices[i] = 1;
			}
		}
		if (outOfBoundsPoints == 4) {
			return null;
		} else if (remake3dPoints) {
			ArrayList<PVector> newNew3DCorners = new ArrayList<PVector>();
			for (PVector p : ptsIn)
				newNew3DCorners.add(p.get());
			for (int i = 0; i < obIndices.length; i++) {
				PVector newPoint = ptsIn.get(i).get();
				if (obIndices[i] == 1) {
					int thisIndex = i;
					int nextIndex = i + 1 < ptsIn.size() ? i + 1 : 0;
					int previousIndex = i - 1 >= 0 ? i - 1 : ptsIn.size() - 1;
					int otherIndex = nextIndex + 1 < ptsIn.size() ? nextIndex + 1
							: 0;
					if (obIndices[nextIndex] == 0
							&& obIndices[previousIndex] == 0) {
						// if both previous and next are valid, use the one that
						// is furthest from the camera
						float distNext = getDistanceFromCameraPlane(ptsIn.get(
								nextIndex).get());
						float distPrev = getDistanceFromCameraPlane(ptsIn.get(
								previousIndex).get());
						if (distNext > distPrev)
							newPoint = new3dPoint(ptsIn.get(nextIndex).get(),
									newPoint);
						else
							newPoint = new3dPoint(ptsIn.get(previousIndex)
									.get(), newPoint);
					} else if (obIndices[nextIndex] == 0)
						newPoint = new3dPoint(ptsIn.get(nextIndex).get(),
								newPoint);
					else if (obIndices[previousIndex] == 0)
						newPoint = new3dPoint(ptsIn.get(previousIndex).get(),
								newPoint);
					else if (obIndices[otherIndex] == 0)
						newPoint = new3dPoint(ptsIn.get(otherIndex).get(),
								newPoint);
				}
				newNew3DCorners.get(i).x = newPoint.x;
				newNew3DCorners.get(i).y = newPoint.y;
				newNew3DCorners.get(i).z = newPoint.z;
			}
			ptsIn = newNew3DCorners;
			new2dCorners = make2dCorners(ptsIn);
		} else
			new2dCorners = make2dCorners(ptsIn);
		return new2dCorners;
	} // end makeRect2dCorners

	private ArrayList<PVector> make2dCorners(ArrayList<PVector> ptsIn) {
		ArrayList<PVector> new2DCorners = new ArrayList<PVector>();
		for (PVector p : ptsIn)
			new2DCorners.add(new PVector(parent.screenX(p.x, p.y, p.z), parent
					.screenY(p.x, p.y, p.z)));
		return new2DCorners;
	} // end make2dCorners

	private PVector new3dPoint(PVector pt1, PVector pt2) {
		// calculate the point plane intersection from two points and a plane
		// pt1 will be the one in bounds
		// look at http://paulbourke.net/geometry/pointlineplane/
		PVector norm = getNormal();
		PVector camPos = getCameraPosition().get();
		PVector sub1 = PVector.sub(camPos, pt1);
		PVector sub2 = PVector.sub(pt2, pt1);
		float top = norm.dot(sub1);
		float bot = norm.dot(sub2);
		float u = top / bot;
		PVector dir = PVector.sub(pt2, pt1);
		float dist = (float) (pt1.dist(pt2) * (.99 * u));
		dir.normalize();
		dir.mult(dist);
		PVector result = pt1.get();
		result.add(dir);
		return result;
	} // end new3dPoint

	// key event
	public void keyEvent(KeyEvent event) {
		if (keyControlsOn && event.getAction() == KeyEvent.RELEASE) {
			if (parent.key == '1')
				toTopView();
			else if (parent.key == '2')
				toFrontView();
			else if (parent.key == '3')
				toLeftView();
			else if (parent.key == '4')
				toRightView();
			else if (parent.key == '5')
				toRearView();
			else if (parent.key == '6')
				toBottomView();
		}
	} // end keyEvent

	// mouse thing
	public void mouseEvent(MouseEvent event) {
		// see https://github.com/processing/processing/wiki/Library-Basics for
		// info on getting the mouse stuff to work
		if (pawingControlsOn) {
			if (event.getAction() == MouseEvent.PRESS
					&& event.getButton() == parent.RIGHT && rightMouseInControl) {
				mouseIsPressed = true;
			} else if (event.getAction() == MouseEvent.PRESS
					&& event.getButton() == parent.LEFT && !rightMouseInControl) {
				mouseIsPressed = true;
			} else if (event.getAction() == MouseEvent.RELEASE) {
				mouseIsPressed = false;
			} else if (event.getAction() == MouseEvent.WHEEL
					&& !disablePawingZooming) {
				// check for shift too to switch between moving camera or simple
				// zooming
				shiftWasPressed = (parent.keyPressed && parent.keyCode == parent.SHIFT);
				int zoomCount = event.getCount();
				float zoomAmount = -zoomCount * zoomIncrement
						* cameraDist.value() / (10000);
				distInertia = -zoomAmount;
				// only if shift isnt pressed with the distance change
				if (!shiftWasPressed) {
					float totalToZoom = zoomAmount;
					float targetZoom = cameraDist.value() - totalToZoom;
					targetZoom = targetZoom < minCamDist ? minCamDist
							: targetZoom;
					cameraDist.setCurrent(targetZoom);
				}
				// otherwise the camera pos and target will both change
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

	public void setHeightScale(float heightScaleIn) {
		heightScale = heightScaleIn;
	} // end setHeightScale

	public float getHeightScale() {
		return heightScale;
	} // end getHeightScale
} // end CamCam
