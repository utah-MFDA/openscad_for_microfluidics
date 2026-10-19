include <BOSL2/std.scad>
include <ports.scad>
include <../components/resistor.scad>

module block_resistor(flow_in, flow_out, port_config,
                      blocks = 1,
                      major_channel = [30, 30, 5],
                      minor_channel = [10,10, 5],
                      eps=1e-2,
                      sharpness = 20,
                      angle=undef)
{
    // Parameter checks
    assert(is_flow_port(flow_in));
    assert(is_flow_port(flow_out));
    assert(is_struct(port_config));

    // Constants and configuration
    width = struct_val(port_config, "width");
    size = struct_val(port_config, "flow_cross_section");
    min_thick = struct_val(port_config, "minimum_thickness");
    dimensions = resistor_dimensions(blocks, major_channel, minor_channel, eps);
    if (dimensions[0] > width || dimensions[1] > width || dimensions[2] > width)
         echo("WARN Internal resistor dimensions greater than width",
                 dimensions, width);

    center_offset = dimensions/2;
    center = width/2 * [1,1,1];
    debug = struct_val(port_config, "debug");

    // calculate ports and minimize the angle between exterior and component ports.
    component_ports = resistor_ports(blocks, major_channel, minor_channel, eps);
    component_in = component_ports[0];
    component_out = component_ports[1];

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
            %cube(width, center=true);
        }

        rotate([0, 0, angle])
        translate(-center_offset)
        resistor(blocks, major_channel, minor_channel, eps);

        // center and rotate relative to origin
        component_in_rot = port_rotate_xy(angle, port_translate(-center_offset, component_in));
        component_out_rot = port_rotate_xy(angle, port_translate(-center_offset, component_out));

        shape = square(size, center=true);
        color("mediumpurple")
        fluid_line_input_junction(flow_in, port_config);
        offset = norm(size) + min_thick;

        color("purple")
        fluid_line(shape, offset, dimensions, exterior_in, component_in_rot, sharpness);

        color("blue")
        fluid_line(shape, offset, dimensions, exterior_out, component_out_rot, sharpness);

        color("skyblue")
        fluid_line_output_junction(flow_out, port_config);

        //

            // for (i = [-1:1], j = [-1:1], k = [-1:1]) {
            //     port = [i,j,k];
            //     if (port != [0,0,0]) {
            //         color("mediumpurple")
            //         fluid_line_input_junction(port, port_config);
            //         side = fluid_line_input_target(port, port_config);
            //         color("purple")
            //         fluid_line(port, side, component_out);
            //     }
            // }
    }
}
debug = true;
// debug = false;
width = 150;
config = create_port_config(width=width, debug=debug, show_boundary=true, minimum_thickness=5);
block_resistor([0,0,1], [-1,0,0], minor_channel=[5,5,20], blocks = 2, angle=45, sharpness=20, port_config=config);

translate([width,0,0])
block_resistor([0,0,1], [1,0,1], minor_channel=[5,5,20], blocks = 1, angle=0, port_config=config);
