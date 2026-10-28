
/*
 * SOLAR POWER PLANT ANIMATED SIMULATOR
 * Processing Java Mode / Android APDE
 *
 * 5 SCREENS:
 * 1. General solar plant layout
 * 2. Solar cell and p-n junction
 * 3. MPPT and battery storage
 * 4. Inverter, transformer and grid
 * 5. Operating dashboard
 *
 * CONTROLS: PREV, NEXT, PLAY/PAUSE, RESET,
 * SUN -, SUN +, LOAD -, LOAD +, CHARGE ON/OFF
 *
 * Educational animation; readings are illustrative.
 * No external libraries required.
 */

final int SW = 1000;
final int SH = 650;

int page = 0;
boolean playing = true;
boolean charging = true;

float t = 0;
float sun = 800;
float load = 0.65;
float soc = 45;
float phase = 0;

float vdc = 0;
float idc = 0;
float pdc = 0;
float pac = 0;
float vac = 230;
float iac = 0;
float mppt = 0;

float scaleView, ox, oy;

float[] photons = new float[35];
float[] electrons = new float[24];
float[] dcFlow = new float[30];
float[] acFlow = new float[24];

color bg, white, yellow, blue, orange, green;

void setup() {
  orientation(LANDSCAPE);
  fullScreen(P2D);
  frameRate(60);
  smooth(4);
  textFont(createFont("SansSerif", 14));

  bg = color(18, 30, 46);
  white = color(245, 249, 255);
  yellow = color(255, 220, 54);
  blue = color(45, 165, 255);
  orange = color(255, 155, 48);
  green = color(60, 210, 130);

  for (int i = 0; i < photons.length; i++) {
    photons[i] = random(1);
  }
  for (int i = 0; i < electrons.length; i++) {
    electrons[i] = random(1);
  }
  for (int i = 0; i < dcFlow.length; i++) {
    dcFlow[i] = random(1);
  }
  for (int i = 0; i < acFlow.length; i++) {
    acFlow[i] = random(1);
  }
}

void draw() {
  background(bg);

  scaleView = min(width / (float)SW, height / (float)SH);
  ox = (width - SW * scaleView) / 2;
  oy = (height - SH * scaleView) / 2;

  pushMatrix();
  translate(ox, oy);
  scale(scaleView);

  updateModel();
  backgroundScene();
  header();

  if (page == 0) drawLayout();
  if (page == 1) drawCell();
  if (page == 2) drawMPPT();
  if (page == 3) drawGrid();
  if (page == 4) drawDashboard();

  footer();
  controls();

  popMatrix();
}

// ------------------------------------------------------------
// SIMULATION MODEL
// ------------------------------------------------------------

void updateModel() {
  float s = constrain(sun / 1000.0, 0, 1);

  // Simplified illustrative PV model.
  float targetV = 40 * s;
  float targetI = 10 * s;
  float targetP = targetV * targetI;

  vdc = lerp(vdc, targetV, 0.04);
  idc = lerp(idc, targetI, 0.04);
  pdc = lerp(pdc, targetP, 0.04);

  mppt = 96 * s;
  pac = lerp(pac, pdc * 0.94, 0.04);
  vac = lerp(vac, 230, 0.04);
  iac = pac * 1000 / max(vac, 1);

  if (playing) {
    t += 1.0 / 60.0;
    phase += 0.06;

    for (int i = 0; i < photons.length; i++) {
      photons[i] += 0.004 + s * 0.004;
      if (photons[i] > 1) photons[i] -= 1;
    }

    for (int i = 0; i < electrons.length; i++) {
      electrons[i] += 0.003 + s * 0.003;
      if (electrons[i] > 1) electrons[i] -= 1;
    }

    for (int i = 0; i < dcFlow.length; i++) {
      dcFlow[i] += 0.004;
      if (dcFlow[i] > 1) dcFlow[i] -= 1;
    }

    for (int i = 0; i < acFlow.length; i++) {
      acFlow[i] += 0.005;
      if (acFlow[i] > 1) acFlow[i] -= 1;
    }

    if (charging && s > 0.05) {
      soc += 0.002 * s;
    } else {
      soc -= 0.001 * load;
    }

    soc = constrain(soc, 0, 100);
  }
}

// ------------------------------------------------------------
// COMMON GRAPHICS
// ------------------------------------------------------------

void backgroundScene() {
  background(19, 32, 49);

  stroke(49, 68, 88, 70);
  strokeWeight(1);

  for (int x = 0; x <= SW; x += 50) {
    line(x, 70, x, 565);
  }
  for (int y = 70; y <= 565; y += 50) {
    line(0, y, SW, y);
  }

  noStroke();
}

void header() {
  noStroke();
  fill(11, 22, 36);
  rect(0, 0, SW, 69);

  fill(yellow);
  textAlign(LEFT, CENTER);
  textSize(21);
  text("SOLAR POWER PLANT", 22, 25);

  fill(190, 212, 233);
  textSize(11);
  text("PHOTOVOLTAIC ENERGY CONVERSION AND CONTROL", 23, 49);

  String[] names = {
    "PLANT LAYOUT",
    "SOLAR CELL",
    "MPPT + BATTERY",
    "INVERTER + GRID",
    "DASHBOARD"
  };

  fill(green);
  textAlign(RIGHT, CENTER);
  textSize(13);
  text((page + 1) + " / 5  " + names[page], 976, 28);

  textAlign(LEFT, BASELINE);
}

void boxPanel(float x, float y, float w, float h, String titleText) {
  noStroke();
  fill(31, 49, 69);
  rect(x, y, w, h, 9);

  fill(215, 230, 244);
  textAlign(LEFT, BASELINE);
  textSize(14);
  text(titleText, x + 13, y + 23);

  stroke(78, 103, 127);
  line(x + 12, y + 33, x + w - 12, y + 33);
  noStroke();
}

void arrow(float x1, float y1, float x2, float y2,
           color c, float weight) {
  stroke(c);
  strokeWeight(weight);
  line(x1, y1, x2, y2);

  float a = atan2(y2 - y1, x2 - x1);

  line(x2, y2,
       x2 - 10 * cos(a - PI / 6),
       y2 - 10 * sin(a - PI / 6));

  line(x2, y2,
       x2 - 10 * cos(a + PI / 6),
       y2 - 10 * sin(a + PI / 6));

  noStroke();
}

void dot(float x, float y, color c, float r) {
  noStroke();
  fill(c);
  ellipse(x, y, r * 2, r * 2);
}

void block(float x, float y, float w, float h,
           String titleText, String subtitle, color c) {
  stroke(119, 146, 170);
  strokeWeight(1.3);
  fill(c);
  rect(x, y, w, h, 7);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(titleText, x + w / 2, y + h / 2 - 7);

  fill(215, 229, 241);
  textSize(10);
  text(subtitle, x + w / 2, y + h / 2 + 11);

  noStroke();
  textAlign(LEFT, BASELINE);
}

void sunIcon(float x, float y, float r) {
  noStroke();
  fill(255, 220, 54, 35);
  ellipse(x, y, r * 3.5, r * 3.5);

  fill(yellow);
  ellipse(x, y, r * 2, r * 2);

  stroke(yellow);
  strokeWeight(2);

  for (int i = 0; i < 12; i++) {
    float a = TWO_PI * i / 12.0 + phase * 0.1;
    line(x + cos(a) * r * 1.3,
         y + sin(a) * r * 1.3,
         x + cos(a) * r * 1.8,
         y + sin(a) * r * 1.8);
  }

  noStroke();
}

void solarPanel(float x, float y, float w, float h,
                int cols, int rows) {
  stroke(211, 224, 238);
  strokeWeight(3);
  fill(48, 59, 72);

  beginShape();
  vertex(x, y);
  vertex(x + w, y);
  vertex(x + w + 15, y + h + 12);
  vertex(x + 15, y + h + 12);
  endShape(CLOSE);

  noStroke();
  fill(14, 38, 86);
  quad(x + 5, y + 5,
       x + w - 5, y + 5,
       x + w + 9, y + h + 7,
       x + 20, y + h + 7);

  float cw = (w - 10) / cols;
  float ch = (h - 10) / rows;

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      float xx = x + 5 + c * cw;
      float yy = y + 5 + r * ch;

      fill(25, 67, 177);
      quad(xx, yy,
           xx + cw - 2, yy,
           xx + cw + 3, yy + ch - 2,
           xx + 6, yy + ch - 2);

      stroke(119, 197, 255);
      strokeWeight(1);
      line(xx + 2, yy + 2, xx + cw - 4, yy + 2);
      noStroke();
    }
  }
}

void batteryIcon(float x, float y, float w, float h, float percent) {
  stroke(205, 218, 231);
  strokeWeight(2);
  fill(65, 80, 95);
  rect(x, y, w, h, 5);

  rect(x + w * 0.23, y - 6, w * 0.16, 7);
  rect(x + w * 0.62, y - 6, w * 0.16, 7);

  noStroke();
  fill(31, 44, 58);
  rect(x + 6, y + 6, w - 12, h - 12, 3);

  color c = percent > 60 ? green :
            percent > 25 ? yellow : color(255, 85, 80);

  fill(c);
  rect(x + 6, y + 6, (w - 12) * percent / 100.0,
       h - 12, 3);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(11);
  text(nf(percent, 1, 0) + "%", x + w / 2, y + h / 2);

  textAlign(LEFT, BASELINE);
}

// ------------------------------------------------------------
// SCREEN 1: COMPLETE SOLAR POWER PLANT LAYOUT
// ------------------------------------------------------------

void drawLayout() {
  boxPanel(16, 84, 968, 465, "GENERAL LAYOUT OF SOLAR POWER PLANT");

  sunIcon(95, 151, 21);

  fill(yellow);
  textAlign(CENTER);
  textSize(12);
  text("SUNLIGHT", 95, 190);

  for (int i = 0; i < 6; i++) {
    float q = i / 5.0;
    arrow(116 + q * 20, 171 + q * 4,
          183 + q * 10, 233 + q * 4,
          yellow, 1.8);
  }

  solarPanel(175, 237, 125, 85, 5, 4);

  fill(white);
  textSize(13);
  text("SOLAR PANEL / PV ARRAY", 245, 355);

  fill(187, 210, 232);
  textSize(10);
  text("Sunlight → DC electricity", 245, 371);

  block(354, 241, 138, 66,
        "MPPT", "Maximum power point", color(42, 98, 113));

  arrow(315, 276, 350, 276, blue, 3);

  for (int i = 0; i < dcFlow.length; i++) {
    dot(316 + dcFlow[i] * 31, 276, blue, 2.4);
  }

  fill(105, 195, 255);
  textAlign(CENTER);
  text("DC", 333, 260);

  block(548, 241, 126, 66,
        "INVERTER", "DC → AC", color(94, 75, 121));

  arrow(495, 276, 544, 276, blue, 3);

  block(737, 241, 130, 66,
        "LOAD / GRID", "Electrical output", color(57, 105, 87));

  arrow(677, 276, 733, 276, orange, 3);

  for (int i = 0; i < acFlow.length; i++) {
    dot(680 + acFlow[i] * 52, 276, orange, 2.5);
  }

  arrow(423, 311, 423, 393, green, 2.5);
  batteryIcon(365, 399, 116, 42, soc);

  fill(white);
  textAlign(CENTER);
  textSize(12);
  text("BATTERY BANK", 423, 461);

  fill(185, 207, 229);
  textSize(10);
  text("Stored DC energy", 423, 477);

  arrow(803, 310, 803, 370, orange, 2.5);

  block(745, 377, 116, 59,
        "TRANSFORMER", "Voltage change", color(103, 82, 62));

  boxPanel(29, 488, 940, 48, "ENERGY CONVERSION");

  fill(235, 243, 250);
  textAlign(CENTER);
  textSize(12);
  text("SUNLIGHT → DC POWER → MPPT → INVERTER → AC POWER → LOAD / GRID",
       500, 519);

  textAlign(LEFT, BASELINE);
}

// ------------------------------------------------------------
// SCREEN 2: SOLAR CELL FUNDAMENTALS
// ------------------------------------------------------------

void drawCell() {
  boxPanel(16, 84, 645, 465, "SOLAR CELL FUNDAMENTALS: p-n JUNCTION");

  stroke(210, 224, 240);
  strokeWeight(2);
  fill(51, 104, 176);
  rect(48, 153, 260, 91);

  fill(142, 77, 121);
  rect(48, 244, 260, 99);

  noStroke();
  fill(white);
  textAlign(CENTER);
  textSize(17);
  text("N-TYPE SEMICONDUCTOR", 178, 190);
  textSize(12);
  text("Extra electrons", 178, 212);

  textSize(17);
  text("P-TYPE SEMICONDUCTOR", 178, 289);
  textSize(12);
  text("Holes", 178, 312);

  stroke(yellow);
  strokeWeight(3);
  line(48, 244, 308, 244);
  noStroke();

  fill(yellow);
  textSize(12);
  text("P-N JUNCTION", 178, 365);

  for (int i = 0; i < photons.length; i++) {
    float x = 57 + photons[i] * 240;
    float y = 126 + ((photons[i] * 73 + t * 30) % 103);
    dot(x, y, yellow, 3);
  }

  fill(yellow);
  textSize(12);
  text("PHOTONS", 178, 126);

  for (int i = 0; i < electrons.length; i++) {
    float x = 60 + electrons[i] * 240;
    float y = 250 + ((electrons[i] * 67 + t * 15) % 82);
    dot(x, y, color(255, 246, 145), 3.2);
  }

  arrow(308, 190, 350, 190, blue, 3);
  arrow(350, 190, 350, 410, blue, 3);
  arrow(350, 410, 100, 410, blue, 3);
  arrow(100, 410, 100, 345, blue, 3);

  fill(111, 196, 255);
  textAlign(LEFT);
  textSize(12);
  text("External DC circuit", 365, 202);
  text("Electron flow", 365, 222);

  block(371, 260, 122, 63,
        "DC LOAD", "Useful electrical work", color(48, 93, 114));

  arrow(350, 291, 367, 291, blue, 2.5);

  boxPanel(680, 84, 304, 465, "WORKING PRINCIPLE");

  fill(230, 239, 249);
  textSize(12);
  text("1. Sunlight carries photon energy.", 697, 145);
  text("2. Photons excite charge carriers.", 697, 181);
  text("3. The junction field separates", 697, 217);
  text("   electrons and holes.", 697, 235);
  text("4. Contacts collect the carriers.", 697, 271);
  text("5. A connected load receives DC.", 697, 307);

  boxPanel(696, 337, 272, 92, "LIVE ILLUSTRATIVE VALUES");

  fill(yellow);
  textSize(14);
  text("Irradiance", 710, 366);
  textAlign(RIGHT);
  text(nf(sun, 1, 0) + " W/m²", 950, 366);

  fill(blue);
  textAlign(LEFT);
  text("DC voltage", 710, 391);
  textAlign(RIGHT);
  text(nf(vdc, 1, 1) + " V", 950, 391);

  fill(green);
  textAlign(LEFT);
  text("DC current", 710, 416);
  textAlign(RIGHT);
  text(nf(idc, 1, 1) + " A", 950, 416);

  fill(190, 211, 230);
  textAlign(LEFT);
  textSize(10);
  text("Conceptual particle animation.", 697, 456);

  textAlign(LEFT, BASELINE);
}

// ------------------------------------------------------------
// SCREEN 3: MPPT AND BATTERY
// ------------------------------------------------------------

void drawMPPT() {
  boxPanel(16, 84, 968, 465, "MPPT CONTROL AND BATTERY STORAGE");

  solarPanel(53, 157, 106, 72, 4, 3);

  fill(white);
  textAlign(CENTER);
  textSize(13);
  text("PV ARRAY", 110, 263);

  arrow(174, 210, 271, 210, blue, 3);

  for (int i = 0; i < dcFlow.length; i++) {
    dot(180 + dcFlow[i] * 86, 210, blue, 2.4);
  }

  block(275, 166, 153, 88,
        "MPPT CONTROLLER", "Track maximum power", color(42, 99, 113));

  arrow(433, 210, 517, 210, blue, 3);

  block(522, 166, 132, 88,
        "DC-DC CONVERTER", "Adjust voltage", color(72, 91, 127));

  arrow(587, 259, 587, 339, green, 3);

  batteryIcon(509, 353, 156, 59, soc);

  fill(white);
  textAlign(CENTER);
  textSize(13);
  text("BATTERY BANK", 587, 436);

  fill(192, 214, 232);
  textSize(11);
  text("State of charge: " + nf(soc, 1, 0) + "%", 587, 455);

  arrow(655, 210, 745, 210, orange, 3);

  block(749, 166, 155, 88,
        "SYSTEM OUTPUT", "To inverter / load", color(93, 75, 113));

  boxPanel(34, 466, 420, 69, "POWER-TRACKING STATUS");

  fill(216, 231, 245);
  textAlign(LEFT);
  textSize(11);
  text("Irradiance", 49, 511);
  text(nf(sun, 1, 0) + " W/m²", 138, 511);

  text("MPPT indicator", 240, 511);
  fill(green);
  text(nf(mppt, 1, 1) + "%", 366, 511);

  boxPanel(691, 289, 270, 246, "BATTERY MANAGEMENT");

  fill(220, 234, 246);
  textSize(13);
  text("Charge controller", 708, 345);

  fill(charging ? green : orange);
  text(charging ? "CHARGING ENABLED" : "CHARGING DISABLED",
       708, 372);

  fill(220, 234, 246);
  textSize(11);
  text("Charging must be regulated", 708, 410);
  text("to protect the battery.", 708, 429);

  text("Stored energy (relative)", 708, 465);

  noStroke();
  fill(53, 68, 84);
  rect(708, 478, 225, 14, 4);

  fill(soc > 60 ? green : soc > 25 ? yellow : color(255, 92, 88));
  rect(708, 478, 225 * soc / 100.0, 14, 4);

  fill(202, 222, 240);
  textSize(10);
  text("Use CHARGE toggle below.", 708, 513);

  textAlign(LEFT, BASELINE);
}

// ------------------------------------------------------------
// SCREEN 4: INVERTER, TRANSFORMER AND GRID
// ------------------------------------------------------------

void drawGrid() {
  boxPanel(16, 84, 968, 465,
           "INVERTER, TRANSFORMER AND GRID CONNECTION");

  block(38, 170, 145, 80,
        "PV / BATTERY", "DC supply", color(44, 95, 126));

  arrow(187, 210, 265, 210, blue, 3);

  for (int i = 0; i < dcFlow.length; i++) {
    dot(191 + dcFlow[i] * 68, 210, blue, 2.5);
  }

  block(270, 170, 146, 80,
        "INVERTER", "DC → AC", color(100, 73, 124));

  stroke(255, 177, 73);
  strokeWeight(2.5);
  noFill();

  beginShape();
  for (int i = 0; i <= 90; i++) {
    float x = 433 + i * 2;
    float y = 210 - sin(i * 0.12 + phase) * 24;
    vertex(x, y);
  }
  endShape();
  noStroke();

  fill(255, 190, 105);
  textAlign(CENTER);
  textSize(12);
  text("AC WAVEFORM", 520, 255);

  arrow(620, 210, 678, 210, orange, 3);

  block(683, 170, 130, 80,
        "TRANSFORMER", "Voltage conversion", color(91, 103, 113));

  stroke(255, 203, 100);
  strokeWeight(2);
  noFill();

  for (int i = 0; i < 4; i++) {
    ellipse(712, 207 + i * 9, 15, 18);
    ellipse(751, 207 + i * 9, 15, 18);
  }

  noStroke();
  arrow(816, 210, 865, 210, orange, 3);

  block(870, 170, 93, 80,
        "GRID", "AC supply", color(54, 110, 84));

  // House illustration.
  fill(192, 208, 221);
  stroke(240, 246, 250);
  strokeWeight(2);
  triangle(445, 352, 488, 320, 531, 352);

  fill(119, 148, 170);
  rect(451, 352, 74, 59);

  fill(48, 68, 88);
  rect(480, 376, 17, 35);

  fill(yellow);
  rect(460, 361, 13, 13);

  noStroke();
  arrow(515, 290, 515, 315, orange, 3);

  fill(white);
  textAlign(CENTER);
  textSize(12);
  text("ELECTRICAL LOAD", 488, 432);

  boxPanel(39, 455, 922, 72, "POWER CONVERSION");

  fill(219, 232, 244);
  textSize(12);
  text("PV produces DC. The inverter produces AC. The transformer adapts voltage.",
       500, 493);

  fill(green);
  text("Illustrative AC output: " + nf(pac, 1, 1) + " W",
       500, 514);

  textAlign(LEFT, BASELINE);
}

// ------------------------------------------------------------
// SCREEN 5: DASHBOARD
// ------------------------------------------------------------

void metric(float x, float y, float w, float h,
            String labelText, String valueText,
            color c, float fraction) {
  stroke(73, 98, 121);
  strokeWeight(1);
  fill(37, 57, 77);
  rect(x, y, w, h, 8);

  noStroke();
  fill(191, 211, 230);
  textAlign(LEFT);
  textSize(12);
  text(labelText, x + 13, y + 24);

  fill(c);
  textSize(22);
  text(valueText, x + 13, y + 58);

  fill(57, 73, 89);
  rect(x + 13, y + 76, w - 26, 8, 4);

  fill(c);
  rect(x + 13, y + 76,
       (w - 26) * constrain(fraction, 0, 1), 8, 4);
}

void drawDashboard() {
  boxPanel(16, 84, 968, 465, "LIVE OPERATING DASHBOARD");

  metric(32, 130, 220, 105, "IRRADIANCE",
         nf(sun, 1, 0) + " W/m²", yellow, sun / 1000.0);

  metric(267, 130, 220, 105, "DC POWER",
         nf(pdc, 1, 1) + " W", blue, pdc / 500.0);

  metric(502, 130, 220, 105, "AC OUTPUT",
         nf(pac, 1, 1) + " W", orange, pac / 500.0);

  metric(737, 130, 220, 105, "BATTERY SOC",
         nf(soc, 1, 0) + "%", green, soc / 100.0);

  boxPanel(32, 255, 451, 119, "ELECTRICAL MEASUREMENTS");

  fill(222, 235, 247);
  textAlign(LEFT);
  textSize(13);

  text("DC voltage", 49, 311);
  text(nf(vdc, 1, 1) + " V", 212, 311);

  text("DC current", 49, 340);
  text(nf(idc, 1, 1) + " A", 212, 340);

  text("AC voltage (illustrative)", 250, 311);
  text(nf(vac, 1, 1) + " V", 451, 311);

  text("AC current", 250, 340);
  text(nf(iac, 1, 2) + " A", 451, 340);

  boxPanel(503, 255, 454, 119, "OPERATING STATUS");

  fill(playing ? green : orange);
  textSize(13);
  text(playing ? "SIMULATION RUNNING" : "SIMULATION PAUSED",
       521, 311);

  fill(221, 234, 246);
  text("Solar irradiance", 521, 340);
  textAlign(RIGHT);
  text(nf(sun, 1, 0) + " W/m²", 920, 340);
  textAlign(LEFT);

  boxPanel(32, 393, 925, 137, "ADJUSTABLE INPUTS");

  fill(226, 237, 248);
  textSize(13);
  text("Sunlight level", 49, 440);
  text(nf(sun, 1, 0) + " W/m²", 240, 440);

  fill(58, 75, 92);
  rect(49, 451, 410, 12, 5);
  fill(yellow);
  rect(49, 451, 410 * constrain(sun / 1000.0, 0, 1),
       12, 5);

  fill(226, 237, 248);
  text("Load demand", 510, 440);
  text(nf(load * 100, 1, 0) + "%", 702, 440);

  fill(58, 75, 92);
  rect(510, 451, 410, 12, 5);
  fill(orange);
  rect(510, 451, 410 * load, 12, 5);

  fill(192, 211, 230);
  textSize(10);
  text("Use SUN and LOAD controls below.", 49, 494);
  text("Elapsed time: " + nf(t, 1, 1) + " seconds",
       510, 494);

  textAlign(LEFT, BASELINE);
}

// ------------------------------------------------------------
// FOOTER AND BUTTONS
// ------------------------------------------------------------

void footer() {
  noStroke();
  fill(11, 22, 36);
  rect(0, 565, SW, 85);

  fill(185, 205, 224);
  textAlign(LEFT);
  textSize(10);

  if (page == 0) {
    text("PV ARRAY → MPPT → INVERTER → LOAD / GRID", 20, 585);
  } else if (page == 1) {
    text("PHOTONS → CHARGE CARRIERS → P-N JUNCTION → DC", 20, 585);
  } else if (page == 2) {
    text("MPPT CONTROL → DC-DC CONVERSION → BATTERY", 20, 585);
  } else if (page == 3) {
    text("DC → INVERTER → AC → TRANSFORMER → GRID", 20, 585);
  } else {
    text("MONITOR THE ILLUSTRATIVE OPERATING VALUES", 20, 585);
  }

  fill(175, 194, 213);
  textSize(9);
  text("Educational model; electrical readings are illustrative.",
       20, 604);
  text("SIM TIME: " + nf(t, 1, 1) + " s", 20, 626);
}

void button(float x, float y, float w, float h,
            String labelText, color c) {
  stroke(180, 201, 222, 100);
  strokeWeight(1);
  fill(c);
  rect(x, y, w, h, 6);

  noStroke();
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(11);
  text(labelText, x + w / 2, y + h / 2);

  textAlign(LEFT, BASELINE);
}

void controls() {
  button(565, 576, 105, 36, "PREV",
         page > 0 ? color(68, 91, 114) : color(45, 55, 67));

  button(677, 576, 105, 36, "NEXT",
         page < 4 ? color(36, 133, 105) : color(45, 55, 67));

  button(789, 576, 87, 36, playing ? "PAUSE" : "PLAY",
         playing ? color(180, 119, 38) : color(36, 133, 105));

  button(883, 576, 95, 36, "RESET", color(83, 91, 112));

  button(565, 616, 66, 27, "SUN -", color(100, 88, 40));
  button(636, 616, 66, 27, "SUN +", color(100, 88, 40));

  button(707, 616, 72, 27, "LOAD -", color(102, 75, 50));
  button(784, 616, 72, 27, "LOAD +", color(102, 75, 50));

  button(861, 616, 117, 27,
         charging ? "CHARGE ON" : "CHARGE OFF",
         charging ? color(38, 121, 82) : color(100, 81, 50));
}

// ------------------------------------------------------------
// TOUCH CONTROLS
// ------------------------------------------------------------

void mousePressed() {
  float mx = (mouseX - ox) / scaleView;
  float my = (mouseY - oy) / scaleView;

  if (mx < 0 || mx > SW) return;

  if (my >= 576 && my <= 612) {
    if (mx >= 565 && mx <= 670) {
      page = max(0, page - 1);
    } else if (mx >= 677 && mx <= 782) {
      page = min(4, page + 1);
    } else if (mx >= 789 && mx <= 876) {
      playing = !playing;
    } else if (mx >= 883 && mx <= 978) {
      resetModel();
    }
    return;
  }

  if (my >= 616 && my <= 645) {
    if (mx >= 565 && mx <= 631) {
      sun = max(0, sun - 100);
    } else if (mx >= 636 && mx <= 702) {
      sun = min(1000, sun + 100);
    } else if (mx >= 707 && mx <= 779) {
      load = max(0.1, load - 0.1);
    } else if (mx >= 784 && mx <= 856) {
      load = min(1.0, load + 0.1);
    } else if (mx >= 861 && mx <= 978) {
      charging = !charging;
    }
  }
}

void resetModel() {
  page = 0;
  playing = true;
  charging = true;

  t = 0;
  sun = 800;
  load = 0.65;
  soc = 45;
  phase = 0;

  vdc = 0;
  idc = 0;
  pdc = 0;
  pac = 0;
  vac = 230;
  iac = 0;
  mppt = 0;

  for (int i = 0; i < photons.length; i++) {
    photons[i] = random(1);
  }
  for (int i = 0; i < electrons.length; i++) {
    electrons[i] = random(1);
  }
  for (int i = 0; i < dcFlow.length; i++) {
    dcFlow[i] = random(1);
  }
  for (int i = 0; i < acFlow.length; i++) {
    acFlow[i] = random(1);
  }
}
