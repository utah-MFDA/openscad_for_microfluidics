include <BOSL2/std.scad>
include <ports.scad>
module block_dummy(inputs, outputs, port_config, id="block_dummy")
{
    module io_hint(i) {
        start = [0,0,0];
        end = v_mul(cell_dimensions, i);
        color("red")
        stroke([start, end], width=10);
    }

    cell_dimensions = struct_val(port_config, "cell_dimensions");
    size = struct_val(port_config, "flow_cross_section");
    shape = square(size, center=true);
    translate(cell_dimensions/2) {
        sphere(10);
        for (input = inputs) {
            if (is_flow_port(input)) {
                target = fluid_line_input_target(input, port_config);
                start = [[0,0,0], -port_tangent(target), port_normal(target)];
                color("mediumpurple")
                fluid_line_input_junction(input, port_config);
                color("purple")
                generic_path(shape, start, target);
            } else {
                io_hint(input);
            }
        }
        for (output = outputs) {
            if (is_flow_port(output)) {
                target = fluid_line_output_target(output, port_config);
                start = [[0,0,0], -port_tangent(target), port_normal(target)];
                color("skyblue")
                fluid_line_output_junction(output, port_config);
                color("blue")
                generic_path(shape, start, target);
            } else {
                io_hint(input);
            }
        }
    }
}
