int jump_height = 400;
player zinc = new player(100, 650, 160, 160, 40, 800, false, false); //initialize the player
object[] obj = new object[10]; //create 10 instances of object: one moon, five possible clouds and four potential simultaneous obstacles on the screen
boolean[] check_object = new boolean[10]; //check which object is present on screen
float old_t = 0, t;  //storing the time of the last loop
int obstacles = 0, last_obstacle = 6, cloud = 0;
boolean playing = false, gameover = false;

void setup() {
    size( 1600, 900 );
    noLoop();
}

void draw()
{
    if(playing)
    {
        background( #364891 ); 
        fill( 194, 178, 128 );
        rect( 0, 500, 1600, 400 );
        noStroke();
        t = millis();  //get the current time
        t -= old_t;    //calculate how much time has passed
        old_t += t;    //store the current time into the old variable for next loop check
        if(zinc.is_jumping)
        {
           if(zinc.down)
           {
               zinc.ypos += t*zinc.speedy/1000;  //move the bunny down accordingly to the speed
               if(zinc.ypos>=650)  //end the jumping session once reaching the ground
               {
                  zinc.ypos = 650; 
                  zinc.down = false;
                  zinc.is_jumping = false;
               }
           }
           else
           {
               zinc.ypos -= t*zinc.speedy/1000;   //move the bunny up accordingly to the speed
               if(zinc.ypos<=650-jump_height)     //upon reaching the highest altitude, the bunny falls down back to the ground
                   zinc.down = true;
           }
        }
        fill( 255, 255, 255 );
        zinc.draw_Player();    //draw the bunny
        if(cloud < 5 && (random(0,100)<0.9))  //check to initiate a new piece of cloud and the chance for a cloud to appear is 0.9% every loop
        {
            int j;
            for(j=1;(j<6) && check_object[j]; j++); 
            cloud++;
            obj[j] = new object(1600, random(20,150), 450, 0, random(100,300), 4);
            check_object[j] = true;
        }
        if(obstacles < 4)  //check to initiate a new obstacle
        {
            //if the last obstacle is at least 400 pixel from the right edge from the window
            //and there is a 1.0% chance a new obstacle appears every loop
            boolean check = false;
            if(check_object[last_obstacle])
            {
                if(obj[last_obstacle].xpos<=1200)
                    check = true;
            }else 
                check = true;
            check &= (random(0,100)<1.0);
            if(check)
            {
                int j;
                for(j=6;(j<10) && check_object[j]; j++);
                last_obstacle = j;   
                obstacles++;
                obj[j] = new object(1600, 650, 100, 100, 400, (int)random(1,3.99));
                check_object[j] = true;
            }            
        }
        for(int i=0; i<10; i++)
        {            
            if(check_object[i])
            {
                obj[i].xpos -= t*obj[i].speed/1000;  
                obj[i].draw_Object(); 
                if(obj[i].xpos<=-obj[i].len)
                {
                    check_object[i] = false;
                    if(i>=6)
                      obstacles--;
                    else if(i>0)
                      cloud--;
                }
            }
        }
        
        for(int i=6; i<10; i++)
        {
            if(check_object[i])
            {
                if(abs(obj[i].xpos-zinc.xpos)<=zinc.len || (abs(obj[i].xpos-zinc.xpos)<=obj[i].len))
                {
                    //tail and beard collisions are tolerated
                    //check each potential part of the bunny that may collide with the obstacle
                    boolean front_leg = (zinc.xpos+120>=obj[i].xpos) && (zinc.xpos+120<=obj[i].xpos+obj[i].len) && (zinc.ypos>=obj[i].ypos-obj[i].hei) && (zinc.ypos<=obj[i].ypos);                    
                    if(front_leg) 
                    {
                        playing = false;
                        gameover = true;
                        break;
                    }
                    boolean front_body = false;
                    for(int j=10; j>=0;j--)
                    {
                        float x = bezierPoint(100,120,123.2,128,(float)j/10);
                        float y = bezierPoint(136,108,68,60,(float)j/10);
                        front_body |= (zinc.xpos+x>=obj[i].xpos) && (zinc.xpos+x<=obj[i].xpos+obj[i].len) && (zinc.ypos-160+y>=obj[i].ypos-obj[i].hei) && (zinc.ypos-160+y<=obj[i].ypos);;
                        if(front_body)
                          break;
                    }                    
                    if(front_body) 
                    {
                        playing = false;
                        gameover = true;
                        break;
                    }
                    boolean back_body = false;
                    for(int j=10; j>=0;j--)
                    {
                        float x = bezierPoint(8,20*0.4,30*0.4,50*0.4,(float)j/10);
                        float y = bezierPoint(116,295*0.4,350*0.4,350*0.4,(float)j/10);
                        back_body |= (zinc.xpos+x>=obj[i].xpos) && (zinc.xpos+x<=obj[i].xpos+obj[i].len) && (zinc.ypos-160+y>=obj[i].ypos-obj[i].hei) && (zinc.ypos-160+y<=obj[i].ypos);;
                        if(back_body)
                          break;
                    }
                    if(back_body) 
                    {
                        playing = false;
                        gameover = true;
                        break;
                    }
                    boolean back_leg = false;                    
                    for(int j=10; j>=0;j--)
                    {
                        float x = bezierPoint(20,16,16,68,(float)j/10);
                        float y = bezierPoint(140,146,150,156,(float)j/10);
                        back_leg |= (zinc.xpos+x>=obj[i].xpos) && (zinc.xpos+x<=obj[i].xpos+obj[i].len) && (zinc.ypos-160+y>=obj[i].ypos-obj[i].hei) && (zinc.ypos-160+y<=obj[i].ypos);;
                        if(back_leg)
                          break;
                    }
                    if(back_leg) 
                    {
                        playing = false;
                        gameover = true;
                        break;
                    }
                    boolean lower_face = false;  
                    for(int j=10; j>=0;j--)
                    {
                        float x = bezierPoint(160,158,141.6,128,(float)j/10);
                        float y = bezierPoint(41.2,48.8,57.6,60,(float)j/10);
                        lower_face |= (zinc.xpos+x>=obj[i].xpos) && (zinc.xpos+x<=obj[i].xpos+obj[i].len) && (zinc.ypos-160+y>=obj[i].ypos-obj[i].hei) && (zinc.ypos-160+y<=obj[i].ypos);;
                        if(lower_face)
                          break;
                    }
                    if(lower_face)
                    {
                        playing = false; //<>//
                        gameover = true;
                        break;
                    }
                    boolean mouth = false;  
                    for(int j=10; j>=0;j--)
                    {
                        float x = bezierPoint(159.6,156.8,143.2,153.2,(float)j/10);
                        float y = bezierPoint(40.8,47.2,50.4,44,(float)j/10);
                        mouth |= (zinc.xpos+x>=obj[i].xpos) && (zinc.xpos+x<=obj[i].xpos+obj[i].len) && (zinc.ypos-160+y>=obj[i].ypos-obj[i].hei) && (zinc.ypos-160+y<=obj[i].ypos);;
                        if(mouth)
                          break;
                    }
                    if(mouth)
                    {
                        playing = false;
                        gameover = true;
                        break;
                    }      
                }
            }
        }
    }
    else
    {        
        //draw and display the game options
        fill(211,211,211);
        rect(600,350,400,200);      
        fill(200,200,200);
        rect(650,400,140,100); 
        rect(810,400,140,100); 
        textSize(55);
        fill(255,255,255);
        text("Play", 665, 465);
        text("Exit", 830, 465);
        if(gameover)  //also display the text "Gameover" if the game is over
        {
            textSize(100);
            text("Game Over", 520, 300);
        }
        noLoop();
    }
}

class object {
  //declare 5 variables; they are length, height, horizontal position,
  //vertical position and the speed respectively.
  float len, hei, xpos, ypos, speed, type;
  
  //constructor for object
  object(float x, float y, float l, float h, float spd, int t)
  {
      //assign each value to its approriate variable
      xpos = x;
      ypos = y;
      len = l;
      hei = h;
      speed = spd;
      type = t;
  }
  
  void draw_Object(){
      if(type == 0)  //the moon
      {
          pushMatrix();
          translate(xpos,ypos);
          fill(255,255,0);
          noStroke();
          arc(70, 70, 140, 140, HALF_PI, PI+HALF_PI);
          fill(#364891);
          beginShape();
          vertex(70,0);
          quadraticVertex(0,70,70,140);
          endShape();
          popMatrix();
      }else if(type == 1)  //a tree
      {
          fill(255,0,0);
          rect(xpos, ypos-hei+150, len, hei);//code added later once the design has been finalized
      }else if(type == 2)  //a bush
      {
          fill(0,255,0);
          rect(xpos, ypos-hei+150, len, hei);//code added later once the design has been finalized        
      }else if(type == 3)  //a stone
      {
          fill(0,0,255);
          rect(xpos, ypos-hei+150, len, hei);//code added later once the design has been finalized      
      }else if(type == 4)  //cloud
      {
          fill(255,255,255);
          pushMatrix();
          translate(xpos,ypos);
          scale(0.5);
          beginShape();
          vertex(50,50);
          bezierVertex(0,100,30,140,100,180); 
          bezierVertex(100,180,140,190,180,170);
          bezierVertex(180,180,240,200,300,170);
          bezierVertex(300,180,360,200,420,180);
          bezierVertex(420,180,520,140,450,50); 
          bezierVertex(450,50,400,0,340,50);
          bezierVertex(350,50,240,-50,150,50);
          bezierVertex(180,50,100,0,50,50); 
          vertex(50,50);
          endShape();   
          scale(1);
          popMatrix();
      }
  }  
}

class player extends object {  //create a new class inheriting the already-existing object class
  boolean is_jumping, down;  //add one more variable to the base class of object
  float speedy;
  
  //constructor for player inheriting the object class
  player(float x, float y, float l, float h, float spd, float speed, boolean jump, boolean d)  //the default object type for player is 11
  {
      super(x, y, l, h, spd, 10); //first construct the object for object class
      speedy = speed;
      is_jumping = jump; // then assign the boolean value to the variables
      down = d;
  }
  
  void draw_Player()
  {
      noFill();
      stroke(0,0,0);
      
      pushMatrix();
      translate(xpos,ypos);       
            
      strokeJoin(ROUND);
      
      fill(255,255,255);
      //face
      beginShape();
      vertex(250*0.4,60*0.4);
      bezierVertex(290*0.4,40*0.4,315*0.4,40*0.4,387*0.4,80*0.4); 
      bezierVertex(394*0.4,84*0.4,404*0.4,88*0.4,400*0.4,103*0.4);
      bezierVertex(395*0.4,122*0.4,354*0.4,144*0.4,320*0.4,150*0.4);
      endShape();
      
      //eye
      beginShape();
      vertex(305*0.4,90*0.4);
      bezierVertex(317*0.4,76*0.4,325*0.4,82*0.4,330*0.4,87*0.4);
      bezierVertex(322*0.4,99*0.4,317*0.4,95*0.4,305*0.4,90*0.4);
      endShape();
      
      //eyeball
      fill(0,0,0);
      ellipse(319*0.4,88*0.4,10*0.4,10*0.4);
      fill(255,255,255);
      ellipse(320*0.4,87*0.4,4*0.4,4*0.4);
      
      fill(#ffb3ff);
      //nose
      beginShape();
      vertex(387*0.4,90*0.4);
      bezierVertex(380*0.4,79*0.4,382*0.4,85*0.4,381*0.4,91*0.4);
      bezierVertex(381.5*0.4,91.5*0.4,382.5*0.4,92.5*0.4,383*0.4,93*0.4);
      bezierVertex(393*0.4,94*0.4,399*0.4,98*0.4,400*0.4,100*0.4);
      bezierVertex(404*0.4,88*0.4,394*0.4,84*0.4,387*0.4,90*0.4);
      endShape();
      
      noFill();
      //mouth
      stroke(0,0,0);
      bezier(399*0.4,102*0.4,392*0.4,118*0.4,358*0.4,126*0.4,383*0.4,110*0.4);
      
      //beard
      bezier(385*0.4,103*0.4,393*0.4,102*0.4,405*0.4,113*0.4,408*0.4,120*0.4);
      bezier(380*0.4,108*0.4,392*0.4,112*0.4,399*0.4,124*0.4,403*0.4,130*0.4);
      bezier(375*0.4,113*0.4,391*0.4,122*0.4,393*0.4,135*0.4,398*0.4,140*0.4);
      
      stroke(0,0,0);
      fill(255,255,255);
      
      //back ear
      beginShape();  
      vertex(258*0.4,56*0.4);
      bezierVertex(242*0.4,35*0.4,180*0.4,8*0.4,120*0.4,0);
      bezierVertex(122*0.4,4*0.4,126*0.4,9*0.4*0.4,127*0.4,12*0.4);  
      vertex(258*0.4,70*0.4);
      endShape();
          
      //noStroke();
      beginShape();    
      //front ear
      vertex(264*0.4,75*0.4);
      bezierVertex(235*0.4,35*0.4,170*0.4,15*0.4,100*0.4,10*0.4);
      bezierVertex(140*0.4,90*0.4,219*0.4,70*0.4,252*0.4,100*0.4);
      endShape();
      
      fill(#ffb3ff);  
      noStroke();
      beginShape();
      //inner front ear
      vertex(255*0.4,75*0.4);
      bezierVertex(225*0.4,40*0.4,170*0.4,35*0.4,120*0.4,20*0.4);
      bezierVertex(140*0.4,75*0.4,219*0.4,70*0.4,247*0.4,90*0.4);
      endShape();
      
      fill(255,255,255);
      stroke(0,0,0);
      
      //tail
      ellipse(20*0.4,290*0.4,40*0.4,40*0.4);
          
      //body
      beginShape();
      vertex(233*0.4,90*0.4);    
      bezierVertex(230*0.4,98*0.4,229*0.4,120*0.4,199*0.4,128*0.4);
      bezierVertex(180*0.4,130*0.4,22*0.4,135*0.4,20*0.4,290*0.4);
      bezierVertex(20*0.4,295*0.4,30*0.4,350*0.4,50*0.4,350*0.4);
      vertex(130*0.4,360*0.4);
      vertex(140*0.4,360*0.4);
      bezierVertex(170*0.4,340*0.4,190*0.4,320*0.4,250*0.4,290*0.4);
      bezierVertex(300*0.4,270*0.4,308*0.4,170*0.4,320*0.4,150*0.4);
      endShape();
       
      
      //back legs
      beginShape();
      vertex(180*0.4,365*0.4);
      bezierVertex(165*0.4,360*0.4,160*0.4,355*0.4,135*0.4,355*0.4);
      vertex(120*0.4,370*0.4);
      endShape();
      
      beginShape();
      vertex(50*0.4,350*0.4);
      bezierVertex(40*0.4,365*0.4,40*0.4,375*0.4,170*0.4,390*0.4);
      quadraticVertex(190*0.4,383*0.4,170*0.4,376*0.4);
      endShape();
      
      beginShape();
      vertex(180*0.4,383*0.4);
      quadraticVertex(205*0.4,375*0.4,180*0.4,367*0.4);
      vertex(180*0.4,367*0.4);
      bezierVertex(200*0.4,367*0.4,115*0.4,365*0.4,110*0.4,350*0.4);
      vertex(50*0.4,350*0.4);
      endShape();
          
      beginShape();
      vertex(130*0.4,360*0.4);
      quadraticVertex(190*0.4,310*0.4,128*0.4,260*0.4);
      endShape();
          
      //front leg    
      beginShape();
      vertex(230*0.4,165*0.4);
      bezierVertex(185*0.4,195*0.4,225*0.4,300*0.4,225*0.4,340*0.4);
      bezierVertex(226*0.4,355*0.4,245*0.4,360*0.4,270*0.4,360*0.4);
      quadraticVertex(300*0.4,345*0.4,270*0.4,330*0.4);
      bezierVertex(250*0.4,315*0.4,250*0.4,275*0.4,255*0.4,250*0.4);
      endShape();  
      
      stroke(255,255,255);
      line(50*0.4,350*0.4,110*0.4,350*0.4);      
      triangle(233*0.4,90*0.4,320*0.4,150*0.4,250*0.4,60*0.4);
             
      noFill();
      stroke(0,0,0);
      bezier(270*0.4,360*0.4,280*0.4,358*0.4,280*0.4,347*0.4,270*0.4,345*0.4);
      
      fill(255,255,255);
            
      popMatrix();
   }
}

void keyPressed() {
    if(key==32)
        zinc.is_jumping = true;
}

void mouseClicked()
{
    if(!playing)
    {
        if(mouseX>=650 && mouseX<=790 && mouseY>=400 && mouseY<=500)
        {
            playing = true;
            gameover = false;
            //reset everything except the cloud and the moon
            for(int i=0; i<10; i++)
            {
              check_object[i] = false;
            }
            old_t = millis();
            obstacles = 0;
            last_obstacle = 6;
            obj = new object[10];
            obj[0] = new object(700,50,0,0,0,0);  //the moon
            zinc = new player(100, 650, 160, 160, 40, 600, false, false); //reinitialize the player
            check_object[0] = true;
            loop();
        }
        if(mouseX>=810 && mouseX<=950 && mouseY>=400 && mouseY<=500)
            exit();  //exit the game
    }
}
