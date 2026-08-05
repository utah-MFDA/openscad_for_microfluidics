use <orientation.scad>

$fa = 1;
$fs = 0.04;

module valve_oneway_squeeze(
    channel_width = 6,
    channel_height = 5,
    channel_length= 24,
    membrane_width = 1,
    membrane_height = 2,
    squeeze_height = 2,
    squeeze_length = 14,
    squeeze_width = 8,
    cross_height = 3,
    cross_spacing = 2,
    outlet_width = 6,
    outlet_height = 4,
    outlet_length = 10,
    inlet_width = 6,
    inlet_height = 4,
    inlet_length = 10
){
    
    box_width = 2*squeeze_width + 2*membrane_width + channel_width;
    box_height = squeeze_length + cross_height + cross_spacing + squeeze_width;
    box_depth = 2*membrane_height + 2*squeeze_height + channel_height;
    assert(channel_length - cross_spacing > squeeze_length);
    
    translate([0, inlet_length , 0]){
        // squeeze channel
        translate([0, channel_length - squeeze_length - cross_spacing, 0])
        {
            side_dimension = [squeeze_width, box_height, box_depth];
            // left wall
            cube(side_dimension);
            
            // right wall
            translate([box_width - squeeze_width, 0, 0])
            cube(side_dimension);
            
            // back wall
            translate([0, box_height - squeeze_width, 0])
            cube([box_width, squeeze_width, box_depth]);
            
            top_dimension = [box_width, squeeze_length, squeeze_height];
            
            // top wall
            translate([0, 0, box_depth - squeeze_height])
            cube(top_dimension);
            
            // bottom wall
            cube(top_dimension);
        }
        
        // crossmembrane
        translate([(box_width - channel_width)/2, channel_length, 0])
        cube([channel_width, cross_height, box_depth]);
        
        // squeeze channel
        color("blue")
        translate([box_width - channel_width, 0, box_depth - channel_height]/2)
        cube([channel_width, channel_length, channel_height]);
        
        
        // outlet channel
        /*color("red")
        translate([(box_width - outlet_width)/2, channel_length+squeeze_width+cross_height, (box_depth - outlet_height)/2])
        cube([outlet_width, outlet_length, outlet_height]);

        // inlet channel
        color("green")
        translate([(box_width - inlet_width)/2, -inlet_length, (box_depth - inlet_height)/2])
        cube([inlet_width, inlet_length, inlet_height]);*/
    }
}

module p_valve_oneway_squeeze(
    xpos, ypos, zpos, orientation, 
    channel_width = 6,
    channel_height = 5,
    channel_length= 24,
    membrane_width = 1,
    membrane_height = 2,
    squeeze_height = 2,
    squeeze_length = 20,
    squeeze_width = 8,
    cross_height = 3,
    cross_spacing = 1,
    outlet_length = 10,
    inlet_length = 10,
    px=7.6e-3, layer=10e-3, chan_h=10, chan_w=14, pitch=30, $fn=30
){
    pitch_offset = pitch - chan_w;
    width = 2*squeeze_width + 2*membrane_width + channel_width;
    height = squeeze_width + cross_height + channel_length + outlet_length + inlet_length;
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([width, height], orientation)
    valve_oneway_squeeze(
        channel_width = channel_width,
        channel_height = channel_height,
        channel_length= channel_length,
        membrane_width = membrane_width,
        membrane_height = membrane_height,
        squeeze_height = squeeze_height,
        squeeze_length = squeeze_length,
        squeeze_width = squeeze_width,
        cross_height = cross_height,
        cross_spacing = cross_spacing,
        outlet_width = chan_w,
        outlet_height = chan_h,
        outlet_length = outlet_length,
        inlet_width = chan_w,
        inlet_height = chan_h,
        inlet_length = inlet_length);
}
