use <../polychannel/polychannel.scad>
use <orientation.scad>

module multi_in_chamber(orientation,
    num_inputs, input_sp, chm_d, chm_l,
    chan_out_w, chan_out_h, chan_in_l = 30, chan_out_l = 30, nozzle_l = 0,
    chan_h=10, chan_w=14, shape="cube")
{
    height = chan_in_l+chan_out_l+chm_l;
    depth = chm_d;
    width = (input_sp*(num_inputs-1)+chan_w);
    chm_l_s1 = chm_l - nozzle_l;
    chm_l_s2 = nozzle_l;

    orient([width, height], orientation)
    translate([width/2, height/2, depth/2]) {
        translate([0,(chm_l-chm_l_s1)/2,0])
        cube([width,
            chm_l_s1,
            chm_d], center=true) ;
        translate([width/2-chan_w/2, chm_l/2, 0])
            for(i = [0:num_inputs-1])
                translate([-input_sp*i, chan_in_l/2, 0])
                    cube([chan_w, chan_in_l, chan_h], center=true);
        translate([0,-chm_l/2-chan_out_l/2, 0])
            cube([chan_w, chan_out_l, chan_h], center=true);
        // This seems to render fine if the length is zero, but ignoring it in case it causes problems.
        if (nozzle_l > 0)
            polychannel(
                [["cube", [width, 1/10, chm_d], [0,-(chm_l/2-nozzle_l),0], [0,[0,0,1]]],
                ["cube", [chan_w, 1/10, chan_h],  [0,-nozzle_l,0], [0,[0,0,1]]]]);
    }
}

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * num_inputs: scalar
 * input_sp: spacing between inputs in pixels.
 * chm_d: chamber depth, in layers.
 * chm_l: chamber length, in pixels
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_multi_in_chamber(xpos, ypos, zpos, orientation,
    num_inputs, input_sp, chm_d, chm_l,
    chan_out_w, chan_out_h,
    chan_in_l = 30, chan_out_l = 30,
    nozzle_l = 0,
    px=7.6e-3, layer=10e-3, lpv=20,
    chan_h=10, chan_w=14, shape="cube", pitch=30)
{
    pitch_offset = pitch - chan_w;

    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
        multi_in_chamber(orientation, num_inputs, input_sp,
                         chm_d, chm_l, chan_out_w, chan_out_h,
                        chan_in_l, chan_out_l, nozzle_l, chan_h, chan_w, shape) ;
}

p_multi_in_chamber(0,0,0,"S",5,50,10,40, nozzle_l=10);
