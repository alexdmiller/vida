import codeanticode.syphon.*;
import controlP5.*;

ControlP5 cp5;

PShader simulationShader;
PShader renderShader;
PShader noiseShader;

PGraphics noiseCanvas;
PGraphics simulationCanvas;
PGraphics renderCanvas;

// resolution of the actual simulation
int simulationWidth = 610;
int simulationHeight = 244;

// the number of pixels on the physical screen
int screenPixelWidth = 610/2;
int screenPixelHeight = 244/2;

// the size to render the screen at
int renderWidth = 610 * 3;
int renderHeight = 244 * 3;

// Simulation parameters
float outerRadius = 10;
float innerRadius = 3;
float birthMin = 0.257; 
float birthMax = 0.336;
float deathMin = 0.365;
float deathMax = 0.549;
float alphaN = 0.028;
float alphaM = 0.147;

float noiseAmplitude = 0;
float noiseScale = 4;

boolean record = false;

void setup() {
  fullScreen(P2D);
  
  simulationCanvas = createGraphics(simulationWidth, simulationHeight, P2D);
  simulationShader = loadShader("smoothlife.glsl");
  
  noiseCanvas = createGraphics(simulationWidth, simulationHeight, P2D);
  noiseShader = loadShader("noise.glsl");
  
  renderCanvas = createGraphics(renderWidth, renderHeight, P2D);
  renderShader = loadShader("led.glsl");
  renderShader.set("screenResolution", float(screenPixelWidth), float(screenPixelHeight));
  renderShader.set("renderResolution", float(renderWidth), float(renderHeight));
  
  setupGUI();
}

void draw() {  
  background(0);
  
  noiseShader.set("time", millis()/1000.0);
  noiseShader.set("scale", noiseScale);
  noiseShader.set("amplitude", noiseAmplitude);
  noiseCanvas.beginDraw();
  noiseCanvas.shader(noiseShader);
  noiseCanvas.rect(0, 0, simulationWidth, simulationHeight);
  noiseCanvas.endDraw();
  
  simulationShader.set("time", millis()/1000.0);
  simulationShader.set("outerRadius", outerRadius);
  simulationShader.set("innerRadius", innerRadius);
  simulationShader.set("b1", birthMin);
  simulationShader.set("b2", birthMax);  
  simulationShader.set("d1", deathMin);
  simulationShader.set("d2", deathMax);
  simulationShader.set("alpha_n", alphaN);
  simulationShader.set("alpha_m", alphaM);
  simulationShader.set("noiseMap", noiseCanvas);
  
  simulationCanvas.beginDraw();
  simulationCanvas.background(0);
  simulationCanvas.shader(simulationShader);
  simulationCanvas.rect(0, 0, simulationWidth, simulationHeight);
  simulationCanvas.endDraw();
    
  renderCanvas.beginDraw();
  renderCanvas.background(0);
  renderCanvas.shader(renderShader);
  renderCanvas.image(simulationCanvas, 0, 0, renderWidth, renderHeight);
  renderCanvas.endDraw();

  image(renderCanvas, 0, 400);
  image(noiseCanvas, 1300, 0);
  image(simulationCanvas, 700, 0);
  
  fill(255);
  text(frameRate, 20, height - 20);
  
  if (record) {
    renderCanvas.save("panel" + nf(frameCount, 4) +".png");
  }
}

void keyPressed() {
  if (key == 's') {
    record = !record;
  }
}

void setupGUI() {
  cp5 = new ControlP5(this);
  
  cp5.addRange("radius")
      .setSize(500, 30)
      .setPosition(20, 20)
      .setBroadcast(false)
      .setRange(0, 20)
      .setRangeValues(innerRadius, outerRadius)
      .setBroadcast(true);
      
  cp5.addRange("birth")
      .setSize(500, 30)
      .setPosition(20, 60)
      .setBroadcast(false)
      .setRange(0, 1)
      .setRangeValues(birthMin, birthMax)
      .setBroadcast(true);

  cp5.addRange("death")
      .setSize(500, 30)
      .setPosition(20, 100)
      .setBroadcast(false)
      .setRange(0, 1)
      .setRangeValues(deathMin, deathMax)
      .setBroadcast(true);
      
  cp5.addSlider("noiseAmplitude")
      .setSize(500, 30)
      .setBroadcast(false)
      .setPosition(20, 140)
      .setRange(0, 1)
      .setValue(0)
      .setBroadcast(true);

  cp5.addSlider("noiseScale")
      .setSize(500, 30)
      .setBroadcast(false)
      .setPosition(20, 180)
      .setRange(0, 20)
      .setValue(4)
      .setBroadcast(true);

  cp5.end();
}

void controlEvent(ControlEvent event) {
  if (event.isFrom("radius")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    innerRadius = event.getController().getArrayValue(0);
    outerRadius = event.getController().getArrayValue(1);
  } else if (event.isFrom("birth")) {
    birthMin = event.getController().getArrayValue(0);
    birthMax = event.getController().getArrayValue(1);
  } else if (event.isFrom("death")) {
    deathMin = event.getController().getArrayValue(0);
    deathMax = event.getController().getArrayValue(1);
  } else if (event.isFrom("noise")) {
    noiseAmplitude = event.getController().getValue();
  } else if (event.isFrom("noiseScale")) {
    noiseScale = event.getController().getValue();
  }
}
