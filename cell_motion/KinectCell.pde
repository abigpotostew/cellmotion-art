  import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import org.openkinect.processing.*;

class KinectCell implements ICellMotion{
  OpenCV opencv;
  Kinect2 kinect;
  
  KinectCell(PApplet pa, int w, int h){
    WIDTH = w;
    HEIGHT = h;
  }
  
  public void setup(PApplet pa, Cells c, PImage source){
    kinect = new Kinect2(pa);
    kinect.initDevice();
  }
  public void stop(PApplet pa){
    
  }
  
  private void maxColor(int[] pxls, int _x, int _y, int w, int h){
    //for(int x=0;x<_x+w
  }
  
  public void draw(PApplet pa, Cells c, PImage source){
    pa.background(0);
    //int[] depth = kinect.getRawDepth(); //0-4500
    c.draw();
    
  }
}