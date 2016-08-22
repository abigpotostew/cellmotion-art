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
    //pg = pa.createGraphics(WIDTH,HEIGHT,P2D);
  }
  public void stop(PApplet pa){
    
  }
  
  private void maxColor(int[] pxls, int _x, int _y, int w, int h){
    //for(int x=0;x<_x+w
  }
  
  public void draw(PApplet pa, Cells c, PImage source){
    pa.background(0);
    
    //pa.loadPixels();
    //int[] pxls = pa.pixels;
    
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
    int clsize = c.getLifesize(); //num cells
    int cellsize = c.getCellSize(); //pixel size
    //float scale = clsize/pa.width;
    int ct=0;
    //x and y in pixels
    for(int x=cellsize/2;x<pa.width;x+=cellsize){
      for(int y=cellsize/2;y<pa.height;y+=cellsize){
        //cc = pa.get(x,y);//pxls[y*pa.width+x];
        if ( averageBrightnessAt (x,y) > 10){
          c.setCellAlive (x,y);
          //println(x,y);
          ct++;
        }
      }
    }
    pa.background(0);
    //println(ct);
    c.draw();
    
  }
}