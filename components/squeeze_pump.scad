use <orientation.scad>
use <../polychannel/polychannel.scad>
use <squeeze_valve.scad>

module squeeze_pump(orientation,
    mem_th, fl_chm_h,
    valve_sp=30,
    // fluid channel parameters
    fl_ext_len=30, fl_tran_len=5, fl_ext_th_len=4,
    // pneumatic channel parameters
    pn_ch_w=14, pn_pad = 14, pn_len = 40, pn_bttm_chm_h=20,
    // extra center spacing if needed when inport_center=false
    extra_sp = 0,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30)
{
    width = 2*fl_ext_len+pn_ch_w*2+2*valve_sp;
    height = pn_len*2+pn_pad;

    orient([width, height], orientation)
    translate([fl_ext_len, height/2, chan_h/2+2*mem_th+fl_chm_h+pn_bttm_chm_h]) {
        translate([0,0,0])
            squeeze_valve(
                mem_th, fl_chm_h,
                fl_ext_len=fl_ext_len,
                fl_tran_len=fl_tran_len,
                fl_ext_th_len=fl_ext_th_len,
                pn_ch_w=pn_ch_w,
                pn_pad=pn_pad,
                pn_len=pn_len,
                pn_bttm_chm_h=pn_bttm_chm_h,
                chan_h=chan_h,
                in_chan_h=chan_h,
                out_chan_h=fl_chm_h);
        translate([valve_sp+pn_ch_w,0,0])
            squeeze_valve(
                mem_th, fl_chm_h,
                pn_ch_w=pn_ch_w,
                pn_pad=pn_pad,
                pn_len=pn_len,
                pn_bttm_chm_h=pn_bttm_chm_h,
                chan_h=chan_h,
                in_chan_h=fl_chm_h,
                out_chan_h=fl_chm_h);
        translate([(valve_sp+pn_ch_w)*2,0,0])
            squeeze_valve(
                mem_th, fl_chm_h,
                fl_ext_len=fl_ext_len,
                fl_tran_len=fl_tran_len,
                fl_ext_th_len=fl_ext_th_len,
                pn_ch_w=pn_ch_w,
                pn_pad=pn_pad,
                pn_len=pn_len,
                pn_bttm_chm_h=pn_bttm_chm_h,
                chan_h=chan_h,
                in_chan_h=fl_chm_h,
                out_chan_h=chan_h);
    }
}

module p_squeeze_pump(xpos, ypos, zpos, orientation,
    mem_th, fl_chm_h,
    valve_sp=30,
    // fluid channel parameters
    fl_ext_len=30, fl_tran_len=5, fl_ext_th_len=4,
    // pneumatic channel parameters
    pn_ch_w=14, pn_pad = 14, pn_len = 40, pn_bttm_chm_h=20,
    // extra center spacing if needed when inport_center=false
    extra_sp = 0,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30)
{
    scale([px,px,layer])
    translate([xpos, ypos, zpos])
    translate([(pitch-chan_w/2), (pitch-chan_w/2), 0])
    squeeze_pump(orientation, mem_th, fl_chm_h,
                valve_sp,
                fl_ext_len, fl_tran_len, fl_ext_th_len,
                pn_ch_w, pn_pad , pn_len , pn_bttm_chm_h,
                chan_h, chan_w, shape);

}
p_squeeze_pump(0,0,0,"E", mem_th=4, fl_chm_h=6,
    pn_ch_w=18);
