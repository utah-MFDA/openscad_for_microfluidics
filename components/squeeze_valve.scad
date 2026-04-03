use <../polychannel/polychannel.scad>
use <orientation.scad>
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

p_squeeze_valve(0,0,0,"N",4,8);
