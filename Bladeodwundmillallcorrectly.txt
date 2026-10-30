
/*
  ================================================================
  3D WIND POWER PLANT - ADVANCED AERODYNAMIC SIMULATOR
  PROCESSING JAVA MODE / APDE / P3D
  COMPLETE SINGLE-FILE SOURCE CODE

  THREE SCREENS:
  1. 3D WIND TURBINE
  2. TAMIL NADU WIND RESOURCE
  3. AIRFOIL LABORATORY

  NEW VECTOR DISPLAY CONTROLS:
  SELECTED VECTORS - Only selected blade and station
  ALL VECTORS      - All 12 aerodynamic stations

  KEYBOARD:
  SPACE = START / PAUSE
  X     = BRAKE
  1-4   = ROTOR SELECTION
  F     = FORCE DISPLAY
  V     = WIND FIELD
  M     = BLADE MESH
  P     = PRESSURE COLOURS
  L     = STREAMLINES
  W     = WAKE
  A     = ALL / SELECTED VECTORS
  B     = NEXT BLADE
  S     = NEXT STATION
  Q     = NEXT SCREEN
  + / - = ZOOM
  R     = RESET CAMERA
  [ / ] = BLADE PITCH
  ARROWS = WIND DIRECTION

  EDUCATIONAL APPROXIMATION - NOT VALIDATED CFD.
  ================================================================
*/

final int HAWT = 0;
final int SAVONIUS = 1;
final int DARRIEUS = 2;
final int GIROMILL = 3;

final int SCREEN1 = 0;
final int SCREEN2 = 1;
final int SCREEN3 = 2;

final int NST = 4;

int screenMode = SCREEN1;
int rotorType = HAWT;

boolean running = true;
boolean brake = false;

boolean showMesh = true;
boolean showPressure = true;
boolean showForces = true;
boolean showField = true;
boolean showStreamlines = true;
boolean showWake = true;

// true = ALL VECTORS
// false = SELECTED VECTORS
boolean showAllVectors = true;

boolean draggingCamera = false;
boolean draggingSlider = false;

int activeSlider = -1;

int selectedBlade = 0;
int selectedStation = 2;
int selectedRegion = 0;

float timeValue = 0;
float windSpeed = 9;
float windDirection = 0;
float airDensity = 1.225;

float rotorAngle = 0;
float omega = 0;

float rotorRadius = 120;
float rotorHeight = 210;
float physicalRadius = 20;

float cameraYaw = -0.35;
float cameraPitch = -0.20;
float zoomScale = 1;

float[] bladePitch = {5, 8, 2};

float[] stationFraction = {
  0.25, 0.45, 0.68, 0.90
};

float airfoilCamber = 0.10;
float airfoilThickness = 0.12;
float airfoilAngle = 5;

float batteryCapacity = 10;
float batterySOC = 35;

float totalTorque = 0;
float mechanicalPower = 0;
float electricalPower = 0;

float selectedLift = 0;
float selectedDrag = 0;
float selectedTorque = 0;
float selectedAlpha = 0;
float selectedRelativeSpeed = 0;

PFont fSmall;
PFont fMedium;
PFont fLarge;

color CYAN;
color BLUE;
color YELLOW;
color GREEN;
color RED;
color WHITE;

String[] regions = {
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

float[] regionWind = {
  9.0, 8.8, 8.2, 7.5, 7.8,
  6.8, 7.8, 7.2, 6.8, 5.4,
  5.2, 5.4, 5.0, 5.8, 6.5,
  6.8, 5.5, 5.8, 5.8, 5.0
};

// ================================================================
// SETUP
// ================================================================

void settings() {
  fullScreen(P3D);
}

void setup() {

  orientation(LANDSCAPE);

  frameRate(40);
  smooth(4);

  fSmall = createFont("SansSerif", 12, true);
  fMedium = createFont("SansSerif", 16, true);
  fLarge = createFont("SansSerif.bold", 21, true);

  textFont(fSmall);

  CYAN = color(35, 225, 255);
  BLUE = color(65, 140, 255);
  YELLOW = color(255, 220, 55);
  GREEN = color(50, 255, 130);
  RED = color(255, 75, 85);
  WHITE = color(245);

  windSpeed = regionWind[0];
}

// ================================================================
// MAIN DRAW
// ================================================================

void draw() {

  background(3, 8, 23);

  timeValue += 0.025;

  if (running && !brake) {

    omega = calculateOmega();

    rotorAngle += omega / 40.0;

  } else if (brake) {

    omega = 0;
  }

  calculateForces();

  if (screenMode == SCREEN1) {
    drawScreen1();
  } else if (screenMode == SCREEN2) {
    drawScreen2();
  } else {
    drawScreen3();
  }
}

// ================================================================
// MATHEMATICAL UTILITIES
// ================================================================

float clamp(float x, float a, float b) {
  return constrain(x, a, b);
}

PVector norm(PVector v) {

  PVector n = v.copy();

  if (n.mag() > 0.000001) {
    n.normalize();
  }

  return n;
}

PVector cross(PVector a, PVector b) {
  return a.cross(b);
}

float wrapAngle(float a) {

  while (a > PI) a -= TWO_PI;
  while (a < -PI) a += TWO_PI;

  return a;
}

// ================================================================
// ROTOR SPEED
// ================================================================

float calculateOmega() {

  if (windSpeed < 0.1) return 0;

  float tsr = 6;

  if (rotorType == SAVONIUS) tsr = 0.9;
  if (rotorType == DARRIEUS) tsr = 3;
  if (rotorType == GIROMILL) tsr = 2.8;

  float w = tsr * windSpeed / physicalRadius;

  return min(w, 38 * TWO_PI / 60.0);
}

float rpm() {
  return abs(omega) * 60 / TWO_PI;
}

// ================================================================
// WIND VELOCITY FIELD
// ================================================================

PVector windAt(float x, float y, float z) {

  float gust =
    1 +
    0.025 * sin(timeValue * 1.7 + x * 0.02) +
    0.015 * cos(timeValue + y * 0.02);

  float v = windSpeed * gust;

  float d = radians(windDirection);

  return new PVector(
    sin(d) * v,
    0.035 * v * sin(timeValue + x * 0.02),
    cos(d) * v
  );
}

// ================================================================
// BLADE GEOMETRY
// ================================================================

float bladeRotation(int b) {

  return rotorAngle +
    TWO_PI * b / 3.0 -
    HALF_PI;
}

float chordAt(float t) {
  return 24 * (1.0 - 0.52 * t);
}

float twistAt(float t) {
  return radians(16 - 13 * t);
}

// ================================================================
// AIRFOIL GEOMETRY
// ================================================================

float camberAt(float x, float camber) {

  float u = constrain((x + 1) / 2, 0, 1);

  return camber * sin(PI * u);
}

float thicknessAt(float x, float thickness) {

  float u = constrain((x + 1) / 2, 0, 1);

  return 5 * thickness * (
    0.2969 * sqrt(max(0, u)) -
    0.1260 * u -
    0.3516 * u * u +
    0.2843 * u * u * u -
    0.1015 * u * u * u * u
  );
}

PVector airfoilPoint(
  float x,
  float side,
  float camber,
  float thickness,
  float incidence,
  float chord
) {

  float yt = thicknessAt(x, thickness);
  float yc = camberAt(x, camber);

  float y = yc + side * yt;

  float a = radians(incidence);

  float xr = x * cos(a) - y * sin(a);
  float yr = x * sin(a) + y * cos(a);

  return new PVector(
    xr * chord / 2,
    yr * chord / 2,
    0
  );
}

// ================================================================
// LOCAL BLADE POINT
// ================================================================

PVector localBladePoint(
  float t,
  float x,
  float side,
  int blade
) {

  float chord = chordAt(t);

  float pitch = bladePitch[blade] +
    degrees(twistAt(t));

  PVector p = airfoilPoint(
    x,
    side,
    airfoilCamber,
    airfoilThickness,
    pitch,
    chord
  );

  return new PVector(
    p.x,
    -rotorRadius * t + p.y,
    p.z
  );
}

// ================================================================
// BLADE POINT IN WORLD COORDINATES
// ================================================================

PVector bladePoint(
  int blade,
  float t,
  float x,
  float side
) {

  float angle = bladeRotation(blade);

  PVector p = localBladePoint(
    t, x, side, blade
  );

  float wx = p.x * cos(angle) - p.y * sin(angle);
  float wy = p.x * sin(angle) + p.y * cos(angle);

  return new PVector(
    wx,
    wy - 50,
    35 + p.z
  );
}

PVector bladeVelocity(PVector p) {

  PVector arm = new PVector(
    p.x,
    p.y + 50,
    0
  );

  return new PVector(
    -omega * arm.y,
    omega * arm.x,
    0
  );
}

// ================================================================
// AERODYNAMIC RESULT
// ================================================================

class AeroResult {

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
// AERODYNAMIC SECTION CALCULATION
// ================================================================

AeroResult sectionResult(int b, int s) {

  AeroResult a = new AeroResult();

  float t = stationFraction[s];

  a.position = bladePoint(b, t, 0, 1);

  a.wind = windAt(
    a.position.x,
    a.position.y,
    a.position.z
  );

  a.velocity = bladeVelocity(a.position);

  a.relative = PVector.sub(
    a.wind,
    a.velocity
  );

  a.speed = a.relative.mag();

  float angle = bladeRotation(b);

  PVector span = new PVector(
    -sin(angle),
    cos(angle),
    0
  );

  PVector flow = a.relative.copy();

  flow.sub(
    PVector.mult(
      span,
      PVector.dot(flow, span)
    )
  );

  flow = norm(flow);

  PVector chord = new PVector(
    cos(angle),
    sin(angle),
    0
  );

  float pitch =
    radians(bladePitch[b]) + twistAt(t);

  chord.rotate(pitch);

  float dotValue = clamp(
    PVector.dot(norm(chord), flow),
    -1, 1
  );

  a.alpha = wrapAngle(acos(dotValue));

  float signValue = PVector.dot(
    cross(norm(chord), flow),
    span
  );

  if (signValue < 0) {
    a.alpha = -a.alpha;
  }

  float alpha = clamp(
    a.alpha,
    radians(-15),
    radians(15)
  );

  a.cl = clamp(
    2 * PI * alpha,
    -1.4,
    1.4
  );

  a.cd =
    0.012 +
    0.018 * abs(alpha) +
    0.12 * alpha * alpha;

  float area = chordAt(t) * 4.0;

  float q = 0.5 * airDensity *
    a.speed * a.speed;

  a.liftN = q * area * abs(a.cl);
  a.dragN = q * area * a.cd;

  PVector liftDirection = cross(span, flow);

  liftDirection = norm(liftDirection);

  if (a.cl < 0) {
    liftDirection.mult(-1);
  }

  a.lift = PVector.mult(
    liftDirection,
    a.liftN
  );

  a.drag = PVector.mult(
    norm(a.relative),
    a.dragN
  );

  a.resultant = PVector.add(
    a.lift,
    a.drag
  );

  PVector arm = new PVector(
    a.position.x,
    a.position.y + 50,
    0
  );

  a.torque = cross(arm, a.resultant).z;

  a.pressure = q;

  return a;
}

// ================================================================
// TOTAL FORCE CALCULATION
// ================================================================

void calculateForces() {

  totalTorque = 0;

  selectedLift = 0;
  selectedDrag = 0;
  selectedTorque = 0;
  selectedAlpha = 0;
  selectedRelativeSpeed = 0;

  for (int b = 0; b < 3; b++) {

    for (int s = 0; s < NST; s++) {

      AeroResult a = sectionResult(b, s);

      totalTorque += a.torque / 4.0;

      if (
        b == selectedBlade &&
        s == selectedStation
      ) {

        selectedLift = a.liftN;
        selectedDrag = a.dragN;
        selectedTorque = a.torque;

        selectedAlpha = degrees(a.alpha);

        selectedRelativeSpeed = a.speed;
      }
    }
  }

  mechanicalPower = abs(totalTorque * omega);

  electricalPower = mechanicalPower * 0.90;
}

// ================================================================
// 3D ARROW
// ================================================================

void arrow3D(
  PVector p,
  PVector v,
  float scaleValue,
  color c,
  float weightValue
) {

  if (v.mag() < 0.001) return;

  PVector d = norm(v);

  PVector end = PVector.add(
    p,
    PVector.mult(v, scaleValue)
  );

  stroke(c);
  strokeWeight(weightValue);

  line(
    p.x, p.y, p.z,
    end.x, end.y, end.z
  );

  PVector ref = abs(d.y) < 0.9 ?
    new PVector(0, 1, 0) :
    new PVector(1, 0, 0);

  PVector side = norm(cross(d, ref));

  float h = 7;

  PVector base = PVector.sub(
    end,
    PVector.mult(d, h)
  );

  PVector a = PVector.add(
    base,
    PVector.mult(side, h * 0.4)
  );

  PVector z = PVector.add(
    base,
    PVector.mult(cross(d, side), h * 0.4)
  );

  line(end.x, end.y, end.z, a.x, a.y, a.z);
  line(end.x, end.y, end.z, z.x, z.y, z.z);
}

// ================================================================
// CYLINDER
// ================================================================

void drawCylinder(
  float x, float y, float z,
  float r, float h
) {

  pushMatrix();

  translate(x, y, z);

  noStroke();

  beginShape(QUAD_STRIP);

  for (int i = 0; i <= 32; i++) {

    float a = TWO_PI * i / 32;

    float px = cos(a) * r;
    float pz = sin(a) * r;

    vertex(px, -h / 2, pz);
    vertex(px, h / 2, pz);
  }

  endShape();

  popMatrix();
}

// ================================================================
// GROUND GRID
// ================================================================

void drawGround() {

  stroke(30, 70, 105, 100);
  strokeWeight(1);

  for (int x = -300; x <= 300; x += 40) {
    line(x, 200, -250, x, 200, 250);
  }

  for (int z = -250; z <= 250; z += 40) {
    line(-300, 200, z, 300, 200, z);
  }
}

// ================================================================
// TURBINE
// ================================================================

void drawTurbine() {

  if (rotorType != HAWT) {
    drawAlternativeRotor();
    return;
  }

  pushStyle();

  noStroke();

  fill(130, 160, 185);

  drawCylinder(0, 75, 0, 9, 250);

  fill(165, 185, 205);

  pushMatrix();

  translate(0, -50, 0);

  box(85, 28, 34);

  translate(0, 0, 35);

  fill(235, 245, 255);

  sphereDetail(18);
  sphere(13);

  popMatrix();

  for (int b = 0; b < 3; b++) {

    pushMatrix();

    translate(0, -50, 35);

    rotateZ(bladeRotation(b));

    drawOneBlade(b);

    popMatrix();
  }

  popStyle();
}

// ================================================================
// 3D BLADE MESH
// ================================================================

void drawOneBlade(int b) {

  int ns = 25;
  int nc = 32;

  if (showMesh) {

    for (int sideIndex = 0; sideIndex < 2; sideIndex++) {

      float side = sideIndex == 0 ? 1 : -1;

      for (int i = 0; i < ns - 1; i++) {

        float t0 = map(i, 0, ns - 1, 0.06, 1);
        float t1 = map(i + 1, 0, ns - 1, 0.06, 1);

        for (int j = 0; j < nc - 1; j++) {

          float x0 = map(j, 0, nc - 1, -1, 1);
          float x1 = map(j + 1, 0, nc - 1, -1, 1);

          PVector p1 = localBladePoint(t0, x0, side, b);
          PVector p2 = localBladePoint(t1, x0, side, b);
          PVector p3 = localBladePoint(t1, x1, side, b);
          PVector p4 = localBladePoint(t0, x1, side, b);

          if (showPressure) {

            if (side > 0) {

              float value = map(x0, -1, 1, 0, 1);

              fill(
                lerpColor(
                  color(40, 210, 255),
                  color(30, 255, 125),
                  value
                )
              );

            } else {

              fill(255, 75, 80);
            }

          } else {

            fill(100, 175, 245);
          }

          noStroke();

          beginShape(QUADS);

          vertex(p1.x, p1.y, p1.z);
          vertex(p2.x, p2.y, p2.z);
          vertex(p3.x, p3.y, p3.z);
          vertex(p4.x, p4.y, p4.z);

          endShape();
        }
      }
    }

    stroke(220, 245, 255, 110);
    strokeWeight(0.65);
    noFill();

    for (int i = 0; i < ns; i++) {

      float t = map(i, 0, ns - 1, 0.06, 1);

      beginShape();

      for (int j = 0; j < nc; j++) {

        float x = map(j, 0, nc - 1, -1, 1);

        PVector p = localBladePoint(t, x, 1, b);

        vertex(p.x, p.y, p.z);
      }

      endShape();
    }
  }

  stroke(255, 255, 255, 210);
  strokeWeight(2);

  line(0, 0, 0, 0, -rotorRadius, 0);

  if (b == selectedBlade) {

    stroke(255, 230, 60);
    strokeWeight(3);

    line(
      -chordAt(0.1) / 2,
      -rotorRadius * 0.1,
      2,
      -chordAt(1) / 2,
      -rotorRadius,
      2
    );
  }
}

// ================================================================
// ALTERNATIVE ROTORS
// ================================================================

void drawAlternativeRotor() {

  pushStyle();

  fill(120, 155, 180);

  drawCylinder(0, 0, 0, 8, 270);

  pushMatrix();

  rotateY(rotorAngle);

  for (int b = 0; b < 3; b++) {

    pushMatrix();

    rotateY(TWO_PI * b / 3);

    if (rotorType == SAVONIUS) {

      fill(40, 190, 235);

      translate(32, 0, 0);

      box(38, rotorHeight, 20);

    } else if (rotorType == DARRIEUS) {

      noFill();

      stroke(40, 220, 255);
      strokeWeight(9);

      beginShape();

      for (int i = 0; i <= 40; i++) {

        float t = map(i, 0, 40, -1, 1);

        float r = rotorRadius *
          (0.68 + 0.32 * cos(t * HALF_PI));

        vertex(r, t * rotorHeight / 2, 0);
      }

      endShape();

    } else {

      fill(50, 160, 245);

      translate(rotorRadius, 0, 0);

      box(14, rotorHeight, 17);
    }

    popMatrix();
  }

  popMatrix();

  popStyle();
}

// ================================================================
// FORCE VECTORS
// ================================================================

void drawForces3D() {

  for (int b = 0; b < 3; b++) {

    for (int s = 0; s < NST; s++) {

      // SELECTED MODE:
      // Skip every station except the selected one.
      if (!showAllVectors &&
          (b != selectedBlade ||
           s != selectedStation)) {
        continue;
      }

      AeroResult a = sectionResult(b, s);

      boolean selected =
        b == selectedBlade &&
        s == selectedStation;

      if (selected) {

        stroke(255);
        strokeWeight(9);

        point(
          a.position.x,
          a.position.y,
          a.position.z
        );
      }

      PVector wind = norm(a.wind);

      PVector start = PVector.sub(
        a.position,
        PVector.mult(wind, 38)
      );

      // CYAN = WIND VELOCITY
      arrow3D(start, wind, 38, CYAN, 2);

      // BLUE = BLADE VELOCITY
      arrow3D(
        a.position,
        a.velocity,
        0.8,
        BLUE,
        2
      );

      // YELLOW = RELATIVE VELOCITY
      arrow3D(
        a.position,
        a.relative,
        2,
        YELLOW,
        2
      );

      // GREEN = LIFT
      arrow3D(
        a.position,
        a.lift,
        0.035,
        GREEN,
        2
      );

      // RED = DRAG
      arrow3D(
        a.position,
        a.drag,
        0.035,
        RED,
        2
      );

      // WHITE = RESULTANT FORCE
      arrow3D(
        a.position,
        a.resultant,
        0.035,
        WHITE,
        2
      );
    }
  }
}

// ================================================================
// WIND VECTOR FIELD
// ================================================================

void drawWindField() {

  for (int x = -210; x <= 210; x += 65) {

    for (int y = -150; y <= 150; y += 65) {

      for (int z = -150; z <= 150; z += 65) {

        PVector p = new PVector(x, y, z);

        PVector v = norm(windAt(x, y, z));

        arrow3D(
          p, v, 19,
          color(40, 145, 230, 170),
          1
        );
      }
    }
  }
}

// ================================================================
// WIND STREAMLINES
// ================================================================

void drawWindLines() {

  pushStyle();

  stroke(40, 210, 255, 120);
  strokeWeight(1.5);

  noFill();

  for (int x = -160; x <= 160; x += 45) {

    for (int y = -130; y <= 130; y += 45) {

      beginShape();

      for (int z = -220; z <= 220; z += 8) {

        float xx = x + 4 * sin(z * 0.02 + timeValue);

        float yy = y + 6 * sin(
          z * 0.018 + timeValue + x * 0.02
        );

        vertex(xx, yy, z);
      }

      endShape();
    }
  }

  popStyle();
}

// ================================================================
// WAKE
// ================================================================

void drawWake() {

  pushStyle();

  noFill();

  stroke(50, 170, 255, 70);

  for (int z = 30; z <= 230; z += 30) {

    pushMatrix();

    translate(0, 0, z);

    ellipse(
      0, 0,
      100 + z * 0.45,
      90 + z * 0.35
    );

    popMatrix();
  }

  popStyle();
}

// ================================================================
// HUD
// ================================================================

void beginHUD() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
}

void endHUD() {
  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// TOP BAR
// ================================================================

void drawTopBar(String heading) {

  beginHUD();

  noStroke();

  fill(3, 10, 27, 245);

  rect(0, 0, width, 53);

  fill(CYAN);

  textFont(fLarge);

  textAlign(LEFT, TOP);

  text(heading, 15, 7);

  fill(255);

  textFont(fSmall);

  text(
    "WIND " + nf(windSpeed, 1, 1) + " m/s" +
    "   RPM " + nf(rpm(), 1, 1) +
    "   OUTPUT " + nf(electricalPower / 1000, 1, 2) + " kW",
    17, 34
  );

  endHUD();
}

// ================================================================
// SLIDER
// ================================================================

void drawUITrack(
  float x,
  float y,
  float w,
  float value,
  float minV,
  float maxV
) {

  stroke(80, 130, 175);
  strokeWeight(5);

  line(x, y, x + w, y);

  float t = map(
    constrain(value, minV, maxV),
    minV, maxV,
    0, 1
  );

  float px = x + t * w;

  stroke(CYAN);
  strokeWeight(4);

  line(x, y, px, y);

  noStroke();

  fill(255, 220, 65);

  ellipse(px, y, 13, 13);
}

// ================================================================
// AIRFOIL PANEL
// ================================================================

void drawJoukowskiPanel(
  float ox,
  float oy,
  float sc
) {

  pushStyle();

  noStroke();

  fill(5, 25, 48, 245);

  rect(
    ox - sc - 12,
    oy - sc * 0.52 - 18,
    sc * 2 + 24,
    sc * 1.15 + 36,
    10
  );

  stroke(120, 160, 190, 110);

  line(ox - sc, oy, ox + sc, oy);

  noStroke();

  fill(30, 140, 225, 120);

  beginShape();

  for (int i = 0; i <= 100; i++) {

    float x = map(i, 0, 100, -1, 1);

    float yt = thicknessAt(x, airfoilThickness);
    float yc = camberAt(x, airfoilCamber);

    float a = radians(airfoilAngle);

    float xx = x * cos(a) - (yc + yt) * sin(a);
    float yy = x * sin(a) + (yc + yt) * cos(a);

    vertex(ox + xx * sc, oy - yy * sc);
  }

  for (int i = 100; i >= 0; i--) {

    float x = map(i, 0, 100, -1, 1);

    float yt = thicknessAt(x, airfoilThickness);
    float yc = camberAt(x, airfoilCamber);

    float a = radians(airfoilAngle);

    float xx = x * cos(a) - (yc - yt) * sin(a);
    float yy = x * sin(a) + (yc - yt) * cos(a);

    vertex(ox + xx * sc, oy - yy * sc);
  }

  endShape(CLOSE);

  stroke(30, 255, 160);
  strokeWeight(2);
  noFill();

  beginShape();

  for (int i = 0; i <= 100; i++) {

    float x = map(i, 0, 100, -1, 1);

    float yt = thicknessAt(x, airfoilThickness);
    float yc = camberAt(x, airfoilCamber);

    float a = radians(airfoilAngle);

    float xx = x * cos(a) - (yc + yt) * sin(a);
    float yy = x * sin(a) + (yc + yt) * cos(a);

    vertex(ox + xx * sc, oy - yy * sc);
  }

  endShape();

  stroke(255, 85, 95);

  beginShape();

  for (int i = 100; i >= 0; i--) {

    float x = map(i, 0, 100, -1, 1);

    float yt = thicknessAt(x, airfoilThickness);
    float yc = camberAt(x, airfoilCamber);

    float a = radians(airfoilAngle);

    float xx = x * cos(a) - (yc - yt) * sin(a);
    float yy = x * sin(a) + (yc - yt) * cos(a);

    vertex(ox + xx * sc, oy - yy * sc);
  }

  endShape();

  fill(255);

  textFont(fSmall);
  textAlign(CENTER);

  text("LIVE BLADE SECTION", ox, oy + sc * 0.72);

  textAlign(LEFT, TOP);

  popStyle();
}

// ================================================================
// SCREEN 1
// ================================================================

void drawScreen1() {

  lights();

  ambientLight(65, 75, 105);

  directionalLight(
    240, 245, 255,
    -0.5, 0.5, -1
  );

  pushMatrix();

  translate(width * 0.34, height * 0.49, 0);

  rotateX(cameraPitch);
  rotateY(cameraYaw);

  scale(zoomScale);

  drawGround();

  if (showWake) drawWake();

  if (showField) drawWindField();

  if (showStreamlines) drawWindLines();

  drawTurbine();

  if (showForces) drawForces3D();

  popMatrix();

  drawTopBar(
    "3D THREE-BLADE WIND TURBINE AERODYNAMICS"
  );

  drawBladeControlPanel();

  // NEW BUTTONS
  drawVectorToggleButtons();

  drawNavigation();
}

// ================================================================
// NEW: SELECTED / ALL VECTOR TOGGLE BUTTONS
// ================================================================

float vectorButtonY() {
  return height - 121;
}

float vectorButtonWidth() {
  return min(190, width * 0.22);
}

float vectorButtonHeight() {
  return 34;
}

float selectedButtonX() {
  return width * 0.17;
}

float allButtonX() {
  return selectedButtonX() +
    vectorButtonWidth() + 15;
}

void drawVectorToggleButtons() {

  beginHUD();

  float y = vectorButtonY();

  float w = vectorButtonWidth();
  float h = vectorButtonHeight();

  // SELECTED VECTORS BUTTON

  boolean selectedActive = !showAllVectors;

  fill(
    selectedActive ?
    color(10, 150, 105) :
    color(18, 38, 65)
  );

  stroke(
    selectedActive ? GREEN : CYAN
  );

  strokeWeight(2);

  rect(
    selectedButtonX(),
    y,
    w,
    h,
    8
  );

  fill(255);

  textFont(fMedium);

  textAlign(CENTER, CENTER);

  text(
    selectedActive ?
    "✓ SELECTED VECTORS" :
    "SELECTED VECTORS",
    selectedButtonX() + w / 2,
    y + h / 2
  );

  // ALL VECTORS BUTTON

  boolean allActive = showAllVectors;

  fill(
    allActive ?
    color(15, 115, 165) :
    color(18, 38, 65)
  );

  stroke(
    allActive ? YELLOW : CYAN
  );

  strokeWeight(2);

  rect(
    allButtonX(),
    y,
    w,
    h,
    8
  );

  fill(255);

  text(
    allActive ?
    "✓ ALL VECTORS" :
    "ALL VECTORS",
    allButtonX() + w / 2,
    y + h / 2
  );

  // DISPLAY STATUS

  fill(CYAN);

  textFont(fSmall);

  textAlign(LEFT, CENTER);

  String status = showAllVectors ?
    "12 STATIONS ACTIVE" :
    "1 STATION ACTIVE";

  text(
    status,
    allButtonX() + w + 12,
    y + h / 2
  );

  textAlign(LEFT, TOP);

  endHUD();
}

// ================================================================
// NEW: VECTOR BUTTON TOUCH DETECTION
// ================================================================

boolean handleVectorToggleClick() {

  if (screenMode != SCREEN1) {
    return false;
  }

  float y = vectorButtonY();

  float w = vectorButtonWidth();
  float h = vectorButtonHeight();

  // SELECTED VECTORS

  if (
    mouseX >= selectedButtonX() &&
    mouseX <= selectedButtonX() + w &&
    mouseY >= y &&
    mouseY <= y + h
  ) {

    showAllVectors = false;

    showForces = true;

    return true;
  }

  // ALL VECTORS

  if (
    mouseX >= allButtonX() &&
    mouseX <= allButtonX() + w &&
    mouseY >= y &&
    mouseY <= y + h
  ) {

    showAllVectors = true;

    showForces = true;

    return true;
  }

  return false;
}

// ================================================================
// SCREEN 1 CONTROL PANEL
// ================================================================

void drawBladeControlPanel() {

  beginHUD();

  float x = width * 0.68;
  float y = 62;
  float w = width * 0.30;

  fill(4, 14, 36, 245);

  noStroke();

  rect(x, y, w, height - 155, 12);

  fill(CYAN);

  textFont(fMedium);

  text("BLADE AERODYNAMIC CONTROL", x + 12, y + 24);

  textFont(fSmall);

  fill(255);

  text(
    "SELECTED BLADE: " + (selectedBlade + 1),
    x + 12, y + 48
  );

  for (int b = 0; b < 3; b++) {

    float sy = y + 82 + b * 45;

    fill(b == selectedBlade ? YELLOW : CYAN);

    text(
      "BLADE " + (b + 1) + " PITCH",
      x + 12, sy
    );

    drawUITrack(
      x + 12, sy + 15, w - 24,
      bladePitch[b],
      -15, 15
    );

    fill(255);

    text(
      nf(bladePitch[b], 1, 1) + " deg",
      x + w - 75, sy
    );
  }

  float sy = y + 225;

  fill(CYAN);

  text("RADIAL BLADE SECTION", x + 12, sy);

  for (int s = 0; s < 4; s++) {

    float bx = x + 12 + s * 58;

    fill(
      selectedStation == s ?
      color(150, 90, 10) :
      color(20, 55, 85)
    );

    stroke(90, 210, 240);

    rect(bx, sy + 12, 49, 30, 5);

    fill(255);

    text(
      "S" + (s + 1),
      bx + 18, sy + 32
    );
  }

  float t = stationFraction[selectedStation];

  float sectionY = y + 285;

  fill(CYAN);

  text("SELECTED SECTION GEOMETRY", x + 12, sectionY);

  fill(255);

  text(
    "Radial position: " + nf(t * 100, 1, 0) + "%",
    x + 12, sectionY + 22
  );

  text(
    "Chord: " + nf(chordAt(t), 1, 2) + " units",
    x + 12, sectionY + 42
  );

  text(
    "Blade twist: " + nf(degrees(twistAt(t)), 1, 2) + " deg",
    x + 12, sectionY + 62
  );

  text(
    "Pitch: " + nf(bladePitch[selectedBlade] +
    degrees(twistAt(t)), 1, 2) + " deg",
    x + 12, sectionY + 82
  );

  float cx = x + w * 0.48;
  float cy = y + 420;

  float sc = min(w * 0.30, 75);

  drawJoukowskiPanel(cx, cy, sc);

  float iy = y + 510;

  fill(CYAN);

  text("AERODYNAMIC PROPERTIES", x + 12, iy);

  fill(255);

  text(
    "Relative velocity: " +
    nf(selectedRelativeSpeed, 1, 2) + " m/s",
    x + 12, iy + 22
  );

  text(
    "Angle of attack: " +
    nf(selectedAlpha, 1, 2) + " deg",
    x + 12, iy + 42
  );

  fill(GREEN);

  text(
    "Lift: " + nf(selectedLift, 1, 2) + " N",
    x + 12, iy + 64
  );

  fill(RED);

  text(
    "Drag: " + nf(selectedDrag, 1, 2) + " N",
    x + 12, iy + 84
  );

  fill(255);

  text(
    "Section torque: " + nf(selectedTorque, 1, 2) + " Nm",
    x + 12, iy + 106
  );

  text(
    "Rotor torque: " + nf(totalTorque, 1, 2) + " Nm",
    x + 12, iy + 128
  );

  text(
    "Mechanical power: " +
    nf(mechanicalPower / 1000, 1, 3) + " kW",
    x + 12, iy + 150
  );

  endHUD();
}

// ================================================================
// SCREEN 2 - TAMIL NADU WIND LAB
// ================================================================

void drawScreen2() {

  beginHUD();

  background(4, 12, 30);

  drawTopBar("TAMIL NADU WIND + BATTERY LAB");

  float x = 20;
  float y = 70;

  fill(5, 22, 48);

  noStroke();

  rect(x, y, width - 40, height - 170, 12);

  fill(CYAN);

  textFont(fMedium);

  text("SELECT WIND REGION", x + 15, y + 25);

  textFont(fSmall);

  for (int i = 0; i < regions.length; i++) {

    int col = i % 2;
    int row = i / 2;

    float bx = x + 15 + col * width * 0.24;
    float by = y + 45 + row * 31;

    fill(
      selectedRegion == i ?
      color(10, 115, 100) :
      color(20, 48, 75)
    );

    stroke(70, 180, 220);

    rect(bx, by, width * 0.22, 26, 5);

    fill(255);

    text(regions[i], bx + 6, by + 18);
  }

  float px = width * 0.54;
  float py = y + 65;

  fill(CYAN);

  textFont(fMedium);

  text("WIND RESOURCE", px, py);

  fill(255);

  textFont(fSmall);

  text(
    "Wind speed: " + nf(windSpeed, 1, 2) + " m/s",
    px, py + 30
  );

  drawUITrack(
    px, py + 48, width * 0.34,
    windSpeed, 0, 25
  );

  float area = PI * sq(physicalRadius);

  float windPower =
    0.5 * airDensity * area * pow(windSpeed, 3);

  float output = windPower * 0.35 * 0.90;

  fill(GREEN);

  text("ESTIMATED POWER", px, py + 100);

  fill(255);

  text(
    "Wind power: " + nf(windPower / 1000, 1, 2) + " kW",
    px, py + 125
  );

  text(
    "Electrical: " + nf(output / 1000, 1, 2) + " kW",
    px, py + 150
  );

  fill(CYAN);

  text("BATTERY STORAGE", px, py + 205);

  fill(255);

  text(
    "Capacity: " + nf(batteryCapacity, 1, 1) + " kWh",
    px, py + 230
  );

  text(
    "SOC: " + nf(batterySOC, 1, 1) + "%",
    px, py + 255
  );

  drawUITrack(
    px, py + 280, width * 0.34,
    batteryCapacity, 1, 100
  );

  drawUITrack(
    px, py + 310, width * 0.34,
    batterySOC, 0, 100
  );

  float stored = batteryCapacity * batterySOC / 100;

  float remaining = batteryCapacity - stored;

  float charging = output * 0.90 / 1000;

  text(
    "Stored energy: " + nf(stored, 1, 2) + " kWh",
    px, py + 345
  );

  text(
    "Energy remaining: " + nf(remaining, 1, 2) + " kWh",
    px, py + 370
  );

  text(
    "Ideal charging time: " +
    (charging > 0.01 ?
    nf(remaining / charging, 1, 2) + " hours" :
    "No charging"),
    px, py + 395
  );

  fill(120, 190, 220);

  text(
    "Regional values are illustrative presets, not measured site data.",
    x + 15, height - 180
  );

  drawNavigation();

  endHUD();
}

// ================================================================
// SCREEN 3 - AIRFOIL LAB
// ================================================================

void drawScreen3() {

  beginHUD();

  background(3, 10, 28);

  drawTopBar("AIRFOIL PROFILE + FLOW LABORATORY");

  fill(5, 20, 45);

  noStroke();

  rect(15, 65, width - 30, height - 170, 12);

  float x = 35;
  float y = 105;

  fill(CYAN);

  textFont(fMedium);

  text("AIRFOIL PARAMETERS", x, y);

  fill(255);

  textFont(fSmall);

  text(
    "Camber: " + nf(airfoilCamber, 1, 3),
    x, y + 40
  );

  drawUITrack(
    x, y + 55, 230,
    airfoilCamber, 0, 0.25
  );

  text(
    "Thickness: " + nf(airfoilThickness, 1, 3),
    x, y + 100
  );

  drawUITrack(
    x, y + 115, 230,
    airfoilThickness, 0.04, 0.22
  );

  text(
    "Angle of attack: " + nf(airfoilAngle, 1, 1),
    x, y + 160
  );

  drawUITrack(
    x, y + 175, 230,
    airfoilAngle, -15, 15
  );

  float ox = width * 0.56;
  float oy = height * 0.48;

  drawAirfoilFlow(ox, oy, 150);

  drawJoukowskiPanel(ox, oy, 120);

  fill(GREEN);

  text("GREEN = SUCTION SIDE", width * 0.79, 150);

  fill(RED);

  text("RED = PRESSURE SIDE", width * 0.79, 180);

  fill(CYAN);

  text("PROFILE MODEL", width * 0.79, 230);

  fill(255);

  text("NACA-style thickness", width * 0.79, 260);

  text("Simplified camber function", width * 0.79, 285);

  text("Not a true Joukowski mapping", width * 0.79, 310);

  drawNavigation();

  endHUD();
}

// ================================================================
// AIRFOIL STREAMLINES
// ================================================================

void drawAirfoilFlow(
  float ox,
  float oy,
  float sc
) {

  pushStyle();

  stroke(35, 190, 255, 120);
  strokeWeight(1.5);
  noFill();

  for (int row = -7; row <= 7; row++) {

    float base = row * 17;

    beginShape();

    for (int i = 0; i <= 100; i++) {

      float x = map(i, 0, 100, -sc * 1.8, sc * 1.8);

      float bend =
        base +
        sin(x / sc * PI + timeValue) * 25 *
        exp(-sq(x / (sc * 0.8)));

      vertex(ox + x, oy - bend);
    }

    endShape();

    float phase = (timeValue * 55 + row * 30) % 240;

    float px = map(
      phase, 0, 240,
      -sc * 1.8, sc * 1.8
    );

    float py = base +
      sin(px / sc * PI + timeValue) * 25 *
      exp(-sq(px / (sc * 0.8)));

    noStroke();

    fill(80, 240, 255);

    ellipse(ox + px, oy - py, 5, 5);

    stroke(35, 190, 255, 120);

    noFill();
  }

  popStyle();
}

// ================================================================
// NAVIGATION BUTTONS
// ================================================================

void drawNavigation() {

  beginHUD();

  float y = height - 75;

  float gap = 8;

  float w = (width - 40 - 2 * gap) / 3;

  String[] labels = {
    "1 TURBINE",
    "2 TAMIL NADU",
    "3 AIRFOIL LAB"
  };

  for (int i = 0; i < 3; i++) {

    fill(
      screenMode == i ?
      color(10, 115, 105) :
      color(20, 45, 75)
    );

    stroke(80, 190, 220);

    rect(
      15 + i * (w + gap),
      y, w, 36, 6
    );

    fill(255);

    textAlign(CENTER, CENTER);

    textFont(fSmall);

    text(
      labels[i],
      15 + i * (w + gap) + w / 2,
      y + 18
    );
  }

  textAlign(LEFT, TOP);

  endHUD();
}

// ================================================================
// MOUSE PRESS
// ================================================================

void mousePressed() {

  // NAVIGATION BUTTONS
  float navY = height - 75;

  if (
    mouseY >= navY &&
    mouseY <= navY + 38
  ) {

    float gap = 8;

    float w = (width - 40 - 2 * gap) / 3;

    int i = floor(
      (mouseX - 15) / (w + gap)
    );

    if (i >= 0 && i < 3) {
      screenMode = i;
    }

    return;
  }

  // NEW VECTOR BUTTONS
  if (handleVectorToggleClick()) {
    return;
  }

  if (screenMode == SCREEN1) {
    handleScreen1Click();
  } else if (screenMode == SCREEN2) {
    handleScreen2Click();
  } else {
    handleScreen3Click();
  }
}

// ================================================================
// SCREEN 1 CLICK
// ================================================================

void handleScreen1Click() {

  float x = width * 0.68;
  float y = 62;
  float w = width * 0.30;

  for (int b = 0; b < 3; b++) {

    float sy = y + 97 + b * 45;

    if (
      mouseY >= sy - 10 &&
      mouseY <= sy + 10 &&
      mouseX >= x + 12 &&
      mouseX <= x + w - 12
    ) {

      selectedBlade = b;

      activeSlider = b;

      draggingSlider = true;

      updateBladeSlider(mouseX);

      return;
    }
  }

  float sy = y + 225;

  for (int s = 0; s < 4; s++) {

    float bx = x + 12 + s * 58;

    if (
      mouseX >= bx &&
      mouseX <= bx + 49 &&
      mouseY >= sy + 12 &&
      mouseY <= sy + 42
    ) {

      selectedStation = s;

      return;
    }
  }

  if (mouseX < x) {
    draggingCamera = true;
  }
}

// ================================================================
// UPDATE BLADE SLIDER
// ================================================================

void updateBladeSlider(float mx) {

  if (activeSlider < 0 || activeSlider >= 3) {
    return;
  }

  float x = width * 0.68 + 12;

  float w = width * 0.30 - 24;

  bladePitch[activeSlider] = map(
    constrain(mx, x, x + w),
    x, x + w,
    -15, 15
  );
}

// ================================================================
// SCREEN 2 CLICK
// ================================================================

void handleScreen2Click() {

  float x = 20;
  float y = 70;

  for (int i = 0; i < regions.length; i++) {

    int col = i % 2;
    int row = i / 2;

    float bx = x + 15 + col * width * 0.24;

    float by = y + 45 + row * 31;

    if (
      mouseX >= bx &&
      mouseX <= bx + width * 0.22 &&
      mouseY >= by &&
      mouseY <= by + 26
    ) {

      selectedRegion = i;

      windSpeed = regionWind[i];

      return;
    }
  }

  float px = width * 0.54;

  float py = y + 65;

  if (mouseY >= py + 38 && mouseY <= py + 60) {

    windSpeed = map(
      constrain(mouseX, px, px + width * 0.34),
      px, px + width * 0.34,
      0, 25
    );

  } else if (mouseY >= py + 270 && mouseY <= py + 290) {

    batteryCapacity = map(
      constrain(mouseX, px, px + width * 0.34),
      px, px + width * 0.34,
      1, 100
    );

  } else if (mouseY >= py + 300 && mouseY <= py + 320) {

    batterySOC = map(
      constrain(mouseX, px, px + width * 0.34),
      px, px + width * 0.34,
      0, 100
    );
  }
}

// ================================================================
// SCREEN 3 CLICK
// ================================================================

void handleScreen3Click() {

  float x = 35;
  float y = 105;

  if (mouseY >= y + 45 && mouseY <= y + 65) {

    airfoilCamber = map(
      constrain(mouseX, x, x + 230),
      x, x + 230,
      0, 0.25
    );

  } else if (mouseY >= y + 105 && mouseY <= y + 125) {

    airfoilThickness = map(
      constrain(mouseX, x, x + 230),
      x, x + 230,
      0.04, 0.22
    );

  } else if (mouseY >= y + 165 && mouseY <= y + 185) {

    airfoilAngle = map(
      constrain(mouseX, x, x + 230),
      x, x + 230,
      -15, 15
    );
  }
}

// ================================================================
// MOUSE DRAG
// ================================================================

void mouseDragged() {

  if (draggingCamera) {

    cameraYaw += (mouseX - pmouseX) * 0.008;

    cameraPitch = constrain(
      cameraPitch + (mouseY - pmouseY) * 0.006,
      -1.1, 1.1
    );
  }

  if (draggingSlider) {
    updateBladeSlider(mouseX);
  }

  if (screenMode == SCREEN3) {
    handleScreen3Drag();
  }

  if (screenMode == SCREEN2) {
    handleScreen2Drag();
  }
}

// ================================================================
// SCREEN 3 SLIDER DRAG
// ================================================================

void handleScreen3Drag() {

  float x = 35;
  float y = 105;

  if (mouseY >= y + 45 && mouseY <= y + 65) {

    airfoilCamber = map(
      constrain(mouseX, x, x + 230),
      x, x + 230,
      0, 0.25
    );
  }

  if (mouseY >= y + 105 && mouseY <= y + 125) {

    airfoilThickness = map(
      constrain(mouseX, x, x + 230),
      x, x + 230,
      0.04, 0.22
    );
  }

  if (mouseY >= y + 165 && mouseY <= y + 185) {

    airfoilAngle = map(
      constrain(mouseX, x, x + 230),
      x, x + 230,
      -15, 15
    );
  }
}

// ================================================================
// SCREEN 2 SLIDER DRAG
// ================================================================

void handleScreen2Drag() {

  float px = width * 0.54;

  float py = 135;

  if (mouseY >= py + 38 && mouseY <= py + 60) {

    windSpeed = map(
      constrain(mouseX, px, px + width * 0.34),
      px, px + width * 0.34,
      0, 25
    );
  }

  if (mouseY >= py + 270 && mouseY <= py + 290) {

    batteryCapacity = map(
      constrain(mouseX, px, px + width * 0.34),
      px, px + width * 0.34,
      1, 100
    );
  }

  if (mouseY >= py + 300 && mouseY <= py + 320) {

    batterySOC = map(
      constrain(mouseX, px, px + width * 0.34),
      px, px + width * 0.34,
      0, 100
    );
  }
}

// ================================================================
// MOUSE RELEASE
// ================================================================

void mouseReleased() {

  draggingCamera = false;

  draggingSlider = false;

  activeSlider = -1;
}

// ================================================================
// KEYBOARD CONTROLS
// ================================================================

void keyPressed() {

  if (key == '1') rotorType = HAWT;
  if (key == '2') rotorType = SAVONIUS;
  if (key == '3') rotorType = DARRIEUS;
  if (key == '4') rotorType = GIROMILL;

  if (key == ' ') {
    running = !running;
  }

  if (key == 'x' || key == 'X') {
    brake = !brake;
  }

  if (key == 'f' || key == 'F') {
    showForces = !showForces;
  }

  if (key == 'v' || key == 'V') {
    showField = !showField;
  }

  if (key == 'm' || key == 'M') {
    showMesh = !showMesh;
  }

  if (key == 'p' || key == 'P') {
    showPressure = !showPressure;
  }

  if (key == 'l' || key == 'L') {
    showStreamlines = !showStreamlines;
  }

  if (key == 'w' || key == 'W') {
    showWake = !showWake;
  }

  // A KEY: SWITCH VECTOR MODE
  if (key == 'a' || key == 'A') {

    showAllVectors = !showAllVectors;

    showForces = true;
  }

  if (key == 'b' || key == 'B') {
    selectedBlade = (selectedBlade + 1) % 3;
  }

  if (key == 's' || key == 'S') {
    selectedStation = (selectedStation + 1) % 4;
  }

  if (key == 'q' || key == 'Q') {
    screenMode = (screenMode + 1) % 3;
  }

  if (key == '+' || key == '=') {

    zoomScale = constrain(
      zoomScale * 1.1,
      0.45, 2.2
    );

    windSpeed = min(25, windSpeed + 0.5);
  }

  if (key == '-') {

    zoomScale = constrain(
      zoomScale / 1.1,
      0.45, 2.2
    );

    windSpeed = max(0, windSpeed - 0.5);
  }

  if (keyCode == LEFT) {
    windDirection = (windDirection + 345) % 360;
  }

  if (keyCode == RIGHT) {
    windDirection = (windDirection + 15) % 360;
  }

  if (key == 'r' || key == 'R') {

    cameraYaw = -0.35;

    cameraPitch = -0.20;

    zoomScale = 1;
  }

  if (key == '[') {

    bladePitch[selectedBlade] = max(
      -15,
      bladePitch[selectedBlade] - 1
    );
  }

  if (key == ']') {

    bladePitch[selectedBlade] = min(
      15,
      bladePitch[selectedBlade] + 1
    );
  }
}

// ================================================================
// END OF COMPLETE WIND POWER PLANT SIMULATOR
// ================================================================
