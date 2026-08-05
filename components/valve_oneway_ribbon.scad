use <orientation.scad>

$fa = 1;
$fs = 0.04;

module valve_oneway_ribbon(
    channel_width_default = 6,
    channel_height_default = 5,
    membrane_width=18,
    membrane_thickness=1,
    membrane_top_gap=4,
    membrane_bottom_gap=2,
    membrane_side_gap=6,
    main_chamber_x=48,
    inlet_x=6,
    inlet_z=3,
){

    
    main_chamber_y = membrane_width+2*membrane_side_gap;
    main_chamber_z = membrane_top_gap + membrane_thickness + membrane_bottom_gap;
    translate([-main_chamber_x/2, -main_chamber_y/2, 0]){
        difference(){
            // Main chamber
            cube([main_chamber_x, main_chamber_y, main_chamber_z]);

            // Ribbon membrane
            translate([0, membrane_side_gap, membrane_bottom_gap])
                cube([main_chamber_x, membrane_width, membrane_thickness]);
        }
        // Top thick outlet
        translate([0.5*(main_chamber_x-inlet_x), 0, main_chamber_z]){
            cube([inlet_x, main_chamber_y, inlet_z]);
            color("red")
            translate([inlet_x/2, main_chamber_y/2, inlet_z])
            translate([-channel_width_default / 2,
                       -channel_width_default / 2,
                       0]) 
            cube([channel_width_default, channel_width_default, 4]);
        }
        // Bottom narrow inlet
        color("green")
        translate([main_chamber_x/2, main_chamber_y/2, 0])
        translate([-channel_width_default / 2,
                  -channel_width_default / 2,
                  -4]) 
        cube([channel_width_default, channel_width_default, 4]);
    }
}

module p_valve_oneway_ribbon(
    xpos, ypos, zpos, orientation,
    membrane_width=18,
    membrane_thickness=1,
    membrane_top_gap=4,
    membrane_bottom_gap=2,
    membrane_side_gap=6,
    main_chamber_x=48,
    inlet_x=6,
    inlet_z=3,
    px=7.6e-3, layer=10e-3, chan_h=10, chan_w=14, pitch=30, $fn=30
){
    pitch_offset = pitch - chan_w;
    main_chamber_y = membrane_width+2*membrane_side_gap;
    main_chamber_z = membrane_top_gap + membrane_thickness + membrane_bottom_gap;
    
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([main_chamber_x, main_chamber_y], orientation)
    translate([main_chamber_x, main_chamber_y, 0]/2)
    valve_oneway_ribbon(
            channel_width_default = chan_w,
            channel_height_default = chan_h,
            membrane_width=membrane_width,
            membrane_thickness=membrane_thickness,
            membrane_top_gap=membrane_top_gap,
            membrane_bottom_gap=membrane_bottom_gap,
            membrane_side_gap=membrane_side_gap,
            main_chamber_x=main_chamber_x,
            inlet_x=inlet_x,
            inlet_z=inlet_z);
}
p_valve_oneway_ribbon(0, 0, 0, "E");
