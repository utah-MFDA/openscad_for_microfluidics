use <../polychannel/polychannel.scad>
use <valve.scad>
use <orientation.scad>

module pump(orientation,
    r1=46, r2=46, r3=46,
    th1 = 10, th2 = 10, th3 = 10,
    fl_h1=10, fl_h2=10, fl_h3=10,
    pn_h1=14, pn_h2=14, pn_h3=14,
    len_sp=30, pn_out_len=20,
    fl_extra_sp=4, pn_extra_sp="fill",
    fl_out_h=10, pn_out_h=10, ends_ex_len=10,
    dwn_chan_h=0, dwn_chan_w=0,
    port_chan_h=0, port_chan_w=0,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30)
{
    module obj() {
        r_max = max(r1, r2, r3);

        dimm  = [chan_w,chan_w,chan_h] ;
        dimmp = [port_chan_w,port_chan_w,port_chan_h] ;
        pt0_0 = [chan_w/2,0,chan_h/2] ;
        pt0_1 = [ends_ex_len,0,0] ;

        pt1_0 = [
            (r1*2+r2*2+r3*2+len_sp*3+ends_ex_len),
            0,
            chan_h/2] ;
        pt1_1 = [ends_ex_len,0,0] ;
        // check 1
        translate([(ends_ex_len+chan_w), 0, 2*chan_h]){
            translate([r1, 0,0])
                valve(
                    valve_r=r1,
                    mem_th=th1,
                    fl_extra_sp=fl_extra_sp,
                    fl_chm_h=fl_h1,
                    pn_chm_h=pn_h1,
                    fl_out_len=len_sp/2,
                    pn_out_len=r_max-r1+pn_out_len,
                    pn_extra_sp=pn_extra_sp,
                    fl_out_h=fl_out_h,
                    chan_h=chan_h, chan_w=chan_w,
                    dwn_chan_h=dwn_chan_h, dwn_chan_w=dwn_chan_w);
            // pump
            translate([(r1*2+len_sp+r2),0,0])
                valve(
                    valve_r=r2,
                    mem_th=th2,
                    fl_chm_h=fl_h2,
                    pn_chm_h=pn_h2,
                    fl_out_len=len_sp/2,
                    pn_out_len=r_max-r2+pn_out_len,
                    fl_extra_sp=fl_extra_sp,
                    pn_extra_sp=pn_extra_sp,
                    fl_out_h=fl_out_h,
                    chan_h=chan_h, chan_w=chan_w,
                    dwn_chan_h=dwn_chan_h, dwn_chan_w=dwn_chan_w);
            // check 2
            translate([(r1*2+r2*2+2*len_sp+r3),0,0])
                valve(
                    valve_r=r3,
                    mem_th=th3,
                    fl_extra_sp=fl_extra_sp,
                    fl_chm_h=fl_h3,
                    pn_chm_h=pn_h3,
                    fl_out_len=len_sp/2,
                    pn_out_len=r_max-r3+pn_out_len,
                    pn_extra_sp=pn_extra_sp,
                    fl_out_h=fl_out_h,
                    chan_h=chan_h, chan_w=chan_w,
                    dwn_chan_h=dwn_chan_h, dwn_chan_w=dwn_chan_w);
        }
        polychannel(
            [[shape, (port_chan_w==0 || port_chan_h==0?dimm:dimmp), pt0_0, [0,[0,0,1]]],
            [shape, dimm, pt0_1, [0,[0,0,1]]],]) ;
        polychannel(
            [[shape, dimm, pt1_0, [0,[0,0,1]]],
            [shape, (port_chan_w==0 || port_chan_h==0?dimm:dimmp), pt1_1, [0,[0,0,1]]],]) ;
    }
    width = r1*2+r2*2+r3*2+len_sp*3+ends_ex_len;
    height = 2*max(r1, r2, r3) + 2*pn_out_len;

    orient([width, height], orientation)
    translate([0, height/2, 0])
        obj() ;
}

module p_pump(xpos, ypos, zpos, orientation,
    r1=46, r2=46, r3=46,
    th1 = 10, th2 = 10, th3 = 10,
    fl_h1=10, fl_h2=10, fl_h3=10,
    pn_h1=14, pn_h2=14, pn_h3=14,
    len_sp=30, pn_out_len=20,
    fl_extra_sp=4, pn_extra_sp="fill",
    fl_out_h=10, pn_out_h=10, ends_ex_len=10,
    dwn_chan_h=0, dwn_chan_w=0,
    port_chan_h=0, port_chan_w=0,
    px=7.6e-3, layer=10e-3, lpv=20, pitch=30,
    chan_h=10, chan_w=14, shape="cube")
{
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([(pitch-chan_w/2), (pitch-chan_w/2), 0])
    pump(orientation,
        r1, r2, r3,
        th1 , th2 , th3 ,
        fl_h1, fl_h2, fl_h3,
        pn_h1, pn_h2, pn_h3,
        len_sp, pn_out_len,
        fl_extra_sp, pn_extra_sp,
        fl_out_h, pn_out_h, ends_ex_len,
        dwn_chan_h, dwn_chan_w,
        port_chan_h, port_chan_w,
        chan_h, chan_w, shape);
}

p_pump (0, 0, 0, "N",
    r1=20, r2=40, r3=20,
    th1=0.6, th2=0.6, th3=0.6,
    fl_h1=3.1, fl_h2=3.1, fl_h3=3.1,
    pn_h1=4, pn_h2=4, pn_h3=4,
    len_sp=15,
    pn_out_len=25, ends_ex_len=10,
    fl_extra_sp=10, pn_extra_sp="fill-edge",
    dwn_chan_h=8, dwn_chan_w=10,
    port_chan_h=10, port_chan_w=14,
    lpv=20, chan_h=10, chan_w=14, shape="cube") ;
