
/*
 * ================================================================
 * CHAIN GRATE STOKER — OVERFEED STOKER
 * Processing Java Mode / Android APDE
 *
 * Corrected airflow:
 *   PRIMARY AIR ONLY: BOTTOM -> AIR COMPARTMENTS -> COAL BED
 *
 * Coal path:
 *   HOPPER -> COAL GATE -> MOVING GRATE -> ASH DISCHARGE
 *
 * Features:
 *   - Android screen auto-scaling
 *   - Animated chain links and sprockets
 *   - Moving coal and combustion zones
 *   - Bottom-up primary air only
 *   - Upward airflow arrows
 *   - Animated flames and ash
 *   - Air compartments and seals
 *   - Touch controls: pause, speed, reset
 *   - No external libraries
 * ================================================================
 */

ArrayList<CoalParticle> coalList;
ArrayList<AirParticle> airList;
ArrayList<FlameParticle> flameList;
ArrayList<AshParticle> ashList;

float vW = 1200;
float vH = 800;
float scaleF;
float xOff, yOff;

float grateStartX = 300;
float grateEndX = 900;
float grateW = 600;
float grateY = 490;

float grateSpeed = 1.5;
float chainOffset = 0;

boolean paused = false;
boolean showLabels = true;
boolean showAir = true;
boolean showFlames = true;

int lastCoalFrame = 0;
int lastAirFrame = 0;

void setup() {
  fullScreen();
  orientation(LANDSCAPE);
  frameRate(60);
  smooth(4);

  scaleF = min(width / vW, height / vH);
  xOff = (width - vW * scaleF) / 2.0;
  yOff = (height - vH * scaleF) / 2.0;

  initialiseSimulation();
}

void initialiseSimulation() {
  coalList = new ArrayList<CoalParticle>();
  airList = new ArrayList<AirParticle>();
  flameList = new ArrayList<FlameParticle>();
  ashList = new ArrayList<AshParticle>();

  chainOffset = 0;
  lastCoalFrame = 0;
  lastAirFrame = 0;

  for (int i = 0; i < 22; i++) {
    float x = grateStartX + 30 + i * 24;
    float y = grateY - random(24, 43);
    coalList.add(new CoalParticle(x, y, true));
  }

  paused = false;
}

void draw() {
  background(244, 246, 249);

  pushMatrix();
  translate(xOff, yOff);
  scale(scaleF);

  drawHeader();

  if (!paused) {
    chainOffset = (chainOffset + grateSpeed) % 40;
    createCoal();
    createBottomAir();
  }

  drawFurnace();
  drawHopper();
  drawCoalGate();
  drawChainGrate();
  drawAirCompartments();

  if (showAir) updateAndDrawAir();
  updateAndDrawCoal();

  if (showFlames) updateAndDrawFlames();

  updateAndDrawAsh();

  if (showLabels) drawLabels();

  drawControls();

  popMatrix();
}

// ================================================================
// HEADER
// ================================================================

void drawHeader() {
  noStroke();
  fill(32, 49, 67);
  rect(0, 0, vW, 55);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("CHAIN GRATE STOKER — OVERFEED STOKER",
       vW / 2, 22);

  textSize(13);
  fill(205, 222, 235);
  text("Primary combustion air enters ONLY from below the grate",
       vW / 2, 43);
}

// ================================================================
// FURNACE AND ASH DISCHARGE
// ================================================================

void drawFurnace() {
  stroke(65);
  strokeWeight(3);
  fill(224, 222, 214);

  // Furnace wall and combustion chamber.
  rect(405, 100, 510, 340);

  // Furnace roof.
  fill(185, 185, 180);
  rect(405, 100, 510, 18);

  // Refractory inner lining.
  noFill();
  stroke(145, 130, 110);
  strokeWeight(5);
  rect(418, 120, 484, 302);

  // Clear combustion region.
  noStroke();
  fill(255, 245, 220, 90);
  rect(425, 125, 470, 292);

  // Ash receiving chute at the right end.
  stroke(65);
  strokeWeight(3);
  fill(190, 188, 180);
  beginShape();
  vertex(grateEndX + 12, grateY - 14);
  vertex(grateEndX + 38, grateY - 14);
  vertex(grateEndX + 78, grateY + 76);
  vertex(grateEndX + 55, grateY + 106);
  vertex(grateEndX + 15, grateY + 70);
  endShape(CLOSE);

  // Ash pit.
  fill(120, 115, 105);
  rect(925, 585, 145, 48);

  fill(35);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("ASH PIT", 997, 607);
}

// ================================================================
// COAL HOPPER
// ================================================================

void drawHopper() {
  stroke(50);
  strokeWeight(3);
  fill(198, 201, 205);

  beginShape();
  vertex(100, 135);
  vertex(255, 135);
  vertex(230, 275);
  vertex(192, 320);
  vertex(160, 320);
  vertex(125, 275);
  endShape(CLOSE);

  // Coal stored inside the hopper.
  noStroke();
  fill(48, 45, 42);

  beginShape();
  vertex(108, 165);
  vertex(247, 165);
  vertex(224, 270);
  vertex(188, 305);
  vertex(164, 305);
  vertex(133, 270);
  endShape(CLOSE);

  // Coal texture.
  stroke(95, 89, 80);
  strokeWeight(2);

  for (int i = 0; i < 14; i++) {
    float x = random(120, 235);
    float y = random(175, 250);
    point(x, y);
  }

  // Hopper outlet.
  noStroke();
  fill(80);
  rect(153, 305, 47, 35);

  stroke(45);
  strokeWeight(3);
  line(153, 340, 200, 340);
}

// ================================================================
// COAL GATE
// ================================================================

void drawCoalGate() {
  stroke(50);
  strokeWeight(2);
  fill(130, 137, 145);

  rect(202, 308, 26, 92);

  fill(90, 96, 103);
  rect(206, 326, 18, 58);

  // Gate adjustment handle.
  stroke(55);
  line(228, 320, 248, 320);
  ellipse(249, 320, 8, 8);
}

// ================================================================
// CHAIN GRATE
// ================================================================

void drawChainGrate() {
  // Main grate track.
  stroke(48);
  strokeWeight(4);
  noFill();

  rect(grateStartX, grateY - 12, grateW, 76, 38);

  // Upper grate chain.
  stroke(60);
  strokeWeight(2);
  fill(145, 151, 158);

  for (float x = grateStartX + 4;
       x < grateEndX - 8; x += 20) {

    rect(x, grateY - 13, 17, 12, 2);

    fill(65);
    ellipse(x + 8, grateY - 7, 3, 3);
    fill(145, 151, 158);
  }

  // Lower return chain.
  for (float x = grateStartX + 4;
       x < grateEndX - 8; x += 20) {

    rect(x, grateY + 54, 17, 12, 2);
  }

  // Moving chain pins on the upper run.
  fill(70);
  noStroke();

  for (float x = 0; x < grateW; x += 40) {
    float px = grateStartX +
      ((x + chainOffset) % grateW);

    ellipse(px, grateY - 7, 7, 7);
  }

  // Moving chain pins on the lower return run.
  for (float x = 0; x < grateW; x += 40) {
    float px = grateEndX -
      ((x + chainOffset) % grateW);

    ellipse(px, grateY + 60, 7, 7);
  }

  // Drive sprocket.
  drawSprocket(grateStartX, grateY + 25, 30);

  // Return sprocket.
  drawSprocket(grateEndX, grateY + 25, 30);

  // Drive linkage.
  stroke(65);
  strokeWeight(5);
  line(grateStartX - 70, grateY + 5,
       grateStartX - 25, grateY + 25);

  fill(155);
  ellipse(grateStartX - 70, grateY + 5, 18, 18);
}

void drawSprocket(float x, float y, float diameter) {
  stroke(50);
  strokeWeight(3);
  fill(175, 180, 185);
  ellipse(x, y, diameter, diameter);

  noFill();
  stroke(75);
  ellipse(x, y, diameter * 0.60, diameter * 0.60);

  strokeWeight(3);
  for (int i = 0; i < 8; i++) {
    float a = TWO_PI * i / 8.0;
    line(x, y,
         x + cos(a) * diameter * 0.38,
         y + sin(a) * diameter * 0.38);
  }

  fill(65);
  noStroke();
  ellipse(x, y, 7, 7);
}

// ================================================================
// UNDER-GRATE AIR COMPARTMENTS
// ================================================================

void drawAirCompartments() {
  float compWidth = grateW / 5.0;

  // Air supply plenum below the grate.
  stroke(60);
  strokeWeight(3);
  fill(203, 224, 238);

  rect(grateStartX + 5, grateY + 105,
       grateW - 10, 42);

  // Five independent air compartments.
  for (int i = 0; i < 5; i++) {
    float x1 = grateStartX + i * compWidth + 5;
    float x2 = x1 + compWidth - 10;

    fill(188, 218, 235);
    rect(x1, grateY + 70,
         x2 - x1, 35);

    // Air compartment separator.
    stroke(95, 125, 143);
    strokeWeight(2);
    line(x2, grateY + 73, x2, grateY + 103);

    // Air seal / regulating damper.
    fill(125, 155, 174);
    rect(x1 + 13, grateY + 88,
         x2 - x1 - 26, 9);

    // Air supply direction.
    drawStaticUpArrow(
      (x1 + x2) / 2,
      grateY + 133,
      22
    );
  }

  // Bottom air inlet.
  fill(75, 145, 185);
  noStroke();
  rect(grateStartX + 220, grateY + 147,
       160, 24);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(13);
  text("PRIMARY AIR INLET",
       grateStartX + 300, grateY + 159);
}

void drawStaticUpArrow(float x, float y, float h) {
  stroke(35, 117, 175);
  strokeWeight(3);

  line(x, y + h / 2, x, y - h / 2);
  line(x, y - h / 2, x - 6, y - h / 2 + 7);
  line(x, y - h / 2, x + 6, y - h / 2 + 7);
}

// ================================================================
// COAL CREATION
// ================================================================

void createCoal() {
  if (frameCount - lastCoalFrame >= 12) {
    coalList.add(
      new CoalParticle(
        220,
        grateY - 32,
        false
      )
    );

    lastCoalFrame = frameCount;
  }
}

class CoalParticle {
  float x, y;
  float size;
  float age;
  float vy;

  boolean onGrate;
  boolean burnt;
  boolean initialCoal;

  CoalParticle(float x, float y, boolean initialCoal) {
    this.x = x;
    this.y = y;
    this.initialCoal = initialCoal;
    this.size = random(9, 16);
    this.age = 0;
    this.vy = 0;
    this.onGrate = initialCoal;
    this.burnt = false;
  }

  void update() {
    if (paused) return;

    if (!onGrate) {
      // Coal falls from the hopper onto the moving grate.
      x += 0.4;
      y += 2.8;
      vy += 0.10;

      if (y >= grateY - 22) {
        y = grateY - random(22, 34);
        onGrate = true;
      }

      return;
    }

    x += grateSpeed * 0.55;
    age += 0.0035;

    // Gradual combustion across the grate.
    if (age > 0.18 && age < 0.78 &&
        random(1) < 0.11 && showFlames) {

      flameList.add(
        new FlameParticle(
          x + random(-5, 5),
          y - random(3, 12)
        )
      );
    }

    // Charcoal/ash formation near the end.
    if (age >= 0.80) {
      burnt = true;
    }

    if (x >= grateEndX + 12) {
      ashList.add(
        new AshParticle(x, grateY - 5)
      );

      x = -1000;
    }
  }

  void display() {
    if (x < -500) return;

    noStroke();

    if (!burnt && age < 0.20) {
      fill(42, 40, 37);
    } else if (!burnt && age < 0.80) {
      fill(105, 73, 48);
    } else {
      fill(95, 91, 84);
    }

    ellipse(x, y, size, size * 0.75);

    // Small coal highlights.
    fill(145, 122, 92, 100);
    ellipse(x - 2, y - 2, size * 0.3, size * 0.25);
  }

  boolean isDead() {
    return x < -900;
  }
}

void updateAndDrawCoal() {
  for (int i = coalList.size() - 1; i >= 0; i--) {
    CoalParticle c = coalList.get(i);

    c.update();
    c.display();

    if (c.isDead()) {
      coalList.remove(i);
    }
  }
}

// ================================================================
// PRIMARY AIR — BOTTOM TO TOP ONLY
// ================================================================

void createBottomAir() {
  if (frameCount - lastAirFrame >= 4) {
    float compWidth = grateW / 5.0;

    int compartment = int(random(5));

    float x = grateStartX +
      compartment * compWidth +
      random(20, compWidth - 20);

    // Every air particle starts below the grate.
    float y = grateY + 137;

    airList.add(new AirParticle(x, y));

    lastAirFrame = frameCount;
  }
}

class AirParticle {
  float x, y;
  float vx, vy;
  float alpha;
  float particleLength;

  AirParticle(float x, float y) {
    this.x = x;
    this.y = y;

    // Positive upward airflow: y decreases in Processing.
    vx = random(-0.25, 0.25);
    vy = random(2.0, 3.6);

    alpha = 235;
    particleLength = random(10, 18);
  }

  void update() {
    if (paused) return;

    x += vx;
    y -= vy;
    alpha -= 1.5;
  }

  void display() {
    if (alpha <= 0) return;

    stroke(30, 135, 200, alpha);
    strokeWeight(2);

    // Arrow shaft pointing UP.
    line(x, y + particleLength / 2,
         x, y - particleLength / 2);

    // Arrow head.
    line(x, y - particleLength / 2,
         x - 4, y - particleLength / 2 + 5);

    line(x, y - particleLength / 2,
         x + 4, y - particleLength / 2 + 5);
  }

  boolean isDead() {
    return alpha <= 0 || y < grateY - 65;
  }
}

void updateAndDrawAir() {
  for (int i = airList.size() - 1; i >= 0; i--) {
    AirParticle a = airList.get(i);

    a.update();
    a.display();

    if (a.isDead()) {
      airList.remove(i);
    }
  }
}

// ================================================================
// FLAMES
// ================================================================

class FlameParticle {
  float x, y;
  float size;
  float alpha;
  float riseSpeed;

  FlameParticle(float x, float y) {
    this.x = x;
    this.y = y;
    size = random(10, 24);
    alpha = random(150, 230);
    riseSpeed = random(1.0, 2.8);
  }

  void update() {
    if (paused) return;

    y -= riseSpeed;
    x += random(-0.8, 0.8);
    size *= 0.985;
    alpha -= 2.7;
  }

  void display() {
    if (alpha <= 0) return;

    noStroke();

    fill(230, 65, 25, alpha * 0.65);
    ellipse(x, y, size, size * 1.5);

    fill(255, 155, 25, alpha);
    ellipse(x, y + 2, size * 0.65, size);

    fill(255, 225, 100, alpha * 0.8);
    ellipse(x, y + 4, size * 0.28, size * 0.55);
  }

  boolean isDead() {
    return alpha <= 0 || y < 100;
  }
}

void updateAndDrawFlames() {
  for (int i = flameList.size() - 1; i >= 0; i--) {
    FlameParticle f = flameList.get(i);

    f.update();
    f.display();

    if (f.isDead()) {
      flameList.remove(i);
    }
  }
}

// ================================================================
// ASH DISCHARGE
// ================================================================

class AshParticle {
  float x, y;
  float vx, vy;
  float size;
  float alpha;

  AshParticle(float x, float y) {
    this.x = x;
    this.y = y;

    vx = random(0.3, 1.5);
    vy = random(0.5, 1.8);
    size = random(5, 10);
    alpha = 255;
  }

  void update() {
    if (paused) return;

    x += vx;
    y += vy;
    vy += 0.08;
    alpha -= 1.5;
  }

  void display() {
    noStroke();
    fill(100, 96, 89, alpha);
    ellipse(x, y, size, size * 0.8);
  }

  boolean isDead() {
    return alpha <= 0 || y > 690;
  }
}

void updateAndDrawAsh() {
  for (int i = ashList.size() - 1; i >= 0; i--) {
    AshParticle a = ashList.get(i);

    a.update();
    a.display();

    if (a.isDead()) {
      ashList.remove(i);
    }
  }
}

// ================================================================
// LABELS
// ================================================================

void drawLabels() {
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);

  text("COAL HOPPER", 65, 112);
  line(145, 120, 170, 150);

  text("COAL GATE", 65, 365);
  line(145, 365, 211, 365);

  text("DRIVE LINKAGE", 60, 450);
  line(185, 450, 252, 495);

  text("DRIVE SPROCKET", 60, 530);
  line(180, 530, 294, 520);

  text("MOVING CHAIN GRATE", 470, 458);

  text("COMBUSTION ZONE", 560, 155);

  text("RETURN BEND", 920, 458);
  line(923, 466, 900, 495);

  text("ASH DISCHARGE", 930, 565);

  // Labels for primary air compartments.
  textAlign(CENTER, CENTER);
  textSize(14);

  fill(30, 100, 150);
  text("UNDER-GRATE AIR COMPARTMENTS",
       grateStartX + grateW / 2,
       grateY + 76);

  text("AIR SEALS / DAMPERS",
       grateStartX + grateW / 2,
       grateY + 119);

  text("AIR FLOWS UPWARD THROUGH THE GRATE",
       grateStartX + grateW / 2,
       grateY + 188);

  // Explicitly indicate no top air inlet in this simulation.
  fill(90, 80, 70);
  textSize(12);
  text("Primary-air-only demonstration",
       650, 405);

  // Figure caption.
  fill(30);
  textSize(21);
  text("Fig. 2.2 — Chain Grate Stoker",
       vW / 2, 745);
}

// ================================================================
// ANDROID TOUCH CONTROLS
// ================================================================

void drawControls() {
  float y = 62;
  float h = 36;

  drawButton(20, y, 145, h,
             paused ? "RESUME" : "PAUSE");

  drawButton(180, y, 145, h, "RESET");

  drawButton(340, y, 155, h, "SPEED -");

  drawButton(510, y, 155, h, "SPEED +");

  drawButton(680, y, 155, h,
             showAir ? "AIR: ON" : "AIR: OFF");

  drawButton(860, y, 155, h,
             showLabels ? "LABELS: ON" : "LABELS: OFF");

  fill(40);
  textAlign(LEFT, CENTER);
  textSize(13);
  text("Grate speed: " + nf(grateSpeed, 1, 1),
       1025, y + h / 2);
}

void drawButton(float x, float y, float w, float h,
                String label) {
  stroke(90, 105, 120);
  strokeWeight(1);
  fill(228, 234, 239);
  rect(x, y, w, h, 7);

  fill(25, 43, 58);
  textAlign(CENTER, CENTER);
  textSize(13);
  text(label, x + w / 2, y + h / 2);
}

void mousePressed() {
  // Convert Android screen coordinates to virtual coordinates.
  float mx = (mouseX - xOff) / scaleF;
  float my = (mouseY - yOff) / scaleF;

  // Controls only.
  if (my >= 62 && my <= 98) {
    if (mx >= 20 && mx <= 165) {
      paused = !paused;
    } else if (mx >= 180 && mx <= 325) {
      initialiseSimulation();
    } else if (mx >= 340 && mx <= 495) {
      grateSpeed = max(0.3, grateSpeed - 0.3);
    } else if (mx >= 510 && mx <= 665) {
      grateSpeed = min(4.0, grateSpeed + 0.3);
    } else if (mx >= 680 && mx <= 835) {
      showAir = !showAir;
      if (!showAir) airList.clear();
    } else if (mx >= 860 && mx <= 1015) {
      showLabels = !showLabels;
    }
  }
}

// ================================================================
// END OF SKETCH
// ================================================================
