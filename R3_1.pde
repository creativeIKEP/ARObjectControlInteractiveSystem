
import processing.video.*;
import jp.nyatla.nyar4psg.*;

Capture cam;
MultiMarker nya; 
PShape obj, obj2;
int flag=2; //0=>x or 1=>y ro 2=>z
int flag2=0;  //patt.kanji Marker is Exist?
int flag3=0;  //patt.kanji Marker is first discover?
PMatrix3D temp=new PMatrix3D();
PMatrix3D matrix=new PMatrix3D();  //rotation matrix until now
float d=0;  //patt.kanji Marker's relative rotation angle(rad)
float dFirst=0;  //patt.kanji Marker's first rotation angle(rad)


void setup() {
  size(640,480,P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);
  cam=new Capture(this,640,480);
  nya=new MultiMarker(this,width,height,"camera_para.dat",NyAR4PsgConfig.CONFIG_PSG);
  nya.addARMarker("patt.hiro",80);//id=0
  nya.addARMarker("patt.kanji",80);//id=1
  obj = loadShape("danbo2.obj");
  obj2=loadShape("yazirusi_red.obj");
  cam.start();
}

void draw()
{
  if (cam.available() !=true) {
      return;
  }
  cam.read();
  nya.detect(cam);
  background(0);
  nya.drawBackground(cam);
  
  
  if(nya.isExist(1) && flag2==1){flag2=1;}
  else if(!nya.isExist(1) && flag2==0){flag2=0;}
  else if(!nya.isExist(1) && flag2==1){//when marker disappear
          if(flag==0){
              matrix=multiple(matrix,xRotateMatrix(d));  //save rotation matrix until now
          }
          if(flag==1){
             matrix=multiple(matrix,yRotateMatrix(d));         
          }
          if(flag==2){
              matrix=multiple(matrix,zRotateMatrix(d));  
          }
          flag2=0;
  }
  else if(nya.isExist(1) && flag2==0){//when marker appear
      flag2=1;
      flag3=1;
      button();  //chage  rotation axis
  }
  
    if(nya.isExist(0)){
         nya.beginTransform(0);
         lights();
        scale(80);   
        
        applyMatrix(matrix);
        
        if(nya.isExist(1)){
            temp=nya.getMarkerMatrix(1);
            temp.m03=0;  //x move=0
            temp.m13=0;  //y move=0
            temp.m23=0;  //z move=0
            
            float dd=atan2(temp.m10, temp.m00);  //marker's z angle
            if(flag3==1){
                 dFirst=dd;
                 flag3=0;
            }
            d=dd-dFirst;  //relative angle
            
            if(flag==0){//when x axis
                PMatrix3D x=xRotateMatrix(d);  //change rad to x rotation matrix
                applyMatrix(x);
            }
            else if(flag==1){
               PMatrix3D y=yRotateMatrix(d);
               applyMatrix(y);
            }
            else if(flag==2){
               PMatrix3D z=zRotateMatrix(d);
               applyMatrix(z);
            }  
        } 
        shape(obj); 
        if(flag==0){obj2.setFill(color(255,0,0)); rotateZ(-PI/2);}
        else if(flag==1){obj2.setFill(color(0,255,0));}
        else if(flag==2){obj2.setFill(color(0,0,255)); rotateX(PI/2);}
        shape(obj2);
         nya.endTransform();   
    }
    
    if(nya.isExist(1)){
        if(flag==0){obj2.setFill(color(255,0,0));}
        else if(flag==1){obj2.setFill(color(0,255,0));}
        else if(flag==2){obj2.setFill(color(0,0,255));}
        nya.beginTransform(1);
        lights();
        rotateX(-PI/2);
        translate(0,-100,0);
        textSize(80);
        if(flag==0){fill(255, 0, 0); text("X", -30, 30);}
        else if(flag==1){fill(0, 255, 0); text("Y", -30, 30);}
        else if(flag==2){fill(0, 0, 255); text("Z", -30, 30);}
        scale(80);
        shape(obj2);
        nya.endTransform();
    }
}

void button(){
        flag++;
        if(flag>2){flag=0;}
}

PMatrix3D multiple(PMatrix3D a, PMatrix3D b){
  //a*b
    PMatrix3D c=new PMatrix3D();
    c.m00=a.m00*b.m00+a.m01*b.m10+a.m02*b.m20+a.m03*b.m30;
    c.m01=a.m00*b.m01+a.m01*b.m11+a.m02*b.m21+a.m03*b.m31;
    c.m02=a.m00*b.m02+a.m01*b.m12+a.m02*b.m22+a.m03*b.m32;
    c.m03=a.m00*b.m03+a.m01*b.m13+a.m02*b.m23+a.m03*b.m33;
    
    c.m10=a.m10*b.m00+a.m11*b.m10+a.m12*b.m20+a.m13*b.m30;
    c.m11=a.m10*b.m01+a.m11*b.m11+a.m12*b.m21+a.m13*b.m31;
    c.m12=a.m10*b.m02+a.m11*b.m12+a.m12*b.m22+a.m13*b.m32;
    c.m13=a.m10*b.m03+a.m11*b.m13+a.m12*b.m23+a.m13*b.m33;
    
     c.m20=a.m20*b.m00+a.m21*b.m10+a.m22*b.m20+a.m23*b.m30;
    c.m21=a.m20*b.m01+a.m21*b.m11+a.m22*b.m21+a.m23*b.m31;
    c.m22=a.m20*b.m02+a.m21*b.m12+a.m22*b.m22+a.m23*b.m32;
    c.m23=a.m20*b.m03+a.m21*b.m13+a.m22*b.m23+a.m23*b.m33;
    
     c.m30=a.m30*b.m00+a.m31*b.m10+a.m32*b.m20+a.m33*b.m30;
    c.m31=a.m30*b.m01+a.m31*b.m11+a.m32*b.m21+a.m33*b.m31;
    c.m32=a.m30*b.m02+a.m31*b.m12+a.m32*b.m22+a.m33*b.m32;
    c.m33=a.m30*b.m03+a.m31*b.m13+a.m32*b.m23+a.m33*b.m33;
    return c;
}

PMatrix3D xRotateMatrix(float d){
     PMatrix3D x=new PMatrix3D(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
     x.m00=1;
     x.m11=cos(d);
     x.m12=sin(d);
     x.m21=-sin(d);
     x.m22=cos(d);
     x.m33=1;
     return x;
}

PMatrix3D yRotateMatrix(float d){
     PMatrix3D x=new PMatrix3D(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
     x.m00=cos(d);
     x.m02=-sin(d);
     x.m11=1;
     x.m20=sin(d);
     x.m22=cos(d);
     x.m33=1;
     return x;
}

PMatrix3D zRotateMatrix(float d){
     PMatrix3D x=new PMatrix3D(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
     x.m00=cos(d);
     x.m01=sin(d);
     x.m10=-sin(d);
     x.m11=cos(d);
     x.m22=1;
     x.m33=1;
     return x;
}
