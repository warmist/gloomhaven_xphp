dial_radius=35;
dial_outer_offset=2;
dial_to_dial=5;
dial_height=1.45;
dial_text_height=0.35;
dial_full_height=dial_height+dial_text_height;
text_offset=29;
output_part=0;

hole_r=25;
module indexed_circle(
    radius=dial_radius,count=30,
    index_radius=3,index_offset=1.5)
{
    main_c_rad=radius;
    difference()
    {
    circle(main_c_rad);
    union(){
    for(i=[0:count])
    {
        inorm=i/count;
        translate([cos(inorm*360),sin(inorm*360),0]*(main_c_rad+index_offset))
        {
        circle(index_radius);
        }
    }
    }
    }
}
//indexed_circle();
module ring(radius,width)
{
    difference()
    {
        circle(radius);
        circle(radius-width);
    }
}
module hole_with_spring(outer_r=18)
{
    $fn=40;
    spring_w=1.5;
    
    ring_r0=outer_r;
    ring_r1=ring_r0-spring_w*2;
    ring_r2=ring_r1-spring_w*2;
    
    detent=1.55;
    angle_step=120;
    outer_spring_w=15;
    holder_w=spring_w;
    holder_w2=1;
    union()
    {
        
        difference()
        {
            union()
            {
                ring(ring_r1,spring_w);
                
                ring(ring_r2,spring_w);
            }
            union()
            {
                for(angle=[0:angle_step:360])
                {
                    rotate([0,0,angle+90])
                    translate([-holder_w2/2,0,0])
                    square([holder_w2,outer_r+5]);
                }
            }
        }
        ring(ring_r0,spring_w);
        difference()
        {
            ring(ring_r0-spring_w,spring_w);
            union()
            {
                for(angle=[0:angle_step:360])
                {
                    
                    rotate([0,0,angle+90])
                    translate([-outer_spring_w/2,0,0])
                    square([outer_spring_w,outer_r+5]);
                }
            }
        }
        for(angle=[0:angle_step:360])
        {
            translate([cos(angle),sin(angle),0]*(ring_r2-detent))
            circle(detent);
        }
        intersection()
        {
            ring(ring_r2+spring_w+0.01,spring_w+0.02);
            for(angle=[0:angle_step:360])
            {
                
                rotate([0,0,angle+90])
                translate([-holder_w2/2-holder_w,0,0])
                square([holder_w,outer_r+5]);
                rotate([0,0,angle+90])
                translate([holder_w2/2,0,0])
                square([holder_w,outer_r+5]);
            }
        }
    }
}
//hole_with_spring();
module indexed_with_spring()
{
    $fn=40;

    union()
    {
        difference()
        {
            indexed_circle();
            circle(hole_r-0.05);
        }
        hole_with_spring(hole_r);
    }
}
//indexed_with_spring();

module dial(flip=false)
{
    text_rotation=flip?180:0;
    direction=flip?-1:1;
    //dial itself
    difference()
    {
        linear_extrude(dial_full_height)
        indexed_with_spring();
        //numbers
        color("red")
        for(i=[0:29])
        {
            text_rad=text_offset;
            inorm=i/30;
            
            translate([0,0,dial_height+0.01])
            translate([
                cos(direction*(inorm*360)),
                sin(direction*(inorm*360)),0]*text_rad)
            
            rotate([0,0,direction*inorm*360+text_rotation])
            linear_extrude(height=dial_text_height+0.01)
            {
            text(str(i),5,halign="center",valign="center");
            }
        }
    }
}

module dial_axis(height,lip_height,lip_w)
{
    $fn=30;
    engagement=0.7; //controls how much the spring moves between each tick
    actual_r=hole_r-1.5*6+engagement;
    wall_w=2;
    height_infill=0.4;
    union()
    {
        //layer so that letters show up
        translate([0,0,-height_infill])
        linear_extrude(height_infill)
        indexed_circle(actual_r,30,1.5,1.5-engagement);

        //the rest of axis is with a hole for faster print
        translate([0,0,-height-height_infill])
        linear_extrude(height+height_infill)
        difference()
        {
            
            indexed_circle(actual_r,30,1.5,1.5-engagement);
            circle(actual_r-wall_w);
        }
    }
    translate([0,0,-height-lip_height])
    linear_extrude(lip_height)
    ring(actual_r+lip_w,wall_w);
}
//color("blue")
//dial_axis(dial_full_height+0.1,0.6,0);

module top()
{
    circle_dist=dial_to_dial;
    circle_rad=dial_radius;
    outer_offset=dial_outer_offset;
    
    finger_index_size=5;
    finger_cutout_size=circle_rad*1;
    text_window_width=8;
    text_window_height=6;
    difference()
    {
        //body itself
        union(){
        translate([0,-circle_rad-outer_offset,0])
        square(
            [circle_rad*2+circle_dist,
            circle_rad*2+outer_offset*2]
        );
        circle(circle_rad+outer_offset);
        translate([circle_rad*2+circle_dist,0,0])
        circle(circle_rad+outer_offset);
        };
        //finger access to the dials
        translate([-finger_cutout_size-circle_rad-outer_offset+finger_index_size,0,0])
        circle(finger_cutout_size);
        
        translate([finger_cutout_size+circle_rad*3+circle_dist+outer_offset-finger_index_size,0,0])
        circle(finger_cutout_size);
        
        //viewports
        intersection()
        {
            translate([text_offset,0,0])
            square([text_window_width,text_window_height],true);
            
            ring(text_offset+text_window_width/2,text_window_width);
        }
        intersection()
        {
            translate([-text_offset+circle_rad*2+circle_dist,0,0])
            square([text_window_width,text_window_height],true);
            
            translate([circle_rad*2+circle_dist,0,0])
            ring(text_offset+text_window_width/2,text_window_width);
        }
    }
    
}
module top_waxis()
{
    $fn=90;
    lip_height=0.6;
    lip_size=-0.0;
    top_height=dial_height;
    difference()
    {
        linear_extrude(top_height)
        top();
        
        translate([dial_radius*2+dial_to_dial,0,0])
        rotate([0,0,180])
        linear_extrude(top_height+0.1)
        text("HP",8,halign="center",valign="center");
        
        //translate([dial_radius*2+dial_to_dial,0,0])
        rotate([0,0,180])
        linear_extrude(top_height+0.1)
        text("XP",8,halign="center",valign="center");
    }
    dial_axis(dial_full_height+0.1,lip_height,lip_size);
    
    translate([dial_radius*2+dial_to_dial,0,0])
    dial_axis(dial_full_height+0.1,lip_height,lip_size);
    
    
    
}
//top_waxis();
module assembly()
{
    //color("blue")
    translate([0,0,dial_full_height])
    top_waxis();
    //#top();
    dial(true);
    translate([dial_radius*2+dial_to_dial,0,0])
    dial();
}
//assembly();
module print()
{
    if(output_part==0)
    {
        translate([0,0,dial_height])
        rotate([180,0,0])
        top_waxis();
    }
    else if(output_part==1)
    {
        translate([0,dial_radius*2.5,0])
        dial(true);
    }
    else
    {
        translate([dial_radius*2+dial_to_dial,dial_radius*2.5,0])
        dial();
    }
}
print();