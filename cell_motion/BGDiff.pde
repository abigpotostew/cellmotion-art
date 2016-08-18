import gab.opencv.*;
import processing.video.*;
import java.awt.*;

class BGDiff implements ICellMotion{
  OpenCV opencv;
  PGraphics pg;
  
  BGDiff(PApplet pa, int w, int h){
    WIDTH = w;
    HEIGHT = h;
  }
  
  public void setup(PApplet pa, Cells c, PImage source){
    opencv = new OpenCV(pa, WIDTH, HEIGHT);
    opencv.startBackgroundSubtraction(5, 3, 0.5);
    pg = pa.createGraphics(WIDTH,HEIGHT,P2D);
  }
  public void stop(PApplet pa){
    
  }
  public void draw(PApplet pa, Cells c, PImage source){
    pa.background(0);
    //pa.image(source,0,0);
    opencv.loadImage (source);
    opencv.updateBackground();
    opencv.dilate();
    opencv.erode();
    
    //pg.beginDraw();
    for (Contour contour : opencv.findContours()) {
      contour.draw();
    }
    //pg.endDraw();
    c.update();
    int clsize = c.getLifesize();
    int cellsize = c.getCellSize();
    float scale = clsize/pa.width;
    for(int x=0;x<clsize;x+=cellsize){
      for(int y=0;y<clsize;y+=cellsize){
        if(pa.get(x,y)>0){
          c.setCellAlive(x,y);
          println(x,y);
        }
      }
    }
    c.draw();
    
  }
}