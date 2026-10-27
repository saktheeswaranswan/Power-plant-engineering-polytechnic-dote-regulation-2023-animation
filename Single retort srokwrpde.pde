
/*
 * ================================================================
 * SINGLE RETORT STOKER — UNDERFEED STOKER
 * Processing Java Mode / Android APDE
 *
 * Based on textbook Fig. 2.3 supplied by the user.
 *
 * MECHANISM:
 *   Coal hopper -> Ram / screw feeder -> Central retort
 *   Fresh coal rises from BELOW the existing combustion bed.
 *   Coal spreads OUTWARD from the central retort.
 *   Primary air -> Side windboxes -> Tuyeres -> Fuel bed
 *   Combustion -> Hot char -> Ash
 *   Ash moves outward -> Side ash discharge -> Ashpits
 *
 * FEATURES:
 *   - Stationary central retort
 *   - Animated mechanical ram
 *   - Upward coal feeding and outward spreading
 *   - Heating, glowing char and ash formation
 *   - Left and right primary-air windboxes
 *   - Animated air arrows
 *   - Flame and ash particles
 *   - Responsive landscape virtual canvas
 *   - Pause, resume, reset, speed and visibility controls
 *   - No external libraries
 * ================================================================
 */

import java.util.ArrayList;

// ---------------- VIRTUAL SCREEN ----------------

final float VW = 1200;
final float VH = 800;

float scaleF, xOff, yOff;

// ---------------- SIMULATION GEOMETRY ----------------

final float CX = 600;

final float RETORT_TOP = 380;
final float RETORT_BOTTOM = 490;

final float BED_LEFT = 325;
final float BED_RIGHT = 875;

final float FLOOR_Y = 650;

// ---------------- PARTICLES ----------------

ArrayList<CoalParticle> coalList;
ArrayList<AirParticle> airList;
ArrayList<FlameParticle> flameList;
ArrayList<AshParticle> ashList;

// ---------------- CONTROLS ----------------

boolean paused = false;
boolean showAir = true;
boolean showFlames = true;
boolean showLabels = true;

float coalSpeed = 1.0;
float airSpeed = 1.0;

float ramStroke = 0;
float ramDirection = 1;

int lastCoalFrame = 0;
int lastAirFrame = 0;

int coalFeedInterval = 19;

// ================================================================
// SETUP
// ================================================================

void setup() {
  orientation(LANDSCAPE);
  fullScreen();
  frameRate(60);
  smooth(4);

  updateScale();
  initialiseSimulation();
}

void updateScale() {
  scaleF = min(width / VW, height / VH);
  xOff = (width - VW * scaleF) * 0.5;
  yOff = (height - VH * scaleF) * 0.5;
}

void initialiseSimulation() {
  coalList = new ArrayList<CoalParticle>();
  airList = new ArrayList<AirParticle>();
  flameList = new ArrayList<FlameParticle>();
  ashList = new ArrayList<AshParticle>();

  ramStroke = 0;
  ramDirection = 1;

  coalSpeed = 1.0;
  airSpeed = 1.0;

  paused = false;

  lastCoalFrame = frameCount;
  lastAirFrame = frameCount;

  // Initial fuel already present in the combustion bed.
  for (int i = 0; i < 58; i++) {
    float x = random(BED_LEFT + 12, BED_RIGHT - 12);
    float y = bedSurfaceY(x) + random(1, 10);

    CoalParticle c = new CoalParticle(x, y);
    c.state = 2;
    c.age = random(0.05, 0.60);
    c.vx = (x < CX ? -1 : 1) * random(0.05, 0.20);

    coalList.add(c);
  }

  // Initial ash collected in both ash pits.
  for (int i = 0; i < 12; i++) {
    ashList.add(new AshParticle(
      random(190, 255), random(612, 640), -1
    ));

    ashList.add(new AshParticle(
      random(945, 1010), random(612, 640), 1
    ));
  }
}

void draw() {
  background(240, 244, 247);

  updateScale();

  pushMatrix();
  translate(xOff, yOff);
  scale(scaleF);

  drawHeader();
  drawControls();

  if (!paused) {
    updateRam();

    if (frameCount - lastCoalFrame >= coalFeedInterval) {
      createCoal();
      lastCoalFrame = frameCount;
    }

    if (showAir && frameCount - lastAirFrame >= 5) {
      createAir();
      lastAirFrame = frameCount;
    }

    if (showFlames) {
      createFlames();
    }
  }

  drawFurnace();
  drawCoalHopper();
  drawRetort();
  drawWindboxes();
  drawFuelBed();

  drawCombustionGlow();

  updateAndDrawAir();
  updateAndDrawCoal();
  updateAndDrawFlames();
  updateAndDrawAsh();

  if (showLabels) {
    drawLabels();
  }

  drawStatus();

  popMatrix();
}

// ================================================================
// HEADER
// ================================================================

void drawHeader() {
  noStroke();
  fill(34, 48, 63);
  rect(0, 0, VW, 49);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(23);

  text("SINGLE RETORT STOKER",
       VW / 2, 17);

  fill(211, 226, 238);
  textSize(12);

  text("UNDERFEED COMBUSTION — FIG. 2.3",
       VW / 2, 36);
}

// ================================================================
// CONTROLS
// ================================================================

void drawControls() {
  float y = 57;
  float h = 34;

  drawButton(12, y, 116, h,
             paused ? "RESUME" : "PAUSE");

  drawButton(136, y, 105, h, "RESET");

  drawButton(249, y, 105, h, "SPEED -");

  drawButton(362, y, 105, h, "SPEED +");

  drawButton(475, y, 112, h,
             showAir ? "AIR: ON" : "AIR: OFF");

  drawButton(595, y, 125, h,
             showFlames ? "FLAME: ON" : "FLAME: OFF");

  drawButton(728, y, 135, h,
             showLabels ? "LABELS: ON" : "LABELS: OFF");
}

void drawButton(float x, float y, float w, float h,
                String label) {
  stroke(100, 113, 126);
  strokeWeight(1);

  fill(225, 234, 241);
  rect(x, y, w, h, 6);

  fill(28, 45, 59);
  textAlign(CENTER, CENTER);
  textSize(12);

  text(label, x + w/2, y + h/2);
}

// ================================================================
// FURNACE CASING
// ================================================================

void drawFurnace() {
  // Outer casing.
  stroke(67, 69, 69);
  strokeWeight(4);
  fill(192, 190, 181);

  rect(145, 125, 910, 535);

  // Refractory lining.
  stroke(140, 120, 101);
  strokeWeight(7);
  noFill();

  rect(161, 143, 878, 499);

  // Furnace interior.
  noStroke();
  fill(255, 235, 197);

  rect(170, 151, 860, 489);

  // Furnace floor.
  stroke(80);
  strokeWeight(4);
  line(170, FLOOR_Y, 1030, FLOOR_Y);

  // Left ash discharge chute.
  stroke(65);
  strokeWeight(3);
  fill(164, 162, 152);

  beginShape();
  vertex(184, 480);
  vertex(231, 480);
  vertex(254, 586);
  vertex(235, 614);
  vertex(194, 586);
  endShape(CLOSE);

  // Right ash discharge chute.
  beginShape();
  vertex(969, 480);
  vertex(1016, 480);
  vertex(1006, 586);
  vertex(965, 614);
  vertex(946, 586);
  endShape(CLOSE);

  // Ashpits.
  noStroke();
  fill(91, 89, 83);

  rect(184, 614, 76, 29);
  rect(944, 614, 76, 29);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);

  text("ASHPIT", 222, 629);
  text("ASHPIT", 982, 629);
}

// ================================================================
// COAL HOPPER
// ================================================================

void drawCoalHopper() {
  stroke(60);
  strokeWeight(3);
  fill(177, 185, 191);

  beginShape();
  vertex(515, 119);
  vertex(685, 119);
  vertex(664, 187);
  vertex(635, 216);
  vertex(565, 216);
  vertex(536, 187);
  endShape(CLOSE);

  // Coal inside hopper.
  noStroke();
  fill(48, 44, 40);

  beginShape();
  vertex(528, 135);
  vertex(672, 135);
  vertex(652, 181);
  vertex(627, 204);
  vertex(573, 204);
  vertex(548, 181);
  endShape(CLOSE);

  // Fixed coal texture.
  randomSeed(29);

  fill(105, 94, 80);

  for (int i = 0; i < 44; i++) {
    ellipse(random(537, 663),
            random(143, 183), 4, 4);
  }

  randomSeed((long)millis());

  // Outlet.
  stroke(60);
  strokeWeight(3);
  fill(139, 146, 151);

  rect(565, 211, 70, 28);

  // Feeder housing.
  fill(165, 174, 181);
  rect(507, 239, 186, 42);

  // Screw shaft.
  stroke(77);
  strokeWeight(6);
  line(600, 280, 600, 349);

  // Screw-flight representation.
  stroke(77, 112, 131);
  strokeWeight(4);

  for (int y = 286; y < 344; y += 12) {
    line(580, y, 620, y + 7);
  }

  // Ram actuator body.
  fill(132, 142, 149);
  stroke(60);
  strokeWeight(2);

  rect(538, 349, 124, 30);

  fill(65);
  noStroke();

  ellipse(548, 364, 8, 8);
  ellipse(652, 364, 8, 8);
}

// ================================================================
// CENTRAL SINGLE RETORT
// ================================================================

void updateRam() {
  ramStroke += ramDirection * 0.65 * coalSpeed;

  if (ramStroke >= 12) {
    ramStroke = 12;
    ramDirection = -1;
  }

  if (ramStroke <= 0) {
    ramStroke = 0;
    ramDirection = 1;
  }
}

void drawRetort() {
  // Stationary retort body.
  stroke(55);
  strokeWeight(4);
  fill(147, 153, 157);

  beginShape();
  vertex(535, 377);
  vertex(665, 377);
  vertex(660, 458);
  vertex(640, 486);
  vertex(560, 486);
  vertex(540, 458);
  endShape(CLOSE);

  // Retort interior.
  noStroke();
  fill(63, 58, 52);

  beginShape();
  vertex(548, 388);
  vertex(652, 388);
  vertex(647, 450);
  vertex(630, 474);
  vertex(570, 474);
  vertex(553, 450);
  endShape(CLOSE);

  // Animated ram plate moves inside the retort.
  float plateY = 454 - ramStroke;

  stroke(47);
  strokeWeight(3);
  fill(185, 190, 194);

  rect(557, plateY, 86, 12);

  // Retort air passages.
  noStroke();
  fill(43, 140, 185);

  for (int y = 407; y <= 450; y += 14) {
    rect(536, y, 11, 6);
    rect(653, y, 11, 6);
  }

  // Coal feed direction.
  drawArrow(600, 569, 600, 526,
            color(169, 79, 28), 4);

  fill(126, 55, 22);
  textAlign(CENTER, CENTER);
  textSize(12);

  text("UPWARD COAL FEED", 600, 580);
}

// ================================================================
// SIDE AIR WINDBOXES AND TUYERES
// ================================================================

void drawWindboxes() {
  stroke(58);
  strokeWeight(3);
  fill(177, 211, 229);

  // Windboxes.
  rect(205, 408, 87, 68);
  rect(908, 408, 87, 68);

  // Air inlet ducts.
  fill(127, 178, 204);

  rect(170, 430, 35, 20);
  rect(995, 430, 35, 20);

  drawArrow(174, 440, 201, 440,
            color(27, 123, 184), 3);

  drawArrow(1026, 440, 999, 440,
            color(27, 123, 184), 3);

  // Tuyeres direct primary air into the fuel bed.
  stroke(69, 119, 143);
  strokeWeight(7);

  line(292, 421, 360, 377);
  line(292, 441, 378, 394);
  line(908, 421, 840, 377);
  line(908, 441, 822, 394);

  // Tuyere openings.
  stroke(31, 109, 147);
  strokeWeight(4);

  for (int i = 0; i < 3; i++) {
    float y = 418 + i * 15;

    line(350, y - 40, 360, y - 34);
    line(850, y - 40, 840, y - 34);
  }
}

// ================================================================
// FUEL BED GEOMETRY
// ================================================================

float bedSurfaceY(float x) {
  // Highest near the retort, lower toward the outer edges.
  return 365 + abs(x - CX) * 0.115;
}

void drawFuelBed() {
  // Coal bed spreads outward from the central retort.
  noStroke();
  fill(67, 54, 43);

  beginShape();
  vertex(333, 407);
  vertex(345, 381);
  vertex(385, 359);
  vertex(438, 337);
  vertex(493, 344);
  vertex(540, 367);
  vertex(560, 390);
  vertex(640, 390);
  vertex(660, 367);
  vertex(707, 344);
  vertex(762, 337);
  vertex(815, 359);
  vertex(855, 381);
  vertex(867, 407);
  vertex(867, 424);
  vertex(333, 424);
  endShape(CLOSE);

  // Retort mouth remains visible.
  fill(63, 58, 52);
  rect(563, 400, 74, 21);

  // Fuel bed direction arrows.
  drawArrow(590, 395, 475, 365,
            color(225, 164, 69), 3);

  drawArrow(610, 395, 725, 365,
            color(225, 164, 69), 3);
}

// ================================================================
// COAL FEED PARTICLES
//
// State 0 = fresh coal rises from the retort.
// State 1 = coal spreads outward across the bed.
// State 2 = combustion and hot char.
// State 3 = ash travels outward and is discharged.
// ================================================================

void createCoal() {
  CoalParticle c = new CoalParticle(
    CX + random(-12, 12),
    465 + random(0, 7)
  );

  c.state = 0;
  coalList.add(c);
}

class CoalParticle {
  float x, y;
  float size;
  float age;
  float vx, vy;
  float alpha;

  int state;

  CoalParticle(float px, float py) {
    x = px;
    y = py;

    size = random(8, 14);
    age = 0;
    vx = 0;
    vy = 0;
    alpha = 255;
    state = 0;
  }

  void update() {
    if (paused) return;

    age += 0.003 * coalSpeed;

    // STATE 0: fresh coal moves upward.
    if (state == 0) {
      y -= 1.35 * coalSpeed;
      x += random(-0.12, 0.12);

      if (y <= 402) {
        state = 1;
        age = 0;

        // Spread in either direction from the retort.
        vx = (x < CX ? -1 : 1)
             * random(0.65, 1.25);

        vy = random(-0.20, 0.15);
      }
    }

    // STATE 1: coal spreads outward over the bed.
    else if (state == 1) {
      x += vx * coalSpeed;
      y += vy * coalSpeed;

      float targetY = bedSurfaceY(x);

      // Coal follows the upward mound profile.
      y += (targetY - y) * 0.10;

      if (abs(x - CX) > 115) {
        state = 2;
        age = 0;
      }

      if (x < BED_LEFT) x = BED_LEFT;
      if (x > BED_RIGHT) x = BED_RIGHT;
    }

    // STATE 2: combustion and conversion into ash.
    else if (state == 2) {
      x += vx * 0.08 * coalSpeed;

      float targetY = bedSurfaceY(x);
      y += (targetY - y) * 0.08;

      if (showFlames && random(1) < 0.035) {
        flameList.add(new FlameParticle(
          x + random(-5, 5),
          y - random(2, 9)
        ));
      }

      // Fuel burns before residue is discharged.
      if (age > 1.0) {
        state = 3;
        age = 0;

        vx = (x < CX ? -1 : 1)
             * random(0.7, 1.15);
        vy = 0.4;
      }
    }

    // STATE 3: burnt residue moves outward and down.
    else if (state == 3) {
      x += vx * coalSpeed;
      y += (1.0 + vy) * coalSpeed;

      vy += 0.025;

      // Transfer the ash to the appropriate side ashpit.
      if (x < 265 || x > 935 || y > 600) {
        int side = (x < CX ? -1 : 1);

        float ashX = side < 0
                     ? random(195, 250)
                     : random(950, 1005);

        ashList.add(new AshParticle(
          ashX, random(605, 622), side
        ));

        alpha = 0;
      }
    }
  }

  void display() {
    if (alpha <= 0) return;

    noStroke();

    if (state == 0) {
      fill(36, 34, 31, alpha);
    } else if (state == 1) {
      fill(85, 64, 46, alpha);
    } else if (state == 2) {
      if (age < 0.35) {
        fill(105, 61, 39, alpha);
      } else {
        fill(184, 72, 28, alpha);
      }
    } else {
      fill(116, 109, 98, alpha);
    }

    ellipse(x, y, size, size * 0.75);

    // Glowing char centre.
    if (state == 2 && age > 0.25) {
      fill(255, 147, 42, 185);
      ellipse(x, y - 1, size * 0.36, size * 0.30);
    }
  }

  boolean isDead() {
    return alpha <= 0 || y > 690;
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
// PRIMARY AIR PARTICLES
// ================================================================

void createAir() {
  boolean left = random(1) < 0.5;

  float x;
  float y;

  if (left) {
    x = random(292, 350);
    y = random(408, 449);
  } else {
    x = random(850, 908);
    y = random(408, 449);
  }

  airList.add(new AirParticle(x, y, left));
}

class AirParticle {
  float x, y;
  float vx, vy;
  float alpha;

  boolean leftSide;

  AirParticle(float px, float py, boolean left) {
    x = px;
    y = py;
    leftSide = left;

    // Left air moves right; right air moves left.
    vx = left ? random(1.0, 1.8)
              : random(-1.8, -1.0);

    // Air travels upward into the burning fuel bed.
    vy = random(-0.9, -0.25);

    alpha = 245;
  }

  void update() {
    if (paused) return;

    x += vx * airSpeed;
    y += vy * airSpeed;

    alpha -= 2.0;
  }

  void display() {
    if (alpha <= 0) return;

    stroke(27, 129, 198, alpha);
    strokeWeight(2);

    float ex = x + vx * 4;
    float ey = y + vy * 4;

    line(x, y, ex, ey);

    float a = atan2(ey - y, ex - x);
    float h = 5;

    line(ex, ey,
         ex - cos(a - 0.55) * h,
         ey - sin(a - 0.55) * h);

    line(ex, ey,
         ex - cos(a + 0.55) * h,
         ey - sin(a + 0.55) * h);
  }

  boolean isDead() {
    // Stop air particles after they enter the central bed.
    return alpha <= 0 ||
           x < 390 || x > 810 ||
           y < 330 || y > 480;
  }
}

void updateAndDrawAir() {
  for (int i = airList.size() - 1; i >= 0; i--) {
    AirParticle a = airList.get(i);

    if (showAir) {
      a.update();
      a.display();
    }

    if (!showAir || a.isDead()) {
      airList.remove(i);
    }
  }
}

// ================================================================
// FLAMES
// ================================================================

void createFlames() {
  if (random(1) < 0.45) {
    float x = random(360, 840);
    float y = bedSurfaceY(x) - random(1, 12);

    flameList.add(new FlameParticle(x, y));
  }
}

class FlameParticle {
  float x, y;
  float size;
  float alpha;
  float riseSpeed;
  float drift;

  FlameParticle(float px, float py) {
    x = px;
    y = py;

    size = random(8, 19);
    alpha = random(155, 235);

    riseSpeed = random(0.7, 1.8);
    drift = random(-0.55, 0.55);
  }

  void update() {
    if (paused) return;

    y -= riseSpeed * coalSpeed;
    x += drift;

    size *= 0.985;
    alpha -= 3.0;
  }

  void display() {
    if (alpha <= 0) return;

    noStroke();

    fill(220, 57, 20, alpha * 0.65);
    ellipse(x, y, size, size * 1.45);

    fill(255, 137, 20, alpha);
    ellipse(x, y + 2, size * 0.65, size * 0.95);

    fill(255, 222, 95, alpha * 0.9);
    ellipse(x, y + 3, size * 0.27, size * 0.5);
  }

  boolean isDead() {
    return alpha <= 0 || y < 155;
  }
}

void updateAndDrawFlames() {
  for (int i = flameList.size() - 1; i >= 0; i--) {
    FlameParticle f = flameList.get(i);

    if (showFlames) {
      f.update();
      f.display();
    }

    if (!showFlames || f.isDead()) {
      flameList.remove(i);
    }
  }
}

// ================================================================
// COMBUSTION GLOW
// ================================================================

void drawCombustionGlow() {
  noStroke();

  for (int i = 0; i < 6; i++) {
    fill(255, 98, 23, 8);

    ellipse(CX, 375,
            175 + i * 24,
            27 + i * 8);
  }
}

// ================================================================
// ASH COLLECTION
// ================================================================

class AshParticle {
  float x, y;
  float vx, vy;
  float size;
  float alpha;

  int side;

  AshParticle(float px, float py, int s) {
    x = px;
    y = py;
    side = s;

    vx = s * random(0.2, 0.8);
    vy = random(0.2, 0.7);

    size = random(4, 8);
    alpha = 245;
  }

  void update() {
    if (paused) return;

    x += vx;
    y += vy;

    vy += 0.025;
    alpha -= 0.55;

    // Ash settles inside the side ashpit.
    if (y > 640) {
      y = 640;
      vy = 0;
      vx *= 0.65;
    }
  }

  void display() {
    if (alpha <= 0) return;

    noStroke();
    fill(104, 100, 92, alpha);

    ellipse(x, y, size, size * 0.8);
  }

  boolean isDead() {
    return alpha <= 0 ||
           x < 175 || x > 1025;
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
// ARROW DRAWING HELPER
// ================================================================

void drawArrow(float x1, float y1,
               float x2, float y2,
               int c, float sw) {
  stroke(c);
  strokeWeight(sw);

  line(x1, y1, x2, y2);

  float a = atan2(y2 - y1, x2 - x1);
  float h = 9;

  line(x2, y2,
       x2 - cos(a - 0.55) * h,
       y2 - sin(a - 0.55) * h);

  line(x2, y2,
       x2 - cos(a + 0.55) * h,
       y2 - sin(a + 0.55) * h);
}

// ================================================================
// LABELS
// ================================================================

void drawLabels() {
  textAlign(LEFT, CENTER);
  textSize(13);
  fill(28);

  text("COAL HOPPER", 335, 145);
  line(440, 145, 516, 155);

  text("RAM / SCREW FEEDER", 335, 257);
  line(490, 257, 510, 263);

  text("CENTRAL RETORT", 350, 463);
  line(478, 463, 540, 442);

  text("COMBUSTION ZONE", 400, 307);

  text("ASH DISCHARGE", 28, 552);
  line(150, 552, 205, 576);

  text("ASH DISCHARGE", 970, 552);
  line(970, 563, 986, 576);

  textAlign(CENTER, CENTER);

  fill(25, 99, 150);
  text("AIR WINDBOX", 248, 394);
  text("AIR WINDBOX", 952, 394);

  text("TUYERES", 334, 342);
  text("TUYERES", 866, 342);

  fill(115, 62, 26);
  text("FRESH COAL RISES FROM BELOW",
       600, 533);

  fill(115, 62, 26);
  text("FUEL SPREADS OUTWARD",
       600, 318);

  fill(28, 94, 139);
  textSize(12);

  text("PRIMARY AIR: SIDE TUYERES INTO THE FUEL BED",
       600, 606);

  fill(35);
  textSize(18);

  text("Fig. 2.3 — Single Retort Stoker",
       600, 690);

  fill(80);
  textSize(12);

  text("Stationary retort • Underfeed coal • Outward ash discharge",
       600, 713);
}

// ================================================================
// STATUS DISPLAY
// ================================================================

void drawStatus() {
  fill(35);
  textAlign(LEFT, CENTER);
  textSize(12);

  text(paused ? "STATUS: PAUSED" : "STATUS: RUNNING",
       18, 758);

  text("Coal: " + coalList.size(),
       190, 758);

  text("Air: " + airList.size(),
       330, 758);

  text("Ash: " + ashList.size(),
       445, 758);

  text("Speed: " + nf(coalSpeed, 1, 1) + "x",
       580, 758);

  text("Primary air: " + (showAir ? "ON" : "OFF"),
       730, 758);
}

// ================================================================
// ANDROID TOUCH / MOUSE CONTROLS
// ================================================================

void mousePressed() {
  float mx = (mouseX - xOff) / scaleF;
  float my = (mouseY - yOff) / scaleF;

  if (mx < 0 || mx > VW ||
      my < 57 || my > 91) {
    return;
  }

  if (mx >= 12 && mx <= 128) {
    paused = !paused;
  }
  else if (mx >= 136 && mx <= 241) {
    initialiseSimulation();
  }
  else if (mx >= 249 && mx <= 354) {
    coalSpeed = max(0.3, coalSpeed - 0.2);
    airSpeed = max(0.3, airSpeed - 0.2);
  }
  else if (mx >= 362 && mx <= 467) {
    coalSpeed = min(3.0, coalSpeed + 0.2);
    airSpeed = min(3.0, airSpeed + 0.2);
  }
  else if (mx >= 475 && mx <= 587) {
    showAir = !showAir;
  }
  else if (mx >= 595 && mx <= 720) {
    showFlames = !showFlames;
  }
  else if (mx >= 728 && mx <= 863) {
    showLabels = !showLabels;
  }
}

// ================================================================
// END OF SINGLE RETORT STOKER SIMULATION
// ================================================================
