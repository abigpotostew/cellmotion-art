interface ICellMotion{
  
  public void setup(PApplet pa, Cells c, PImage source);
  public void stop(PApplet pa);
  public void draw(PApplet pa, Cells c, PImage source);
}