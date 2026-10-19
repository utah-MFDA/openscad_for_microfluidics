use <../polychannel/polychannel.scad>
use <orientation.scad>

default_blocks = 1;
default_major_channel= [14, 10, 5];
default_minor_channel = [6, 5, 5];
default_eps=1e-2;

function resistor_dimensions(blocks, major_channel, minor_channel, eps) =
    [max(major_channel.x, minor_channel.x),
     (1+blocks)*major_channel.z + blocks*minor_channel.z + eps,
     max(major_channel.y, minor_channel.y) ];

function resistor_ports(blocks, major_channel, minor_channel, eps) =
    let (dimensions = resistor_dimensions(blocks, major_channel, minor_channel, eps))
    let (anchor_in = [[dimensions.x/2, 0, dimensions.z/2], [0,-1,0], [0,0,1]])
    let (anchor_out = [[dimensions.x/2, dimensions.y, dimensions.z/2], [0,1,0], [0,0,1]])
    [anchor_in, anchor_out];

module resistor(blocks = default_blocks,
                major_channel = default_major_channel,
                minor_channel = default_minor_channel,
                offset = 4,
                eps = default_eps)
{
    minor = [minor_channel.x, eps, minor_channel.y];
    major = [major_channel.x, eps, major_channel.y];
    foo = [0, [0, 0, 1]];
    minor_length = [0, minor_channel.z, 0];
    major_length = [0, major_channel.z, 0];
    offset_array = [offset, 0, 0];

    function block_dimensions(offset_dir) = [
            ["cube", minor, offset_dir, foo],
            ["cube", minor, minor_length, foo],
            ["cube", major, -offset_dir, foo],
            ["cube", major, major_length, foo],
    ];

    translate([0, eps/2,0])
    color("RosyBrown") {
        params_pos_relative = concat(
            [
                ["cube", major, [major_channel.x, 0, major_channel.y]/2, foo],
                ["cube", major, major_length, foo],
            ],
            [ for (i = [0:blocks-1]) each
                let (offset = (i % 2 ? -1 : 1)*offset_array)
                block_dimensions(offset)
            ]
        );
        polychannel(params_pos_relative);
    }
}

module p_resistor(xpos, ypos, zpos, orientation="N",
    numblocks = 1, wchan = 14, hchan = 10, w3chan = 6, h3chan = 5, lenchan = 5,
        eps = 1e-2, edge_offset=5,
        px=7.6e-3, layer=10e-3, lpv=20, pitch=30, chan_def=[10, 14])

{
    major_channel = [wchan, hchan, lenchan];
    minor_channel = [w3chan, h3chan, lenchan];
    p_resistor(xpos, ypos, zpos, orientation,
            blocks+2, major_channel, minor_channel, eps,
            edge_offset, px, layer, lpv, pitch, chan_def);
}

module cell_resistor(xpos, ypos, zpos, orientation="N",
                blocks, major_channel, minor_channel, eps = 1e-2,
                edge_offset=5,
                px=7.6e-3, layer=10e-3, lpv=20, pitch=30, chan_def=[10, 14])
{
    dimensions = resistor_dimensions(blocks = numblocks,
                                     major_channel,
                                    minor_channel,
                                    eps);
    width = dimensions.x + edge_offset*2;
    height = dimensions.y + edge_offset*2;
    pitch_offset = pitch - chan_def.x;
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([width, height], orientation)
    translate([1, 1, 0] * edge_offset)
    resistor(blocks, major_channel, minor_channel, eps);
}
