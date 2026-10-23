include <BOSL2/std.scad>
include <ports.scad>

function dynamic_serpentine_port(in, out, channel, bounds, port_config) =
    [
        [[0, bounds.z/2, 0], [0,1,0], [0,0,1]],
        [[0, -bounds.z/2, 0], [0,-1,0], [0,0,1]]
    ];

module dynamic_serpentine(in, out, channel, bounds, port_config)
{
    // Determine spacing for a channel
    min_thick = struct_val(port_config, "minimum_thickness");
    spacing = [min_thick + channel.x, min_thick + channel.y];

    // number of lines that can fit on a layer
    turns_per_layer = floor(bounds.y / spacing.x);
    // length of a line on a layer
    turnaround_length = PI*spacing.x/2;
    turnaround_radius = spacing.x/2;
    turnaround_width = turnaround_radius + channel.x/2;
    up_radius = spacing.y/2;
    up_length = PI*spacing.y/2;
    line_length = bounds.x - 2*turnaround_width;
    turn_length = line_length + turnaround_length;
    // last turn is an up rather than a turnaround
    layer_length = turns_per_layer * turn_length - turnaround_length + up_length;
    // number of layers needed
    folds = floor(channel.z / layer_length);
    last_layer_length = channel.z - folds * layer_length;
    last_layer_turns = floor(last_layer_length/turn_length);
    total_turns = turns_per_layer * folds + last_layer_turns;
    remainder = channel.z - folds*layer_length - last_layer_turns*turn_length;
    assert((folds+1)*spacing.y < bounds.z);

    echo("turns per layer", turns_per_layer);
    echo("folds", folds);
    echo("turn length", turn_length);
    echo("total turns", total_turns);
    echo("layer length", layer_length);
    echo("last layer length", last_layer_length);
    echo("remainder", remainder);
    echo("total length", folds*layer_length + last_layer_turns*turn_length + remainder);

    // path segments
    line = [[-line_length/2, 0, 0], [line_length/2,0,0]];
    remainder_line = [[-line_length/2, 0, 0], [-line_length/2 + remainder, 0, 0]];
    forward = path3d(arc(n=10, r=turnaround_radius, angle=[-90,90]));
    up = xrot(90, path3d(arc(n=10, r=up_radius, angle=[-90,90])));

    parts = [ for (i = [0:total_turns-1])
        let (turn = i % turns_per_layer)
        let (layer = floor(i / turns_per_layer))
        let (turnaround_join = layer % 2 ? yflip(forward) : forward)
        let (join = turn == turns_per_layer - 1 ? up : turnaround_join)
        let (line_parts = i % 2 ? [line, join] : [xflip(line), xflip(join)])
        echo(turn, layer, line_parts[0], line_parts[1][0], line_parts[1][9])
        path_join(line_parts)
    ];
    main_path = path_join(parts);
    remainder_part =
        let (turn = total_turns % turns_per_layer)
        let (fold = floor(total_turns / folds))
        let (line_part = turn % 2 ? remainder_line : xflip(remainder_line))
        echo(line_part)
        line_part;
    path = remainder > 0 ? path_join([main_path, remainder_part]) : main_path;

    shape = square([channel.x, channel.y], center=true);
    translate(-[0, spacing.x * (turns_per_layer - 1), spacing.y * (folds - 1)]/2)
    path_sweep(shape, path);
}

module block_serpentine(flow_in, flow_out, port_config,
                        channel = [30, 30, 50],
                        debug=false)
{
    // Parameter checks
    assert(is_flow_port(flow_in));
    assert(is_flow_port(flow_out));
    assert(is_struct(port_config));
    io_offset = struct_val(port_config, "io_offset");
    assert(io_offset > 0 || (flow_in != flow_out));

    // Constants and configuration
    debug = debug || struct_val(port_config, "debug");
    sharpness = 10;
    cell_dimensions = struct_val(port_config, "cell_dimensions");
    size = struct_val(port_config, "flow_cross_section");
    min_thick = struct_val(port_config, "minimum_thickness");
    margin = min_thick + norm(size);
    bounds = 0.8*cell_dimensions;

    center = cell_dimensions/2;

    {
    // translate(center) {
        if (struct_val(port_config, "show_boundary")) {
            %cube(cell_dimensions, center=true);
        }

        serp_ports = dynamic_serpentine_port(flow_in, flow_out, channel, bounds);
        exterior_in = fluid_line_input_target(flow_in, port_config);
        exterior_out = fluid_line_output_target(flow_out, port_config);

        shape = square(size, center=true);

        generic_path(shape, exterior_in, port_tangent_scale(sharpness, serp_ports[0]), debug=debug);
        fluid_line_input_junction(flow_in, port_config);

        generic_path(shape, exterior_out, port_tangent_scale(sharpness, serp_ports[1]), debug=debug);
        fluid_line_output_junction(flow_out, port_config);

        dynamic_serpentine(flow_in, flow_out, channel, bounds, port_config);
    }
}

config = create_port_config(cell_dimensions = 100/0.9*[1,1,1], show_boundary=true, debug=false);
block_serpentine([0,1,0], [1,-1,0], channel=[20, 10,500], config);
