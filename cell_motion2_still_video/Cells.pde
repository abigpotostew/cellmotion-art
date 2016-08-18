class Cells{
  int cellSize;// = 3;
int simulationSpeed = 1; //smaller is faster

int[] rule;
final int neighborsCt = 5;
 
//Program Vars
int[][] world,copy;
int lifeSize;// = WIDTH/cellSize;
int cellFillColor = 255;
int cellStrokeColor = 0;
boolean isDragging;
  int WIDTH, HEIGHT;
  
int delta = 0;
boolean keyDown=false;
  
  Cells(int w, int h, int _cellSize){
    WIDTH=w; HEIGHT=h;
    cellSize = _cellSize;
    lifeSize = w/cellSize;
    world = new int[lifeSize][lifeSize];
    copy = new int[lifeSize][lifeSize];
    rule = new int[1<<neighborsCt];
    randomRule();
  }
  
  public void setCellAlive(PVector pos){
    setCellAlive ( (int)pos.x, (int)pos.y);
  }
  
  public void clearRule(){
    for(int i=0;i<rule.length;++i){
      rule[i]=0;
    }
    println("Rule cleared to 0");
  }
  
  synchronized public void setCellAlive(int x, int y){
    x = floor(x / cellSize);
    y = floor(y / cellSize);
    if ( x < lifeSize && x > 0 && y < lifeSize && y > 0 ){
      if ( world[y][x] != 1 )
        world[y][x] = 1;
    }
  }
  
  private int applyRule(int[] rule, int[][] W, final int x, final int y){
    int state = 0;
    int xi, yi;
    final int[][] offset = {{-1,0},{0,-1},{1,0},{0,1},{0,0}};
    for(int i=4;i>=0;--i){
       state <<= 1;
       xi = x+offset[i][0];
       yi = y+offset[i][1];
       if(xi<0) xi+=lifeSize;
       if(xi>=lifeSize) xi%=lifeSize;
       if(yi<0) yi+=lifeSize;
       if(yi>=lifeSize) yi%=lifeSize;
       if(W[yi][xi] > 0){
         state += 1;
       }
    }
    //state >>= 1;
    int mask = (1<<(state));
    return rule[state]; //return value of bit counted at state
}

private void updateWorld ( int[][] W, int[] rule ) {

  for ( int y = 0; y < lifeSize; y++ ) {
    for ( int x = 0; x < lifeSize; x++ ) {
      copy[y][x] = applyRule(rule, W, x,y);

    }
  }
  int[][] tmp = W;
  W = copy;
  copy = tmp;
}

private void resetWorld(){
  for(int y=0;y<lifeSize;++y){
    for(int x=0;x<lifeSize;++x){
      world[y][x] = 0;
    }
  }
  final int cx=lifeSize/2, cy = lifeSize/2;
  world[cy-1][cy-0] = 1;
  world[cy+1][cy-0] = 1;
  world[cy+0][cy-1] = 1;
  world[cy+0][cy+1] = 1;
  
}

void update(){
  if ( ++delta == simulationSpeed ){
    delta = 0;
    updateWorld(world, rule);
  }
}

 synchronized void draw() {
  if(keyPressed && !keyDown){
    keyDown = true;
    switch(key){
      case 'c':
        clearRule(); break;
      case 'r':
        resetWorld(); break;
      default:
        randomRule(); break;
    }
  }else{
    keyDown = false;
  }
  //background(0);
  stroke(cellStrokeColor);
  
  //if(mousePressed)m.update(world,mousePressed);
  
  //draw world
  fill(cellFillColor);
  for ( int y = 0; y < lifeSize; y++ ){
    for ( int x = 0; x < lifeSize; x++ ){
      if ( world[y][x] == 1 ) {
        rect( x*cellSize, y*cellSize, cellSize, cellSize );
      }
    }
  }
  //m.display();
  //fill (255,0,0);
}

private void randomRule(){
  //rule = (int)random(0,429496729);
  for(int i=0;i<rule.length;++i){
    rule[i] = (int)random(2);
  }
}

}