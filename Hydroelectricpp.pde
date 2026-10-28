
/*
 * ================================================================
 * HYDROELECTRIC POWER PLANT - COMPLETE ANIMATED SIMULATOR
 *
 * Platform: Processing Java Mode / Android APDE
 * Renderer: P2D
 * Libraries: None
 *
 * OPERATING SEQUENCE:
 * Reservoir -> Dam intake -> Penstock -> Reaction turbine
 * -> Mechanical shaft -> Generator -> Electrical output
 * Turbine outlet -> Draft tube -> Tailrace
 *
 * CONTROLS:
 * START / PAUSE : Start or pause the simulation
 * RESET         : Reset water and turbine
 * SPEED - / +   : Adjust water flow speed
 * FLOW ON/OFF   : Open or close the intake gate
 *
 * Touchscreen compatible. Rotate the Android device to landscape
 * for the best view.
 * ================================================================
 */

float simTime = 0;
float flowSpeed = 1.0;
float waterFlow = 0.0;
float turbineRPM = 0.0;
float generatorPower = 0.0;
float waterLevel = 0.0;
float shaftAngle = 0.0;

boolean running = true;
boolean gateOpen = true;

float[] particlePos = new float[65];
float[] outletPos = new float[32];
float[] electricPos = new float[18];

float viewScale;
float offsetX;
float offsetY;

int sceneW = 1000;
int sceneH = 650;

color skyColor = color(218, 237, 247);
color waterColor = color(44, 151, 218);
color darkWater = color(22, 100, 167);
color damColor = color(155, 161, 168);
color penstockColor = color(117, 130, 143);
color metalColor = color(93, 104, 117);
color turbineColor = color(228, 155, 44);
color electricColor = color(255, 220, 70);

void setup() {
  fullScreen(P2D);
  orientation(LANDSCAPE);
  frameRate(60);
  smooth(4);
  textFont(createFont("SansSerif", 15));

  for (int i = 0; i < particlePos.length; i++) {
    particlePos[i] = random(0, 1);
  }

  for (int i = 0; i < outletPos.length; i++) {
    outletPos[i] = random(0, 1);
  }

  for (int i = 0; i < electricPos.length; i++) {
    electricPos[i] = random(0, 1);
  }
}

void draw() {
  background(22, 31, 45);

  // Fit the complete drawing into the available screen.
  viewScale = min(width / (float)sceneW,
                  height / (float)sceneH);

  offsetX = (width - sceneW * viewScale) / 2.0;
  offsetY = (height - sceneH * viewScale) / 2.0;

  pushMatrix();
  translate(offsetX, offsetY);
  scale(viewScale);

  drawBackground();
  drawTitle();

  if (running && gateOpen) {
    waterFlow = lerp(waterFlow, flowSpeed, 0.045);
  } else {
    waterFlow = lerp(waterFlow, 0, 0.035);
  }

  turbineRPM = lerp(turbineRPM, waterFlow * 180.0, 0.055);
  generatorPower = lerp(generatorPower,
                        waterFlow * 100.0, 0.045);

  if (running) {
    simTime += 1.0 / 60.0;
    shaftAngle += radians(turbineRPM * 0.035);
  }

  drawReservoir();
  drawDam();
  drawIntakeGate();
  drawPenstock();
  drawPenstockWater();
  drawTurbineAssembly();
  drawShaft();
  drawGenerator();
  drawDraftTube();
  drawTailrace();
  drawElectricalOutput();
  drawFlowDirectionArrows();
  drawComponentLabels();
  drawInformationPanel();
  drawControls();
  drawLegend();

  popMatrix();
}

// ================================================================
// BACKGROUND AND TITLE
// ================================================================

void drawBackground() {
  noStroke();
  fill(skyColor);
  rect(0, 0, sceneW, sceneH);

  // Distant hills.
  fill(176, 205, 188);
  beginShape();
  vertex(0, 195);
  vertex(100, 135);
  vertex(205, 185);
  vertex(325, 125);
  vertex(430, 190);
  vertex(550, 145);
  vertex(680, 195);
  vertex(810, 130);
  vertex(1000, 190);
  vertex(1000, 650);
  vertex(0, 650);
  endShape(CLOSE);

  // Ground.
  fill(190, 181, 148);
  rect(0, 420, 1000, 230);

  // Lower bedrock.
  fill(135, 130, 117);
  beginShape();
  vertex(0, 540);
  vertex(300, 515);
  vertex(600, 535);
  vertex(1000, 500);
  vertex(1000, 650);
  vertex(0, 650);
  endShape(CLOSE);

  // Ground strata.
  stroke(112, 107, 96, 100);
  strokeWeight(1);
  for (int i = 0; i < 12; i++) {
    line(0, 555 + i * 9, 1000, 535 + i * 9);
  }
  noStroke();
}

void drawTitle() {
  fill(21, 43, 65);
  textAlign(CENTER, CENTER);
  textSize(23);
  text("HYDROELECTRIC POWER PLANT", 500, 27);

  textSize(11);
  fill(49, 74, 95);
  text("WATER ENERGY  ->  MECHANICAL ENERGY  ->  ELECTRICAL ENERGY",
       500, 49);

  textAlign(LEFT, BASELINE);
}

// ================================================================
// RESERVOIR
// ================================================================

void drawReservoir() {
  // Reservoir body behind the dam.
  noStroke();
  fill(44, 151, 218);
  beginShape();
  vertex(0, 155);
  vertex(177, 155);
  vertex(177, 340);
  vertex(0, 340);
  endShape(CLOSE);

  // Surface waves.
  stroke(173, 229, 255);
  strokeWeight(2);
  noFill();

  for (int i = 0; i < 8; i++) {
    float y = 168 + i * 19;
    float shift = (simTime * 22 + i * 23) % 45;

    for (int x = -30; x < 170; x += 65) {
      float xx = x + shift;
      line(xx, y, xx + 27, y);
    }
  }

  noStroke();
  fill(19, 75, 132);
  textSize(15);
  textAlign(CENTER);
  text("RESERVOIR", 82, 137);

  fill(255);
  textSize(11);
  text("Stored water", 82, 195);
  textAlign(LEFT);
}

// ================================================================
// DAM AND FOUNDATION
// ================================================================

void drawDam() {
  // Main concrete dam.
  stroke(75, 81, 88);
  strokeWeight(2);
  fill(damColor);

  beginShape();
  vertex(177, 100);
  vertex(212, 100);
  vertex(249, 350);
  vertex(177, 350);
  endShape(CLOSE);

  // Concrete texture.
  stroke(120, 126, 132);
  strokeWeight(1);

  for (int y = 125; y < 330; y += 28) {
    line(184, y, 221, y);
  }

  // Base.
  noStroke();
  fill(112, 116, 119);
  rect(150, 350, 135, 12);

  fill(31, 48, 64);
  textSize(13);
  text("DAM", 200, 83);

  stroke(31, 48, 64);
  strokeWeight(1);
  line(200, 88, 207, 125);
  noStroke();
}

// ================================================================
// INTAKE GATE
// ================================================================

void drawIntakeGate() {
  // Intake tunnel.
  stroke(91, 104, 113);
  strokeWeight(2);
  fill(210, 214, 215);
  rect(177, 245, 105, 42);

  // Gate body.
  fill(gateOpen ? color(60, 155, 95) : color(205, 75, 65));
  rect(245, 239, 12, 55);

  stroke(55, 65, 74);
  line(251, 239, 251, 224);
  line(238, 224, 264, 224);
  noStroke();

  fill(30, 49, 66);
  textSize(12);
  text("INTAKE GATE", 223, 215);

  fill(gateOpen ? color(20, 120, 60) : color(175, 40, 35));
  textSize(10);
  text(gateOpen ? "OPEN" : "CLOSED", 230, 310);
}

// ================================================================
// PENSTOCK
// ================================================================

void drawPenstock() {
  // Main sloping pressure pipe.
  stroke(61, 72, 83);
  strokeWeight(27);
  noFill();

  beginShape();
  vertex(264, 265);
  vertex(315, 280);
  vertex(367, 303);
  vertex(420, 320);
  vertex(485, 320);
  vertex(545, 320);
  endShape();

  // Interior.
  stroke(193, 204, 210);
  strokeWeight(19);

  beginShape();
  vertex(264, 265);
  vertex(315, 280);
  vertex(367, 303);
  vertex(420, 320);
  vertex(485, 320);
  vertex(545, 320);
  endShape();

  // Pipe joints.
  stroke(70, 82, 93);
  strokeWeight(3);

  for (int x = 315; x <= 520; x += 65) {
    float y = x < 420
      ? 280 + (x - 315) * 0.38
      : 320;

    line(x, y - 12, x, y + 12);
  }

  noStroke();

  fill(28, 47, 65);
  textSize(14);
  text("PENSTOCK", 372, 266);

  stroke(28, 47, 65);
  strokeWeight(1);
  line(400, 270, 410, 302);
  noStroke();
}

void drawPenstockWater() {
  // Moving water particles travel from intake to turbine.
  for (int i = 0; i < particlePos.length; i++) {
    if (running && gateOpen) {
      particlePos[i] += 0.0018 * flowSpeed;
    }

    if (particlePos[i] > 1) {
      particlePos[i] -= 1;
    }

    float t = particlePos[i];
    float x;
    float y;

    if (t < 0.2) {
      float q = t / 0.2;
      x = lerp(264, 367, q);
      y = lerp(265, 303, q);
    } else if (t < 0.5) {
      float q = (t - 0.2) / 0.3;
      x = lerp(367, 420, q);
      y = lerp(303, 320, q);
    } else {
      float q = (t - 0.5) / 0.5;
      x = lerp(420, 545, q);
      y = 320;
    }

    noStroke();
    fill(15, 110, 200, 210);
    ellipse(x, y, 5, 5);
  }
}

// ================================================================
// REACTION TURBINE
// ================================================================

void drawTurbineAssembly() {
  // Turbine housing.
  stroke(62, 75, 88);
  strokeWeight(2);
  fill(195, 204, 210);
  ellipse(590, 320, 86, 72);

  fill(131, 146, 157);
  ellipse(590, 320, 61, 57);

  // Water enters the runner.
  noStroke();
  fill(40, 150, 220, 170);
  ellipse(568, 320, 42, 39);

  // Rotating runner.
  pushMatrix();
  translate(590, 320);
  rotate(shaftAngle);

  fill(turbineColor);
  stroke(128, 78, 18);
  strokeWeight(2);

  for (int i = 0; i < 8; i++) {
    pushMatrix();
    rotate(TWO_PI * i / 8.0);

    beginShape();
    vertex(0, -7);
    vertex(25, -13);
    vertex(34, -4);
    vertex(12, 3);
    endShape(CLOSE);

    popMatrix();
  }

  fill(245, 192, 83);
  ellipse(0, 0, 23, 23);

  fill(80, 89, 96);
  ellipse(0, 0, 10, 10);
  popMatrix();

  noStroke();
  fill(25, 43, 61);
  textAlign(CENTER);
  textSize(13);
  text("REACTION TURBINE", 590, 263);

  textSize(10);
  text("Rotating runner", 590, 278);
  textAlign(LEFT);
}

// ================================================================
// MECHANICAL SHAFT
// ================================================================

void drawShaft() {
  // Shaft connecting the turbine to the generator.
  stroke(68, 79, 90);
  strokeWeight(12);
  line(631, 320, 733, 320);

  stroke(217, 225, 230);
  strokeWeight(5);
  line(631, 320, 733, 320);

  // Coupling.
  stroke(68, 79, 90);
  strokeWeight(2);
  fill(155, 169, 180);
  rect(653, 306, 15, 28);
  rect(670, 306, 15, 28);

  noStroke();
  fill(30, 48, 66);
  textSize(11);
  textAlign(CENTER);
  text("SHAFT", 681, 294);
  textAlign(LEFT);
}

// ================================================================
// GENERATOR
// ================================================================

void drawGenerator() {
  // Generator body.
  stroke(58, 72, 84);
  strokeWeight(2);
  fill(85, 130, 165);
  rect(727, 275, 105, 91, 8);

  // Generator end plates.
  fill(165, 181, 193);
  ellipse(727, 320, 30, 64);
  ellipse(832, 320, 30, 64);

  // Stator coil representation.
  noFill();
  stroke(235, 190, 70);
  strokeWeight(3);

  for (int i = 0; i < 5; i++) {
    rect(745 + i * 14, 290, 8, 60, 3);
  }

  // Rotating rotor.
  pushMatrix();
  translate(779, 320);
  rotate(shaftAngle);

  stroke(51, 61, 71);
  strokeWeight(2);
  fill(218, 222, 224);
  ellipse(0, 0, 42, 42);

  fill(65, 93, 121);
  rect(-8, -18, 16, 36);

  fill(235, 190, 70);
  ellipse(0, 0, 10, 10);
  popMatrix();

  noStroke();
  fill(23, 44, 63);
  textSize(14);
  textAlign(CENTER);
  text("GENERATOR", 779, 253);

  textSize(10);
  text("Mechanical to electrical", 779, 386);
  textAlign(LEFT);
}

// ================================================================
// DRAFT TUBE
// ================================================================

void drawDraftTube() {
  // Draft tube expands toward the tailrace.
  stroke(64, 77, 89);
  strokeWeight(2);

  fill(171, 185, 193);
  beginShape();
  vertex(608, 351);
  vertex(625, 351);
  vertex(673, 431);
  vertex(714, 431);
  vertex(700, 447);
  vertex(659, 447);
  endShape(CLOSE);

  // Water inside the tube.
  noStroke();
  fill(39, 146, 215, 220);
  beginShape();
  vertex(615, 359);
  vertex(621, 359);
  vertex(666, 424);
  vertex(702, 424);
  vertex(698, 437);
  vertex(665, 437);
  endShape(CLOSE);

  // Flow particles.
  for (int i = 0; i < outletPos.length; i++) {
    if (running && gateOpen) {
      outletPos[i] += 0.0025 * flowSpeed;
    }

    if (outletPos[i] > 1) {
      outletPos[i] -= 1;
    }

    float t = outletPos[i];
    float x = lerp(621, 697, t);
    float y = lerp(367, 430, t);

    noStroke();
    fill(220, 246, 255);
    ellipse(x, y, 4, 4);
  }

  fill(27, 47, 64);
  textSize(12);
  textAlign(CENTER);
  text("DRAFT TUBE", 660, 464);
  textAlign(LEFT);
}

// ================================================================
// TAILRACE
// ================================================================

void drawTailrace() {
  noStroke();

  // Tailrace pool.
  fill(40, 132, 192);
  beginShape();
  vertex(700, 435);
  vertex(1000, 435);
  vertex(1000, 570);
  vertex(700, 570);
  endShape(CLOSE);

  // Water surface waves.
  stroke(155, 225, 250);
  strokeWeight(2);

  for (int i = 0; i < 7; i++) {
    float y = 451 + i * 15;
    float shift = (simTime * 25 + i * 19) % 75;

    for (int x = 700; x < 1000; x += 90) {
      line(x + shift, y, x + shift + 28, y);
    }
  }

  noStroke();
  fill(255);
  textSize(15);
  textAlign(CENTER);
  text("TAILRACE", 851, 417);

  textSize(11);
  text("Discharged water", 851, 435);
  textAlign(LEFT);
}

// ================================================================
// ELECTRICAL OUTPUT
// ================================================================

void drawElectricalOutput() {
  // Power line from generator to the consumer grid.
  stroke(72, 82, 92);
  strokeWeight(5);
  line(832, 296, 892, 296);
  line(892, 296, 892, 222);
  line(892, 222, 955, 222);

  stroke(244, 191, 45);
  strokeWeight(2);
  line(832, 296, 892, 296);
  line(892, 296, 892, 222);
  line(892, 222, 955, 222);

  // Electrical energy particles.
  for (int i = 0; i < electricPos.length; i++) {
    if (running && gateOpen) {
      electricPos[i] += 0.005 * flowSpeed;
    }

    if (electricPos[i] > 1) {
      electricPos[i] -= 1;
    }

    float t = electricPos[i];
    float x;
    float y;

    if (t < 0.5) {
      x = lerp(832, 892, t * 2);
      y = 296;
    } else {
      x = 892;
      y = lerp(296, 222, (t - 0.5) * 2);
    }

    if (t >= 0.9) {
      x = lerp(892, 955, (t - 0.9) * 10);
      y = 222;
    }

    noStroke();
    fill(electricColor);
    ellipse(x, y, 7, 7);
  }

  // Power grid / consumer icon.
  stroke(54, 69, 82);
  strokeWeight(2);
  fill(240, 242, 241);
  rect(940, 181, 45, 47);

  stroke(54, 69, 82);
  line(947, 191, 978, 218);
  line(978, 191, 947, 218);
  line(962, 181, 962, 228);
  line(940, 204, 985, 204);

  noStroke();
  fill(25, 43, 62);
  textAlign(CENTER);
  textSize(12);
  text("POWER GRID", 962, 164);

  textSize(10);
  text(nf(generatorPower, 1, 0) + " kW*", 962, 246);
  textAlign(LEFT);
}

// ================================================================
// FLOW DIRECTION ARROWS
// ================================================================

void drawFlowDirectionArrows() {
  if (waterFlow > 0.08) {
    drawArrow(290, 273, 320, 284, color(15, 91, 165));
    drawArrow(386, 309, 416, 319, color(15, 91, 165));
    drawArrow(489, 320, 523, 320, color(15, 91, 165));
    drawArrow(669, 414, 687, 431, color(15, 91, 165));
  }

  fill(25, 45, 62);
  textSize(11);
  text("Water flow", 327, 343);
}

void drawArrow(float x1, float y1, float x2, float y2, color c) {
  stroke(c);
  strokeWeight(3);
  line(x1, y1, x2, y2);

  float a = atan2(y2 - y1, x2 - x1);

  line(x2, y2,
       x2 - 9 * cos(a - PI / 6),
       y2 - 9 * sin(a - PI / 6));

  line(x2, y2,
       x2 - 9 * cos(a + PI / 6),
       y2 - 9 * sin(a + PI / 6));

  noStroke();
}

// ================================================================
// COMPONENT LABELS
// ================================================================

void drawComponentLabels() {
  fill(29, 47, 65);
  textSize(11);

  text("HIGH HEAD", 29, 360);
  text("PRESSURE PIPE", 332, 356);
  text("TURBINE RUNNER", 542, 375);
  text("GENERATOR ROTOR", 746, 405);

  // Small pointer markers.
  stroke(45, 62, 78);
  strokeWeight(1);
  line(90, 347, 132, 330);
  line(370, 344, 386, 325);
  line(577, 365, 590, 342);
  line(788, 394, 779, 342);
  noStroke();
}

// ================================================================
// LIVE INFORMATION PANEL
// ================================================================

void drawInformationPanel() {
  // Semi-transparent dashboard.
  noStroke();
  fill(20, 37, 55, 235);
  rect(16, 405, 282, 177, 12);

  fill(255);
  textSize(15);
  text("LIVE OPERATING DATA", 31, 429);

  stroke(105, 133, 154);
  line(30, 439, 282, 439);
  noStroke();

  textSize(12);
  fill(220, 233, 244);

  text("Water flow level", 31, 460);
  text(nf(waterFlow * 100, 1, 0) + " %", 226, 460);

  // Flow bar.
  fill(55, 70, 84);
  rect(31, 469, 245, 8, 4);

  fill(43, 174, 233);
  rect(31, 469, 245 * constrain(waterFlow, 0, 1), 8, 4);

  fill(220, 233, 244);
  text("Turbine speed", 31, 498);
  text(nf(turbineRPM, 1, 0) + " rpm*", 226, 498);

  text("Generator output", 31, 521);
  text(nf(generatorPower, 1, 1) + " kW*", 226, 521);

  text("Elapsed time", 31, 544);
  text(nf(simTime, 1, 1) + " s", 226, 544);

  fill(gateOpen ? color(104, 226, 151)
                : color(255, 115, 105));
  text(gateOpen ? "INTAKE OPEN" : "INTAKE CLOSED", 31, 568);

  fill(207, 220, 231);
  textSize(9);
  text("*Illustrative simulation values", 31, 579);
}

// ================================================================
// TOUCHSCREEN CONTROLS
// ================================================================

void drawControls() {
  int y = 600;

  drawButton(310, y, 112, 34,
             running ? "PAUSE" : "START",
             running ? color(201, 143, 43)
                     : color(39, 152, 94));

  drawButton(430, y, 90, 34,
             "RESET", color(75, 99, 123));

  drawButton(528, y, 54, 34,
             "-", color(75, 99, 123));

  drawButton(588, y, 54, 34,
             "+", color(75, 99, 123));

  drawButton(650, y, 150, 34,
             gateOpen ? "CLOSE GATE" : "OPEN GATE",
             gateOpen ? color(54, 119, 155)
                      : color(39, 152, 94));

  // Speed indicator.
  fill(27, 46, 64);
  textSize(11);
  text("FLOW SPEED: " + nf(flowSpeed, 1, 1) + "x",
       817, 621);
}

void drawButton(float x, float y, float w, float h,
                String label, color c) {
  stroke(255, 255, 255, 100);
  strokeWeight(1);
  fill(c);
  rect(x, y, w, h, 7);

  noStroke();
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(label, x + w / 2, y + h / 2);

  textAlign(LEFT, BASELINE);
}

void drawLegend() {
  fill(25, 45, 62);
  textSize(10);

  fill(37, 143, 214);
  rect(321, 550, 13, 8, 2);
  fill(25, 45, 62);
  text("Water", 339, 558);

  fill(turbineColor);
  ellipse(405, 554, 10, 10);
  fill(25, 45, 62);
  text("Mechanical", 415, 558);

  fill(electricColor);
  ellipse(506, 554, 10, 10);
  fill(25, 45, 62);
  text("Electrical", 516, 558);
}

// ================================================================
// TOUCH / MOUSE INPUT
// ================================================================

void mousePressed() {
  // Convert actual screen coordinates to scene coordinates.
  float mx = (mouseX - offsetX) / viewScale;
  float my = (mouseY - offsetY) / viewScale;

  // Ignore taps outside the simulation canvas.
  if (mx < 0 || mx > sceneW || my < 0 || my > sceneH) {
    return;
  }

  // Start / pause.
  if (mx >= 310 && mx <= 422 &&
      my >= 600 && my <= 634) {
    running = !running;
    return;
  }

  // Reset.
  if (mx >= 430 && mx <= 520 &&
      my >= 600 && my <= 634) {
    resetSimulation();
    return;
  }

  // Slower water flow.
  if (mx >= 528 && mx <= 582 &&
      my >= 600 && my <= 634) {
    flowSpeed = max(0.2, flowSpeed - 0.2);
    return;
  }

  // Faster water flow.
  if (mx >= 588 && mx <= 642 &&
      my >= 600 && my <= 634) {
    flowSpeed = min(2.0, flowSpeed + 0.2);
    return;
  }

  // Intake gate.
  if (mx >= 650 && mx <= 800 &&
      my >= 600 && my <= 634) {
    gateOpen = !gateOpen;
    return;
  }
}

void resetSimulation() {
  simTime = 0;
  waterFlow = 0;
  turbineRPM = 0;
  generatorPower = 0;
  shaftAngle = 0;
  flowSpeed = 1.0;
  running = true;
  gateOpen = true;

  for (int i = 0; i < particlePos.length; i++) {
    particlePos[i] = random(0, 1);
  }

  for (int i = 0; i < outletPos.length; i++) {
    outletPos[i] = random(0, 1);
  }

  for (int i = 0; i < electricPos.length; i++) {
    electricPos[i] = random(0, 1);
  }
}
