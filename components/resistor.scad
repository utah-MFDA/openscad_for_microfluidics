use <../polychannel/polychannel.scad>
use <orientation.scad>

default_blocks = 1;
default_major_channel= [14, 10];
default_minor_channel = [6, 5];
default_channel_length = 5;
default_eps=1e-2;

function resistor_dimensions(blocks, major_channel, minor_channel, channel_length, eps) =
    [max(major_channel.x, minor_channel.x),
     (1+4*blocks)*channel_length+eps,
     max(major_channel.y, minor_channel.y) ];

function resistor_ports(blocks, major_channel, minor_channel, channel_length, eps) =
    let (dimensions = resistor_dimensions(blocks, major_channel, minor_channel, channel_length, eps))
    let (anchor_in = [[0, -dimensions.y/2, dimensions.z/2], [0,-1,0], [0,0,1]])
    let (anchor_out = [[0, dimensions.y/2, dimensions.z/2], [0,1,0], [0,0,1]])
    [anchor_in, anchor_out];

module resistor(blocks = default_blocks, major_channel = default_major_channel, minor_channel = default_minor_channel, channel_length = default_channel_length, eps = default_eps)
{
    minor = [minor_channel.x, eps, minor_channel.y];
    major = [major_channel.x, eps, major_channel.y];
    foo = [0, [0, 0, 1]];
    length = [0, channel_length, 0];
    four = [4, 0, 0];
    resistor_block = [
        ["cube", minor, four, foo],
        ["cube", minor, length, foo],
        ["cube", major, -four, foo],
        ["cube", major, length, foo],
        ["cube", minor, -four, foo],
        ["cube", minor, length, foo],
        ["cube", major, four, foo],
        ["cube", major, length, foo],
    ];

    translate([0, eps/2,0])
    color("RosyBrown") {
        params_pos_relative = concat(
            [
                ["cube", major, [major_channel.x/2, 0, major_channel.y/2], foo],
                ["cube", major, length, foo],
            ],
            [ for (i = [0:blocks-1]) each resistor_block]
        );
        polychannel(params_pos_relative);
    }
}

module p_resistor(xpos, ypos, zpos, orientation="N",
    numblocks = 1, wchan = 14, hchan = 10, w3chan = 6, h3chan = 5, lenchan = 5,
        eps = 1e-2, edge_offset=5,
        px=7.6e-3, layer=10e-3, lpv=20, pitch=30, chan_def=[10, 14])

{
    dimensions = resistor_dimensions(numblocks = numblocks,
                                     wchan = wchan,
                                     hchan = hchan,
                                     w3chan = w3chan,
                                     h3chan = h3chan,
                                     lenchan = lenchan,
                                     eps = eps);
    width = dimensions.x + edge_offset*2;
    height = dimensions.y + edge_offset*2;
    pitch_offset = pitch - chan_def.x;
    scale([px, px, layer])
    translate([xpos, ypos, zpos])
    translate([pitch_offset/2, pitch_offset/2, 0])
    orient([width, height], orientation)
    translate([1, 1, 0] * edge_offset)
    resistor(numblocks = numblocks,
             wchan = wchan,
             hchan = hchan,
             w3chan = w3chan,
             h3chan = h3chan,
             lenchan = lenchan,
             eps = eps);
}
