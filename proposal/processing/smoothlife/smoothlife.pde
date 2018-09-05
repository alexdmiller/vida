import controlP5.*;

ControlP5 cp5;

PShader simulationShader;
PShader renderShader;

PGraphics simulationCanvas;
PGraphics renderCanvas;

// Simulation parameters
float outerRadius = 10;
float innerRadius = 3;
float birth1 = 0.257; 
float birth2 = 0.336;
float death1 = 0.365;
float death2 = 0.549;
float alphaN = 0.028;
float alphaM = 0.147;

float renderScale = 6;

void setup() {
  fullScreen(P2D);    
  
  simulationCanvas = createGraphics(610/2, 244/2, P2D);
  simulationShader = loadShader("smoothlife.glsl");
  simulationShader.set("resolution", float(simulationCanvas.width), float(simulationCanvas.height));
  
  renderCanvas = createGraphics(int(simulationCanvas.width * renderScale), int(simulationCanvas.height * renderScale), P2D);
  renderShader = loadShader("led.glsl");
  renderShader.set("pixelSize", float(simulationCanvas.width), float(simulationCanvas.height));
  
  setupGUI();
}

void draw() {
  background(0);
  
  simulationShader.set("time", millis()/1000.0);
  simulationShader.set("keyDown", keyPressed);
  simulationShader.set("outerRadius", outerRadius);
  simulationShader.set("innerRadius", innerRadius);
  simulationShader.set("b1", birth1);
  simulationShader.set("b2", birth2);
  simulationShader.set("d1", death1);
  simulationShader.set("d2", death2);
  simulationShader.set("alpha_n", alphaN);
  simulationShader.set("alpha_m", alphaM);
  
  simulationCanvas.beginDraw();
  simulationCanvas.background(0);
  simulationCanvas.shader(simulationShader);
  simulationCanvas.rect(0, 0, simulationCanvas.width, simulationCanvas.height);
  simulationCanvas.endDraw();
  
  renderCanvas.beginDraw();
  renderCanvas.background(0);
  renderCanvas.shader(renderShader);
  renderCanvas.image(simulationCanvas, 0, 0, renderCanvas.width, renderCanvas.height);
  renderCanvas.endDraw();
  
  image(renderCanvas, 0, 0);
  image(simulationCanvas, 400, 850);

  fill(255);
  text(frameRate, 20, height - 20);
}

void keyPressed() {
  if (key == 's') {
    renderCanvas.save("panel" + frameCount +".png");
  }
}

void setupGUI() {
  cp5 = new ControlP5(this);
  cp5.addSlider("outerRadius")
     .setPosition(20,40 + 800)
     .setRange(0,30);
     
  cp5.addSlider("innerRadius")
     .setPosition(20,60 + 800)
     .setRange(0,30);

  cp5.addSlider("birth1")
     .setPosition(20,80 + 800)
     .setRange(0,1); 
  cp5.addSlider("birth2")
     .setPosition(20,100 + 800)
     .setRange(0,1);
  cp5.addSlider("death1")
     .setPosition(20,120 + 800)
     .setRange(0,1);
  cp5.addSlider("death2")
     .setPosition(20,140 + 800)
     .setRange(0,1);
  cp5.addSlider("alphaN")
     .setPosition(20,160 + 800)
     .setRange(0,1);
  cp5.addSlider("alphaM")
     .setPosition(20,180 + 800)
     .setRange(0,1);
}
