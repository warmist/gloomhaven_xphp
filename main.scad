dial_radius=35;
dial_outer_offset=2;
dial_to_dial=5;
dial_height=2.5;
text_offset=28;
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
    holder_w=2;
    union()
    {
        ring(ring_r0,spring_w);
        ring(ring_r1,spring_w);
        ring(ring_r2,spring_w);
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
                translate([-holder_w/2,0,0])
                square([holder_w,outer_r+5]);
            }
        }
    }
}
//hole_with_spring();
module indexed_with_spring()
{
    $fn=40;
    hole_r=18;
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
    dial_h=2;
    //dial itself
    linear_extrude(dial_h)
    indexed_with_spring();
    //numbers
    text_rotation=flip?180:0;
    ang_offset=flip?4:-4;
    color("red")
    linear_extrude(dial_height)
    ring(19,1);
    //numbers
    color("red")
    for(i=[0:29])
    {
        text_h=dial_height-dial_h;
        text_rad=text_offset;
        inorm=i/30;
        
        translate([0,0,dial_h])
        translate([
            cos(inorm*360+ang_offset),
            sin(inorm*360+ang_offset),0]*text_rad)
        rotate([0,0,inorm*360+text_rotation])
        linear_extrude(height=text_h)
        {
        text(str(i),4,halign="center");
        //linear_extrude(text_h);
        }
    }
}
//dial();
module dial_axis(height,lip_height,lip_w)
{
    $fn=30;
    engagement=0.5; //controls how much the spring moves between each tick
    actual_r=18-1.5*6+engagement;
    translate([0,0,-height])
    linear_extrude(height)
    indexed_circle(actual_r,30,1.5,1.5-engagement);
    translate([0,0,-height-lip_height])
    linear_extrude(lip_height)
    #circle(actual_r+lip_w);
}
//color("blue")
//dial_axis();
module top()
{
    circle_dist=dial_to_dial;
    circle_rad=dial_radius;
    outer_offset=dial_outer_offset;
    
    finger_index_size=5;
    finger_cutout_size=circle_rad*1;
    difference()
    {
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
        
        translate([-finger_cutout_size-circle_rad-outer_offset+finger_index_size,0,0])
        circle(finger_cutout_size);
        
        translate([finger_cutout_size+circle_rad*3+circle_dist+outer_offset-finger_index_size,0,0])
        circle(finger_cutout_size);
        
        translate([text_offset,0,0])
        square([8,5],true);
        
        translate([-text_offset+circle_rad*2+circle_dist,0,0])
        square([8,5],true);
    }
    
}
module top_waxis()
{
    $fn=80;
    lip_height=1;
    lip_size=0.1;
    difference()
    {
        linear_extrude(1.5)
        top();
        
        translate([dial_radius*2+dial_to_dial,0,0])
        rotate([0,0,180])
        linear_extrude(1.6)
        text("HP",8,halign="center",valign="center");
        
        //translate([dial_radius*2+dial_to_dial,0,0])
        rotate([0,0,180])
        linear_extrude(1.6)
        text("XP",8,halign="center",valign="center");
    }
    dial_axis(dial_height+0.1,lip_height,lip_size);
    
    translate([dial_radius*2+dial_to_dial,0,0])
    dial_axis(dial_height+0.1,lip_height,lip_size);
    
    
    
}
//top_waxis();
module assembly()
{
    //color("blue")
    translate([0,0,dial_height])
    top_waxis();
    //#top();
    dial(true);
    translate([dial_radius*2+dial_to_dial,0,0])
    dial();
}
//assembly();

module test_print4()
{
    dial(true);
}
//test_print4();
module test_print5()
{
    dial();
}
test_print5();
module test_print2()
{
    top_waxis();
}
//test_print2();