function mixer_ports(size, lead, angle) =
    let (length = size.x*sin(angle)/(1-cos(angle)))
    let (input_a = [[size.x/2,0, size.y/2], [0,-1,0], [0,0,1]])
    let (input_b = [[size.x/2+length*sin(angle), 0, size.y/2], [0,-1,0], [0,0,1]])
    let (output = [[size.x/2, length+2*lead, size.y/2], [0,1,0], [0,0,1]])
    [input_a, input_b, output];

function mixer_dimensions(size, lead, angle) =
    let (length = size.x*sin(angle)/(1-cos(angle)))
    [size.x+length*sin(angle), length+2*lead, size.y];

module mixer(size, lead=0, angle=45) {
    length = size.x*sin(angle)/(1-cos(angle));
    assert(sin(angle)*length > size.x)

    translate([size.x, length+lead, size.y])
    rotate([180, 0, -90]) {
        // Angled branch
        rotate([0, 0, -angle])
        cube([length, size.x, size.y]);

        // Angled branch corner
        translate([length*cos(angle), -length*sin(angle), 0])
        cube([length*(1-cos(angle)), size.x, size.y]);
        //
        // Angled branch lead
        translate([length, -length*sin(angle), 0])
        cube([lead, size.x, size.y]);

        // Output lead
        translate([-lead, 0, 0])
        cube([lead, size.x, size.y]);

        // Straight branch
        cube([length, size.x, size.y]);

        // Straight branch lead.
        translate([length, 0, 0])
        cube([lead, size.x, size.y]);

    }

}

use <openmfda/components/orientation.scad>
module p_mixer(xpos, ypos, zpos, orientation,
                px = 7.6e-3,
                layer = 10e-3,
                pitch=30,
                chan_h=10, chan_w=14) {
    cross_section = [chan_h, chan_w];
    angle = 45;
    lead = 4;
    dimensions = mixer_dimensions(cross_section, lead, angle);
    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset, pitch_offset, 0])
    orient([dimensions.x/2, dimensions.y/2], orientation)
    mixer(cross_section, lead, angle);
}

