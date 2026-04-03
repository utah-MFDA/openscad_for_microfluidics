use <../polychannel/polychannel.scad>
use <orientation.scad>
module fluid_chamber(
    valve_r, fl_chm_h,
    fl_out_len=20,
    fl_out_h  =10,
    dwn_chan_h=0, dwn_chan_w=0,
    fl_extra_sp = 0,
    chan_h=10, chan_w=14, shape="cube", $fn=30)
{
    dwn_chan_w = !dwn_chan_w ? chan_w : dwn_chan_w;
    dwn_chan_h = !dwn_chan_h ? chan_h : dwn_chan_h;
    chan_dimm     = [chan_w, chan_w, chan_h];
    chan_dimm_dwn = [dwn_chan_w, dwn_chan_w, chan_h];
    translate([0,0,fl_chm_h/2])
        cylinder(fl_chm_h, r=valve_r, center=true);
    // fluid connection channel definitions
    inp_pos = 0;
    outp_pos= valve_r-chan_w/2+fl_extra_sp;

    fl_len_0 = valve_r-chan_w/2+fl_out_len;
    fl_len_1 = abs(fl_out_len-fl_extra_sp);

    polychannel(
        [
        [shape, chan_dimm_dwn, [inp_pos,0,-chan_h/2], [0,[0,0,1]]],
        [shape, chan_dimm, [0,0,-fl_out_h], [0,[0,0,1]]],
        [shape, chan_dimm, [-fl_len_0,0,0], [0,[0,0,1]]]
    ]);
    polychannel(
        [[shape, chan_dimm,
        [outp_pos,0,-chan_h/2], [0,[0,0,1]]],
        [shape, chan_dimm, [0,0,-fl_out_h], [0,[0,0,1]]],
        [shape, chan_dimm, [fl_len_1,0,0], [0,[0,0,1]]]
    ]);

}
module pneumatic_chamber(
    valve_r, pn_chm_h,
    pn_out_len=20,
    pn_out_h  =10,
    dwn_chan_h=0, dwn_chan_w=0,
    pn_extra_sp = 0,
    chan_h=10, chan_w=14, shape="cube", $fn=30)
{
    chan_dimm     = [chan_w, chan_w, chan_h];
    chan_dimm_dwn = [dwn_chan_w, dwn_chan_w, chan_h];
    translate([0,0,(pn_chm_h/2)])
        cylinder(pn_chm_h, r=valve_r, center=true);
    // pneumatic channel definitions
    init_z_off = (pn_chm_h+chan_h/2);
    pn_pos_lat_fill = (valve_r-chan_w/2-1);
    pn_pos_lat_fill_edge = (valve_r+chan_w/2-4);
    pn_pos_lat_default =  (valve_r/4+chan_w/2);
    pn_pos_lat = (pn_extra_sp=="fill" ? pn_pos_lat_fill
                    : (pn_extra_sp=="fill-edge" ? pn_pos_lat_fill_edge
                        : pn_pos_lat_default));
    pn_len_fill = pn_out_len+1;
    pn_len_fill_edge =  pn_out_len-chan_w+4;
    pn_len_default = valve_r*3/4-chan_w+pn_out_len;
    pn_len = (pn_extra_sp=="fill" ? pn_len_fill
                : (pn_extra_sp=="fill-edge" ? pn_len_fill_edge
                    : pn_len_default));

    polychannel(
        [[shape, chan_dimm, [0,pn_pos_lat,init_z_off], [0,[0,0,1]]],
        [shape, chan_dimm, [0,0,pn_out_h], [0,[0,0,1]]],
        [shape, chan_dimm, [0,pn_len,0], [0,[0,0,1]]]
    ]);
    polychannel(
        [[shape, chan_dimm, [0,-pn_pos_lat,init_z_off], [0,[0,0,1]]],
        [shape, chan_dimm, [0,0,pn_out_h], [0,[0,0,1]]],
        [shape, chan_dimm, [0,-pn_len,0], [0,[0,0,1]]]
    ]);
}
/**
 * valve_r: valve chamber radius in pixels.
 * mem_th: membrane thickness in layers.
 * fl_chm_h: fluid chamber depth in layers.
 * pn_chm_h: pneumatic chamber depth in layers.
 * fl_out_len: channel leads length, in pixels.
 * fl_out_h: channel leads height, in layers.
 * pn_out_len: channel leads length, in pixels.
 * pn_out_h: channel leads height, in layers.
 * dwn_chan_h, dwn_chan_w: cross section of depthwise channels, in pixels.
 * fl_extra_sp, pn_extra_sp: offset in pixels
 * flip_fl: boolean
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
*/
module valve(
    valve_r, mem_th, fl_chm_h, pn_chm_h,
    fl_out_len=20, pn_out_len=20,
    fl_out_h  =10, pn_out_h  =10,
    dwn_chan_h=0, dwn_chan_w=0,
    fl_extra_sp = 0, pn_extra_sp = 0,
    chan_h=10, chan_w=14, shape="cube", $fn=30)
{

    fluid_chamber(valve_r, fl_chm_h, fl_out_len, fl_out_h,
                    dwn_chan_h, dwn_chan_w, fl_extra_sp,
                    chan_h, chan_w, shape);
    translate([0, 0, fl_chm_h+mem_th])
    pneumatic_chamber(valve_r, pn_chm_h, pn_out_len, pn_out_h,
                        dwn_chan_h, dwn_chan_w, pn_extra_sp,
                        chan_h, chan_w, shape);
}



/**
 * valve_r: valve chamber radius in pixels.
 * mem_th: membrane thickness in layers.
 * fl_chm_h: fluid chamber depth in layers.
 * pn_chm_h: pneumatic chamber depth in layers.
 * fl_out_len: channel leads length, in pixels.
 * fl_out_h: channel leads height, in layers.
 * pn_out_len: channel leads length, in pixels.
 * pn_out_h: channel leads height, in layers.
 * dwn_chan_h, dwn_chan_w: cross section of depthwise channels, in pixels.
 * fl_extra_sp, pn_extra_sp: offset in pixels
 * flip_fl: boolean
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
*/
module valve_inline(
    valve_r, mem_th, fl_chm_h, pn_chm_h,
    fl_out_len=20, pn_out_len=20,
    fl_out_h  =10, pn_out_h  =10,
    dwn_chan_h=0, dwn_chan_w=0,
    fl_extra_sp = 0, pn_extra_sp = 0,
    chan_h=10, chan_w=14, shape="cube", $fn=30)
{

    fluid_chamber(valve_r, fl_chm_h, fl_out_len, fl_out_h,
                    dwn_chan_h, dwn_chan_w, fl_extra_sp,
                    chan_h, chan_w, shape);
    rotate([0,0,90])
    translate([0, 0, fl_chm_h+mem_th])
    pneumatic_chamber(valve_r, pn_chm_h, pn_out_len, pn_out_h,
                        dwn_chan_h, dwn_chan_w, pn_extra_sp,
                        chan_h, chan_w, shape);
}

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * valve_r: valve chamber radius in pixels.
 * mem_th: membrane thickness in layers.
 * fl_chm_h: fluid chamber depth in layers.
 * fl_out_len: channel leads length, in pixels.
 * fl_out_h: channel leads height, in layers.
 * pn_chm_h: pneumatic chamber depth in layers.
 * pn_out_len: channel leads length, in pixels.
 * pn_out_h: channel leads height, in layers.
 * dwn_chan_h, dwn_chan_w: cross section of depthwise channels, in pixels.
 * fl_extra_sp, pn_extra_sp: one of "fill", "fill-edge", or a scalar offset in pixels
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_valve(xpos, ypos, zpos, orientation,
    valve_r, mem_th, fl_chm_h, pn_chm_h,
    fl_out_len=20, pn_out_len=20,
    fl_out_h  =10, pn_out_h  =10,
    dwn_chan_h=0, dwn_chan_w=0,
    fl_extra_sp = 0, pn_extra_sp = 0, rot_pn=true,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, $fn=30)
{
    width = 2*(valve_r + fl_out_len);
    height =2*(valve_r + pn_out_len);

    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([width, height], orientation)
    translate([width/2, height/2, fl_out_h+chan_h])
        valve(
            valve_r, mem_th, fl_chm_h, pn_chm_h,
            fl_out_len, pn_out_len,
            fl_out_h  , pn_out_h  ,
            dwn_chan_h, dwn_chan_w,
            fl_extra_sp, pn_extra_sp,
            chan_h, chan_w, shape, $fn);
}

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * valve_r: valve chamber radius in pixels.
 * mem_th: membrane thickness in layers.
 * fl_chm_h: fluid chamber depth in layers.
 * fl_out_len: channel leads length, in pixels.
 * fl_out_h: channel leads height, in layers.
 * pn_chm_h: pneumatic chamber depth in layers.
 * pn_out_len: channel leads length, in pixels.
 * pn_out_h: channel leads height, in layers.
 * dwn_chan_h, dwn_chan_w: cross section of depthwise channels, in pixels.
 * fl_extra_sp, pn_extra_sp: one of "fill", "fill-edge", or a scalar offset in pixels
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_valve_inline(xpos, ypos, zpos, orientation,
    valve_r, mem_th, fl_chm_h, pn_chm_h,
    fl_out_len=20, pn_out_len=20,
    fl_out_h  =10, pn_out_h  =10,
    dwn_chan_h=0, dwn_chan_w=0,
    fl_extra_sp = 0, pn_extra_sp = 0,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, $fn=30)
{
    width = 2*valve_r;
    height =  2*(valve_r + max(pn_out_len, fl_out_len));

    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([width, height], orientation)
    translate([width/2, height/2, fl_out_h+chan_h])
        valve_inline(
            valve_r, mem_th, fl_chm_h, pn_chm_h,
            fl_out_len, pn_out_len,
            fl_out_h  , pn_out_h  ,
            dwn_chan_h, dwn_chan_w,
            fl_extra_sp, pn_extra_sp,
            chan_h, chan_w, shape, $fn);
}


p_valve(0, 0, 0, "E", 100, 5, 10, 15);
