//13 bits to represent 1 depth value
//use char (unsigned 16 bit)

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
//import java.io.IOException;

void writeKinectFrame(FloatBuffer depthPositions){
  //File file = new File("depth.data");
  //createPath(file);
  //;
  String file = savePath("depth.data");
  //FileOutputStream fos = openFile(file);
  println(file);
  try{
    DataOutputStream dos = new DataOutputStream(new BufferedOutputStream(openFile(file)));
    depthPositions.rewind();
    float v;
    float max=0, min=100000.0;
    for( int i=0;i<depthPositions.capacity();++i){ //should by 512*424
      v = depthPositions.get(i);
      if ((v)>max){
        max=(v);
      }
      if(v<min)min=v;
      //output.print (v);
      dos.writeFloat(v);
    }
    dos.flush();
    dos.close();
    println("Max:", max, "Min:", min);
    exit(); 
  }catch(IOException e){
    System.out.println("IOException : " + e);
      exit();
  }
}

FileOutputStream openFile(String path){
  try
    {
      return new FileOutputStream(path);
  }
    catch (IOException e)
    {
      System.out.println("IOException : " + e);
      exit();
    }
    return null;
}

void readKinectFrame(){
  
}