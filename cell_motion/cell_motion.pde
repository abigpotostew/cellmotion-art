int WIDTH, HEIGHT;
Cells cells;
OptFlow flow;
volatile PVector[][] buffer;

final float minFlowDistance = 3;

Capture video;
Movie myMovie;

PImage opticalSource;

Thread calcThread;

final static PVector ONE = new PVector(1,1);
final static PVector ZERO = new PVector(0,0);

final static int[][] rules = {
  //strains of kombucha:
  {0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1},
  //flappy mist clouds
  {0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
  //moving up
  {0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1},
  {0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0}
};

void setup(){
  size(480,480,P2D);
  WIDTH=width; HEIGHT=height;
  cells = new Cells(WIDTH,HEIGHT, 3);
  cells.setRules(rules);
  flow = new OptFlow (this,WIDTH,HEIGHT);
  
   video = new Capture(this, WIDTH,HEIGHT);
   video.start();
   opticalSource = video;
   /*myMovie = new Movie(this, "street.mov");
   myMovie.loop();
   opticalSource = myMovie;*/
  

  buffer = flow.buildFlowBuffer();
  
  //init buffer for debug
  /*for(int y=0;y<buffer.length;++y){
    for(int x=0;x<buffer[y].length;++x){
      buffer[y][x] = new PVector();
      if (y<100 || x<100 || y > 500 || x > 500){
        buffer[y][x].set(100,100);
      }
    }
  }*/
  
  
  calcThread = new Thread()
  {
    public void run() {
      while(true){
        flow.calculate (buffer, opticalSource);
        synchronized(cells){
          setCellsToFlow (buffer, cells); //syncronized
        }
        if (Thread.interrupted()) {
          println("end thread");
          return;
        }
      }
    }
  };
  calcThread.start();
}

void nonSynchronizedDraw(){
  //ccimage(video,0,0);
  
  cells.update();
  flow.calculate (buffer,opticalSource);
  setCellsToFlow (buffer, cells);
  cells.draw();
}

void synchronizedDraw(){
  synchronized(cells){
    cells.update();
    setCellsToFlow(buffer,cells);
    cells.draw();
  }
}

void draw(){
  background(0);
  
  synchronizedDraw();
  //nonSynchronizedDraw();
  
  /*synchronized(cells){ //debug draw
    stroke(255,0,0);
    final int w = buffer.length, h = buffer[0].length;
    final int stepSize = 3;
    PVector flowVec;
    for (int y = 0; y < h; y+=stepSize) {
      for (int x = 0; x < w; x+=stepSize) {
        flowVec = buffer[y][x];
        if(flowVec!=null){
          //print("yo");
          if (len2(flowVec) > minFlowDistance)
            line(x, y, x+flowVec.x, y+flowVec.y);
        }
      }
    }
  }*/
  /////flow.debugDraw(myMovie);
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


void captureEvent(Capture c) {
  c.read();
}

void movieEvent(Movie m) {
  m.read();
}


void stop(){
  calcThread.interrupt();
  flow.stop();
  
}

float len2(PVector p){
  return p.dot(ONE);
}