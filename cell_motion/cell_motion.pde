int WIDTH, HEIGHT;
Cells cells;
//OptFlow flow;

ICellMotion motion;

final float minFlowDistance = 3;

Capture video;
Movie myMovie;

PImage opticalSource;


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
  
  
   if(false){
     video = new Capture(this, WIDTH,HEIGHT);
     video.start();
     opticalSource = video;
   } else{
   
     myMovie = new Movie(this, "street.mov");
     myMovie.loop();
     opticalSource = myMovie;
   }
  

  //motion = new OptFlow (this,WIDTH,HEIGHT);
  motion = new BGDiff (this,WIDTH,HEIGHT);
  
  motion.setup(this,cells, opticalSource);
    
  
  
}



void draw(){
  surface.setTitle("FPS: "+frameRate);
  
  
  motion.draw (this, cells, opticalSource);
  
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




void captureEvent(Capture c) {
  c.read();
}

void movieEvent(Movie m) {
  m.read();
}


void stop(){
  //flow.stop();
  motion.stop(this);
}

float len2(PVector p){
  return p.dot(ONE);
}