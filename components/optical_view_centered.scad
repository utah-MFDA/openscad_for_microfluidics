use <../polychannel/polychannel.scad>
use <orientation.scad>

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * r_ch: radius of chambers in pixels.
 * i_depth: in layers
 * d_depth: in layers
 * d_ch_distance: in layers
 * num_of_ch: number of chambers, scalar
 * init_path_len: length of input channel, in pixels.
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_optical_view_centered(xpos, ypos, zpos, orientation,
    r_ch=20, i_depth=10, d_depth=6, d_ch_distance=10, num_of_ch=5, init_path_len=27,
    px=7.6e-3, layer=10e-3, lpv=20, pitch=30,
   chan_w=10, chan_h=14, shape="cube")
{
    pitch_offset = pitch - chan_w;
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    optical_view_centered(orientation,
        r_ch, i_depth, d_depth, d_ch_distance, num_of_ch, init_path_len,
       chan_w, chan_h, shape);
}
/**
 * orientation: string enum, see orient module.
 * r_ch: radius of chambers in pixels.
 * i_depth: in layers
 * d_depth: in layers
 * d_ch_distance: in layers
 * num_of_ch: number of chambers, scalar
 * init_path_len: length of input channel, in pixels.
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
*/
module optical_view_centered(orientation,
    r_ch=20, i_depth=10, d_depth=6, d_ch_distance=10, num_of_ch=5, init_path_len=27,
   chan_w=10, chan_h=14, shape="cube")
{
    // path defs
    // path defs
    i_dimm = [chan_w, chan_w, i_depth] ;
    nr = [0,[0,0,1]] ;

    // cylinder curve correction
    cc = 3;

    module obj()
    {
        // Create cylinders, with the first centered on the origin.
        for(i = [0:num_of_ch-1])
        {
            translate([i*(2*r_ch+d_ch_distance),0,-d_depth*i/2])
            cylinder(r=r_ch, h=i_depth+d_depth*i) ;

            d1  = [i_dimm[0], i_dimm[1], i_depth+d_depth*i] ;
            d2  = [i_dimm[0], i_dimm[1], i_depth+d_depth*(i+1)] ;

            pt1 = [ r_ch+i*(2*r_ch+d_ch_distance)+cc, 0, i_dimm[2]/2];
            pt2 = [ d_ch_distance+i_dimm[0]/2-cc, 0, 0] ;

            if(i < num_of_ch-1)
                polychannel([
                    [shape, d1, pt1, nr],
                    [shape, d2, pt2, nr],
                ]) ;
        }

        // Inlet
        f_dimm = [i_dimm[0], i_dimm[1], i_dimm[2]+(num_of_ch-1)*d_depth] ;
        f_pt = [(r_ch*2+d_ch_distance)*(num_of_ch-1)+r_ch-i_dimm[0]/2, 0, i_dimm[2]/2] ;

        polychannel([[shape, f_dimm, f_pt, nr],
             [shape, i_dimm, [init_path_len/2, 0, 0], nr],
             [shape, i_dimm, [init_path_len/2, 0, 0], nr]]) ;
        // Outlet
        polychannel([[shape, i_dimm, [-r_ch,0,i_dimm[2]/2], nr],
            [shape, i_dimm, [-init_path_len,0,0], nr]]) ;
    }

    width = num_of_ch*r_ch*2 + (num_of_ch - 1)*d_ch_distance + init_path_len*2 + i_dimm[0]/2;
    height = 2*r_ch;

    orient([width, height], orientation)
    translate([init_path_len+r_ch+i_dimm[0]/2, r_ch,d_depth*(num_of_ch-1)/2 ])
    obj();

}

p_optical_view_centered(0,0,0,"E") ;
