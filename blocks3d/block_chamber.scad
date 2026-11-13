include <BOSL2/std.scad>
include <ports.scad>

function chamber_port_target(port, channel, chamber, port_config) =
    let (is_top = (norm(port) == 1 && (port.z != 0)))
    let (normal = is_top ? [-1, 0, 0] : [0, 0, 1])
    [v_mul(port, chamber/2), port, normal];

module block_chamber(flow_in, flow_out, port_config,
                        chamber = [30, 30, 50],
                        rounding = 5,
                        debug=false)
{
    assert(flow_in != flow_out, "IO offset not supported yet.");
    cell_dimensions = struct_val(port_config, "cell_dimensions");
    size = struct_val(port_config, "flow_cross_section");
    debug = debug || struct_val(port_config, "debug");
    min_thick = struct_val(port_config, "minimum_thickness");
    margin = norm(size) + min_thick;
    sharpness = 10;
    center = cell_dimensions/2;

    exterior_out = fluid_line_output_target(flow_out, port_config);
    exterior_in = fluid_line_input_target(flow_in, port_config);

    shape = square(size, center=true);
    module sunk_fluid_line(flow, exterior)
    {
        interior = chamber_port_target(flow, size, chamber, port_config);
        sink = [[0, 0, 0], port_tangent(interior), port_normal(interior)];
        generic_path(shape, interior, exterior, debug=debug);
        generic_path(shape, port_mirror(interior), sink, debug=debug);
    }
    translate(center) {
        if (struct_val(port_config, "show_boundary")) {
            %cube(cell_dimensions, center=true);
        }

        cuboid(chamber, rounding=rounding);
        fluid_line_input_junction(port = flow_in, port_config = port_config);
        sunk_fluid_line(flow_in, exterior_in);
        fluid_line_output_junction(port = flow_out, port_config = port_config);
        sunk_fluid_line(flow_out, exterior_out);
    }
}

port_config = create_port_config(show_boundary=true, cell_dimensions=[200,200,200]);
block_chamber([0,1,1], [1,1,0], port_config, debug=false);
