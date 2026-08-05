$fa = 1;
$fs = 0.04;

module valve_oneway_ribbon(
    channel_width = 6,
    channel_height = 5,
    membrane_width=18,
    membrane_thickness=1,
    membrane_top_gap=4,
    membrane_bottom_gap=2,
    membrane_side_gap=6,
    main_chamber_x=48,
    inlet_x=6,
    inlet_z=3,
    layer = 0.010,
    px = 0.0076
){
    membrane_width=membrane_width*px;
    membrane_thickness=membrane_thickness*layer;
    membrane_top_gap=membrane_top_gap*layer;
    membrane_bottom_gap=membrane_bottom_gap*layer;
    membrane_side_gap=membrane_side_gap*px;
    main_chamber_x=main_chamber_x*px;
    inlet_x=inlet_x*px;
    inlet_z=inlet_z*layer;
        
    channel_width_default = channel_width*px;
    channel_height_default = channel_height*layer;
    
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
            cube([channel_width_default, channel_width_default, 4*layer]);
        }
        // Bottom narrow inlet
        color("green")
        translate([main_chamber_x/2, main_chamber_y/2, 0])
        translate([-channel_width_default / 2,
                  -channel_width_default / 2,
                  -4*layer]) 
        cube([channel_width_default, channel_width_default, 4*layer]);
    }
}


