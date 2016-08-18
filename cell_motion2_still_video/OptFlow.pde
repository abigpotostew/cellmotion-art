import gab.opencv.*;
import processing.video.*;
import java.awt.*;

class OptFlow{
  
  OpenCV opencv;
  final int WIDTH, HEIGHT;

final PVector ZERO = new PVector();


  OptFlow(PApplet pa, int w, int h){
    WIDTH = w;
    HEIGHT = h;
    
      //video = new Capture(pa, w, h);

      
    opencv = new OpenCV(pa, w, h);
  }
  
  public void start(){
    //video.start();
  }
  
  void captureEvent(final Capture c){
    if (c==video){
      c.read();
    }
  }
  
  synchronized public void calculate(PVector[][] buffer){
    opencv.loadImage(video);
    opencv.calculateOpticalFlow();
    allFlow(buffer);
  }
  
  synchronized public void calculate(PVector[][] buffer, Movie m){
    opencv.loadImage(m);
    opencv.calculateOpticalFlow();
    allFlow(buffer);
  }
  
  final private void allFlow(PVector[][] buffer){
    //Flow f = opencv.flow;
    assert(buffer.length <= HEIGHT);
    assert(buffer[0].length <= WIDTH);
    PVector v;
    for (int y=0; y<buffer.length;++y){
      for (int x=0; x<buffer[y].length;++x){
        v = opencv.getFlowAt(x,y);
        buffer[y][x] = v;
      }
    }
    //return buffer;
  }
  
  PVector[][] buildFlowBuffer(){
    return new PVector[HEIGHT][WIDTH];
  }
  
  synchronized void debugDraw(Movie m){
    //opencv.loadImage(video);
    //opencv.calculateOpticalFlow();

    image(m==null?video:m, 0, 0, width, height );
  
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    
    Flow flow = opencv.flow;
    final int stepSize = 8;
    final int halfStep = stepSize/2;
    
    float w = flow.width(), h=flow.height();
    float sw = width/w, sh = height/h;
    PVector flowVec;
    float xi,yi;
    
    for (int y = 0; y < h; y+=stepSize) {
      for (int x = 0; x < w; x+=stepSize) {
        /*flowVec = flow.getAverageFlowInRegion(
          clamp (x-halfStep,0, (int)w),
          clamp (y-halfStep,0,(int)h),stepSize,stepSize);*/
          flowVec = flow.getFlowAt(x,y);
        //if (ZERO.dist(flowVec) > .2 ){
          xi = x*sw;
          yi = y*sh;
           line(xi, yi, xi+flowVec.x, yi+flowVec.y);
        //}
      }
    }
  }
  
  public void stop(){
    video.stop();
  }
}