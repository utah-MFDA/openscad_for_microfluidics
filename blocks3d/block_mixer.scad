include <BOSL2/std.scad>
include <ports.scad>
include <../components/mixer.scad>

function reorder_inputs(output, input_a, input_b, port_config) =
    // Eliminate the offsets, they would push points
    // just around the other side and flip the order
    let (simple_config = struct_set(struct_set(port_config,
                                 "collision_offset", [0,0]),
                                 "io_offset", 0))
    let (y = fluid_line_output_target(output, simple_config))
    let (a = fluid_line_input_target(input_a, simple_config))
    let (b = fluid_line_input_target(input_b, simple_config))
    let (ports = [y, a, b])
    let (base = atan2(port_position(y).y, port_position(y).x))
    let (angles = [for (port = ports)
                    let (p = port_position(port))
                    posang(atan2(p.y, p.x) - base)])
    sortidx(angles);

module block_mixer(input_a, input_b, output, port_config, mixer_angle=45, mixer_lead=4, sharpness=10, angle=undef, round=1, debug = false)
{
    // Parameter checks
    assert(is_flow_port(input_a));
    assert(is_flow_port(input_b));
    assert(is_flow_port(output));
    assert(input_b != input_a);
    assert(input_b != input_a);

    io_offset = struct_val(port_config, "io_offset");
    assert(io_offset > 0 || (input_b != output && input_a != output));

    // Constants and configuration
    cell_dimensions = struct_val(port_config, "cell_dimensions");
    size = struct_val(port_config, "flow_cross_section");
    min_thick = struct_val(port_config, "minimum_thickness");
    margin = norm(size) + min_thick;
    debug = struct_val(port_config, "debug") || debug;
    intersect_test = struct_val(port_config, "intersect_test");

    dimensions = mixer_dimensions(size, mixer_lead, mixer_angle);
    center_offset = dimensions * diagonal([1,1,0]/2);
    center = cell_dimensions/2;
    // minimize the angles between component and exterior ports.
    component_ports = [for (c = mixer_ports(size, mixer_lead, mixer_angle))
                        port_translate(-center_offset, c)];

    // swap order of inputs so that the order is counter-clockwise to match mixer order
    port_order = reorder_inputs(output, input_a, input_b, port_config);
    ports = [
        fluid_line_output_target(output, port_config),
        fluid_line_input_target(input_a, port_config),
        fluid_line_input_target(input_b, port_config)
    ];
    exterior_ports = [for (i = port_order) ports[i]];

    minim_angle = minimize_angle(exterior_ports, component_ports, port_config);
    round_angle = modang(round(posang(minim_angle)/round)*round);
    use_angle = (is_undef(angle) ? round_angle : angle);

    // Geometry
    module mixer_fluid_line(external_port, component_port)    {
        component = port_rotate_xy(use_angle, component_port);
        fluid_line(square(size, center=true), margin, dimensions, external_port, component, sharpness, debug=debug);
    }

    module inner_in_a()
    {
        color("mediumpurple")
        fluid_line_input_junction(input_a, port_config);

        color("purple")
        mixer_fluid_line(exterior_ports[1], component_ports[1]);
    }

    module inner_in_b()
    {
        color("mediumpurple")
        fluid_line_input_junction(input_b, port_config);

        color("purple")
        mixer_fluid_line(exterior_ports[2], component_ports[2]);
    }

    module inner_out()
    {
        color("skyblue")
        fluid_line_output_junction(output, port_config);

        color("blue")
        mixer_fluid_line(exterior_ports[0], component_ports[0]);
    }

    module inner_mixer()
    {
        rotate([0,0,use_angle])
        translate(-center_offset)
        mixer(size, mixer_lead, mixer_angle);
    }

    translate(center) {
        // This is gross to embed, but not really a better place to put it
        // with the needed scope closure
        if (intersect_test) {
            intersection() {
                inner_in_b();
                inner_in_a();
            }
            intersection() {
                inner_in_b();
                inner_out();
            }
            intersection() {
                inner_in_b();
                round = 45;
                inner_mixer();
            }
            intersection() {
                inner_in_a();
                inner_out();
            }
            intersection() {
                inner_in_a();
                round = 45;
                inner_mixer();
            }
            intersection() {
                inner_out();
                round = 45;
                inner_mixer();
            }
        } else {
            // outer boundary
            if (struct_val(port_config, "show_boundary")) {
                %cube(cell_dimensions, center=true);
            }
            inner_in_b();
            inner_in_a();
            inner_out();
            round = 45;
            inner_mixer();
        }
    }
}
