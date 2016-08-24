//13 bits to represent 1 depth value
//use char (unsigned 16 bit)

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
//import java.io.IOException;

void writeKinectFrame(FloatBuffer depthPositions, boolean appendMode){

  String file = savePath("depth.data");
  println(file);
  
  try{
    DataOutputStream dos = new DataOutputStream(
                             new BufferedOutputStream(
                               new FileOutputStream(file, appendMode) ) );
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
    //dos.writeFloat(Float.NaN);
    
    dos.flush();
    dos.close();
    println("Max:", max, "Min:", min);
    //exit(); 
  }catch(IOException e){
    System.out.println("IOException : " + e);
      //exit();
  }
}

void readKinectFrame(){
  
}