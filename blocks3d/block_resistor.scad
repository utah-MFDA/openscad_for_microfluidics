include <BOSL2/std.scad>
include <ports.scad>
include <../components/resistor.scad>

module block_resistor(flow_in, flow_out, port_config,
                      blocks = 1,
                      major_channel = [30, 30, 5],
                      minor_channel = [10,10, 5],
                      offset=6,
                      eps=1e-2,
                      sharpness = 20,
                      angle=undef,
                      debug=false)
{
    // Parameter checks
    assert(is_flow_port(flow_in));
    assert(is_flow_port(flow_out));
    assert(is_struct(port_config));
    io_offset = struct_val(port_config, "io_offset");
    assert(io_offset > 0 || (flow_in != flow_out));

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
    intersect_test = struct_val(port_config, "intersect_test");

    // calculate ports and minimize the angle between exterior and component ports.
    component_ports = [
        for (port = resistor_ports(blocks, major_channel, minor_channel, eps))
        port_translate(-center_offset, port)];
    component_out = component_ports[0];
    component_in = component_ports[1];

    exterior_in = fluid_line_input_target(flow_in, port_config);
    exterior_out = fluid_line_output_target(flow_out, port_config);
    exterior_ports = [exterior_out, exterior_in];

    // Try and minimize the angle, round to the nearest 90 degree
    minim_angle = minimize_angle(exterior_ports, component_ports, port_config);
    round = 180;
    round_angle = modang(round(posang(minim_angle)/round)*round);
    use_angle = (is_undef(angle) ? round_angle : angle);

    shape = square(size, center=true);
    margin = norm(size)/2 + min_thick;

    module inner_resist()
    {
        rotate([0, 0, use_angle])
        translate(-center_offset)
        resistor(blocks, major_channel, minor_channel, offset=offset, eps=eps);
    }

    module inner_input()
    {
        color("mediumpurple")
        fluid_line_input_junction(flow_in, port_config);

        color("purple")
        fluid_line(shape, margin, dimensions, exterior_in,
                   port_rotate_xy(use_angle, component_in),
                   sharpness, debug=debug);
    }

    module inner_output()
    {
        color("blue")
        fluid_line(shape, margin, dimensions, exterior_out,
                   port_rotate_xy(use_angle, component_out),
                   sharpness, debug=debug);

        color("skyblue")
        fluid_line_output_junction(flow_out, port_config);
    }

    // geometry
    translate(center) {
        if (intersect_test) {
            intersection() {
                inner_resist();
                inner_input();
            }
            intersection() {
                inner_output();
                inner_input();
            }
            intersection() {
                inner_output();
                inner_resist();
            }
        } else {

            // outer boundary
            if (struct_val(port_config, "show_boundary")) {
                %cube(cell_dimensions, center=true);
            }

            inner_input();
            inner_output();
            inner_resist();
        }
    }
}
