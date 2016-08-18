import gab.opencv.*;
import processing.video.*;
import java.awt.*;

class OptFlow implements ICellMotion{
  
  
  volatile PVector[][] buffer;
  
  Thread calcThread;
  OpenCV opencv;
  final int WIDTH, HEIGHT;

  final PVector ZERO = new PVector();


  OptFlow(PApplet pa, int w, int h){
    WIDTH = w;
    HEIGHT = h;
    opencv = new OpenCV(pa, w, h);
  }
  
  public void calculate(PVector[][] buffer, PImage m){
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
  
  void debugDraw(PImage m){
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
    
    public void stop(PApplet pa){
    //video.stop();
      calcThread.interrupt();
    }
    
    public void setup(PApplet pa, Cells c, PImage source)
    {
      this.buffer = this.buildFlowBuffer();
      
      calcThread = new Thread(new OptFlowRunnable(this, source, c));
      calcThread.start();
    }
  
  class OptFlowRunnable implements Runnable{
    OptFlow oflow;
    PImage optSrc;
    Cells c;
    
    OptFlowRunnable(OptFlow _oflow, PImage _optSrc, Cells _c){
      oflow = _oflow;
      optSrc = _optSrc;
      c = _c;
    }
    public void run() {
      while(true){
        calculate (oflow.buffer, optSrc);
        synchronized(c){
          setCellsToFlow (oflow.buffer, c); //syncronized
        }
        if (Thread.interrupted()) {
          println("end thread");
          return;
        }
    }
    }
  }


  void nonSynchronizedDraw(){
    //ccimage(video,0,0);
    
    cells.update();
    ((OptFlow)motion).calculate (((OptFlow)motion).buffer,opticalSource);
    setCellsToFlow (((OptFlow)motion).buffer, cells);
    cells.draw();
  }

  void synchronizedDraw(Cells c, PImage source){
    synchronized(c){
      c.update();
      setCellsToFlow(this.buffer,c);
      c.draw();
    }
  }

  public void draw(PApplet pa, Cells c, PImage source){
    synchronizedDraw( c,  source);
    //nonSynchronizedDraw();
  }
}

void setCellsToFlow(PVector[][] flowBuffer, Cells cells){
  final int w = flowBuffer.length, h = flowBuffer[0].length;
  final int stepSize = 3;
  float f;
  for (int y = 0; y < h; y+=stepSize) {
    for (int x = 0; x < w; x+=stepSize) {
      if(flowBuffer[y][x]==null) return;
      f = len2 (flowBuffer[y][x]);
      if ( f > minFlowDistance){
        cells.setCellAlive (x,y);
          //println(f);
      }
    }
  }
}