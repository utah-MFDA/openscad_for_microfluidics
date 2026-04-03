use <../polychannel/polychannel.scad>
use <orientation.scad>

module chamber(orientation,
    chm_r, chm_h, chm_len=0,
    conn_ch_w=14, conn_ch_h=10, conn_ch_l=20,
    han_h=10, chan_w=14, shape="cube", $fn=50)
{

    width = chm_len + 2*conn_ch_l;
    height = 2*chm_r ;
    orient([width, height], orientation)
    translate([width/2, height/2, chm_h/2]) {

        real_conn_h = (conn_ch_h>chm_h?chm_h:conn_ch_h);

        if(chm_len > 2*chm_r) {

            translate([chm_len/2-chm_r, 0, 0])
                cylinder(chm_h, r=chm_r, center= true) ;
            translate([-chm_len/2+chm_r, 0, 0])
                cylinder(chm_h, r=chm_r, center= true) ;
            cube([chm_len-chm_r*2, chm_r*2, chm_h], center= true) ;
        } else {
            cylinder(chm_h, r=chm_r, center= true) ;
        }
        translate([-chm_len/2-conn_ch_l/2+chm_r/2, 0, 0])
            cube([conn_ch_l+chm_r, conn_ch_w, real_conn_h], center=true);
        translate([chm_len/2+conn_ch_l/2-chm_r/2, 0, 0])
            cube([conn_ch_l+chm_r, conn_ch_w, real_conn_h], center=true);

    }
}

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * chm_r: chamber radius in pixels.
 * chm_h: chamber depth in layers.
 * chm_len: chamber length between radius in pixels.
 * mem_th: membrane thickness in layers.
 * conn_ch_w: width of input/output channel in pixels.
 * conn_ch_h: depth of input/output channel in layers.
 * conn_ch_l: length of input/output channel in pixels.
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_chamber(xpos, ypos, zpos, orientation,
    chm_r, chm_h, chm_len=0,
    conn_ch_w=14, conn_ch_h=10, conn_ch_l=20,
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, $fn=50)
{

    pitch_offset = pitch - chan_w;
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    chamber(orientation, chm_r, chm_h, chm_len, conn_ch_w, conn_ch_h, conn_ch_l, chan_h, chan_w, shape, $fn);
}


p_chamber(0, 0, 0, "E", 100, 10, chm_len=800);
