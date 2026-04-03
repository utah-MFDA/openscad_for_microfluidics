use <../polychannel/polychannel.scad>
use <orientation.scad>

module tall_mixer(orientation,
    mix_l, mix_w, mix_h,
    chan_io_len=20, chan_tran_len=10, mix_z_offset=0,
    chan_h=10, chan_w=14, shape="cube")
{
    chan_io_dimm = [1, chan_w, chan_h];
    chan_mix_dimm= [1, mix_w, mix_h] ;

    width = 2*(chan_io_len+chan_tran_len)+mix_l;
    init_l_offset = width/2;
    height = chan_w;
    orient([width, height], orientation)
    translate([width/2, height/2,mix_h/2])
        polychannel([
        ["cube", chan_io_dimm, [-init_l_offset, 0, 0], [0,[0,0,1]]],
        ["cube", chan_io_dimm, [chan_io_len, 0, 0], [0,[0,0,1]]],
        ["cube", chan_mix_dimm,[chan_tran_len, 0, mix_z_offset], [0,[0,0,1]]],
        ["cube", chan_mix_dimm,[mix_l, 0, 0], [0,[0,0,1]]],
        ["cube", chan_io_dimm, [chan_tran_len, 0, -mix_z_offset], [0,[0,0,1]]],
        ["cube", chan_io_dimm, [chan_io_len, 0, 0], [0,[0,0,1]]],
        ]) ;
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
module p_tall_mixer(xpos, ypos, zpos, orientation,
    mix_l, mix_w, mix_h,
    chan_io_len=20, chan_tran_len=10, mix_z_offset=0,
    px=7.6e-3, layer=10e-3, lpv=20, pitch=30,
    chan_h=10, chan_w=14, shape="cube")
{
    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    tall_mixer(orientation,
                mix_l, mix_w, mix_h,
                chan_io_len, chan_tran_len, mix_z_offset,
                chan_h, chan_w, shape);
}

p_tall_mixer(0, 0, 0, "E", 100, 6, 50, mix_z_offset=10);
