import netP5.*;
import oscP5.*;
import processing.video.*;
import controlP5.*;

//movie
Movie normal;
float normalAlpha = 255;
Movie plane;
float planeAlpha = 0;
boolean triggered;
float triggeredTime;
boolean normalFadingIn, normalFadingOut, planeFadingIn, planeFadingOut;
float fadeStep = 1;
//controlp5
ControlP5 cp5;
Chart brainWaveChart;

//osc
OscP5 oscP5;



void setup() {
  size(640, 480);
  normal = new Movie(this, "balcony_normal.mp4");
  normal.loop();
  plane = new Movie(this, "balcony_plane.mp4");

  //controlp5
  cp5 = new ControlP5(this);
  brainWaveChart = cp5
    .addChart("brainWave")
    .setPosition(10, 10)
    .setRange(0, 1)
    .setSize(200, 30)
    .setView(Chart.LINE);
  brainWaveChart.addDataSet("brainWave");


  cp5.addButton("TriggerAbnormal")
    .setPosition(10, 60)
    .setSize(200, 20);

  //osc
  oscP5 = new OscP5(this, 5001);
}


void draw() {
  background(255);


  if (planeFadingIn && planeAlpha < 255) {
    planeAlpha += fadeStep;
  }

  if (planeFadingOut && planeAlpha > 0) {
    planeAlpha -= fadeStep;
    if (planeAlpha <= 0) {
      plane.stop();
      triggered = false;
    }
  }

  if (millis()-triggeredTime > 12000) {
    normalFadingIn = true;
    normalFadingOut = false;
    planeFadingIn = false;
    planeFadingOut = true;
  }
  tint(255, normalAlpha);
  image(normal, 0, 0);
  tint(255, planeAlpha);
  image(plane, 0, 0);
}

void movieEvent(Movie m) {
  m.read();
}

void controlEvent(ControlEvent e) {
  if (e.isFrom("TriggerAbnormal")) {
    trigger();
  }
}

void oscEvent(OscMessage m) {
  //  println(m.addrPattern());
  //  println("---");
  if (m.checkAddrPattern("/muse/elements/experimental/concentration")) {
    float incomevalue = m.get(0).floatValue();
    if (incomevalue>0.9) {
      trigger();
    }
    brainWaveChart.push("brainWave", incomevalue);
  }
}

void trigger () {
  if (!triggered)triggeredTime = millis();
  triggered = true;
  //normalFadingIn = false;
  //normalFadingOut = true;
  planeFadingIn = true;
  planeFadingOut = false;
  plane.play();
}