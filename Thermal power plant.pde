
/*
 * THERMAL POWER PLANT - STEP-BY-STEP FLOW SIMULATOR
 * Processing Java Mode / Android APDE
 * No external libraries required.
 *
 * STEP 1: Coal, combustion air and furnace
 * STEP 2: Boiler, economizer and superheater
 * STEP 3: Turbine, generator and electrical output
 * STEP 4: Condenser and feedwater recovery
 * STEP 5: Cooling circuit, flue gas and ash handling
 *
 * Controls:
 * BACKWARD | FORWARD | PLAY/PAUSE | RESET
 * LABELS ON/OFF | SPEED SLIDER
 *
 * Touch-friendly landscape layout.
 */

boolean running = true;
boolean labelsOn = true;

float flowSpeed = 1.0;
int currentStep = 1;
final int TOTAL_STEPS = 5;

final float WORLD_W = 1000;
final float WORLD_H = 600;

float scaleUI = 1;
float offX = 0;
float offY = 0;

ArrayList<FlowPath> paths = new ArrayList<FlowPath>();

Node coalUnload, coalPrep, coalStorage, coalHandling;
Node boiler, economizer, airPreheater, superheater;
Node dustCollector, fdFan, idFan, chimney;
Node turbine, generator, condenser, coolingTower;
Node coolingPump, feedPump, ashHandling, ashStorage;

final float SPEED_MIN = 0.25;
final float SPEED_MAX = 3.0;

final float SLIDER_X1 = 715;
final float SLIDER_X2 = 895;
final float SLIDER_Y = 553;

void setup() {
  orientation(LANDSCAPE);
  frameRate(60);
  smooth();
  textFont(createFont("SansSerif", 12));
  createPlant();
}

void createPlant() {
  paths.clear();

  coalUnload = new Node(25, 90, 105, 36,
    "Coal unloading");
  coalPrep = new Node(25, 137, 105, 36,
    "Coal preparation");
  coalStorage = new Node(25, 184, 105, 36,
    "Coal storage");
  coalHandling = new Node(25, 231, 105, 36,
    "Coal handling");

  boiler = new Node(245, 235, 100, 86,
    "BOILER");
  economizer = new Node(245, 365, 115, 34,
    "Economizer");
  superheater = new Node(385, 213, 108, 32,
    "Superheater");

  fdFan = new Node(365, 67, 58, 34,
    "FD fan");
  airPreheater = new Node(450, 113, 116, 42,
    "Air preheater");
  dustCollector = new Node(610, 113, 108, 42,
    "Dust collector");
  idFan = new Node(744, 115, 48, 38,
    "ID fan");
  chimney = new Node(835, 82, 48, 83,
    "Chimney");

  turbine = new Node(555, 226, 82, 42,
    "Turbine");
  generator = new Node(690, 226, 92, 42,
    "Generator");

  condenser = new Node(575, 385, 125, 42,
    "Condenser");
  coolingTower = new Node(840, 365, 70, 85,
    "Cooling tower");
  coolingPump = new Node(755, 455, 54, 32,
    "Pump");
  feedPump = new Node(405, 455, 58, 32,
    "Feed pump");

  ashHandling = new Node(25, 324, 105, 38,
    "Ash handling");
  ashStorage = new Node(25, 374, 105, 38,
    "Ash storage");

  // STEP 1: COAL FEED
  addPath("COAL", color(196,145,73), 1.7, 1,
    new float[] {77,126, 77,137});
  addPath("COAL", color(196,145,73), 1.7, 1,
    new float[] {77,173, 77,184});
  addPath("COAL", color(196,145,73), 1.7, 1,
    new float[] {77,220, 77,231});
  addPath("COAL", color(196,145,73), 2.0, 1,
    new float[] {130,250, 195,250, 195,275, 245,275});

  // STEP 5: ASH HANDLING
  addPath("ASH", color(155,164,177), 1.8, 5,
    new float[] {270,321, 270,343, 170,343, 130,343});
  addPath("ASH", color(155,164,177), 1.7, 5,
    new float[] {77,362, 77,374});

  // STEP 1: COMBUSTION AIR
  addPath("AIR", color(80,174,245), 2.0, 1,
    new float[] {455,77, 423,77});
  addPath("AIR", color(80,174,245), 2.0, 1,
    new float[] {365,84, 340,84, 340,134, 450,134});
  addPath("AIR", color(80,174,245), 2.0, 1,
    new float[] {450,145, 420,145, 420,194,
                 300,194, 300,235});

  // STEP 2 AND STEP 5: FLUE GAS / HEAT RECOVERY
  addPath("FLUE", color(244,132,73), 2.1, 2,
    new float[] {330,246, 350,246, 350,180,
                 505,180, 505,155});
  addPath("FLUE", color(244,132,73), 2.1, 2,
    new float[] {300,321, 300,365});
  addPath("FLUE", color(244,132,73), 2.1, 5,
    new float[] {360,382, 430,382, 430,174, 450,174});
  addPath("FLUE", color(244,132,73), 2.1, 5,
    new float[] {566,134, 610,134});
  addPath("FLUE", color(244,132,73), 2.1, 5,
    new float[] {718,134, 744,134});
  addPath("FLUE", color(244,132,73), 2.1, 5,
    new float[] {792,134, 835,134});

  // STEP 4: CONDENSATE / FEEDWATER
  addPath("WATER", color(60,205,224), 2.2, 4,
    new float[] {575,406, 500,406, 500,471, 463,471});
  addPath("WATER", color(60,205,224), 2.2, 4,
    new float[] {405,471, 382,471, 382,382, 360,382});
  addPath("WATER", color(60,205,224), 2.2, 4,
    new float[] {300,365, 300,321});

  // STEP 2: BOILER -> SUPERHEATER
  addPath("STEAM", color(244,91,198), 2.1, 2,
    new float[] {310,235, 310,201, 420,201, 420,213});

  // STEP 3: SUPERHEATER -> TURBINE
  addPath("STEAM", color(244,91,198), 2.1, 3,
    new float[] {493,229, 525,229, 525,247, 555,247});

  // STEP 4: TURBINE EXHAUST -> CONDENSER
  addPath("STEAM", color(244,91,198), 2.1, 4,
    new float[] {596,268, 596,385});

  // STEP 3: TURBINE SHAFT -> GENERATOR -> GRID
  addPath("POWER", color(255,211,74), 2.0, 3,
    new float[] {637,247, 690,247});
  addPath("POWER", color(255,211,74), 2.0, 3,
    new float[] {782,247, 815,247, 815,220, 920,220});

  // STEP 5: COOLING WATER CIRCUIT
  addPath("COOL", color(86,157,255), 2.0, 5,
    new float[] {850,433, 820,433, 820,471, 809,471});
  addPath("COOL", color(86,157,255), 2.0, 5,
    new float[] {755,471, 730,471, 730,406, 700,406});
  addPath("COOL", color(86,157,255), 2.0, 5,
    new float[] {700,395, 790,395, 790,355,
                 875,355, 875,365});
}

void draw() {
  background(13,21,33);

  scaleUI = min(width / WORLD_W, height / WORLD_H);
  offX = (width - WORLD_W * scaleUI) * 0.5;
  offY = (height - WORLD_H * scaleUI) * 0.5;

  pushMatrix();
  translate(offX, offY);
  scale(scaleUI);

  drawGrid();
  drawHeader();
  drawStepPanel();

  // Draw every route. Future-stage routes are dimmed.
  for (int i = 0; i < paths.size(); i++) {
    paths.get(i).drawRoute();
  }

  drawCoalAndAsh();
  drawAirAndFlueEquipment();
  drawBoilerSection();
  drawPowerSection();
  drawCoolingSection();

  // Animate only the stages reached so far.
  if (running) {
    for (int i = 0; i < paths.size(); i++) {
      if (paths.get(i).stage <= currentStep) {
        paths.get(i).update();
      }
    }
  }

  for (int i = 0; i < paths.size(); i++) {
    if (paths.get(i).stage <= currentStep) {
      paths.get(i).drawParticles();
    }
  }

  drawLegend();
  drawControls();
  drawStatus();

  popMatrix();
}

void drawGrid() {
  stroke(28,42,59);
  strokeWeight(0.6);

  for (int x = 0; x <= WORLD_W; x += 25) {
    line(x,0,x,WORLD_H);
  }

  for (int y = 0; y <= WORLD_H; y += 25) {
    line(0,y,WORLD_W,y);
  }
}

void drawHeader() {
  fill(239,246,255);
  textAlign(LEFT,CENTER);
  textSize(20);
  text("THERMAL POWER PLANT",20,22);

  fill(150,177,204);
  textSize(10);
  text("STEP-BY-STEP ENGINEERING FLOW SIMULATOR",22,43);

  stroke(62,83,108);
  line(20,56,980,56);
}

void drawStepPanel() {
  noStroke();
  fill(22,36,54,240);
  rect(185,65,615,32,7);

  fill(230,242,255);
  textAlign(LEFT,CENTER);
  textSize(11);
  text("CURRENT STEP " + currentStep + " / " +
       TOTAL_STEPS,198,81);

  fill(120,215,245);
  textSize(10);
  text(getStepTitle(),350,81);

  // Step progress indicators.
  for (int i = 1; i <= TOTAL_STEPS; i++) {
    float x = 815 + (i-1)*32;

    if (i == currentStep) {
      fill(70,207,236);
    } else if (i < currentStep) {
      fill(71,147,170);
    } else {
      fill(55,69,86);
    }

    ellipse(x,81,19,19);

    fill(245);
    textAlign(CENTER,CENTER);
    textSize(9);
    text(str(i),x,81);
  }
}

String getStepTitle() {
  if (currentStep == 1) return "Coal and combustion air";
  if (currentStep == 2) return "Boiler and steam heating";
  if (currentStep == 3) return "Turbine and electricity";
  if (currentStep == 4) return "Condensation and recovery";
  return "Cooling, exhaust and ash";
}

void drawCoalAndAsh() {
  coalUnload.draw(color(105,76,43), currentStep >= 1);
  coalPrep.draw(color(105,76,43), currentStep >= 1);
  coalStorage.draw(color(105,76,43), currentStep >= 1);
  coalHandling.draw(color(105,76,43), currentStep >= 1);

  ashHandling.draw(color(73,81,94), currentStep >= 5);
  ashStorage.draw(color(73,81,94), currentStep >= 5);

  if (labelsOn) {
    smallLabel("COAL FEED",145,241,color(226,181,104));
    smallLabel("BOTTOM ASH",143,330,color(180,190,205));
  }
}

void drawAirAndFlueEquipment() {
  fdFan.draw(color(36,83,128), currentStep >= 1);
  airPreheater.draw(color(112,71,42), currentStep >= 1);
  dustCollector.draw(color(81,76,102), currentStep >= 5);
  idFan.draw(color(36,83,128), currentStep >= 5);
  chimney.draw(color(72,82,98), currentStep >= 5);

  drawFan(394,84);
  drawFan(768,134);

  noStroke();
  fill(190,207,222,45);
  ellipse(858,73,23,9);
  ellipse(850,65,17,7);
  ellipse(862,57,19,8);

  if (labelsOn) {
    smallLabel("Atmospheric air",430,64,color(106,190,255));
    smallLabel("Flue gas",523,174,color(255,166,112));
    smallLabel("Treated gas",760,108,color(255,166,112));
  }
}

void drawBoilerSection() {
  boiler.draw(color(120,65,40), currentStep >= 2);
  economizer.draw(color(100,79,45), currentStep >= 2);
  superheater.draw(color(117,52,89), currentStep >= 2);

  noStroke();
  fill(255,108,38,150);
  triangle(268,305,284,269,300,305);
  fill(255,214,74,200);
  triangle(279,306,286,284,294,306);

  if (labelsOn) {
    smallLabel("Feedwater",326,424,color(88,223,238));
    smallLabel("Saturated steam",327,190,color(255,121,211));
    smallLabel("Superheated steam",432,195,color(255,121,211));
  }
}

void drawPowerSection() {
  turbine.draw(color(42,98,107), currentStep >= 3);
  generator.draw(color(99,83,34), currentStep >= 3);

  stroke(188,230,232);
  strokeWeight(1.5);
  line(570,247,622,247);

  for (int i = 0; i < 4; i++) {
    float x = 576+i*12;
    line(x,238,x+5,247);
    line(x+5,247,x,256);
  }

  noFill();
  stroke(255,224,112);
  strokeWeight(1.6);
  ellipse(736,247,20,20);
  line(728,247,733,241);
  line(733,241,739,253);
  line(739,253,744,245);

  stroke(255,218,95);
  strokeWeight(1.3);
  line(920,194,908,237);
  line(920,194,932,237);
  line(908,237,932,237);
  line(911,220,929,220);
  line(914,207,926,207);
  line(908,237,929,207);
  line(932,237,911,207);

  if (labelsOn) {
    smallLabel("Transmission lines",862,188,color(255,224,112));
    smallLabel("Electrical output",827,210,color(255,224,112));
    smallLabel("Exhaust steam",606,333,color(255,121,211));
  }
}

void drawCoolingSection() {
  condenser.draw(color(36,89,120), currentStep >= 4);
  coolingPump.draw(color(31,72,111), currentStep >= 5);
  feedPump.draw(color(31,72,111), currentStep >= 4);
  coolingTower.draw(color(25,70,89), currentStep >= 5);

  stroke(100,177,204);
  strokeWeight(1.3);
  noFill();

  beginShape();
  vertex(850,389);
  vertex(900,389);
  vertex(891,438);
  vertex(859,438);
  endShape(CLOSE);

  line(859,438,850,447);
  line(891,438,900,447);
  line(850,447,900,447);
  line(855,425,895,425);
  line(857,411,893,411);

  noStroke();
  fill(89,211,230,130);
  ellipse(875,389,38,8);

  fill(177,223,232,65);
  ellipse(870,379,18,7);
  ellipse(882,374,16,7);

  drawPumpIcon(434,471);
  drawPumpIcon(782,471);

  if (labelsOn) {
    smallLabel("Warm cooling water",710,383,color(105,205,248));
    smallLabel("Cooled water",763,496,color(105,205,248));
    smallLabel("Condensate return",410,439,color(88,223,238));
  }
}

void drawFan(float x,float y) {
  stroke(195,225,246);
  strokeWeight(1.4);
  noFill();
  ellipse(x,y,18,18);
  line(x-5,y-5,x+5,y+5);
  line(x-5,y+5,x+5,y-5);
}

void drawPumpIcon(float x,float y) {
  stroke(130,210,235);
  strokeWeight(1.4);
  fill(19,54,79);
  ellipse(x,y,25,19);
  noStroke();
  fill(137,222,244);
  triangle(x-5,y-5,x+6,y,x-5,y+5);
}

void smallLabel(String s,float x,float y,int c) {
  fill(c);
  textAlign(LEFT,CENTER);
  textSize(9);
  text(s,x,y);
}

void drawLegend() {
  float x = 18;
  float y = 438;

  fill(218,231,244);
  textAlign(LEFT,CENTER);
  textSize(11);
  text("FLOW LEGEND",x,y);

  legendItem(x,y+19,color(196,145,73),"Coal");
  legendItem(x,y+37,color(80,174,245),"Air");
  legendItem(x,y+55,color(244,132,73),"Flue gas");
  legendItem(x,y+73,color(60,205,224),"Feedwater");
  legendItem(x,y+91,color(244,91,198),"Steam");
  legendItem(x,y+109,color(255,211,74),"Power");
  legendItem(x,y+127,color(155,164,177),"Ash");
}

void legendItem(float x,float y,int c,String name) {
  stroke(c);
  strokeWeight(3);
  line(x,y,x+20,y);
  noStroke();

  fill(220,233,245);
  textSize(9);
  text(name,x+27,y);
}

void drawControls() {
  noStroke();
  fill(23,35,52,245);
  rect(180,522,800,66,8);

  button(190,535,77,31,"BACKWARD",
         color(65,76,100));

  button(272,535,70,31,"FORWARD",
         color(32,105,130));

  button(347,535,72,31,running ? "PAUSE" : "PLAY",
         color(35,112,92));

  button(424,535,65,31,"RESET",
         color(112,72,48));

  button(494,535,94,31,
         labelsOn ? "LABELS ON" : "LABELS OFF",
         color(65,76,100));

  fill(220,235,250);
  textAlign(LEFT,CENTER);
  textSize(10);
  text("SPEED",615,537);

  stroke(100,125,150);
  strokeWeight(4);
  line(SLIDER_X1,SLIDER_Y,SLIDER_X2,SLIDER_Y);

  float knob = map(flowSpeed,SPEED_MIN,SPEED_MAX,
                   SLIDER_X1,SLIDER_X2);

  stroke(120,220,245);
  strokeWeight(2);
  line(SLIDER_X1,SLIDER_Y,knob,SLIDER_Y);

  noStroke();
  fill(230,250,255);
  ellipse(knob,SLIDER_Y,13,13);

  fill(215,233,248);
  textSize(10);
  text(nf(flowSpeed,1,2)+"x",910,553);
}

void button(float x,float y,float w,float h,
            String s,int c) {
  noStroke();
  fill(c);
  rect(x,y,w,h,6);

  fill(250);
  textAlign(CENTER,CENTER);
  textSize(9);
  text(s,x+w/2,y+h/2);
}

void drawStatus() {
  fill(150,180,205);
  textAlign(LEFT,CENTER);
  textSize(9);

  text(running ? "ANIMATION RUNNING" :
       "ANIMATION PAUSED",195,510);

  text("STEP " + currentStep + ": " + getStepTitle(),
       410,510);

  text("EDUCATIONAL SCHEMATIC - NOT TO SCALE",
       730,510);
}

float logicalX(float screenX) {
  return (screenX-offX)/scaleUI;
}

float logicalY(float screenY) {
  return (screenY-offY)/scaleUI;
}

void mousePressed() {
  handleTouch(mouseX,mouseY);
}

void mouseDragged() {
  float x = logicalX(mouseX);
  float y = logicalY(mouseY);

  if (y >= SLIDER_Y-18 && y <= SLIDER_Y+18 &&
      x >= SLIDER_X1-12 && x <= SLIDER_X2+12) {

    flowSpeed = constrain(
      map(x,SLIDER_X1,SLIDER_X2,SPEED_MIN,SPEED_MAX),
      SPEED_MIN,SPEED_MAX
    );
  }
}

void handleTouch(float sx,float sy) {
  float x = logicalX(sx);
  float y = logicalY(sy);

  if (y >= 535 && y <= 566) {

    // BACKWARD: return to the previous step.
    if (x >= 190 && x <= 267) {
      previousStep();
      return;
    }

    // FORWARD: move to the next step.
    if (x >= 272 && x <= 342) {
      nextStep();
      return;
    }

    // PLAY / PAUSE.
    if (x >= 347 && x <= 419) {
      running = !running;
      return;
    }

    // RESET everything to Step 1.
    if (x >= 424 && x <= 489) {
      resetAnimation();
      return;
    }

    // Show / hide labels.
    if (x >= 494 && x <= 588) {
      labelsOn = !labelsOn;
      return;
    }
  }

  // Speed slider.
  if (y >= SLIDER_Y-18 && y <= SLIDER_Y+18 &&
      x >= SLIDER_X1-12 && x <= SLIDER_X2+12) {

    flowSpeed = constrain(
      map(x,SLIDER_X1,SLIDER_X2,SPEED_MIN,SPEED_MAX),
      SPEED_MIN,SPEED_MAX
    );
  }
}

void nextStep() {
  if (currentStep < TOTAL_STEPS) {
    currentStep++;
    resetNewlyActivatedPaths();
  } else {
    // At the final step, keep the simulator on Step 5.
    currentStep = TOTAL_STEPS;
  }
}

void previousStep() {
  if (currentStep > 1) {
    currentStep--;
  }
}

void resetNewlyActivatedPaths() {
  for (int i = 0; i < paths.size(); i++) {
    if (paths.get(i).stage == currentStep) {
      paths.get(i).reset();
    }
  }
}

void resetAnimation() {
  currentStep = 1;
  running = true;
  flowSpeed = 1.0;

  for (int i = 0; i < paths.size(); i++) {
    paths.get(i).reset();
  }
}

void addPath(String kind,int c,float rate,
             int stage,float[] points) {
  paths.add(new FlowPath(kind,c,rate,stage,points));
}

class Node {
  float x,y,w,h;
  String title;

  Node(float x0,float y0,float w0,float h0,
       String label) {
    x = x0;
    y = y0;
    w = w0;
    h = h0;
    title = label;
  }

  void draw(int base,boolean active) {
    if (active) {
      stroke(137,205,225);
      strokeWeight(1.5);
      fill(base);
    } else {
      stroke(63,79,96);
      strokeWeight(1);
      fill(37,47,61);
    }

    rect(x,y,w,h,5);

    if (active) {
      stroke(255,255,255,35);
      line(x+5,y+4,x+w-5,y+4);
    }

    noStroke();

    if (active) {
      fill(246,250,255);
    } else {
      fill(110,125,141);
    }

    textAlign(CENTER,CENTER);
    textSize(title.length()>13 ? 9 : 10);
    text(title,x+w/2,y+h/2);
  }
}

class FlowPath {
  String kind;
  int col;
  int stage;
  float rate;

  float[] px,py,cumulative;
  float totalLength = 0;

  float[] particleDistance;
  int particleCount = 5;

  FlowPath(String k,int c,float r,int st,
           float[] coords) {
    kind = k;
    col = c;
    rate = r;
    stage = st;

    int n = coords.length/2;

    px = new float[n];
    py = new float[n];
    cumulative = new float[n];

    for (int i = 0; i < n; i++) {
      px[i] = coords[2*i];
      py[i] = coords[2*i+1];

      if (i > 0) {
        totalLength += dist(
          px[i-1],py[i-1],px[i],py[i]
        );
      }

      cumulative[i] = totalLength;
    }

    particleDistance = new float[particleCount];
    reset();
  }

  void reset() {
    if (totalLength <= 0) return;

    for (int i = 0; i < particleCount; i++) {
      particleDistance[i] =
        totalLength*i/particleCount;
    }
  }

  void update() {
    if (totalLength <= 0) return;

    for (int i = 0; i < particleCount; i++) {
      particleDistance[i] += rate*flowSpeed;

      while (particleDistance[i] >= totalLength) {
        particleDistance[i] -= totalLength;
      }
    }
  }

  void drawRoute() {
    // Dim routes that have not yet been introduced.
    if (stage <= currentStep) {
      stroke(col);
    } else {
      stroke(red(col)*0.32,
             green(col)*0.32,
             blue(col)*0.32);
    }

    strokeWeight(stage == currentStep ? 2.4 : 1.5);
    noFill();

    beginShape();
    for (int i = 0; i < px.length; i++) {
      vertex(px[i],py[i]);
    }
    endShape();

    // Direction arrows follow the route.
    if (stage <= currentStep) {
      for (int i = 1; i < px.length; i++) {
        float x1 = px[i-1];
        float y1 = py[i-1];
        float x2 = px[i];
        float y2 = py[i];

        if (dist(x1,y1,x2,y2) < 13) continue;

        float t = 0.68;
        float ax = lerp(x1,x2,t);
        float ay = lerp(y1,y2,t);
        float a = atan2(y2-y1,x2-x1);

        pushMatrix();
        translate(ax,ay);
        rotate(a);

        noStroke();
        fill(col);
        triangle(0,0,-7,-3.5,-7,3.5);

        popMatrix();
      }
    }
  }

  void drawParticles() {
    if (totalLength <= 0) return;

    noStroke();

    for (int i = 0; i < particleCount; i++) {
      float d = particleDistance[i];

      float x = px[0];
      float y = py[0];

      for (int j = 1; j < px.length; j++) {
        if (d <= cumulative[j]) {
          float segmentStart = cumulative[j-1];

          float segmentLength =
            cumulative[j]-segmentStart;

          float t = segmentLength <= 0 ? 0 :
            (d-segmentStart)/segmentLength;

          x = lerp(px[j-1],px[j],t);
          y = lerp(py[j-1],py[j],t);
          break;
        }
      }

      fill(col);

      float diameter = kind.equals("POWER") ?
        5.5 : 4.5;

      ellipse(x,y,diameter,diameter);

      fill(255,255,255,125);
      ellipse(x-1,y-1,1.6,1.6);
    }
  }
}
