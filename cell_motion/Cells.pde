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

int[][] ruleBank;
int ruleBankIdx=0;
  
  Cells(int w, int h, int _cellSize){
    WIDTH=w; HEIGHT=h;
    cellSize = _cellSize;
    lifeSize = w/cellSize;
    world = new int[lifeSize][lifeSize];
    copy = new int[lifeSize][lifeSize];
    rule = new int[1<<neighborsCt];
    randomRule();
  }
  
  //num cells across
  public int getLifesize(){
    return this.lifeSize;
  }
  
  //pixel size of a cell
  public int getCellSize(){
    return this.cellSize;
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
  
  public void copyRule (final int[] other){
    assert(other.length >= rule.length);
    arrayCopy (other,rule, rule.length);
  }
  
  public void setRules(int[][] these){
    ruleBank = these;
  }
  
   public void setCellAlive(int x, int y){
    setCell(x,y,1);
  }
  
  //x,y in pixels
  public void setCell(int x, int y, int state){
    x = floor(x / cellSize);
    y = floor(y / cellSize);
    if ( x < lifeSize && x > 0 && y < lifeSize && y > 0 ){
      if ( world[y][x] != state )
        world[y][x] = state;
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
  
  int neighborCount ( int _x, int _y ) {
    int ct = 0;
    int xi,yi;
    for ( int y = -1; y <= 1; y++) {
      for ( int x = -1; x <= 1; x++) {
        xi = x+_x;
        yi = y+_y;
        if(xi<0) xi+=lifeSize;
        if(xi>=lifeSize) xi%=lifeSize;
        if(yi<0) yi+=lifeSize;
        if(yi>=lifeSize) yi%=lifeSize;
        
        if (xi == _x && yi == _y );
        else ct += world[yi][xi];
        
      }
    }
    return ct;
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
  
  void incRuleBank(){
    copyRule(ruleBank[ruleBankIdx]);
    println(ruleBankIdx);
    ruleBankIdx = (ruleBankIdx+1)%ruleBank.length;
    
  }

 void draw() {
    if(keyPressed){
      if(!keyDown){
      switch(key){
        case 'z':
          incRuleBank();
          break;
        case 'a':
          writeRule(rule); break;
        case 'c':
          clearRule(); break;
        case 'r':
          resetWorld(); break;
        default:
          randomRule(); break;
      }
      }
      keyDown = true;
    }else{
      keyDown = false;
    }
    //background(0);
    stroke(cellStrokeColor);
    
    //if(mousePressed)m.update(world,mousePressed);
    
    //draw world
    fill(cellFillColor);
    int ct;
    for ( int y = 0; y < lifeSize; y++ ){
      for ( int x = 0; x < lifeSize; x++ ){
        if ( world[y][x] == 1 ) {
          ct = neighborCount(x,y);
          fill(map(ct,0,8,0,255),67,20);
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