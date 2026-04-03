use <../polychannel/polychannel.scad>
use <orientation.scad>

module in_line_membrane(orientation,
    mem_r, mem_th, fl_chm_h, pn_chm_h,
    fl_out_len  = 30, pn_out_len=30,
    chan_h=10, chan_w=14, shape="cube", $fn=30)
{
    chan_dimm = [chan_w, chan_w, chan_h];
    width = 2*(mem_r + fl_out_len);
    height = 2*(mem_r + pn_out_len);

    orient([width, height], orientation)
    translate([width, height,0]/2) {

        // Fluid chamber
        translate([0,0,fl_chm_h/2])
            cylinder(fl_chm_h, r=mem_r, center=true);
        // Pneumatic chamber
        translate([0,0,(fl_chm_h+mem_th+pn_chm_h/2)])
                cylinder(pn_chm_h, r=mem_r, center=true);
        // Fluid channel
        polychannel([
            ["cube", chan_dimm, [-width/2, 0, chan_h/2], [0,[0,0,1]] ],
            ["cube", chan_dimm, [width, 0, 0], [0,[0,0,1]], ]]);

        z_chan_offset = (fl_chm_h+pn_chm_h+mem_th-chan_h/2);
        // Pneumatic channel
        polychannel([
            ["cube", chan_dimm, [0, -width/2, z_chan_offset], [0,[0,0,1]] ],
            ["cube", chan_dimm, [0, width, 0], [0,[0,0,1]], ]]);
    }
}

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * mem_r: membrane radius in pixels.
 * mem_th: membrane thickness in layers.
 * lf_out_len: length of channels extending outside of valve radius in pixels
 * extra_sp: extra center spacing if needed when inport_center=false in pixels
 * fl_chm_h, pn_chm_h: fluid and pneumatic chamber depths, in layers
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_in_line_membrane(xpos, ypos, zpos, orientation,
    mem_r, mem_th, fl_chm_h, pn_chm_h,
    fl_out_len  = 30, pn_out_len=30,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, $fn=30)
{
    // No calculations mix px and layer units.
    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    in_line_membrane(orientation, mem_r, mem_th, fl_chm_h, pn_chm_h,
                    fl_out_len, pn_out_len, chan_h, chan_w, shape);

}

p_in_line_membrane(0,0,0,"N",
    50, 10, 20, 40);
