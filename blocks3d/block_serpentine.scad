include <BOSL2/std.scad>
include <ports.scad>

function dynamic_serpentine_parameters(in, out, channel, bounds, port_config) =
    // Determine spacing for a channel
    let (min_thick = struct_val(port_config, "minimum_thickness"))
    let (spacing = [min_thick + channel.x, min_thick + channel.y])

    // number of lines that can fit on a layer
    let (turns_per_layer = floor(bounds.y / spacing.x))
    // length of a line on a layer
    let (turnaround_length = PI*spacing.x/2)
    let (turnaround_radius = spacing.x/2)
    let (turnaround_width = turnaround_radius + channel.x/2)
    let (up_radius = spacing.y/2)
    let (up_length = PI*spacing.y/2)
    let (line_length = bounds.x - 2*turnaround_width)
    let (turn_length = line_length + turnaround_length)
    // last turn is an up rather than a turnaround
    let (layer_length = turns_per_layer * turn_length - turnaround_length + up_length)
    // number of layers needed
    let (folds = floor(channel.z / layer_length))
    let (layers = folds + 1)
    let (last_layer_length = channel.z - folds * layer_length)
    let (last_layer_turns = floor(last_layer_length/turn_length))
    let (total_turns = turns_per_layer * folds + last_layer_turns)
    let (remainder = channel.z - folds*layer_length - last_layer_turns*turn_length)
    assert((folds+1)*spacing.y < bounds.z)
    // path segments
    let (line = [[-line_length/2, 0, 0], [line_length/2,0,0]])
    let (remainder_line = remainder > 0 ?
                        [[-line_length/2, 0, 0], [-line_length/2 + remainder, 0, 0]]
                        : [])
    let (forward = path3d(arc(n=10, r=turnaround_radius, angle=[-90,90])))
    let (up = xrot(90, path3d(arc(n=10, r=up_radius, angle=[-90,90]))))
    [turns_per_layer, total_turns, layers, spacing, line, remainder_line, forward, up];

function dynamic_serpentine_dimensions(in, out, channel, bounds, port_config) =
    let (parameters = dynamic_serpentine_parameters(in, out, channel, bounds, port_config))
    dynamic_serpentine_dimensions_precalc(parameters);

function dynamic_serpentine_dimensions_precalc(parameters) =
    let (turns_per_layer = parameters[0])
    let (spacing = parameters[3])
    let (layers = parameters[2])
    [0, spacing.x * (turns_per_layer - 1), spacing.y * (layers - 1)];

function dynamic_serpentine_port(in, out, channel, bounds, port_config) =
    let (parameters = dynamic_serpentine_parameters(in, out, channel, bounds, port_config))
    let (dimensions = dynamic_serpentine_dimensions_precalc(parameters))
    let (path = dynamic_serpentine_path_precalc(parameters))
    dynamic_serpentine_port_precalc(path, dimensions);

function dynamic_serpentine_port_precalc(path, dimensions) =
    let (first = path[0], second = path[1])
    let (ultimate = path[len(path)-1], penultimate = path[len(path)-2])
    [
        [first - dimensions/2, unit(first - second), [0,0,1]],
        [ultimate - dimensions/2, unit(ultimate - penultimate), [0,0,1]]
    ];

function dynamic_serpentine_path_precalc(parameters) =
    let (turns_per_layer = parameters[0])
    let (total_turns = parameters[1])
    let (layers = parameters[2])
    let (spacing = parameters[3])
    let (line = parameters[4])
    let (remainder_line = parameters[5])
    let (forward = parameters[6])
    let (up = parameters[7])
    let (parts = [ for (i = [0:total_turns-1])
        let (turn = i % turns_per_layer)
        let (layer = floor(i / turns_per_layer))
        let (turnaround_join = layer % 2 ? yflip(forward) : forward)
        let (join = turn == turns_per_layer - 1 ? up : turnaround_join)
        let (line_parts = i % 2 ? [line, join] : [xflip(line), xflip(join)])
        path_join(line_parts)
    ])
    let (remainder_part =
        let (turn = total_turns % turns_per_layer)
        let (line_part = turn % 2 ? remainder_line : xflip(remainder_line))
        line_part)
    path_join([path_join(parts), remainder_part]);

module dynamic_serpentine(in, out, channel, bounds, port_config)
{
    parameters = dynamic_serpentine_parameters(in, out, channel, bounds, port_config);
    dimensions = dynamic_serpentine_dimensions_precalc(parameters);
    path = dynamic_serpentine_path_precalc(parameters);
    shape = square([channel.x, channel.y], center=true);
    translate(-dimensions/2)
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

        serp_ports = dynamic_serpentine_port(flow_in, flow_out, channel, bounds, port_config);
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
block_serpentine([1,-1,0], [-1,0,1], channel=[20, 10,500], config);
