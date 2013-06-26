class STween {
  // this will simply r
  int duration = 1;
  float progress = 0f; // where it is along the duration
  float lastFrame = -1f;
  float percent = 0f; // progress / duration
  int delay = 0;
  float startValue = 0f;
  float endValue = 1f;
  private float value = 1f;
  float conception = 0f;

  final int LINEAR = 0;
  final int QUAD_BOTH = 1;
  final int CUBIC_BOTH = 2;
  final int QUARTIC_BOTH = 3;
  final int QUINT_IN = 20;
  int mode = QUAD_BOTH; // default

  boolean isPlaying = false; 

  // redirect
  STween redirectTween = null;
  boolean inRedirect = false;
  float redirectNewTarget = 0f;
  float redirectOldTarget = 0f;
  int redirectNewDuration = 0;
  int redirectOldDuration = 0;

  STween (int duration_, int delay_) {
    duration = duration_;
    delay = delay_;
    value = startValue;
  } // end Constructor

  void setModeLinear () {
    mode = LINEAR;
  } // end setModeLinear
  void setModeCubicBoth() {
    mode = CUBIC_BOTH;
  } // end setModeCubic
  void setModeQuadBoth() {
    mode = QUAD_BOTH;
  } // end setModeQuadBot
  void setModeQuarticBoth() {
    mode = QUARTIC_BOTH;
  } // end setModeQuarticBoth
  void setModeQuintIn() {
    mode = QUINT_IN;
  } // end setModeQuintIn

  void play() {
    if (!isPlaying && progress > 0) conception -= delay;
    else if (!isPlaying) conception = frameCount;
    if (progress == duration || isPlaying) progress = 0;
    if (redirectTween != null) redirectTween.play();
    isPlaying = true;
  } // end play

  void pause() {
    isPlaying = false;
    if (redirectTween != null) redirectTween.pause();
  } // end 

  boolean isPlaying() {
    return isPlaying;
  } // end isPlaying

    void setBegin(float valueIn) {
   resetProgress();
    startValue = valueIn;
  } // end setBegin

    void setEnd (float valueIn) {
    setBegin(value);
    endValue = valueIn;
  } // end setEnd

  void resetProgress (){
    progress = 0;
  } // end resetProgress

  void setDelay (int delayIn) {
    if (!isPlaying()) {
      //println("in SimpleTween.  setting delay to: " + delayIn);
      delay = delayIn;
    }
  } // end setDelay

  void setDuration(int durationIn) {
    duration = durationIn;
  } // end setDuration

    float getProgress () {
    return progress;
  } // end getProgress

    boolean isDone () {
    if (progress == duration) return true;
    return false;
  } // end isDone


    float valueST() {
    updateRedirect();
    if (isPlaying && progress >= duration && redirectTween == null) {
      //println(frameCount + " toggling isPlaying to false");
      isPlaying = false;
    }
    if (isPlaying && frameCount > conception + delay) {
      if (frameCount != lastFrame) {
        progress++;
        lastFrame = frameCount;
      }
      findValue();
    }
    else if (progress == duration && redirectTween != null) {
      value = endValue;
    }
    else if (progress == 0) {
      value = startValue;
    }
    updatePercent();
    return value;
  }// end value


    void updatePercent() {
    percent = (float)progress / duration;
    //if (redirectTween != null) if (progress == duration && redirectTween.isPlaying()) percent = (float)(progress + (redirectTween.progress - (conception + duration - redirectTween.conception))) / duration;
  } // end updateMultiplierAndPercent

  void findValue() {
    // see http://www.gizma.com/easing/
    // t = current time -- frameCount - conception
    // b = start value -- startValue
    // c = change in value -- (endValue - startValue)
    // d = duration -- duration
    float t = progress;
    float c = (endValue - startValue);
    float d = duration;
    float b = startValue;
    switch (mode) {
    case LINEAR :
      value = c*t/d + b; 
      break;
    case QUAD_BOTH : 
      t /= d/2;
      if (t < 1) value = c/2*t*t + b;
      else {
        t--;
        value = -c/2 * (t*(t-2) - 1) + b;
      }
      break;
    case CUBIC_BOTH : 
      t /= d/2;
      if (t < 1) value = c/2*t*t*t + b;
      else {
        t-=2;
        value = c/2*(t*t*t + 2) + b;
      }
      break;      
    case QUARTIC_BOTH :
      t /= d/2;
      if (t < 1) value = c/2*t*t*t*t + b;
      else {
        t -= 2;
        value = -c/2 * (t*t*t*t - 2) + b;
      }
      break;
    case QUINT_IN :
      t /= d;
      value = c*t*t*t*t*t + b;
      break;
    } // end switch
  } // end findValue

  void redirect() {
    if (isPlaying && redirectTween == null) { // for now only one redirect is allowed because more than one looks crappy
      //redirectTween = new STween(duration - progress - 1, 0, 0, 1);
      redirectTween = new STween(duration, 0);
      //println ("making new reidreictTween.  should die at frame : " + (frameCount + duration));
      redirectTween.mode = mode;
      redirectTween.play();
      redirectNewTarget = 1f;
      redirectOldTarget = endValue;
      redirectNewDuration = floor((duration - (conception + duration - redirectTween.conception)));
      redirectOldDuration = duration;      
      inRedirect = true;
    }
  } // end redirect

  void updateRedirect() {
    if (inRedirect) {
      if (redirectTween.isDone() && progress >= duration) {
        endValue = redirectNewTarget;
        //println("resetting old duration: " + duration);
        duration = redirectOldDuration;
        //println("resetting old duration: " + duration);
        inRedirect = false;
        redirectTween = null;
      }
      else {
        endValue = (redirectTween.valueST() * redirectNewTarget + (1 - redirectTween.valueST()) * redirectOldTarget);
        duration = floor(redirectTween.valueST() * redirectNewDuration + (redirectOldDuration));
      }
    }
  } // end updateRedirect

  String toString () {
    return frameCount + " - tween percent: " +  nf(percent, 0, 3) + " duration: " + duration + " start: " + startValue + " end: " + endValue + " isPlaying: " + isPlaying + " value: " + value + " conception: " + conception + " delay: " + delay;
  } // end toString
} // end class SimpleTween






class FSTween extends STween {
  float startFloat = 0f;
  float endFloat = 1f;

  private float valueF;

  // redirect vars
  float redirectNewTargetF;
  float redirectOldTargetF;

  FSTween (int duration_, int delay_, float startFloat_, float endFloat_) {
    super(duration_, delay_);
    startFloat = startFloat_;
    endFloat = endFloat_;
    valueF = startFloat;
  } // end constructor

  void playLive(float valueIn) {
    if (valueIn - endFloat != 0 || (!super.isPlaying() && startFloat != endFloat)) {
      if (super.isPlaying() && super.redirectTween == null) {
        redirect(valueIn);
        println("making new redirect.  trying to go from old end: " + endFloat + " to new end: " + valueIn);
      }
      else if (!super.isPlaying() && !super.inRedirect) {
        setBegin(valueF);
        setEnd(valueIn);
        super.play();
      }
      else return;
    }
  } // end playLive


  void setBegin(float valueIn) {
    startFloat = valueIn;
  } // end setBegin

    void setEnd (float valueIn) {
    setBegin(valueF);
    super.setBegin(0);
    endFloat = valueIn;
  } // end setEnd

  float getEnd () {
    return endFloat;
} // end getEnd

float value() {
  updateRedirectC();
  float multiplier = super.valueST();
  if (multiplier == 1) valueF = endFloat;
  else if (multiplier == 0) valueF = startFloat;
  else {
    valueF = (multiplier * endFloat) + (1 - multiplier) * startFloat;
  }
  return valueF;
} // end value

void redirect(float f) {
  if (super.isPlaying && super.redirectTween == null) {
    super.redirect();
    redirectNewTargetF = f;
    redirectOldTargetF = endFloat;
  }
} // end redirect  

void updateRedirectC() {
  if (super.inRedirect) {
    if (super.redirectTween.isDone()) {
      endFloat = redirectNewTargetF;
    }
    else {        
      endFloat = (super.redirectTween.valueST() * redirectNewTargetF) + (1 - super.redirectTween.valueST()) * redirectOldTargetF;
    }
  }
} // end updateRedirect
} // end class FTween





class PVSTween extends STween {
  PVector startPV = new PVector();
  PVector endPV = new PVector();
  private PVector valuePV = new PVector();

  // redirect vars
  PVector redirectNewTargetPV = new PVector();
  PVector redirectOldTargetPV = new PVector();

  PVSTween (int duration_, int delay_, PVector startPV_, PVector endPV_) {
    super(duration_, delay_);
    startPV = startPV_;
    endPV = endPV_;
    valuePV = startPV.get();
  } // end constructor

  void playLive(PVector valueIn) {
    PVector test = PVector.sub(valueIn, endPV);
    if ((valueIn.x - endPV.x != 0 || valueIn.y - endPV.y != 0 || valueIn.z - endPV.z != 0)  || (!super.isPlaying() && ((startPV.x != endPV.x && startPV.y != endPV.y && startPV.z != endPV.z)))) {
      if (super.isPlaying() && !super.inRedirect) {
        redirect(valueIn);
      }
      else if (!super.isPlaying() && !super.inRedirect) {
        setBegin(valuePV);
        setEnd(valueIn);
        super.play();
      }
      else return;
    }
  } // end playLive

  void setBegin(PVector valueIn) {
    startPV = valueIn;
  } // end setBegin

    void setEnd (PVector valueIn) {
    setBegin(valuePV);
    super.setBegin(0);
    endPV = valueIn;
  } // end setEnd

  PVector getEnd () {
    return endPV;
} // end getEnd

  PVector value() {
    updateRedirectPV();
    float multiplier = super.valueST();
    //println("multiplier: " + multiplier);
    if (multiplier == 1) valuePV = endPV.get();
    else if (multiplier == 0) valuePV = startPV.get();
    else {
      PVector diff = PVector.sub(endPV, startPV);
      diff.mult(multiplier);
      valuePV = PVector.add(startPV, diff);
    }
    return valuePV;
  } // end value

  void redirect(PVector valueIn) {
    if (super.isPlaying && super.redirectTween == null) {
      super.redirect();
      redirectNewTargetPV = valueIn.get();
      redirectOldTargetPV = endPV.get();
    }
  } // end redirect  


  // note to self... ideally maybe the start position should shift too...?
    void updateRedirectPV() {
    if (super.inRedirect) {
      if (super.redirectTween.isDone()) {
        endPV = redirectNewTargetPV.get();
      }
      else {
        PVector a = PVector.mult(redirectNewTargetPV, (super.redirectTween.valueST()));
        PVector b = PVector.mult(redirectOldTargetPV, (1 - super.redirectTween.valueST()));
        endPV = PVector.add(b, a);
      }
    }
  } // end updateRedirect
} // end class PVSTween






class CSTween extends STween {
  color startColor, endColor;
  private color valueC;

  // redirect vars
  color redirectNewTargetC;
  color redirectOldTargetC;

  CSTween (int duration_, int delay_, color startColor_, color endColor_) {
    super(duration_, delay_);
    startColor = startColor_;
    endColor = endColor_;
    valueC = startColor;
  } // end constructor

    void playLive(color valueIn) {
    if (valueIn - endColor != 0 || (!super.isPlaying() && startColor != endColor)) {
      if (super.isPlaying() && !super.inRedirect) {
        redirect(valueIn);
      }
      else if (!super.isPlaying() && !super.inRedirect) {
        setBegin(valueC);
        setEnd(valueIn);
        super.play();
      }
      else return;
    }
  } // end playLive


  void setBegin(color valueIn) {
    startColor = valueIn;
  } // end setBegin

    void setEnd (color valueIn) {
    setBegin(valueC);
    super.setBegin(0);
    endColor = valueIn;
  } // end setEnd

  color getEnd () {
    return endColor;
} // end getEnd

  color value() {
    updateRedirectC();
    float multiplier = super.valueST();
    if (multiplier == 1) valueC = endColor;
    else if (multiplier == 0) valueC = startColor;
    else {
      float r = (multiplier * red(endColor) + (1 - multiplier) * red(startColor));
      float g = (multiplier * green(endColor) + (1 - multiplier) * green(startColor));
      float b = (multiplier * blue(endColor) + (1 - multiplier) * blue(startColor));
      float a = (multiplier * alpha(endColor) + (1 - multiplier) * alpha(startColor));
      valueC = color(r, g, b, a);
    }
    return valueC;
  } // end value

  void redirect(color c) {
    if (super.isPlaying && super.redirectTween == null) {
      super.redirect();
      redirectNewTargetC = c;
      redirectOldTargetC = endColor;
    }
  } // end redirect  

  void updateRedirectC() {
    if (super.inRedirect) {
      if (super.redirectTween.isDone()) {
        endColor = redirectNewTargetC;
      }
      else {
        float r = (super.redirectTween.valueST() * red(redirectNewTargetC) + (1 - super.redirectTween.valueST()) * red(redirectOldTargetC));
        float g = (super.redirectTween.valueST() * green(redirectNewTargetC) + (1 - super.redirectTween.valueST()) * green(redirectOldTargetC));
        float b = (super.redirectTween.valueST() * blue(redirectNewTargetC) + (1 - super.redirectTween.valueST()) * blue(redirectOldTargetC));
        float a = (super.redirectTween.valueST() * alpha(redirectNewTargetC) + (1 - super.redirectTween.valueST()) * alpha(redirectOldTargetC));        
        endColor = color(r, g, b, a);
      }
    }
  } // end updateRedirect
} // end class CSTween


