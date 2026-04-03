use <../polychannel/polychannel.scad>
use <orientation.scad>

module p_valve_4way(xpos, ypos, zpos, orientation,
    valve_r, mem_th, fl_chm_h, pn_chm_h,
    out_len=30, fl_out_h=10, fl_out_len=10, pn_out_len=10,
    // length of channels extending outside of valve radius
    fl_extra_sp=10, pn_extra_sp=10, pn_up_layers=10, rot_pn=false,
    px=7.6e-3, layer=10e-3, lpv=20, pitch=30,
    chan_h=10, chan_w=14, shape="cube")
{

    module obj()
    {
        $fn=30;
        chan_dimm = [chan_w, chan_w, chan_h];
        translate([0,0,fl_chm_h/2])
            cylinder(fl_chm_h, r=valve_r, center=true);
        translate([0,0,(fl_chm_h+mem_th+pn_chm_h/2)])
            cylinder(pn_chm_h, r=valve_r, center=true);

        // fluid connection channel definitions

        inp_pos = -((valve_r/4+fl_extra_sp)*px);

        outp_pos= -inp_pos;


        fl_len_0 = (valve_r*3/4-chan_w/2-fl_extra_sp+fl_out_len);

        fl_len_1 = (valve_r*3/4-chan_w/2-fl_extra_sp+fl_out_len) ;

        polychannel(
            [[shape, chan_dimm, [inp_pos,0,-chan_h/2], [0,[0,0,1]]],
            [shape, chan_dimm, [0,0,-fl_out_h], [0,[0,0,1]]],
            [shape, chan_dimm, [-fl_len_0,0,0], [0,[0,0,1]]]
        ]);
        polychannel(
            [[shape, chan_dimm, [outp_pos,0,-chan_h/2], [0,[0,0,1]]],
            [shape, chan_dimm, [0,0,-fl_out_h], [0,[0,0,1]]],
            [shape, chan_dimm, [fl_len_1,0,0], [0,[0,0,1]]]
        ]);
        polychannel(
            [[shape, chan_dimm, [0,inp_pos,-chan_h/2], [0,[0,0,1]]],
            [shape, chan_dimm, [0,0,-fl_out_h], [0,[0,0,1]]],
            [shape, chan_dimm, [0,-fl_len_0,0], [0,[0,0,1]]]
        ]);
        polychannel(
            [[shape, chan_dimm, [0,outp_pos,-chan_h/2], [0,[0,0,1]]],
            [shape, chan_dimm, [0,0,-fl_out_h], [0,[0,0,1]]],
            [shape, chan_dimm, [0,fl_len_1,0], [0,[0,0,1]]]
        ]);

        // pneumatic channel definitions
        init_z_off = (fl_chm_h+mem_th+pn_chm_h);
        //pn_pos_lat = (valve_r/4+chan_w/2);
        //pn_len     = (valve_r*3/4-chan_w+out_len);
        pn_pos_lat = (pn_extra_sp=="fill"?
            (valve_r-chan_w/2-1):
            (pn_extra_sp=="fill-edge"?(valve_r+chan_w/2-4):
                (valve_r/4+chan_w/2)));
        pn_len     = (pn_extra_sp=="fill"?
            (pn_out_len+1):
            (pn_extra_sp=="fill-edge"?(pn_out_len-chan_w+4):
                (valve_r*3/4-chan_w+pn_out_len)));

        rotate([0,0,(rot_pn?90:0)])
        {
        polychannel(
            [[shape, chan_dimm, [0,pn_pos_lat,init_z_off], [0,[0,0,1]]],
            [shape, chan_dimm, [0,0,pn_up_layers], [0,[0,0,1]]],
            [shape, chan_dimm, [0,pn_len,0], [0,[0,0,1]]]
        ]);
        polychannel(
            [[shape, chan_dimm, [0,-pn_pos_lat,init_z_off], [0,[0,0,1]]],
            [shape, chan_dimm, [0,0,pn_up_layers], [0,[0,0,1]]],
            [shape, chan_dimm, [0,-pn_len,0], [0,[0,0,1]]]
        ]);
        }
    }

    extend = 2*(valve_r + max(fl_out_len, pn_out_len));
    dimensions = [extend, extend];
    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient(dimensions, orientation)
    translate(dimensions/2)
    translate([0, 0, 2*chan_h])
        obj();
}

p_valve_4way(0,0,0,"N",
    50,4,10,20);
