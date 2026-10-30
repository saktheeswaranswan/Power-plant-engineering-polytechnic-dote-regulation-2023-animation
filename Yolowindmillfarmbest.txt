
/*
================================================================
 ADVANCED 3D WIND FARM INSPECTION AND MAINTENANCE SIMULATOR
 PROCESSING ANDROID MODE / APDE
 P3D - SINGLE FILE EDUCATIONAL APPLICATION

 ADVANCED COURSE - SPOILER ALERT

 MODULES:
 01. Introduction
 02. Wind farm 3D grid
 03. HAWT / VAWT inspection
 04. Drone systems
 05. Drone flight routes
 06. Human inspection
 07. Blade defects
 08. Synthetic crack generator
 09. YOLO computer vision
 10. Defect classification
 11. Gearbox and bearing faults
 12. Generator and electrical faults
 13. Tower and foundation faults
 14. Brake and yaw faults
 15. Vibration and thermal inspection
 16. Preventive maintenance
 17. Corrective maintenance
 18. Fault diagnosis and remedies
 19. Predictive maintenance
 20. Complete inspection mission

 NOTE:
 YOLO detections in this sketch are synthetic educational
 detections. Actual inference requires a trained YOLO model.
================================================================
*/

int page = 0;
int totalPages = 20;

int turbineMode = 0;   // 0 HAWT, 1 VAWT
int selectedTurbine = 0;

boolean running = true;
boolean droneActive = false;
boolean humanActive = false;
boolean yoloActive = false;
boolean showLabels = true;
boolean showDefects = true;
boolean missionComplete = false;

float rotorAngle = 0;
float windSpeed = 12;
float animationSpeed = 1;

float cameraRotation = 0;
float cameraTilt = -0.20;

float droneX = -260;
float droneY = -90;
float droneZ = 0;

float droneTargetX = 0;
float droneTargetY = -100;
float droneTargetZ = 0;

float humanX = 0;
float humanY = 100;
float humanZ = 0;

float windOffset = 0;
float detectionPulse = 0;

int droneWaypoint = 0;
int inspectionCount = 0;
int detectedCount = 0;
int repairedCount = 0;

int defectCount = 8;
int maxDefects = 30;

float[] defectX = new float[30];
float[] defectY = new float[30];
float[] defectZ = new float[30];

int[] defectType = new int[30];
int[] defectSeverity = new int[30];
boolean[] defectDetected = new boolean[30];
boolean[] defectRepaired = new boolean[30];

float[] turbineHealth = new float[9];

String[] faultNames = {
  "SURFACE CRACK",
  "LEADING EDGE EROSION",
  "DELAMINATION",
  "LIGHTNING DAMAGE",
  "IMPACT DAMAGE",
  "COATING FAILURE",
  "BLADE DEFORMATION",
  "BOLT LOOSENING",
  "BEARING OVERHEATING",
  "GEARBOX VIBRATION",
  "OIL LEAKAGE",
  "GENERATOR OVERHEATING",
  "INSULATION FAILURE",
  "TOWER CORROSION",
  "FOUNDATION CRACK",
  "BRAKE FAILURE",
  "YAW MISALIGNMENT",
  "HYDRAULIC LEAKAGE"
};

String[] severityNames = {
  "LOW",
  "MEDIUM",
  "HIGH",
  "CRITICAL"
};

String[] pageTitles = {
  "ADVANCED INSPECTION INTRODUCTION",
  "WIND FARM 3D GRID",
  "HAWT AND VAWT INSPECTION",
  "DRONE INSPECTION SYSTEM",
  "DRONE FLIGHT ROUTES",
  "HUMAN INSPECTION PROCEDURES",
  "WIND TURBINE BLADE DEFECTS",
  "SYNTHETIC CRACK GENERATION",
  "YOLO COMPUTER VISION",
  "DEFECT CLASSIFICATION",
  "GEARBOX AND BEARING FAULTS",
  "GENERATOR AND ELECTRICAL FAULTS",
  "TOWER AND FOUNDATION FAULTS",
  "BRAKE AND YAW FAULTS",
  "VIBRATION AND THERMAL INSPECTION",
  "PREVENTIVE MAINTENANCE",
  "CORRECTIVE MAINTENANCE",
  "FAULT DIAGNOSIS AND REMEDIES",
  "PREDICTIVE MAINTENANCE",
  "COMPLETE INSPECTION MISSION"
};

String[][] pageText = {

 {
  "Wind turbines require regular inspection.",
  "Inspection prevents unexpected failures.",
  "Drones improve accessibility and image collection.",
  "Human inspectors perform detailed assessment.",
  "Computer vision assists defect identification."
 },

 {
  "Wind farm consists of multiple turbines.",
  "Every turbine receives a unique identification.",
  "GPS coordinates define turbine locations.",
  "Drone routes cover the complete wind farm.",
  "Inspection records are stored turbine-wise."
 },

 {
  "Inspect blades, hub and nacelle.",
  "Check tower, foundation and fasteners.",
  "Inspect gearbox, generator and bearings.",
  "Check yaw, pitch and brake systems.",
  "Compare actual condition with baseline data."
 },

 {
  "Drone: multirotor or fixed-wing platform.",
  "Camera: RGB, zoom and thermal imaging.",
  "GPS: position and waypoint navigation.",
  "IMU: orientation and motion measurement.",
  "Battery and communication monitoring."
 },

 {
  "1. Establish a safe launch area.",
  "2. Check weather and wind conditions.",
  "3. Plan turbine inspection waypoints.",
  "4. Capture blade root, middle and tip.",
  "5. Inspect leading and trailing edges.",
  "6. Return home and review image data."
 },

 {
  "Human inspection uses visual examination.",
  "Rope access may be used by trained personnel.",
  "Ultrasonic testing identifies internal flaws.",
  "Thermography detects abnormal heat patterns.",
  "Tap testing can identify some delamination.",
  "Borescope inspects inaccessible internal areas."
 },

 {
  "Surface cracks: fatigue or stress concentration.",
  "Erosion: rain, sand and airborne particles.",
  "Delamination: separation between laminate layers.",
  "Lightning: localized thermal and electrical damage.",
  "Impact: birds, debris and foreign objects.",
  "Coating failure: UV exposure and ageing."
 },

 {
  "Synthetic cracks are generated for training.",
  "Crack length: 10 to 200 mm in this model.",
  "Crack width: 0.2 to 5 mm in this model.",
  "Severity: low, medium, high or critical.",
  "Location: blade root, middle or tip.",
  "These are simulation values, not acceptance limits."
 },

 {
  "YOLO detects objects in image frames.",
  "Model predicts bounding box coordinates.",
  "Class identifies the suspected defect.",
  "Confidence represents model prediction score.",
  "NMS removes overlapping predictions.",
  "Real inference requires trained model weights."
 },

 {
  "Classify defect type and location.",
  "Record image and turbine identification.",
  "Assess extent and progression.",
  "Compare with manufacturer acceptance criteria.",
  "Escalate serious defects for engineering review."
 },

 {
  "Gearbox vibration can indicate gear damage.",
  "Bearing faults create characteristic vibration.",
  "Oil leakage reduces lubrication reliability.",
  "Inspect oil quality and temperature.",
  "Use vibration analysis and oil analysis.",
  "Repair only under approved maintenance procedures."
 },

 {
  "Generator overheating can indicate overload.",
  "Insulation failure may cause electrical faults.",
  "Inspect winding temperature and insulation.",
  "Check terminal connections and cooling.",
  "Use electrical tests by qualified personnel.",
  "Isolate equipment before electrical maintenance."
 },

 {
  "Inspect tower corrosion and coating.",
  "Check welded joints and bolt connections.",
  "Inspect foundation concrete for cracking.",
  "Check drainage and settlement.",
  "Use suitable NDT for structural assessment."
 },

 {
  "Brake faults can prevent safe stopping.",
  "Yaw errors cause rotor misalignment.",
  "Inspect brake wear and hydraulic pressure.",
  "Check yaw motors and drive components.",
  "Use approved shutdown and maintenance procedures."
 },

 {
  "Accelerometers measure machine vibration.",
  "Thermal cameras reveal heat anomalies.",
  "Trend data instead of relying on one reading.",
  "Compare with baseline operating conditions.",
  "Use calibrated instruments and qualified analysis."
 },

 {
  "Follow manufacturer maintenance schedules.",
  "Inspect blades at defined intervals.",
  "Monitor oil, bearings and vibration.",
  "Check electrical connections and cooling.",
  "Record every inspection and maintenance action."
 },

 {
  "Identify and confirm the fault.",
  "Isolate the affected equipment.",
  "Assess risk and repair requirements.",
  "Replace or repair approved components.",
  "Perform post-maintenance testing.",
  "Document the work and release authorization."
 },

 {
  "Crack: assess structural significance.",
  "Erosion: approved protective surface repair.",
  "Delamination: engineering assessment and repair.",
  "Bearing fault: replace if confirmed necessary.",
  "Oil leakage: identify seal or connection failure.",
  "Electrical fault: isolate and test safely."
 },

 {
  "Combine inspection and condition-monitoring data.",
  "Track defect growth over time.",
  "Estimate maintenance priority.",
  "Plan intervention before functional failure.",
  "Never use prediction alone to certify safety."
 },

 {
  "Select turbine in the wind farm.",
  "Launch drone inspection mission.",
  "Capture synthetic blade images.",
  "Run educational YOLO detections.",
  "Assign severity and maintenance priority.",
  "Review human inspection and repair status.",
  "Generate final inspection summary."
 }
};

// ================================================================
// INITIALIZATION
// ================================================================

void settings() {
  fullScreen(P3D);
}

void setup() {

  orientation(LANDSCAPE);

  frameRate(40);
  smooth(4);

  textAlign(LEFT, TOP);

  for (int i = 0; i < 9; i++) {
    turbineHealth[i] = random(75, 100);
  }

  initializeDefects();
}

// ================================================================
// SYNTHETIC DEFECT INITIALIZATION
// ================================================================

void initializeDefects() {

  defectCount = 8;

  for (int i = 0; i < defectCount; i++) {
    createDefect(i);
  }

}

void createDefect(int i) {

  if (i < 0 || i >= maxDefects) return;

  defectX[i] = random(-65, 65);
  defectY[i] = random(-105, 105);
  defectZ[i] = random(-12, 12);

  defectType[i] = (int)random(0, 6);

  defectSeverity[i] = (int)random(0, 4);

  defectDetected[i] = false;
  defectRepaired[i] = false;

}

void addSyntheticDefect() {

  if (defectCount >= maxDefects) return;

  createDefect(defectCount);

  defectCount++;

}

// ================================================================
// MAIN DRAW
// ================================================================

void draw() {

  background(8, 16, 32);

  if (running) {
    updateSimulation();
  }

  draw3DWorld();

  drawHUD();

}

// ================================================================
// SIMULATION UPDATE
// ================================================================

void updateSimulation() {

  windOffset += 1.2 * animationSpeed;

  rotorAngle += 0.025 * animationSpeed *
                constrain(windSpeed / 12.0, 0.2, 2);

  detectionPulse += 0.06;

  if (droneActive) {
    updateDrone();
  }

  if (humanActive) {
    updateHuman();
  }

}

// ================================================================
// 3D WORLD
// ================================================================

void draw3DWorld() {

  lights();

  ambientLight(70, 80, 100);

  directionalLight(230, 235, 255,
                   -0.5, 0.7, -1);

  pointLight(30, 180, 255, 0, -180, 250);

  pushMatrix();

  translate(width * 0.50, height * 0.48, 0);

  rotateX(cameraTilt);
  rotateY(cameraRotation);

  scale(min(width, height) / 650.0);

  drawFarmGround();

  drawWindFarmGrid();

  drawInspectionRoute();

  drawDrone();

  drawHumanTechnician();

  drawInspectionStation();

  popMatrix();

}

// ================================================================
// WIND FARM GRID
// ================================================================

void drawFarmGround() {

  pushStyle();

  noStroke();

  fill(20, 55, 58);

  pushMatrix();

  translate(0, 220, 0);

  box(1000, 8, 750);

  popMatrix();

  stroke(70, 110, 110, 100);
  strokeWeight(1);

  for (int i = -450; i <= 450; i += 50) {
    line(i, 215, -350, i, 215, 350);
    line(-450, 215, i, 450, 215, i);
  }

  popStyle();

}

void drawWindFarmGrid() {

  int id = 0;

  for (int row = -1; row <= 1; row++) {

    for (int col = -1; col <= 1; col++) {

      pushMatrix();

      float x = col * 260;
      float z = row * 230;

      translate(x, 0, z);

      if (id == selectedTurbine) {
        stroke(50, 255, 170);
        noFill();
        strokeWeight(3);
        ellipse(0, 218, 115, 115);
      }

      if (id == selectedTurbine) {
        drawSelectedTurbine();
      } else {
        drawSmallTurbine();
      }

      popMatrix();

      id++;

    }
  }

}

// ================================================================
// SELECTED TURBINE
// ================================================================

void drawSelectedTurbine() {

  if (turbineMode == 0) {
    drawHAWT();
  } else {
    drawVAWT();
  }

  if (showDefects) {
    drawDefects();
  }

}

// ================================================================
// SMALL FARM TURBINES
// ================================================================

void drawSmallTurbine() {

  drawVerticalCylinder(0, 100, 0,
                       7, 230,
                       color(125, 145, 170));

  pushMatrix();

  translate(0, -30, 0);

  fill(150, 175, 195);
  noStroke();

  box(50, 20, 24);

  translate(0, 0, 18);

  rotateZ(rotorAngle);

  fill(220, 230, 245);

  for (int i = 0; i < 3; i++) {

    pushMatrix();

    rotateZ(TWO_PI * i / 3);

    translate(0, -38, 0);

    box(6, 75, 5);

    popMatrix();

  }

  popMatrix();

}

// ================================================================
// HAWT
// ================================================================

void drawHAWT() {

  drawVerticalCylinder(0, 95, 0,
                       13, 270,
                       color(145, 165, 185));

  pushMatrix();

  translate(0, -35, 0);

  fill(145, 175, 200);
  noStroke();

  box(105, 34, 44);

  pushMatrix();

  translate(0, 0, 38);

  rotateZ(rotorAngle);

  fill(220, 235, 250);

  sphereDetail(12);
  sphere(13);

  for (int i = 0; i < 3; i++) {

    pushMatrix();

    rotateZ(TWO_PI * i / 3.0);

    drawBlade();

    popMatrix();

  }

  popMatrix();

  popMatrix();

}

// ================================================================
// BLADE GEOMETRY
// ================================================================

void drawBlade() {

  pushMatrix();

  translate(0, -60, 0);

  fill(220, 235, 248);

  noStroke();

  beginShape(QUADS);

  vertex(-5, 0, 3);
  vertex(5, 0, 3);
  vertex(12, -115, 1);
  vertex(-2, -115, 1);

  vertex(-5, 0, -3);
  vertex(5, 0, -3);
  vertex(12, -115, -1);
  vertex(-2, -115, -1);

  vertex(-5, 0, 3);
  vertex(-5, 0, -3);
  vertex(-2, -115, -1);
  vertex(-2, -115, 1);

  vertex(5, 0, 3);
  vertex(5, 0, -3);
  vertex(12, -115, -1);
  vertex(12, -115, 1);

  endShape();

  popMatrix();

}

// ================================================================
// VAWT
// ================================================================

void drawVAWT() {

  drawVerticalCylinder(0, 0, 0,
                       8, 230,
                       color(180, 200, 220));

  pushMatrix();

  rotateY(rotorAngle);

  if (page == 6 || page == 7 || page == 8) {
    drawDarrieus();
  } else {
    drawSavonius();
  }

  popMatrix();

}

// ================================================================
// SAVONIUS
// ================================================================

void drawSavonius() {

  noFill();

  stroke(65, 190, 230);
  strokeWeight(12);

  arc(-25, 0, 90, 200, -HALF_PI, HALF_PI);

  arc(25, 0, 90, 200, HALF_PI, PI + HALF_PI);

  drawVerticalCylinder(0, 0, 0,
                       7, 220,
                       color(200, 215, 230));

}

// ================================================================
// DARRIEUS AND GIROMILL
// ================================================================

void drawDarrieus() {

  drawVerticalCylinder(0, 0, 0,
                       7, 220,
                       color(200, 215, 230));

  stroke(65, 200, 255);
  strokeWeight(8);
  noFill();

  for (int b = 0; b < 3; b++) {

    pushMatrix();

    rotateY(TWO_PI * b / 3.0);

    if (page == 8) {

      line(65, -105, 0, 65, 105, 0);

    } else {

      beginShape();

      for (int i = 0; i <= 25; i++) {

        float t = map(i, 0, 25, -1, 1);

        float y = t * 105;

        float r = 25 + 40 * cos(t * HALF_PI);

        vertex(r, y, 0);

      }

      endShape();

    }

    strokeWeight(4);

    line(0, -105, 0, 65, -105, 0);
    line(0, 105, 0, 65, 105, 0);

    popMatrix();

  }

}

// ================================================================
// SYNTHETIC DEFECT DISPLAY
// ================================================================

void drawDefects() {

  for (int i = 0; i < defectCount; i++) {

    if (defectRepaired[i]) continue;

    pushMatrix();

    translate(defectX[i],
              defectY[i],
              defectZ[i] + 15);

    if (defectType[i] == 0) {

      // Artificial crack

      stroke(255, 50, 45);
      strokeWeight(3);

      line(-10, -5, 0, 8, 10, 0);
      line(8, 10, 0, 15, 16, 0);

    } else if (defectType[i] == 1) {

      // Erosion

      noStroke();
      fill(220, 155, 65);

      sphere(7);

    } else if (defectType[i] == 2) {

      // Delamination marker

      noFill();
      stroke(255, 175, 30);
      strokeWeight(3);

      ellipse(0, 0, 18, 12);

    } else if (defectType[i] == 3) {

      // Lightning damage

      stroke(255, 255, 40);
      strokeWeight(4);

      line(-8, -8, 0, 0, 0, 0);
      line(0, 0, 0, 8, 8, 0);

    } else if (defectType[i] == 4) {

      // Impact damage

      noStroke();
      fill(255, 90, 60);

      sphere(8);

    } else {

      // Coating failure

      noStroke();
      fill(170, 95, 70);

      box(15, 9, 3);

    }

    if (defectDetected[i] && yoloActive) {

      noFill();

      stroke(30, 255, 120);
      strokeWeight(2);

      box(25, 22, 18);

    }

    popMatrix();

  }

}

// ================================================================
// DRONE
// ================================================================

void drawDrone() {

  pushMatrix();

  translate(droneX, droneY, droneZ);

  rotateY(frameCount * 0.08);

  // Drone main body

  noStroke();

  fill(35, 45, 65);

  box(32, 9, 24);

  // Arms and rotors

  stroke(180, 205, 230);
  strokeWeight(4);

  line(-12, 0, 0, -35, 0, 0);
  line(12, 0, 0, 35, 0, 0);
  line(0, 0, -10, 0, 0, -35);
  line(0, 0, 10, 0, 0, 35);

  noStroke();

  fill(40, 220, 255);

  for (int i = 0; i < 4; i++) {

    pushMatrix();

    if (i == 0) translate(-35, 0, 0);
    if (i == 1) translate(35, 0, 0);
    if (i == 2) translate(0, 0, -35);
    if (i == 3) translate(0, 0, 35);

    rotateY(frameCount * 0.25);

    box(28, 2, 4);

    popMatrix();

  }

  // Camera

  fill(255, 220, 50);

  translate(0, 10, 8);

  sphere(5);

  popMatrix();

}

// ================================================================
// DRONE MOVEMENT
// ================================================================

void updateDrone() {

  droneX = lerp(droneX, droneTargetX, 0.025);
  droneY = lerp(droneY, droneTargetY, 0.025);
  droneZ = lerp(droneZ, droneTargetZ, 0.025);

  if (abs(droneX - droneTargetX) < 5 &&
      abs(droneY - droneTargetY) < 5) {

    droneWaypoint++;

    if (droneWaypoint > 4) {

      droneActive = false;

      missionComplete = true;

      inspectionCount++;

    } else {

      setDroneWaypoint();

    }

  }

}

void setDroneWaypoint() {

  if (droneWaypoint == 0) {
    droneTargetX = -180;
    droneTargetY = -90;
    droneTargetZ = 0;
  }

  if (droneWaypoint == 1) {
    droneTargetX = -70;
    droneTargetY = -145;
    droneTargetZ = 15;
  }

  if (droneWaypoint == 2) {
    droneTargetX = 70;
    droneTargetY = -100;
    droneTargetZ = 0;
  }

  if (droneWaypoint == 3) {
    droneTargetX = 130;
    droneTargetY = -45;
    droneTargetZ = 25;
  }

  if (droneWaypoint == 4) {
    droneTargetX = -260;
    droneTargetY = -90;
    droneTargetZ = 0;
  }

}

// ================================================================
// HUMAN TECHNICIAN
// ================================================================

void drawHumanTechnician() {

  if (!humanActive) return;

  pushMatrix();

  translate(humanX, humanY, humanZ);

  // Body

  noStroke();

  fill(255, 135, 35);

  box(15, 35, 12);

  // Head

  translate(0, -25, 0);

  fill(220, 175, 140);

  sphere(9);

  // Safety helmet

  translate(0, -7, 0);

  fill(255, 210, 20);

  sphere(10);

  // Legs

  stroke(35, 40, 55);
  strokeWeight(5);

  line(-5, 20, 0, -7, 45, 0);
  line(5, 20, 0, 7, 45, 0);

  popMatrix();

}

void updateHuman() {

  humanX = lerp(humanX, 70, 0.02);
  humanY = lerp(humanY, 110, 0.02);

}

// ================================================================
// INSPECTION ROUTE
// ================================================================

void drawInspectionRoute() {

  if (!droneActive) return;

  pushStyle();

  stroke(30, 230, 255, 180);
  strokeWeight(2);

  line(droneX, droneY, droneZ,
       droneTargetX, droneTargetY, droneTargetZ);

  popStyle();

}

// ================================================================
// INSPECTION STATION
// ================================================================

void drawInspectionStation() {

  pushMatrix();

  translate(250, 160, -130);

  fill(55, 100, 150);
  noStroke();

  box(75, 75, 50);

  fill(30, 255, 170);

  translate(0, -40, 0);

  sphere(7);

  popMatrix();

}

// ================================================================
// YOLO EDUCATIONAL DETECTION ENGINE
// ================================================================

void runYOLOSimulation() {

  yoloActive = true;

  detectedCount = 0;

  for (int i = 0; i < defectCount; i++) {

    // Synthetic detections for educational use.
    // This is NOT neural network inference.

    if (random(1) > 0.15) {

      defectDetected[i] = true;

      detectedCount++;

    }

  }

}

// ================================================================
// DEFECT SEVERITY
// ================================================================

String getSeverity(int i) {

  return severityNames[
    constrain(defectSeverity[i], 0, 3)
  ];

}

String getFaultName(int i) {

  return faultNames[
    constrain(defectType[i], 0, faultNames.length - 1)
  ];

}

// ================================================================
// REPAIR DEMONSTRATION
// ================================================================

void repairDetectedDefects() {

  for (int i = 0; i < defectCount; i++) {

    if (defectDetected[i] &&
        !defectRepaired[i]) {

      // Training demonstration only.
      // Actual repairs require engineering approval.

      if (defectSeverity[i] < 3) {

        defectRepaired[i] = true;

        repairedCount++;

      }

    }

  }

}

// ================================================================
// WIND FARM HEALTH
// ================================================================

float calculateFarmHealth() {

  float total = 0;

  for (int i = 0; i < 9; i++) {
    total += turbineHealth[i];
  }

  return total / 9.0;

}

// ================================================================
// 3D CYLINDER
// ================================================================

void drawVerticalCylinder(float x, float y, float z,
                          float radius, float h,
                          color c) {

  pushMatrix();

  translate(x, y, z);

  noStroke();

  fill(c);

  beginShape(QUAD_STRIP);

  for (int i = 0; i <= 16; i++) {

    float a = TWO_PI * i / 16;

    float px = cos(a) * radius;
    float pz = sin(a) * radius;

    vertex(px, -h/2, pz);
    vertex(px, h/2, pz);

  }

  endShape();

  popMatrix();

}

// ================================================================
// HUD
// ================================================================

void drawHUD() {

  hint(DISABLE_DEPTH_TEST);

  camera();

  noStroke();

  fill(5, 15, 35, 245);

  rect(0, 0, width, 65);

  fill(60, 220, 255);

  textSize(min(21, width * 0.035));

  text("ADVANCED WIND FARM INSPECTION SYSTEM",
       12, 8);

  fill(255, 190, 70);

  textSize(11);

  text("ADVANCED COURSE - SPOILER ALERT",
       14, 39);

  fill(220);

  textSize(12);

  text("WIND " + nf(windSpeed, 1, 1) + " m/s",
       width * 0.74, 10);

  text("FARM HEALTH " +
       nf(calculateFarmHealth(), 1, 1) + "%",
       width * 0.74, 34);

  drawEducationalPanel();

  hint(ENABLE_DEPTH_TEST);

}

// ================================================================
// EDUCATIONAL PANEL
// ================================================================

void drawEducationalPanel() {

  float panelY = height - min(205, height * 0.33);

  noStroke();

  fill(5, 15, 35, 245);

  rect(0, panelY, width, height - panelY);

  fill(50, 220, 255);

  textSize(15);

  text(pageTitles[page], 12, panelY + 7);

  fill(230);

  textSize(11);

  float lineY = panelY + 32;

  for (int i = 0; i < pageText[page].length; i++) {

    text(pageText[page][i],
         13, lineY + i * 15);

  }

  // Live inspection information

  fill(80, 255, 175);

  textSize(11);

  text("DETECTED: " + detectedCount,
       width * 0.70, panelY + 30);

  text("REPAIRED: " + repairedCount,
       width * 0.70, panelY + 47);

  text("DEFECTS: " + defectCount,
       width * 0.70, panelY + 64);

  drawControls(panelY);

}

// ================================================================
// CONTROL BUTTONS
// ================================================================

void drawControls(float panelY) {

  float y = panelY - 42;

  float gap = 5;

  float w = (width - 24 - gap * 9) / 10.0;

  drawButton(12, y, w, 34, "PREV");
  drawButton(12 + (w+gap), y, w, 34, "NEXT");

  drawButton(12 + 2*(w+gap), y, w, 34, "HAWT");
  drawButton(12 + 3*(w+gap), y, w, 34, "VAWT");

  drawButton(12 + 4*(w+gap), y, w, 34, "DRONE");
  drawButton(12 + 5*(w+gap), y, w, 34, "HUMAN");

  drawButton(12 + 6*(w+gap), y, w, 34, "YOLO");
  drawButton(12 + 7*(w+gap), y, w, 34, "DEFECT");

  drawButton(12 + 8*(w+gap), y, w, 34, "REPAIR");
  drawButton(12 + 9*(w+gap), y, w, 34, "RESET");

  fill(190, 215, 235);

  textSize(10);

  text("PAGE " + (page+1) + " / " + totalPages,
       width - 95, panelY + 7);

}

void drawButton(float x, float y,
                float w, float h, String label) {

  fill(30, 65, 95);

  stroke(75, 190, 230);

  strokeWeight(1);

  rect(x, y, w, h, 6);

  fill(255);

  textSize(10);

  textAlign(CENTER, CENTER);

  text(label, x+w/2, y+h/2);

  textAlign(LEFT, TOP);

}

// ================================================================
// TOUCHSCREEN INPUT
// ================================================================

void mousePressed() {

  float panelY = height - min(205, height * 0.33);

  float y = panelY - 42;

  if (mouseY >= y && mouseY <= y + 34) {

    float gap = 5;

    float w = (width - 24 - gap * 9) / 10.0;

    int button = (int)((mouseX - 12) / (w + gap));

    if (button >= 0 && button <= 9) {

      if (button == 0) {
        page = (page - 1 + totalPages) % totalPages;
      }

      if (button == 1) {
        page = (page + 1) % totalPages;
      }

      if (button == 2) {
        turbineMode = 0;
      }

      if (button == 3) {
        turbineMode = 1;
      }

      if (button == 4) {
        startDroneMission();
      }

      if (button == 5) {
        humanActive = !humanActive;
      }

      if (button == 6) {
        runYOLOSimulation();
      }

      if (button == 7) {
        addSyntheticDefect();
      }

      if (button == 8) {
        repairDetectedDefects();
      }

      if (button == 9) {
        resetMission();
      }

    }

  } else if (mouseY < panelY) {

    // Tap to select a wind farm turbine.

    selectedTurbine++;

    if (selectedTurbine >= 9) {
      selectedTurbine = 0;
    }

  }

}

// ================================================================
// CAMERA ROTATION
// ================================================================

void mouseDragged() {

  cameraRotation += (mouseX - pmouseX) * 0.006;

  cameraTilt += (mouseY - pmouseY) * 0.003;

  cameraTilt = constrain(cameraTilt, -0.9, 0.9);

}

// ================================================================
// DRONE MISSION START
// ================================================================

void startDroneMission() {

  droneActive = true;

  missionComplete = false;

  droneWaypoint = 0;

  droneX = -260;
  droneY = -90;
  droneZ = 0;

  setDroneWaypoint();

}

// ================================================================
// MISSION RESET
// ================================================================

void resetMission() {

  droneActive = false;

  humanActive = false;

  yoloActive = false;

  missionComplete = false;

  droneWaypoint = 0;

  detectedCount = 0;

  repairedCount = 0;

  droneX = -260;
  droneY = -90;
  droneZ = 0;

  initializeDefects();

}

// ================================================================
// KEYBOARD CONTROLS
// ================================================================

void keyPressed() {

  if (key == ' ') {
    running = !running;
  }

  if (key == '+') {
    windSpeed = min(25, windSpeed + 1);
  }

  if (key == '-') {
    windSpeed = max(1, windSpeed - 1);
  }

  if (key == '1') {
    turbineMode = 0;
    page = 2;
  }

  if (key == '2') {
    turbineMode = 1;
    page = 2;
  }

  if (key == '3') {
    startDroneMission();
    page = 3;
  }

  if (key == '4') {
    humanActive = !humanActive;
    page = 5;
  }

  if (key == '5') {
    runYOLOSimulation();
    page = 8;
  }

  if (key == 'n' || key == 'N') {
    page = (page + 1) % totalPages;
  }

  if (key == 'p' || key == 'P') {
    page = (page - 1 + totalPages) % totalPages;
  }

  if (key == 'r' || key == 'R') {
    resetMission();
  }

  if (key == 'd' || key == 'D') {
    addSyntheticDefect();
  }

  if (key == 'y' || key == 'Y') {
    runYOLOSimulation();
  }

  if (key == 'h' || key == 'H') {
    humanActive = !humanActive;
  }

}
