
/*
====================================================================
 TAMIL NADU 3D WIND POWER PLANT
 ADVANCED TOUCH-CONTROLLED AERODYNAMIC LABORATORY

 PROCESSING JAVA MODE / APDE / P3D

 NO KEYBOARD REQUIRED
 ALL CONTROLS ARE TOUCH OPERATED

 SCREEN 1 - 3D WIND TURBINE
  * Three rotating HAWT blades
  * Independent blade pitch controls
  * HAWT / Savonius / Darrieus / Giromill
  * 3D aerodynamic blade mesh
  * Pressure and suction surfaces
  * Wind velocity vector field
  * Blade velocity vectors
  * Relative velocity vectors
  * Lift / Drag / Resultant vectors
  * Global and blade-only vector toggles
  * Live airfoil cross-section
  * Touch camera rotation and zoom
  * Start / Pause / Emergency Brake

 SCREEN 2 - TAMIL NADU WIND RESOURCE
  * 20 regional presets
  * Wind speed slider
  * Wind direction slider
  * Power estimate
  * Battery capacity
  * Battery state of charge
  * Charging estimate

 SCREEN 3 - JOUKOWSKI AIRFOIL LAB
  * Camber slider
  * Thickness slider
  * Angle of attack slider
  * Animated airflow
  * Pressure and suction surfaces

 EDUCATIONAL VISUALIZATION
 NOT VALIDATED CFD OR BEM SOFTWARE
====================================================================
*/

import processing.event.*;

// ================================================================
// CONSTANTS
// ================================================================

final int HAWT=0;
final int SAVONIUS=1;
final int DARRIEUS=2;
final int GIROMILL=3;

final int SCREEN1=0;
final int SCREEN2=1;
final int SCREEN3=2;

final int NST=4;
final int NBLADES=3;

// ================================================================
// GLOBAL STATE
// ================================================================

int screenMode=SCREEN1;
int rotorType=HAWT;

boolean running=true;
boolean brake=false;

boolean showMesh=true;
boolean showPressure=true;

boolean showForces=true;
boolean showField=true;
boolean showStreamlines=true;
boolean showWake=true;

boolean showAllVectors=true;
boolean showBladeVectors=true;
boolean showForceVectors=true;

boolean draggingCamera=false;
boolean draggingSlider=false;

int activeSlider=-1;
int selectedBlade=0;
int selectedStation=2;
int selectedRegion=0;

float timeValue=0;

float windSpeed=8;
float windDirection=0;
float airDensity=1.225;

float rotorAngle=0;
float omega=0;

float rotorRadius=120;
float rotorHeight=210;
float physicalRadius=20;

float cameraYaw=-0.35;
float cameraPitch=-0.20;
float zoomScale=1;

float[] bladePitch={5,5,5};

float airfoilCamber=0.10;
float airfoilThickness=0.12;
float airfoilAngle=5;

float batteryCapacity=10;
float batterySOC=35;

float totalTorque=0;
float mechanicalPower=0;
float electricalPower=0;

float selectedLift=0;
float selectedDrag=0;
float selectedTorque=0;
float selectedAlpha=0;
float selectedRelativeSpeed=0;

PFont fSmall,fMedium,fLarge;

color CYAN;
color BLUE;
color YELLOW;
color GREEN;
color RED;
color WHITE;

// Touch interface dimensions.

float panelX;
float panelW;

// ================================================================
// REGIONS
// ================================================================

String[] regions={
  "Muppandal - Kanyakumari",
  "Aralvaimozhi",
  "Tirunelveli",
  "Coimbatore - Palghat",
  "Kambam - Theni",
  "Dindigul",
  "Sengottai - Tenkasi",
  "Thoothukudi",
  "Ramanathapuram",
  "Madurai",
  "Sivaganga",
  "Pudukkottai",
  "Trichy",
  "Salem",
  "Erode",
  "Tiruppur",
  "Chennai",
  "Nagapattinam",
  "Cuddalore",
  "Thanjavur"
};

float[] regionWind={
  9,8.8,8.2,7.5,7.8,
  6.8,7.8,7.2,6.8,5.4,
  5.2,5.4,5,5.8,6.5,
  6.8,5.5,5.8,5.8,5
};

// ================================================================
// SETUP
// ================================================================

void settings(){
  fullScreen(P3D);
}

void setup(){

  orientation(LANDSCAPE);

  frameRate(40);
  smooth(4);

  CYAN=color(35,225,255);
  BLUE=color(65,140,255);
  YELLOW=color(255,220,55);
  GREEN=color(50,255,130);
  RED=color(255,75,85);
  WHITE=color(245);

  fSmall=createFont("SansSerif",12,true);
  fMedium=createFont("SansSerif",16,true);
  fLarge=createFont("SansSerif.bold",21,true);

  windSpeed=regionWind[0];

  panelX=width*0.68;
  panelW=width*0.30;
}

// ================================================================
// MAIN DRAW
// ================================================================

void draw(){

  background(3,8,23);

  timeValue+=0.025;

  panelX=width*0.68;
  panelW=width*0.30;

  if(running && !brake){

    omega=calculateOmega();

    rotorAngle+=omega/40.0;

  }else{

    omega=0;
  }

  calculateForces();

  if(screenMode==SCREEN1){

    drawScreen1();

  }else if(screenMode==SCREEN2){

    drawScreen2();

  }else{

    drawScreen3();
  }
}

// ================================================================
// PHYSICS UTILITIES
// ================================================================

float clamp(float x,float a,float b){
  return constrain(x,a,b);
}

PVector norm(PVector v){

  PVector n=v.copy();

  if(n.mag()>0.000001)n.normalize();

  return n;
}

float wrapAngle(float a){

  while(a>PI)a-=TWO_PI;
  while(a<-PI)a+=TWO_PI;

  return a;
}

PVector cross(PVector a,PVector b){
  return a.cross(b);
}

// ================================================================
// ROTOR SPEED
// ================================================================

float calculateOmega(){

  if(windSpeed<0.1)return 0;

  float tsr=6;

  if(rotorType==SAVONIUS)tsr=0.9;
  if(rotorType==DARRIEUS)tsr=3;
  if(rotorType==GIROMILL)tsr=2.8;

  float w=tsr*windSpeed/physicalRadius;

  return min(w,38*TWO_PI/60.0);
}

float rpm(){
  return abs(omega)*60/TWO_PI;
}

// ================================================================
// WIND FIELD
// ================================================================

PVector windAt(float x,float y,float z){

  float gust=
    1+
    0.025*sin(timeValue*1.7+x*0.02)+
    0.015*cos(timeValue+y*0.02);

  float v=windSpeed*gust;

  float d=radians(windDirection);

  return new PVector(
    sin(d)*v,
    0.035*v*sin(timeValue+x*0.02),
    cos(d)*v
  );
}

// ================================================================
// BLADE GEOMETRY
// ================================================================

float bladeRotation(int b){

  return rotorAngle+
    TWO_PI*b/3.0-HALF_PI;
}

float stationFraction(int s){

  float[] f={0.25,0.45,0.68,0.90};

  return f[constrain(s,0,3)];
}

float chordAt(float t){
  return 24*(1.0-0.52*t);
}

float twistAt(float t){
  return radians(16-13*t);
}

// ================================================================
// AIRFOIL MATHEMATICS
// ================================================================

float camberAt(float x,float camber){

  float u=constrain((x+1)/2,0,1);

  return camber*sin(PI*u);
}

float thicknessAt(float x,float thickness){

  float u=constrain((x+1)/2,0,1);

  return 5*thickness*(
    0.2969*sqrt(u)-
    0.1260*u-
    0.3516*u*u+
    0.2843*u*u*u-
    0.1015*u*u*u*u
  );
}

PVector airfoilPoint(
  float x,
  float side,
  float camber,
  float thickness,
  float incidence,
  float chord
){

  float yt=thicknessAt(x,thickness);
  float yc=camberAt(x,camber);

  float y=yc+side*yt;

  float a=radians(incidence);

  float xr=x*cos(a)-y*sin(a);
  float yr=x*sin(a)+y*cos(a);

  return new PVector(
    xr*chord/2,
    yr*chord/2,
    0
  );
}

// ================================================================
// BLADE POINT
// ================================================================

PVector bladePoint(
  int blade,
  float t,
  float x,
  float side
){

  float angle=bladeRotation(blade);

  float pitch=bladePitch[blade]+degrees(twistAt(t));

  PVector section=airfoilPoint(
    x,
    side,
    airfoilCamber,
    airfoilThickness,
    pitch,
    chordAt(t)
  );

  float radius=rotorRadius*t;

  float lx=section.x;
  float ly=-radius+section.y;

  float wx=lx*cos(angle)-ly*sin(angle);
  float wy=lx*sin(angle)+ly*cos(angle);

  return new PVector(wx,wy-50,35+section.z);
}

// ================================================================
// BLADE VELOCITY
// ================================================================

PVector bladeVelocity(PVector p){

  PVector arm=new PVector(
    p.x,
    p.y+50,
    0
  );

  return new PVector(
    -omega*arm.y,
    omega*arm.x,
    0
  );
}

// ================================================================
// AERODYNAMIC RESULT
// ================================================================

class AeroResult{

  PVector position;
  PVector wind;
  PVector velocity;
  PVector relative;

  PVector lift;
  PVector drag;
  PVector resultant;

  float speed;
  float alpha;

  float cl;
  float cd;

  float liftN;
  float dragN;

  float torque;
  float pressure;
}

// ================================================================
// SECTION CALCULATION
// ================================================================

AeroResult sectionResult(int b,int s){

  AeroResult a=new AeroResult();

  float t=stationFraction(s);

  a.position=bladePoint(b,t,0,1);

  a.wind=windAt(
    a.position.x,
    a.position.y,
    a.position.z
  );

  a.velocity=bladeVelocity(a.position);

  a.relative=PVector.sub(
    a.wind,
    a.velocity
  );

  a.speed=a.relative.mag();

  float angle=bladeRotation(b);

  PVector span=new PVector(
    -sin(angle),
    cos(angle),
    0
  );

  PVector flow=a.relative.copy();

  flow.sub(
    PVector.mult(span,PVector.dot(flow,span))
  );

  flow=norm(flow);

  PVector chord=new PVector(
    cos(angle),
    sin(angle),
    0
  );

  float pitch=radians(bladePitch[b])+twistAt(t);

  chord.rotate(pitch);

  float dot=clamp(
    PVector.dot(norm(chord),flow),
    -1,1
  );

  a.alpha=wrapAngle(acos(dot));

  float sign=PVector.dot(
    cross(norm(chord),flow),
    span
  );

  if(sign<0)a.alpha=-a.alpha;

  float alpha=clamp(
    a.alpha,
    radians(-15),
    radians(15)
  );

  a.cl=clamp(2*PI*alpha,-1.4,1.4);

  a.cd=0.012+
    0.018*abs(alpha)+
    0.12*alpha*alpha;

  float area=chordAt(t)*4.0;

  float q=0.5*airDensity*a.speed*a.speed;

  a.liftN=q*area*abs(a.cl);
  a.dragN=q*area*a.cd;

  PVector liftDirection=cross(span,flow);

  liftDirection=norm(liftDirection);

  if(a.cl<0)liftDirection.mult(-1);

  a.lift=PVector.mult(
    liftDirection,
    a.liftN
  );

  a.drag=PVector.mult(
    norm(a.relative),
    a.dragN
  );

  a.resultant=PVector.add(a.lift,a.drag);

  PVector arm=new PVector(
    a.position.x,
    a.position.y+50,
    0
  );

  a.torque=cross(arm,a.resultant).z;

  a.pressure=q;

  return a;
}

// ================================================================
// TOTAL FORCES
// ================================================================

void calculateForces(){

  totalTorque=0;

  selectedLift=0;
  selectedDrag=0;
  selectedTorque=0;
  selectedAlpha=0;
  selectedRelativeSpeed=0;

  for(int b=0;b<3;b++){

    for(int s=0;s<NST;s++){

      AeroResult a=sectionResult(b,s);

      totalTorque+=a.torque/4.0;

      if(b==selectedBlade && s==selectedStation){

        selectedLift=a.liftN;
        selectedDrag=a.dragN;

        selectedTorque=a.torque;

        selectedAlpha=degrees(a.alpha);

        selectedRelativeSpeed=a.speed;
      }
    }
  }

  mechanicalPower=abs(totalTorque*omega);

  electricalPower=mechanicalPower*0.90;
}

// ================================================================
// 3D ARROW
// ================================================================

void arrow3D(
  PVector p,
  PVector v,
  float scaleValue,
  color c,
  float weight
){

  if(v.mag()<0.001)return;

  PVector d=norm(v);

  PVector end=PVector.add(
    p,
    PVector.mult(v,scaleValue)
  );

  stroke(c);
  strokeWeight(weight);

  line(
    p.x,p.y,p.z,
    end.x,end.y,end.z
  );

  PVector ref=abs(d.y)<0.9?
    new PVector(0,1,0):
    new PVector(1,0,0);

  PVector side=norm(cross(d,ref));

  float h=7;

  PVector base=PVector.sub(
    end,PVector.mult(d,h)
  );

  PVector aa=PVector.add(
    base,PVector.mult(side,h*0.4)
  );

  PVector zz=PVector.add(
    base,
    PVector.mult(cross(d,side),h*0.4)
  );

  line(end.x,end.y,end.z,aa.x,aa.y,aa.z);

  line(end.x,end.y,end.z,zz.x,zz.y,zz.z);
}

// ================================================================
// SCREEN 1
// ================================================================

void drawScreen1(){

  lights();

  ambientLight(65,75,105);

  directionalLight(
    240,245,255,-0.5,0.5,-1
  );

  pushMatrix();

  translate(width*0.34,height*0.49,0);

  rotateX(cameraPitch);
  rotateY(cameraYaw);

  scale(zoomScale);

  drawGround();

  if(showWake)drawWake();

  if(showField)drawWindField();

  if(showStreamlines)drawWindLines();

  drawTurbine();

  if(showForces)drawForces3D();

  popMatrix();

  drawTopBar("3D WIND TURBINE AERODYNAMICS");

  drawBladeControlPanel();

  drawNavigation();
}

// ================================================================
// GROUND
// ================================================================

void drawGround(){

  stroke(30,70,105,100);
  strokeWeight(1);

  for(int x=-300;x<=300;x+=40){
    line(x,200,-250,x,200,250);
  }

  for(int z=-250;z<=250;z+=40){
    line(-300,200,z,300,200,z);
  }
}

// ================================================================
// TURBINE
// ================================================================

void drawTurbine(){

  if(rotorType!=HAWT){

    drawAlternativeRotor();
    return;
  }

  pushStyle();

  noStroke();

  fill(130,160,185);

  drawCylinder(0,75,0,9,250);

  fill(165,185,205);

  pushMatrix();

  translate(0,-50,0);

  box(85,28,34);

  translate(0,0,35);

  fill(235,245,255);

  sphereDetail(18);
  sphere(13);

  popMatrix();

  for(int b=0;b<3;b++){

    pushMatrix();

    translate(0,-50,35);

    rotateZ(bladeRotation(b));

    drawOneBlade(b);

    popMatrix();
  }

  popStyle();
}

// ================================================================
// BLADE MESH
// ================================================================

void drawOneBlade(int b){

  int ns=25;
  int nc=32;

  if(showMesh){

    for(int i=0;i<ns-1;i++){

      float t0=map(i,0,ns-1,0.06,1);
      float t1=map(i+1,0,ns-1,0.06,1);

      for(int j=0;j<nc-1;j++){

        float x0=map(j,0,nc-1,-1,1);
        float x1=map(j+1,0,nc-1,-1,1);

        PVector p1=localBladePoint(t0,x0,1,b);
        PVector p2=localBladePoint(t1,x0,1,b);
        PVector p3=localBladePoint(t1,x1,1,b);
        PVector p4=localBladePoint(t0,x1,1,b);

        fill(
          showPressure?
          lerpColor(
            color(40,210,255),
            color(30,255,125),
            map(x0,-1,1,0,1)
          ):
          color(100,175,245)
        );

        noStroke();

        beginShape(QUADS);

        vertex(p1.x,p1.y,p1.z);
        vertex(p2.x,p2.y,p2.z);
        vertex(p3.x,p3.y,p3.z);
        vertex(p4.x,p4.y,p4.z);

        endShape();
      }
    }

    // Pressure surface.

    for(int i=0;i<ns-1;i++){

      float t0=map(i,0,ns-1,0.06,1);
      float t1=map(i+1,0,ns-1,0.06,1);

      for(int j=0;j<nc-1;j++){

        float x0=map(j,0,nc-1,-1,1);
        float x1=map(j+1,0,nc-1,-1,1);

        PVector p1=localBladePoint(t0,x0,-1,b);
        PVector p2=localBladePoint(t1,x0,-1,b);
        PVector p3=localBladePoint(t1,x1,-1,b);
        PVector p4=localBladePoint(t0,x1,-1,b);

        fill(
          showPressure?
          color(255,75,80):
          color(70,140,240)
        );

        noStroke();

        beginShape(QUADS);

        vertex(p1.x,p1.y,p1.z);
        vertex(p2.x,p2.y,p2.z);
        vertex(p3.x,p3.y,p3.z);
        vertex(p4.x,p4.y,p4.z);

        endShape();
      }
    }

    // Mesh wireframe.

    stroke(220,245,255,110);
    strokeWeight(0.65);
    noFill();

    for(int i=0;i<ns;i++){

      float t=map(i,0,ns-1,0.06,1);

      beginShape();

      for(int j=0;j<nc;j++){

        float x=map(j,0,nc-1,-1,1);

        PVector p=localBladePoint(t,x,1,b);

        vertex(p.x,p.y,p.z);
      }

      endShape();
    }
  }

  // Blade edge.

  stroke(255,255,255,210);
  strokeWeight(2);

  line(0,0,0,0,-rotorRadius,0);

  if(b==selectedBlade){

    stroke(255,230,60);
    strokeWeight(3);

    line(
      -chordAt(0.1)/2,
      -rotorRadius*0.1,
      2,
      -chordAt(1)/2,
      -rotorRadius,
      2
    );
  }
}

// ================================================================
// LOCAL BLADE POINT
// ================================================================

PVector localBladePoint(
  float t,
  float x,
  float side,
  int blade
){

  float pitch=bladePitch[blade]+degrees(twistAt(t));

  PVector p=airfoilPoint(
    x,side,
    airfoilCamber,
    airfoilThickness,
    pitch,
    chordAt(t)
  );

  return new PVector(
    p.x,
    -rotorRadius*t+p.y,
    p.z
  );
}

// ================================================================
// CYLINDER
// ================================================================

void drawCylinder(
  float x,float y,float z,
  float r,float h
){

  pushMatrix();

  translate(x,y,z);

  noStroke();

  beginShape(QUAD_STRIP);

  for(int i=0;i<=32;i++){

    float a=TWO_PI*i/32;

    float px=cos(a)*r;
    float pz=sin(a)*r;

    vertex(px,-h/2,pz);
    vertex(px,h/2,pz);
  }

  endShape();

  popMatrix();
}

// ================================================================
// ALTERNATIVE ROTORS
// ================================================================

void drawAlternativeRotor(){

  pushStyle();

  fill(120,155,180);

  drawCylinder(0,0,0,8,270);

  pushMatrix();

  rotateY(rotorAngle);

  for(int b=0;b<3;b++){

    pushMatrix();

    rotateY(TWO_PI*b/3);

    if(rotorType==SAVONIUS){

      fill(40,190,235);

      translate(32,0,0);

      box(38,rotorHeight,20);

    }else if(rotorType==DARRIEUS){

      noFill();

      stroke(40,220,255);
      strokeWeight(9);

      beginShape();

      for(int i=0;i<=40;i++){

        float t=map(i,0,40,-1,1);

        float r=rotorRadius*
          (0.68+0.32*cos(t*HALF_PI));

        vertex(r,t*rotorHeight/2,0);
      }

      endShape();

    }else{

      fill(50,160,245);

      translate(rotorRadius,0,0);

      box(14,rotorHeight,17);
    }

    popMatrix();
  }

  popMatrix();

  popStyle();
}

// ================================================================
// VECTOR DISPLAY
// ================================================================

void drawForces3D(){

  for(int b=0;b<3;b++){

    for(int s=0;s<NST;s++){

      boolean selected=
        b==selectedBlade &&
        s==selectedStation;

      if(!showAllVectors && !selected)continue;

      AeroResult a=sectionResult(b,s);

      if(selected){

        stroke(255);
        strokeWeight(9);

        point(
          a.position.x,
          a.position.y,
          a.position.z
        );
      }

      // Wind vector on blades.

      if(showBladeVectors){

        arrow3D(
          a.position,
          a.wind,
          2,
          CYAN,
          selected?3:1
        );

        arrow3D(
          a.position,
          a.velocity,
          1.2,
          BLUE,
          selected?3:1
        );

        arrow3D(
          a.position,
          a.relative,
          2,
          YELLOW,
          selected?3:1
        );
      }

      // Aerodynamic forces.

      if(showForceVectors){

        arrow3D(
          a.position,
          a.lift,
          0.035,
          GREEN,
          selected?3:1
        );

        arrow3D(
          a.position,
          a.drag,
          0.035,
          RED,
          selected?3:1
        );

        arrow3D(
          a.position,
          a.resultant,
          0.035,
          WHITE,
          selected?3:1
        );
      }
    }
  }
}

// ================================================================
// SURROUNDING WIND VECTOR FIELD
// ================================================================

void drawWindField(){

  for(int x=-210;x<=210;x+=65){

    for(int y=-150;y<=150;y+=65){

      for(int z=-150;z<=150;z+=65){

        PVector p=new PVector(x,y,z);

        PVector v=norm(windAt(x,y,z));

        arrow3D(
          p,v,19,
          color(40,145,230,170),
          1
        );
      }
    }
  }
}

// ================================================================
// STREAMLINES
// ================================================================

void drawWindLines(){

  pushStyle();

  stroke(40,210,255,120);
  strokeWeight(1.5);
  noFill();

  for(int x=-160;x<=160;x+=45){

    for(int y=-130;y<=130;y+=45){

      beginShape();

      for(int z=-220;z<=220;z+=8){

        float xx=x+4*sin(z*0.02+timeValue);

        float yy=y+6*sin(
          z*0.018+timeValue+x*0.02
        );

        vertex(xx,yy,z);
      }

      endShape();
    }
  }

  popStyle();
}

// ================================================================
// WAKE
// ================================================================

void drawWake(){

  pushStyle();

  noFill();

  stroke(50,170,255,70);

  for(int z=30;z<=230;z+=30){

    pushMatrix();

    translate(0,0,z);

    ellipse(
      0,0,
      100+z*0.45,
      90+z*0.35
    );

    popMatrix();
  }

  popStyle();
}

// ================================================================
// TOP BAR
// ================================================================

void drawTopBar(String heading){

  hint(DISABLE_DEPTH_TEST);

  camera();
  noLights();

  noStroke();

  fill(3,10,27,245);

  rect(0,0,width,53);

  fill(CYAN);

  textFont(fLarge);

  text(heading,15,7);

  fill(255);

  textFont(fSmall);

  text(
    "WIND "+nf(windSpeed,1,1)+" m/s"+
    "   RPM "+nf(rpm(),1,1)+
    "   OUTPUT "+nf(electricalPower/1000,1,2)+" kW",
    17,34
  );

  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// TOUCH BUTTON
// ================================================================

void touchButton(
  String label,
  float x,
  float y,
  float w,
  float h,
  boolean active
){

  pushStyle();

  stroke(90,200,235);

  strokeWeight(1);

  fill(
    active?
    color(10,125,110):
    color(18,43,72)
  );

  rect(x,y,w,h,7);

  fill(255);

  textFont(fSmall);

  textAlign(CENTER,CENTER);

  text(label,x+w/2,y+h/2);

  textAlign(LEFT,TOP);

  popStyle();
}

// ================================================================
// TOUCH SLIDER
// ================================================================

void touchSlider(
  String label,
  float x,
  float y,
  float w,
  float value,
  float minV,
  float maxV
){

  pushStyle();

  fill(255);

  textFont(fSmall);

  text(label,x,y-10);

  float t=map(
    constrain(value,minV,maxV),
    minV,maxV,
    0,1
  );

  stroke(85,125,160);
  strokeWeight(6);

  line(x,y+12,x+w,y+12);

  stroke(CYAN);
  line(x,y+12,x+w*t,y+12);

  noStroke();

  fill(YELLOW);

  ellipse(x+w*t,y+12,16,16);

  popStyle();
}

// ================================================================
// SCREEN 1 TOUCH PANEL
// ================================================================

void drawBladeControlPanel(){

  hint(DISABLE_DEPTH_TEST);

  camera();
  noLights();

  float x=panelX;
  float y=62;
  float w=panelW;

  fill(4,14,36,245);

  noStroke();

  rect(x,y,w,height-145,12);

  fill(CYAN);

  textFont(fMedium);

  text("TOUCH CONTROL CENTRE",x+12,y+22);

  // Running buttons.

  float bw=(w-36)/2;

  touchButton(
    running?"PAUSE":"START",
    x+12,y+36,bw,36,running
  );

  touchButton(
    "BRAKE",
    x+24+bw,y+36,bw,36,brake
  );

  // Rotor selection.

  textFont(fSmall);

  fill(CYAN);

  text("ROTOR TYPE",x+12,y+94);

  float rw=(w-36)/4;

  String[] rotorNames={
    "HAWT","SAVONIUS","DARRIEUS","GIROMILL"
  };

  for(int i=0;i<4;i++){

    touchButton(
      rotorNames[i],
      x+12+i*(rw+4),
      y+105,
      rw,
      34,
      rotorType==i
    );
  }

  // Independent pitch sliders.

  for(int b=0;b<3;b++){

    float sy=y+175+b*43;

    touchSlider(
      "BLADE "+(b+1)+" PITCH  "+
      nf(bladePitch[b],1,1)+" deg",
      x+12,sy,w-105,
      bladePitch[b],-15,15
    );

    touchButton(
      "SELECT",
      x+w-78,sy-7,65,30,
      selectedBlade==b
    );
  }

  // Section buttons.

  float sy=y+320;

  fill(CYAN);

  text("RADIAL SECTION SELECTION",x+12,sy);

  float sw=(w-36)/4;

  for(int s=0;s<4;s++){

    touchButton(
      "S"+(s+1),
      x+12+s*(sw+4),
      sy+12,
      sw,
      32,
      selectedStation==s
    );
  }

  // Cross-section.

  float cx=x+w*0.50;
  float cy=y+425;

  drawJoukowskiPanel(
    cx,cy,min(w*0.32,80)
  );

  // Vector display buttons.

  float vy=y+510;

  fill(CYAN);

  text("VISUALIZATION TOGGLES",x+12,vy);

  float tw=(w-36)/3;

  touchButton(
    "FIELD",
    x+12,vy+12,tw,31,showField
  );

  touchButton(
    "BLADE VECTORS",
    x+18+tw,vy+12,tw,31,showBladeVectors
  );

  touchButton(
    "FORCES",
    x+24+2*tw,vy+12,tw,31,showForceVectors
  );

  touchButton(
    "STREAMLINES",
    x+12,vy+49,tw,31,showStreamlines
  );

  touchButton(
    "WAKE",
    x+18+tw,vy+49,tw,31,showWake
  );

  touchButton(
    "MESH",
    x+24+2*tw,vy+49,tw,31,showMesh
  );

  touchButton(
    "PRESSURE",
    x+12,vy+86,tw,31,showPressure
  );

  touchButton(
    "ALL VECTORS",
    x+18+tw,vy+86,tw,31,showAllVectors
  );

  touchButton(
    "FORCE DISPLAY",
    x+24+2*tw,vy+86,tw,31,showForces
  );

  // Live results.

  float iy=vy+132;

  fill(CYAN);

  text("LIVE AERODYNAMIC DATA",x+12,iy);

  fill(255);

  text(
    "Relative velocity: "+nf(selectedRelativeSpeed,1,2)+" m/s",
    x+12,iy+20
  );

  text(
    "Angle of attack: "+nf(selectedAlpha,1,2)+" deg",
    x+12,iy+39
  );

  fill(GREEN);

  text(
    "Lift: "+nf(selectedLift,1,2)+" N",
    x+12,iy+58
  );

  fill(RED);

  text(
    "Drag: "+nf(selectedDrag,1,2)+" N",
    x+12,iy+77
  );

  fill(255);

  text(
    "Torque: "+nf(totalTorque,1,2)+" Nm",
    x+12,iy+96
  );

  text(
    "Power: "+nf(mechanicalPower/1000,1,3)+" kW",
    x+12,iy+115
  );

  // Camera buttons.

  touchButton(
    "LEFT",
    x+12,iy+130,tw,31,false
  );

  touchButton(
    "RIGHT",
    x+18+tw,iy+130,tw,31,false
  );

  touchButton(
    "RESET",
    x+24+2*tw,iy+130,tw,31,false
  );

  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// AIRFOIL PANEL
// ================================================================

void drawJoukowskiPanel(
  float ox,
  float oy,
  float sc
){

  pushStyle();

  rectMode(CENTER);

  noStroke();

  fill(5,25,48,245);

  rect(
    ox,oy,
    sc*2+24,
    sc*1.15+36,
    10
  );

  rectMode(CORNER);

  // Airfoil fill.

  noStroke();

  fill(30,140,225,100);

  beginShape();

  for(int i=0;i<=100;i++){

    float x=map(i,0,100,-1,1);

    float yt=thicknessAt(x,airfoilThickness);
    float yc=camberAt(x,airfoilCamber);

    float a=radians(airfoilAngle);

    float xx=x*cos(a)-(yc+yt)*sin(a);
    float yy=x*sin(a)+(yc+yt)*cos(a);

    vertex(ox+xx*sc,oy-yy*sc);
  }

  for(int i=100;i>=0;i--){

    float x=map(i,0,100,-1,1);

    float yt=thicknessAt(x,airfoilThickness);
    float yc=camberAt(x,airfoilCamber);

    float a=radians(airfoilAngle);

    float xx=x*cos(a)-(yc-yt)*sin(a);
    float yy=x*sin(a)+(yc-yt)*cos(a);

    vertex(ox+xx*sc,oy-yy*sc);
  }

  endShape(CLOSE);

  // Suction side.

  stroke(30,255,160);
  strokeWeight(2);
  noFill();

  beginShape();

  for(int i=0;i<=100;i++){

    float x=map(i,0,100,-1,1);

    float yy=camberAt(x,airfoilCamber)+
      thicknessAt(x,airfoilThickness);

    float a=radians(airfoilAngle);

    vertex(
      ox+(x*cos(a)-yy*sin(a))*sc,
      oy-(x*sin(a)+yy*cos(a))*sc
    );
  }

  endShape();

  // Pressure side.

  stroke(255,85,95);

  beginShape();

  for(int i=0;i<=100;i++){

    float x=map(i,0,100,-1,1);

    float yy=camberAt(x,airfoilCamber)-
      thicknessAt(x,airfoilThickness);

    float a=radians(airfoilAngle);

    vertex(
      ox+(x*cos(a)-yy*sin(a))*sc,
      oy-(x*sin(a)+yy*cos(a))*sc
    );
  }

  endShape();

  fill(255);

  textFont(fSmall);
  textAlign(CENTER);

  text("LIVE AIRFOIL SECTION",ox,oy+sc*0.85);

  textAlign(LEFT);

  popStyle();
}

// ================================================================
// SCREEN 2
// ================================================================

void drawScreen2(){

  hint(DISABLE_DEPTH_TEST);

  camera();
  noLights();

  background(4,12,30);

  drawTopBar("TAMIL NADU WIND + BATTERY LAB");

  float x=20;
  float y=70;

  fill(5,22,48);

  noStroke();

  rect(x,y,width-40,height-160,12);

  fill(CYAN);

  textFont(fMedium);

  text("SELECT WIND REGION",x+15,y+25);

  textFont(fSmall);

  // Region buttons.

  for(int i=0;i<regions.length;i++){

    int col=i%2;
    int row=i/2;

    float bx=x+15+col*width*0.24;
    float by=y+45+row*31;

    touchButton(
      regions[i],
      bx,by,width*0.22,26,
      selectedRegion==i
    );
  }

  float px=width*0.54;
  float py=y+65;

  fill(CYAN);

  textFont(fMedium);

  text("WIND RESOURCE",px,py);

  touchSlider(
    "Wind speed: "+nf(windSpeed,1,2)+" m/s",
    px,py+35,width*0.32,
    windSpeed,0,25
  );

  touchSlider(
    "Wind direction: "+nf(windDirection,1,0)+" deg",
    px,py+90,width*0.32,
    windDirection,0,360
  );

  float area=PI*sq(physicalRadius);

  float windPower=
    0.5*airDensity*area*pow(windSpeed,3);

  float output=windPower*0.35*0.90;

  fill(GREEN);

  text("ESTIMATED OUTPUT",px,py+150);

  fill(255);

  text(
    "Wind power: "+nf(windPower/1000,1,2)+" kW",
    px,py+175
  );

  text(
    "Electrical estimate: "+nf(output/1000,1,2)+" kW",
    px,py+198
  );

  // Battery.

  fill(CYAN);

  textFont(fMedium);

  text("BATTERY STORAGE",px,py+250);

  touchSlider(
    "Capacity: "+nf(batteryCapacity,1,1)+" kWh",
    px,py+280,width*0.32,
    batteryCapacity,1,100
  );

  touchSlider(
    "Battery SOC: "+nf(batterySOC,1,1)+"%",
    px,py+330,width*0.32,
    batterySOC,0,100
  );

  float stored=batteryCapacity*batterySOC/100;

  float remaining=batteryCapacity-stored;

  float charging=output*0.90/1000;

  fill(255);

  text(
    "Stored energy: "+nf(stored,1,2)+" kWh",
    px,py+375
  );

  text(
    "Remaining: "+nf(remaining,1,2)+" kWh",
    px,py+398
  );

  text(
    "Ideal charging time: "+
    (charging>0.01?
    nf(remaining/charging,1,2)+" hours":
    "No charging"),
    px,py+421
  );

  fill(120,190,220);

  text(
    "Regional values are educational presets, not measured site data.",
    25,height-125
  );

  drawNavigation();

  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// SCREEN 3
// ================================================================

void drawScreen3(){

  hint(DISABLE_DEPTH_TEST);

  camera();
  noLights();

  background(3,10,28);

  drawTopBar("JOUKOWSKI AIRFOIL LABORATORY");

  fill(5,20,45);

  noStroke();

  rect(15,65,width-30,height-160,12);

  float x=35;
  float y=110;

  fill(CYAN);

  textFont(fMedium);

  text("TOUCH AIRFOIL PARAMETERS",x,y);

  touchSlider(
    "Camber: "+nf(airfoilCamber,1,3),
    x,y+55,230,
    airfoilCamber,0,0.25
  );

  touchSlider(
    "Thickness: "+nf(airfoilThickness,1,3),
    x,y+120,230,
    airfoilThickness,0.04,0.22
  );

  touchSlider(
    "Angle of attack: "+nf(airfoilAngle,1,1)+" deg",
    x,y+185,230,
    airfoilAngle,-15,15
  );

  float ox=width*0.56;
  float oy=height*0.47;

  drawAirfoilFlow(ox,oy,150);

  drawJoukowskiPanel(
    ox,oy,120
  );

  fill(GREEN);

  text("GREEN = SUCTION SIDE",width*0.79,150);

  fill(RED);

  text("RED = PRESSURE SIDE",width*0.79,180);

  fill(CYAN);

  text("JOUKOWSKI MAPPING",width*0.79,230);

  fill(255);

  text("z = ζ + c² / ζ",width*0.79,260);

  text(
    "Airfoil geometry changes with controls.",
    width*0.79,300
  );

  drawNavigation();

  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// AIRFOIL FLOW
// ================================================================

void drawAirfoilFlow(
  float ox,
  float oy,
  float sc
){

  pushStyle();

  stroke(35,190,255,120);
  strokeWeight(1.5);

  noFill();

  for(int row=-7;row<=7;row++){

    float base=row*17;

    beginShape();

    for(int i=0;i<=100;i++){

      float x=map(i,0,100,-sc*1.8,sc*1.8);

      float bend=
        base+
        sin(x/sc*PI+timeValue)*25*
        exp(-sq(x/(sc*0.8)));

      vertex(ox+x,oy-bend);
    }

    endShape();

    float px=map(
      (timeValue*55+row*30)%240,
      0,240,
      -sc*1.8,sc*1.8
    );

    float py=base+
      sin(px/sc*PI+timeValue)*25*
      exp(-sq(px/(sc*0.8)));

    noStroke();

    fill(80,240,255);

    ellipse(ox+px,oy-py,5,5);
  }

  popStyle();
}

// ================================================================
// NAVIGATION BUTTONS
// ================================================================

void drawNavigation(){

  hint(DISABLE_DEPTH_TEST);

  camera();
  noLights();

  float y=height-75;

  float gap=8;

  float w=(width-40-2*gap)/3;

  String[] labels={
    "1 TURBINE",
    "2 TAMIL NADU",
    "3 AIRFOIL LAB"
  };

  for(int i=0;i<3;i++){

    touchButton(
      labels[i],
      15+i*(w+gap),
      y,w,36,
      screenMode==i
    );
  }

  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// TOUCH INPUT - NAVIGATION
// ================================================================

void mousePressed(){

  // Navigation.

  float navY=height-75;

  if(mouseY>=navY && mouseY<=navY+38){

    float gap=8;

    float w=(width-40-2*gap)/3;

    int i=floor((mouseX-15)/(w+gap));

    if(i>=0 && i<3){

      screenMode=i;

      draggingCamera=false;
      draggingSlider=false;

    }

    return;
  }

  if(screenMode==SCREEN1){

    handleScreen1Touch();

  }else if(screenMode==SCREEN2){

    handleScreen2Touch();

  }else{

    handleScreen3Touch();
  }
}

// ================================================================
// TOUCH HIT TEST
// ================================================================

boolean inside(
  float x,float y,
  float w,float h
){

  return mouseX>=x &&
    mouseX<=x+w &&
    mouseY>=y &&
    mouseY<=y+h;
}

// ================================================================
// SCREEN 1 TOUCH HANDLER
// ================================================================

void handleScreen1Touch(){

  float x=panelX;
  float y=62;
  float w=panelW;

  float bw=(w-36)/2;

  // START / PAUSE.

  if(inside(x+12,y+36,bw,36)){

    running=!running;

    if(running)brake=false;

    return;
  }

  // Emergency brake.

  if(inside(x+24+bw,y+36,bw,36)){

    brake=!brake;

    if(brake)running=false;

    return;
  }

  // Rotor selection.

  float rw=(w-36)/4;

  for(int i=0;i<4;i++){

    if(inside(
      x+12+i*(rw+4),
      y+105,
      rw,34
    )){

      rotorType=i;

      return;
    }
  }

  // Pitch sliders and blade selection.

  for(int b=0;b<3;b++){

    float sy=y+175+b*43;

    if(inside(x+12,sy-9,w-105,30)){

      selectedBlade=b;

      activeSlider=b;

      draggingSlider=true;

      updateBladePitch(mouseX);

      return;
    }

    if(inside(x+w-78,sy-7,65,30)){

      selectedBlade=b;

      return;
    }
  }

  // Section selection.

  float sy=y+320;

  float sw=(w-36)/4;

  for(int s=0;s<4;s++){

    if(inside(
      x+12+s*(sw+4),
      sy+12,
      sw,32
    )){

      selectedStation=s;

      return;
    }
  }

  // Visualization toggles.

  float vy=y+510;

  float tw=(w-36)/3;

  if(inside(x+12,vy+12,tw,31)){
    showField=!showField;
    return;
  }

  if(inside(x+18+tw,vy+12,tw,31)){
    showBladeVectors=!showBladeVectors;
    return;
  }

  if(inside(x+24+2*tw,vy+12,tw,31)){
    showForceVectors=!showForceVectors;
    return;
  }

  if(inside(x+12,vy+49,tw,31)){
    showStreamlines=!showStreamlines;
    return;
  }

  if(inside(x+18+tw,vy+49,tw,31)){
    showWake=!showWake;
    return;
  }

  if(inside(x+24+2*tw,vy+49,tw,31)){
    showMesh=!showMesh;
    return;
  }

  if(inside(x+12,vy+86,tw,31)){
    showPressure=!showPressure;
    return;
  }

  if(inside(x+18+tw,vy+86,tw,31)){
    showAllVectors=!showAllVectors;
    return;
  }

  if(inside(x+24+2*tw,vy+86,tw,31)){
    showForces=!showForces;
    return;
  }

  // Camera buttons.

  float iy=vy+132;

  if(inside(x+12,iy+130,tw,31)){

    cameraYaw-=0.15;

    return;
  }

  if(inside(x+18+tw,iy+130,tw,31)){

    cameraYaw+=0.15;

    return;
  }

  if(inside(x+24+2*tw,iy+130,tw,31)){

    cameraYaw=-0.35;
    cameraPitch=-0.20;
    zoomScale=1;

    return;
  }

  // Camera touch drag.

  if(mouseX<panelX){

    draggingCamera=true;
  }
}

// ================================================================
// PITCH SLIDER UPDATE
// ================================================================

void updateBladePitch(float mx){

  if(activeSlider<0 || activeSlider>=3)return;

  float x=panelX+12;
  float w=panelW-105;

  bladePitch[activeSlider]=map(
    constrain(mx,x,x+w),
    x,x+w,
    -15,15
  );
}

// ================================================================
// SCREEN 2 TOUCH HANDLER
// ================================================================

void handleScreen2Touch(){

  float x=20;
  float y=70;

  // Regional selection.

  for(int i=0;i<regions.length;i++){

    int col=i%2;
    int row=i/2;

    float bx=x+15+col*width*0.24;
    float by=y+45+row*31;

    if(inside(
      bx,by,width*0.22,26
    )){

      selectedRegion=i;

      windSpeed=regionWind[i];

      return;
    }
  }

  float px=width*0.54;
  float py=y+65;

  // Wind speed.

  if(inside(px,py+25,width*0.32,25)){

    windSpeed=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      0,25
    );

    return;
  }

  // Wind direction.

  if(inside(px,py+80,width*0.32,25)){

    windDirection=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      0,360
    );

    return;
  }

  // Battery capacity.

  if(inside(px,py+265,width*0.32,30)){

    batteryCapacity=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      1,100
    );

    return;
  }

  // Battery SOC.

  if(inside(px,py+315,width*0.32,30)){

    batterySOC=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      0,100
    );

    return;
  }
}

// ================================================================
// SCREEN 3 TOUCH HANDLER
// ================================================================

void handleScreen3Touch(){

  float x=35;
  float y=110;

  if(inside(x,y+45,230,25)){

    airfoilCamber=map(
      constrain(mouseX,x,x+230),
      x,x+230,
      0,0.25
    );

    return;
  }

  if(inside(x,y+110,230,25)){

    airfoilThickness=map(
      constrain(mouseX,x,x+230),
      x,x+230,
      0.04,0.22
    );

    return;
  }

  if(inside(x,y+175,230,25)){

    airfoilAngle=map(
      constrain(mouseX,x,x+230),
      x,x+230,
      -15,15
    );

    return;
  }
}

// ================================================================
// TOUCH DRAGGING
// ================================================================

void mouseDragged(){

  if(draggingCamera){

    cameraYaw+=(mouseX-pmouseX)*0.008;

    cameraPitch=constrain(
      cameraPitch+(mouseY-pmouseY)*0.006,
      -1.1,1.1
    );

    return;
  }

  if(draggingSlider){

    updateBladePitch(mouseX);

    return;
  }

  if(screenMode==SCREEN2){

    handleScreen2Drag();

  }else if(screenMode==SCREEN3){

    handleScreen3Drag();
  }
}

// ================================================================
// SCREEN 2 CONTINUOUS SLIDERS
// ================================================================

void handleScreen2Drag(){

  float px=width*0.54;
  float py=135;

  if(mouseY>=py+25 && mouseY<=py+50){

    windSpeed=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      0,25
    );
  }

  if(mouseY>=py+80 && mouseY<=py+105){

    windDirection=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      0,360
    );
  }

  if(mouseY>=py+265 && mouseY<=py+295){

    batteryCapacity=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      1,100
    );
  }

  if(mouseY>=py+315 && mouseY<=py+345){

    batterySOC=map(
      constrain(mouseX,px,px+width*0.32),
      px,px+width*0.32,
      0,100
    );
  }
}

// ================================================================
// SCREEN 3 CONTINUOUS SLIDERS
// ================================================================

void handleScreen3Drag(){

  float x=35;
  float y=110;

  if(mouseY>=y+45 && mouseY<=y+70){

    airfoilCamber=map(
      constrain(mouseX,x,x+230),
      x,x+230,
      0,0.25
    );
  }

  if(mouseY>=y+110 && mouseY<=y+135){

    airfoilThickness=map(
      constrain(mouseX,x,x+230),
      x,x+230,
      0.04,0.22
    );
  }

  if(mouseY>=y+175 && mouseY<=y+200){

    airfoilAngle=map(
      constrain(mouseX,x,x+230),
      x,x+230,
      -15,15
    );
  }
}

// ================================================================
// TOUCH RELEASE
// ================================================================

void mouseReleased(){

  draggingCamera=false;

  draggingSlider=false;

  activeSlider=-1;
}

// ================================================================
// END OF TOUCH-CONTROLLED SIMULATOR
// ================================================================
