use <../polychannel/polychannel.scad>
use <orientation.scad>

default_valve_squeeze_channel_taper = 5;

function valve_squeeze_dimensions(membrane, chamber, ctrl_chamber, channel, channel_taper=default_valve_squeeze_channel_taper) =
    let (ctrl_chamber_top = ctrl_chamber[0])
    let (ctrl_chamber_side = ctrl_chamber[1])
    let (ctrl_chamber_bottom = ctrl_chamber[2])
    [
        2*membrane_width + chamber_width + 2*ctrl_chamber_side,
        chamber_length + 2*channel_taper,
        2*membrane_height + chamber_height + ctrl_chamber_top + ctrl_chamber_bottom
    ];

function valve_squeeze_flow_ports(membrane, chamber, ctrl_chamber, channel, channel_taper=default_valve_squeeze_channel_taper) =
    [[[0, chamber.z/2 + channel_taper, 0], [0, 1, 0], [0, 0, 1]],
     [[0, -(chamber.z/2 + channel_taper), 0], [0, -1, 0], [0,0,1]]];

/*
 * membrane: [side thickness, top/bottom thickness]
 * chamber: [width, height, length]
 * ctrl_chamber: [top, bottom, side, length]
 * channel: [width, height]
 * channel_taper: length
*/
module valve_squeeze(membrane, chamber, ctrl_chamber, channel, channel_taper=default_valve_squeeze_channel_taper )
{
    membrane_width = membrane.x;
    membrane_height = membrane.y;

    chamber_width = chamber.x;
    chamber_height = chamber.y;
    chamber_length = chamber.z;
    chamber_cross = [chamber_width, chamber_height];

    ctrl_chamber_top = ctrl_chamber[0];
    ctrl_chamber_side = ctrl_chamber[1];
    ctrl_chamber_bottom = ctrl_chamber[2];
    ctrl_chamber_length = ctrl_chamber[3];

    assert(chamber_length >= ctrl_chamber_length);

    membrane_cutout = [
        2*membrane_width + chamber_width,
        chamber_length,
        2*membrane_height + chamber_height];

    chamber_dimensions = [chamber_width, chamber_length, chamber_height];

    ctrl_chamber_dimensions = [
        membrane_cutout.x + 2*ctrl_chamber_side,
        ctrl_chamber_length,
        membrane_cutout.y + ctrl_chamber_top + ctrl_chamber_bottom];

    ctrl_chamber_offset = [ 0, 0, (ctrl_chamber_top - ctrl_chamber_bottom)/2];

    // Control chamber
    difference() {
        translate(ctrl_chamber_offset)
        cube(ctrl_chamber_dimensions, center=true);
        cube(membrane_cutout, center=true);
    }

    // Fluid chamber
    union() {
        cube(chamber_dimensions, center=true);
        if (channel_taper > 0) {
            translate([0, -chamber_length/2, 0])
            rotate([90, 0, 0])
            prismoid(chamber_cross, channel, channel_taper);
            translate([0, chamber_length/2+channel_taper, 0])
            rotate([90, 0, 0])
            prismoid(channel, chamber_cross, channel_taper);
        }
    }

    module prismoid(bottom, top, h)
    {
        points = [
          [ -bottom.x/2, -bottom.y/2, 0 ],
          [  bottom.x/2, -bottom.y/2, 0 ],
          [  bottom.x/2,  bottom.y/2, 0 ],
          [ -bottom.x/2,  bottom.y/2, 0 ],
          [ -top.x/2, -top.y/2, h ],
          [  top.x/2, -top.y/2, h ],
          [  top.x/2,  top.y/2, h ],
          [ -top.x/2,  top.y/2, h ]];

        faces = [
          [0,1,2,3],  // bottom
          [4,5,1,0],  // front
          [7,6,5,4],  // top
          [5,6,2,1],  // right
          [6,7,3,2],  // back
          [7,4,0,3]]; // left
        polyhedron(points, faces);
    }
}

/**
 * mem_th: membrane thickness in layers.
 * fl_chm_h: fluid chamber height in layers.
 * fl_ext_len: fluid input extension length in pixels.
 * fl_tran_len: length of fluid channel through squeeze in pixels.
 * fl_ext_th_len: fluid extension thickness in layers.
 * pn_ch_w: pneumatic channel width in pixels.
 * pn_pad: pneumatic channel connection size in pixels.
 * pn_len: length of pneumatic connection in pixels.
 * pn_bttm_chm_h: pneumatic chamber height in layers.
 * chan_h: height of channel in layers.
 * chan_w: width of channel in pixels.
 * shape: shape of channel. see polychannel
 */
module squeeze_valve(
    mem_th, fl_chm_h,
    // fluid channel parameters
    fl_ext_len=30, fl_tran_len=5, fl_ext_th_len=4,
    // pneumatic channel parameters
    pn_ch_w=14, pn_pad = 10, pn_len = 30, pn_bttm_chm_h=20,
    chan_h=10, in_chan_h=10, out_chan_h=10, chan_w=14, shape="cube")
{
    no_rot = [0,[0,0,1]];

    pn_chan_dimm = [pn_ch_w, chan_w, chan_h];
    pn_chm_offset= (mem_th*2+fl_chm_h);
    pn_chm_h = pn_bttm_chm_h;


    out_fl_chan_dimm = [1, chan_w, out_chan_h] ;
    in_fl_chan_dimm = [1, chan_w, in_chan_h] ;
    fl_chan_dimm  = [1, chan_w, fl_chm_h] ;


    //pneumatic channel
    polychannel([
        [shape, pn_chan_dimm, [0,-pn_len,0], no_rot],
        [shape, pn_chan_dimm, [0,2*pn_len,0], no_rot]
    ]);
    translate([0,(chan_w/2+pn_pad),-pn_chm_offset/2-chan_h/2])
        cube([pn_ch_w, chan_w, pn_chm_offset], center=true);
    translate([0,-(chan_w/2+pn_pad),-pn_chm_offset/2-chan_h/2])
        cube([pn_ch_w, chan_w, pn_chm_offset], center=true);
    bttm_chm_l = (chan_w*2+pn_pad*2);
    translate([0,0,-pn_chm_offset-(chan_h/2+pn_chm_h/2)])
        cube([pn_ch_w, bttm_chm_l, pn_chm_h], center=true);

    //fluid channel

    fl_z_offset = (chan_h/2+mem_th+fl_chm_h/2) ;
    fl_pt_1 = (fl_ext_len-fl_tran_len-pn_ch_w/2-fl_ext_th_len) ;

    polychannel([
        [shape, in_fl_chan_dimm, [-fl_ext_len, 0, -fl_z_offset], no_rot],
        [shape, in_fl_chan_dimm, [fl_pt_1, 0,0], no_rot],
        [shape, fl_chan_dimm, [fl_tran_len, 0,0], no_rot],
        [shape, fl_chan_dimm, [(pn_ch_w+fl_ext_th_len*2), 0,0], no_rot],
        [shape, out_fl_chan_dimm, [fl_tran_len, 0,0], no_rot],
        [shape, out_fl_chan_dimm, [fl_pt_1, 0,0], no_rot],

    ]);
}

module p_squeeze_valve(xpos, ypos, zpos, orientation,
    mem_th, fl_chm_h,
    // fluid channel parameters
    fl_ext_len=30, fl_tran_len=5, fl_ext_th_len=4,
    // pneumatic channel parameters
    pn_ch_w=14, pn_pad = 10, pn_len = 30, pn_bttm_chm_h=20,
    // set if transition state
    px=7.6e-3, layer=10e-3, lpv=20, pitch=30,
    chan_h = 10, in_chan_h=10, out_chan_h=10, chan_w=14, shape="cube")
{
    z_offset = (chan_h/2+mem_th*2+fl_chm_h+pn_bttm_chm_h) ;
    x_off = (fl_ext_len+0.5) ;
    y_off = (pn_len+chan_w/2) ;
    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([2*x_off, 2*y_off], orientation)
    translate([x_off, y_off, z_offset])
    squeeze_valve(
        mem_th, fl_chm_h,
        fl_ext_len, fl_tran_len,fl_ext_th_len,
        pn_ch_w, pn_pad, pn_len, pn_bttm_chm_h,
        chan_h, in_chan_h, out_chan_h, chan_w, shape);
}
