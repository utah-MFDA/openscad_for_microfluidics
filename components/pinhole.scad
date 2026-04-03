use <orientation.scad>
module pinhole(xpos, ypos, zpos, orientation,
    diameter=140, length=260, cone=67,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, $fn=30)
{
    // Note that diameter is consistent across height and thus not in layer unit.
    scale([px, px, px])
    translate([xpos, ypos, zpos])
    orient([length+cone, diameter], orientation)
    translate([0, diameter/2, diameter/2])
    rotate([0, 90, 0])
        union(){
        translate([0, 0, length])
        cylinder(h = cone, d1 = diameter, d2 = 0);

        cylinder(d = diameter, h = length);
    };
}

pinhole(0, 0, 0, "N", 140, 250, 67);
