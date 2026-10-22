include <BOSL2/std.scad>
include <ports.scad>

function dynamic_serpentine_port(in, out, channel, bounds, port_config) =
    [
        [[0, channel.z/2, 0], [0,1,0], [0,0,1]],
        [[0, -channel.z/2, 0], [0,-1,0], [0,0,1]]
    ];

module dynamic_serpentine(in, out, channel, bounds, port_config)
{
    ports = dynamic_serpentine_port(in, out, channel, bounds, port_config);
    start = ports[0];
    end = ports[1];
    cross_s = [channel.x, channel.y];
    length = channel.z;
    assert(length < bounds.y);
    cube([channel.x, channel.z, channel.y], center=true);
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

        dynamic_serpentine(flow_in, flow_out, channel, bounds);
    }
}

config = create_port_config(show_boundary=true, debug=false);
block_serpentine([0,1,0], [1,-1,0], config);
