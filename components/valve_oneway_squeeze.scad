$fa = 1;
$fs = 0.04;

module valve_oneway_squeeze(
    channel_width = 6,
    channel_height = 5,
    length=24,
    height=14,
    layer = 0.010,
    px = 0.0076
){

    channel_width_px = channel_width * px;
    channel_height_layer = channel_height * layer;
    length_px = length * px;
    height_layer = height * layer;

    ch_w = 8*px;
    ch_wtwo = 10*px;

    wall_w = 8*px;
    mem_h = layer;
    squeeze = 2*layer;
    squeezer = (height_layer-2*mem_h-squeeze)/2;

    translate([-(length_px+ch_w+wall_w)/2, -(3*ch_w+2*wall_w)/2 , 0]){
        cube([length_px+ch_w+wall_w,ch_w,height_layer]);
        translate([0,2*ch_w+2*wall_w])
        cube([length_px+ch_w+wall_w,ch_w,height_layer]);
        translate([0,ch_w+wall_w])
        cube([ch_w+wall_w/2,ch_w,height_layer]);
        translate([0,ch_w+wall_w,squeezer+mem_h])
        cube([length_px+ch_w+2.5*wall_w,ch_w,squeeze]);
        color("green")
        translate([length_px+ch_w+1.5*wall_w,ch_w+wall_w])
        cube([ch_w+wall_w/2,ch_w,height_layer]);


        cube([ch_w,3*ch_w+2*wall_w,height_layer]);
        translate([ch_w+wall_w,0,0])
        cube([length_px,3*ch_w+2*wall_w,squeezer]);
        translate([ch_w+wall_w,0,squeezer+squeeze+2*mem_h])
        cube([length_px,3*ch_w+2*wall_w,squeezer]);

        // Outlet channel
        color("red")
        translate([-5*px, (3*ch_w+2*wall_w)/2, height_layer/2 - channel_height_layer/2])
        cube([10*px, channel_width_px, channel_height_layer]);
    }
}
