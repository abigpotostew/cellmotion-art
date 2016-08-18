import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

final PVector ZERO = new PVector();
final static PVector ONE = new PVector(1,1);

void setup() {
  size(640, 480, P3D);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  
  //opencv.flow.setWindowSize(15);

  video.start();
}

void draw() {
  //scale(2);
  opencv.loadImage(video);
  opencv.calculateOpticalFlow();

  image (video, 0, 0, width, height );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  
  Flow flow = opencv.flow;
  final int stepSize = 6;
  final int halfStep = stepSize/2;
  
  float w = opencv.flow.width(), h = opencv.flow.height();
  float sw = width/w, sh = height/h;
  PVector flowVec;
  float xi,yi;
  
  for (int y = 0; y < h; y+=stepSize) {
    for (int x = 0; x < w; x+=stepSize) {
      /*flowVec = flow.getAverageFlowInRegion(
        clamp (x-halfStep,0, (int)w),
        clamp (y-halfStep,0,(int)h),stepSize,stepSize);*/
        flowVec = opencv.getFlowAt(x,y);
      if (len2(flowVec) > 2 ){
        xi = x*sw;
        yi = y*sh;
         line(xi, yi, xi+flowVec.x, yi+flowVec.y);
      }
    }
  }
  //flow.draw();
  //opencv.drawOpticalFlow();
}


int clamp(int v, int lo, int hi){
  return min(max(v, lo),hi);
}

void captureEvent(Capture c) {
  c.read();
}

float len2(PVector p){
  return p.dot(ONE);
}