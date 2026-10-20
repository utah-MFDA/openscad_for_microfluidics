include <BOSL2/std.scad>
include <ports.scad>
include <../components/resistor.scad>

module block_resistor(flow_in, flow_out, port_config,
                      blocks = 1,
                      major_channel = [30, 30, 5],
                      minor_channel = [10,10, 5],
                      offset=2,
                      eps=1e-2,
                      sharpness = 20,
                      angle=undef,
                      debug=false)
{
    // Parameter checks
    assert(is_flow_port(flow_in));
    assert(is_flow_port(flow_out));
    assert(is_struct(port_config));

    // Constants and configuration
    cell_dimensions = struct_val(port_config, "cell_dimensions");
    size = struct_val(port_config, "flow_cross_section");
    min_thick = struct_val(port_config, "minimum_thickness");
    dimensions = resistor_dimensions(blocks, major_channel, minor_channel, eps);
    if (dimensions.x > cell_dimensions.x || dimensions.y > cell_dimensions.y || dimensions.z > cell_dimensions.z)
         echo("WARN Internal resistor dimensions greater than cell size",
                 dimensions, cell_dimensions);

    center_offset = dimensions/2;
    center = cell_dimensions/2;
    debug = debug || struct_val(port_config, "debug");

    // calculate ports and minimize the angle between exterior and component ports.
    component_ports = resistor_ports(blocks, major_channel, minor_channel, eps);
    component_in = port_translate(-center_offset, component_ports[0]);
    component_out = port_translate(-center_offset, component_ports[1]);

    exterior_in = fluid_line_input_target(flow_in, port_config);
    exterior_out = fluid_line_output_target(flow_out, port_config);
    exterior_ports = [exterior_in, exterior_out];

    // Try and minimize the angle, round to the nearest 90 degree
    minim_angle = round(minimize_angle(exterior_ports, component_ports, port_config)/90)*90;

    angle = (is_undef(angle) ? minim_angle : angle);

    // geometry
    translate(center) {
        // outer boundary
        if (struct_val(port_config, "show_boundary")) {
            %cube(cell_dimensions, center=true);
        }

        rotate([0, 0, angle])
        translate(-center_offset)
        resistor(blocks, major_channel, minor_channel, offset=offset, eps=eps);

        shape = square(size, center=true);
        margin = norm(size) + min_thick;

        color("mediumpurple")
        fluid_line_input_junction(flow_in, port_config);

        color("purple")
        fluid_line(shape, margin, dimensions, exterior_in,
                   port_rotate_xy(angle, component_in),
                   sharpness, debug=debug);

        color("blue")
        fluid_line(shape, margin, dimensions, exterior_out,
                   port_rotate_xy(angle, component_out),
                   sharpness, debug=debug);

        color("skyblue")
        fluid_line_output_junction(flow_out, port_config);
    }
}
