use <../polychannel/polychannel.scad>
use <orientation.scad>

/**
 * xpos, ypos: position in pixels.
 * zpos: position in layers
 * orientation: string enum, see orient module.
 * size: dimensions of the chamber in [px, px, layer]
 * ports: list of ports. Format is [ direction, lenght, offset ] where direction is one of /[xyz][+-]/ length is in pixels or layers, and offset is a tuple.
 * edge_rounding: rounding radius, in pixels.
 * clr: color to apply to the inner chamber geometry.
 * px: millimeters per pixel
 * layer: millimeters per layer
 * chan_h: channel height in layers.
 * chan_w: channel width in pixels.
 * shape: channel shape, see polychannel.
 * pitch: distance between channels, in pixels
*/
module p_reservoir(xpos, ypos, zpos, orientation,
    ports =[ ["z+", 50, [-140, 0]] ],
    size=[300, 300, 250], edge_rounding=0.5,
    center=true, clr="gray",
    px=0.0076, layer=0.010, pitch = 30,
    chan_w=14, chan_h=10, $fs=0.04, $fa=1)
{
    // TODO this doesn't account for any extensions of the ports beyond the chamber
    n_size = [size[0]*px, size[1]*px, size[2]*layer];
    translate([xpos*px, ypos*px, zpos*layer])
    translate([(pitch-chan_w/2)*px, (pitch-chan_w/2)*px, 0])
    orient(n_size, orientation)
    translate(n_size/2)
        reservoir(size=size, edge_rounding=edge_rounding,
        ports=ports,
        chan_w=chan_w, chan_h=chan_h,
        center=center, clr=clr, px=px, layer=layer, $fs=$fs, $fa=$fa) ;
}

module reservoir(size=[300, 300, 250], ports=[], edge_rounding=0.5, center=true, clr="gray",
    chan_w=14, chan_h=10,
    px=0.0076, layer=0.010, $fs=0.04, $fa=1) {
	module obj() {
        n_size = [size[0]*px, size[1]*px, size[2]*layer];
        translate = (center == false) ?
    		[edge_rounding, edge_rounding, edge_rounding] :
    		[
    			edge_rounding - (n_size[0] / 2),
    			edge_rounding - (n_size[1] / 2),
    			edge_rounding - (n_size[2] / 2)
    	];

        color(clr){
            translate(v = translate)
            minkowski() {
                cube(size = [
                    n_size[0] - (edge_rounding * 2),
                    n_size[1] - (edge_rounding * 2),
                    n_size[2] - (edge_rounding * 2)
                ]);
                sphere(r = edge_rounding);
            }
        }
    }
    module port (side, port_len=50, from_center=true, x_off=0, y_off=0)
    {
        i_orient =
            (side[0]=="x"?
                (side[1]=="+"?
                    [[1,0,0]*px,[0,-1,0]*px,[0,0,1]*layer]
                    :[[-1,0,0]*px,[0,-1,0]*px,[0,0,1]*layer]
                ):
            (side[0]=="y"?
                (side[1]=="+"?
                    [[0,1,0]*px, [1,0,0]*px, [0,0,1]*layer]
                    :[[0,-1,0]*px, [1,0,0]*px, [0,0,1]*layer]
                ):
            (side[0]=="z"?
                (side[1]=="+"?
                    [[0,0,1]*layer, [1,0,0]*px, [0,1,0]*px]
                    :[[0,0,-1]*layer, [1,0,0]*px, [0,1,0]*px]
                )
                :"error")));


        i_pt_s =
            (side[0]=="x"?
                size[0]/4
                :
            (side[0]=="y"?
                size[1]/4
                :
            (side[0]=="z"?
                size[2]/4
                :"error")));

        pt0 = i_orient[0]*i_pt_s+i_orient[1]*x_off+i_orient[2]*y_off;
        pt1 = i_orient[0]*(port_len)+i_orient[0]*i_pt_s;
        polychannel([
            ["cube",[chan_w*px, chan_w*px, chan_h*layer], pt0, [0,[1,0,0]]],
            ["cube",[chan_w*px, chan_w*px, chan_h*layer], pt1, [0,[1,0,0]]]
            ], clr="crimson");

    }

    obj() ;
    for(p = ports) {
        dir = p[0];
        len = p[1];
        offset = p[2];
        port(dir, port_len=len, x_off=offset[0], y_off=offset[1]);
    }
}

port_a = ["z+", 50, [-140, 0]];
port_b = ["x+", 50, [0, -270/2]];
p_reservoir(0,0,0,"N",size=[300, 300, 280], edge_rounding=0.5, ports=[port_a, port_b], clr="lightblue");

