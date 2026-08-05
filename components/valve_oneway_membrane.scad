$fa = 1;
$fs = 0.04;

module valve_oneway_membrane(
    input_channel_length=15,
    top_chamber_h=8,
    bottom_chamber_h= 4,
    membrane_diameter=50,
    membrane_thickness=1,
    u_channel_length=10,
    u_channel_height=15,
    angle_offset_u_channel=0,
    angle_offset_input_channel=0,
    channel_width_default = 6,
    channel_height_default = 5,
    layer = 0.010,
    px = 0.0076
){
    input_channel_length=input_channel_length*px;
    top_chamber_h=top_chamber_h*layer;
    bottom_chamber_h= bottom_chamber_h*layer;
    membrane_diameter=membrane_diameter*px;
    membrane_thickness=membrane_thickness*layer;
    u_channel_length=u_channel_length*px;
    u_channel_height=u_channel_height*layer;
    channel_width_default = channel_width_default*px;
    channel_height_default = channel_height_default*layer;

    module xchan(l, w = channel_width_default, h = channel_height_default) {
        color("lightblue")
        if (l < 0)
            mirror([1, 0, 0])
        translate([0, -floor(w / px / 2) * px, 0]) cube([-l, w, h]);
        else
        translate([0, -floor(w / px / 2) * px, 0]) cube([l, w, h]);
    }

    module ychan(l, w = channel_width_default, h = channel_height_default) {
        color("lightblue")
        if (l < 0)
            mirror([0, -1, 0])
        translate([-floor(w / px / 2) * px, 0, 0]) cube([w, -l, h]);
        else
        translate([-floor(w / px / 2) * px, 0, 0]) cube([w, l, h]);
    }

    module zchan(l, xy = channel_width_default) {
        color("lightblue")
        translate([-xy / 2, -xy / 2, 0]) {
            if (l < 0)
                mirror([0, 0, 1])
            cube([xy, xy, -l]);
            else
            cube([xy, xy, l]);
        }
    }

    // Top chamber
    cylinder(h=top_chamber_h, d=membrane_diameter);

    // Bottom chamber
    translate([0, 0, -(membrane_thickness+bottom_chamber_h)])
        cylinder(h=bottom_chamber_h, d=membrane_diameter);

    // Input channel
    color("red")
    rotate([0, 0, angle_offset_input_channel])
    translate([-(input_channel_length + membrane_diameter/2) + px, 0, 0])
        xchan(input_channel_length);

    // U channel
    rotate([0, 0, angle_offset_u_channel])
    translate([membrane_diameter/2 - px, 0, channel_height_default/2]){
        xchan(u_channel_length, h=channel_height_default/2);
        translate([u_channel_length, 0, channel_height_default/2]){
            zchan(-u_channel_height);
            translate([0, 0, -u_channel_height]){
                xchan(-u_channel_length -px, h=channel_height_default/2);
                translate([-u_channel_length - channel_height_default/2, 0, 0]){
                    zchan(u_channel_height-(bottom_chamber_h + membrane_thickness + channel_height_default/2));
                }
            }
        }
    }

    // Output channel
    color("green")
    translate([0, 0, -(membrane_thickness + bottom_chamber_h)]){
        zchan(-5*layer);
    }
}

