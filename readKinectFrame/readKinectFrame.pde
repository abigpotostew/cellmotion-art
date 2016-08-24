// Thomas Sanchez Lengeling
// Kinect 3d Point Cloud example with different color types.

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import java.nio.*;
import java.io.DataInputStream;
import java.io.BufferedInputStream;
import java.io.FileInputStream;


final int MAX_DEPTH = 4500; // out of 4500
final int DEPTH_BUFFER_SIZE = 512 * 424;
int maxDepth=4500;


float angle = 3.141594;
float scaleValue = 50;


//openGL
PGL pgl;
PShader sh;

//VBO buffer location in the GPU
int vertexVboId;
int colorVboId;

int vertLoc;

FloatBuffer depthPositions;

void setup() {
  size(900, 700, P3D);



  //start shader
  //shader usefull to add post-render effects to the point cloud
  sh = loadShader("frag.glsl", "vert.glsl");
  smooth(16);

  //create VBO
  PGL pgl = beginPGL();

  // allocate buffer big enough to get all VBO ids back
  IntBuffer intBuffer = IntBuffer.allocate(1);
  pgl.genBuffers(1, intBuffer);

  //memory location of the VBO
  vertexVboId = intBuffer.get(0);
  

  endPGL();
  
   depthPositions = readKinectFrame(sketchPath()+"/data/"+"depth.data");
}

float[] readKinectFrameRaw(String absPath){
  float[] raw = new float[512*424*3];
  try{
    DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream(absPath)));
    int i=0;
    while(in.available()>0){
      raw[i++]=in.readFloat();
    }
  } catch(IOException e){
    System.out.println("IOException : " + e);
    exit();
  }
  return raw;
}

FloatBuffer readKinectFrame(String absPath){
  float[] raw = readKinectFrameRaw(absPath);
  FloatBuffer out = FloatBuffer.allocate(raw.length*2);
  out.put(raw);
  out.rewind();
  return out;
}

void draw() {
  
  background(0);


  //rotate the scene
  pushMatrix();
  translate(width/2 + map(mouseX,0,width,-5000,5000)/*- (cos(angle-HALF_PI)*4500*.5)*/, height/2 + map(mouseY,0,height,-5000,5000), scaleValue);
  rotateY(angle);
  //rotateZ(HALF_PI);
  
  stroke(255);

  //obtain the XYZ camera positions based on the depth data
  
   
  

  pgl = beginPGL();
  sh.bind();

  //send the the vertex positions (point cloud) and color down the render pipeline
  //positions are render in the vertex shader, and color in the fragment shader
  vertLoc = pgl.getAttribLocation(sh.glProgram, "vertex");
  pgl.enableVertexAttribArray(vertLoc);

  
  int vertData = 512*424;//kinect2.depthWidth * kinect2.depthHeight;

  //vertex
  {
    pgl.bindBuffer(PGL.ARRAY_BUFFER, vertexVboId);
    // fill VBO with data
    pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertData * 3, depthPositions, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    pgl.vertexAttribPointer(vertLoc, 3, PGL.FLOAT, false, Float.BYTES * 3, 0);
  }


  
  // unbind VBOs
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

  //draw the point cloud as a set of points
  pgl.drawArrays(PGL.POINTS, 0, vertData);

  //disable drawing
  pgl.disableVertexAttribArray(vertexVboId);

  sh.unbind();
  endPGL();

  popMatrix();

  text("Framerate: " + (int)(frameRate), 10, 515);
  
  if(keyPressed){
    if (key == 'a') {
    angle += 0.1;
    println("angle "+angle);
  }

  if (key == 's') {
    angle -= 0.1;
    println("angle "+angle);
  }

  if (key == 'z') {
    scaleValue +=5;
    println("scaleValue "+scaleValue);
  }


  if (key == 'x') {
    scaleValue -=5;
    println("scaleValue "+scaleValue);
  }
    
  }
}


void keyPressed() {


  
  
}