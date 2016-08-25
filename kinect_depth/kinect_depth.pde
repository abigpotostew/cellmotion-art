// Thomas Sanchez Lengeling
// Kinect 3d Point Cloud example with different color types.

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import java.nio.*;
import org.openkinect.processing.Kinect2;

final int MAX_DEPTH = 4500; // out of 4500
final int DEPTH_BUFFER_SIZE = 512 * 424;
int maxDepth=4500;

Kinect2 kinect2;

float angle = 3.141594;
float scaleValue = 50;

//change color of the point cloud
int drawState = 1;

//openGL
PGL pgl;
PShader sh;

//VBO buffer location in the GPU
int vertexVboId;
int colorVboId;

int vertLoc;
int colorLoc;

final int DRAW =0, ADJUSTING = 1;
int state = DRAW;
boolean hasWritten = false;

//float[][] tmpBuffer;
float[] depthTmpBuffer;
//float[] depthTmpBuffer2;

void setup() {
  size(900, 700, P3D);

  kinect2 = new Kinect2(this);
  // Start all data
  kinect2.initDepth();
  kinect2.initIR();
  kinect2.initVideo();
  kinect2.initRegistered();
  kinect2.initDevice();

  //start shader
  //shader usefull to add post-render effects to the point cloud
  sh = loadShader("frag.glsl", "vert.glsl");
  smooth(16);

  //create VBO
  PGL pgl = beginPGL();

  // allocate buffer big enough to get all VBO ids back
  IntBuffer intBuffer = IntBuffer.allocate(2);
  pgl.genBuffers(2, intBuffer);

  //memory location of the VBO
  vertexVboId = intBuffer.get(0);
  colorVboId = intBuffer.get(1);
  
  //tmpBuffer = new float[2][DEPTH_BUFFER_SIZE*3];
  //depthTmpBuffer = tmpBuffer[0];
  //depthTmpBuffer2 = tmpBuffer[1];

  endPGL();
}


void draw() {
  if(state==ADJUSTING){
    maxDepth = (int)map(mouseX,0,width,0,4500);
    //println("hey ",maxDepth);
  }
  
  background(0);

  //draw all the Kinect v2 frames
  /*image(kinect2.getDepthImage(), 0, 0, 320, 240);
  image(kinect2.getIrImage(), 320, 0, 320, 240);
  image(kinect2.getVideoImage(), 320*2, 0, 320, 240);
  image(kinect2.getRegisteredImage(), 320*3, 0, 320, 240);
  */
  kinect2.getDepthImage();
  kinect2.getIrImage();
  kinect2.getVideoImage();
  kinect2.getRegisteredImage();
  fill(255);

  //rotate the scene
  pushMatrix();
  translate(width/2 - (cos(angle-HALF_PI)*4500*.5), height/2, scaleValue);
  rotateY(angle);
  stroke(255);

  //obtain the XYZ camera positions based on the depth data
  FloatBuffer depthPositions = kinect2.getDepthBufferPositions();
   
  {
    final int end = depthPositions.capacity(); //<>//
    if(depthTmpBuffer == null){
      depthTmpBuffer = new float[end];
    }
    depthPositions.get(depthTmpBuffer);
    for(int i = 2; i < end-2; i+=3){
      float z = depthTmpBuffer[i];//depthPositions.get(i);
      if(z>maxDepth) depthTmpBuffer[i]=-10000;
      //depthPositions.put(i,z);
      //float z = depthTmpBuffer[i+2];
      
    }
    depthPositions.rewind();
    depthPositions.put(depthTmpBuffer);
    depthPositions.rewind();
    if(keyPressed && key=='w'){
      writeKinectFrame(depthPositions,hasWritten,250);
       hasWritten = true;
    }
  }
   

  //obtain the color information as IntBuffers
  IntBuffer irData         = kinect2.getIrColorBuffer();
  IntBuffer registeredData = kinect2.getRegisteredColorBuffer();
  IntBuffer depthData      = kinect2.getDepthColorBuffer();

  pgl = beginPGL();
  sh.bind();

  //send the the vertex positions (point cloud) and color down the render pipeline
  //positions are render in the vertex shader, and color in the fragment shader
  vertLoc = pgl.getAttribLocation(sh.glProgram, "vertex");
  pgl.enableVertexAttribArray(vertLoc);

  //enable drawing to the vertex and color buffer
  colorLoc = pgl.getAttribLocation(sh.glProgram, "color");
  pgl.enableVertexAttribArray(colorLoc);
  
  int vertData = kinect2.depthWidth * kinect2.depthHeight;

  //vertex
  {
    pgl.bindBuffer(PGL.ARRAY_BUFFER, vertexVboId);
    // fill VBO with data
    pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertData * 3, depthPositions, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    pgl.vertexAttribPointer(vertLoc, 3, PGL.FLOAT, false, Float.BYTES * 3, 0);
  }


  //color
  //change color of the point cloud depending on the depth, ir and color+depth information.
  switch(drawState) {
  case 0:
    pgl.bindBuffer(PGL.ARRAY_BUFFER, colorVboId);
    // fill VBO with data
    pgl.bufferData(PGL.ARRAY_BUFFER,  Integer.BYTES * vertData, depthData, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    break;
  case 1:
    pgl.bindBuffer(PGL.ARRAY_BUFFER, colorVboId);
    // fill VBO with data
    pgl.bufferData(PGL.ARRAY_BUFFER,  Integer.BYTES * vertData, irData, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    break;
  case 2:
    pgl.bindBuffer(PGL.ARRAY_BUFFER, colorVboId);
    // fill VBO with data
    //int target, int size, Buffer data, int usage
    pgl.bufferData(PGL.ARRAY_BUFFER, Integer.BYTES * vertData, registeredData, PGL.DYNAMIC_DRAW);
    // associate currently bound VBO with shader attribute
    break;
  }
  //int index, int size, int type, boolean normalized, int stride, int offset
  pgl.vertexAttribPointer(colorLoc, 4, PGL.UNSIGNED_BYTE, false, Byte.BYTES, 0);
  
  // unbind VBOs
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

  //draw the point cloud as a set of points
  pgl.drawArrays(PGL.POINTS, 0, vertData);

  //disable drawing
  pgl.disableVertexAttribArray(vertexVboId);
  pgl.disableVertexAttribArray(colorVboId);

  sh.unbind();
  endPGL();

  popMatrix();

  text("Framerate: " + (int)(frameRate), 10, 515);
  text("Max Depth: " + (int)(maxDepth), 10, 525);
}

void keyPressed() {

  if (key == '1') {
    drawState = 0;
  }

  if (key == '2') {
    drawState = 1;
  }
  if (key == '3') {
    drawState = 2;
  }

  if (key == 'a') {
    angle += 0.1;
    println("angle "+angle,cos(angle));
  }

  if (key == 's') {
    angle -= 0.1;
    println("angle "+angle,cos(angle));
  }

  if (key == 'z') {
    scaleValue +=5;
    println("scaleValue "+scaleValue);
  }


  if (key == 'x') {
    scaleValue -=5;
    println("scaleValue "+scaleValue);
  }
  
  if (key=='d'){
    state = state==ADJUSTING?DRAW:ADJUSTING;
    println(state==ADJUSTING?"Adjusting":"Draw");
  }
  
  if (key=='w'){
    //writeKinectFrame(kinect2.getDepthBufferPositions());
  }
  
  if (key=='q'){
    exit();
  }
}