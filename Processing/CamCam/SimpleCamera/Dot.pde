class Dot {
  PVSTween pos = new PVSTween(100, 0, new PVector(), new PVector());
  FSTween rot = new FSTween(100, 0, 0, 0); 
  
  Dot (PVector pos_){
    pos.setCurrent(pos_);
  } // end constructor
  
  void display(){
    pushMatrix();
    translate(pos.value().x, pos.value().y, pos.value().z);
    rotate(rot.value());
    stroke(255);
    noFill();
    box(5);
    popMatrix();
  } // end display
  
} // end class Dot
