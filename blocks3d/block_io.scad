include <openmfda/components/interconnect.scad>
include <ports.scad>
include <BOSL2/std.scad>

module block_pinhole(connections, diameter, depth, cone, port_config, orientation = [0, 0, 1], sharpness=40)
{
    width = struct_val(port_config, "width");
    size = struct_val(port_config, "flow_cross_section");
    debug = struct_val(port_config, "debug");

    assert(diameter < width);
    assert(depth < width);
    assert(norm(orientation) == 1 && (orientation.x == 1 || orientation.y == 1 || orientation.z == 1));

    translate([1,1,1]*width/2) {
        rotate(v_mul(orientation, [90, 90, orientation.z < 1 ? 180: 0]))  {
            union(){
                translate([0, 0, depth/2])
                cylinder(d = diameter, h = depth, center=true);
                translate([0, 0, -cone/2])
                cylinder(h = cone, d1 = norm(size), d2 = diameter, center=true);
            };
        }
        for (connection = connections) {
            hole_target = [orientation*(width/2 - depth - cone), -orientation, connection];
            assert(is_flow_port(connection));
            fluid_line_input_junction(connection, port_config);
            target = fluid_line_input_target(connection, port_config);
            external = port_tangent_scale(sharpness, target);
            generic_path(square(size, center=true), external, hole_target, splinesteps=30, debug=debug);
        }
    }
}

module block_interconnect(connections, port_config)
{
    width = struct_val(port_config, "width");
    size = struct_val(port_config, "flow_cross_section");
    debug = struct_val(port_config, "debug");
    sharpness = 10;
    target = interconnect_target([0, 0]);
    target_point = [0, 0, -width/2 + size.y/2];
    center_size = [size.x, size.y, size.y];
    translate([1,1,1]*width/2) {
        translate(target_point)
        cylinder(center_size.y, r1=size.x+1, r2=size.x+1, center=true);

        for (connection = connections) {
            fluid_line_input_junction(connection, port_config);
            if (connection.x == 0 && connection.y == 0) {
                cube();
            } else {
                assert(is_flow_port(connection));
                target = fluid_line_input_target(connection, port_config);
                external = port_tangent_scale(sharpness, target);

                tangent = [connection.x, connection.y, 0];
                component = [target_point+size.x*unit(tangent), tangent, sharpness*tangent, [0, 1, 0]];
                generic_path(square(size, center=true), external, component, debug=debug);
            }
        }

    }

}
module block_interconnect_path(grid, target, height, port_config)
{
    width = struct_val(port_config, "width");
    size = struct_val(port_config, "flow_cross_section");
    debug = struct_val(port_config, "debug");
    sharpness = 50;
    grid_target = port_tangent_scale(sharpness, interconnect_target(grid));
    target_offset = [[width/2, width/2, size.y], [0,0,0], [0,0,0]];
    offset = [[0, 0, height], [0,0,0], [0,0,0]];
    color("green")
    path(size, target + target_offset, grid_target + offset, debug=debug);

}
port_config = create_port_config();
block_interconnect([[-1,1,-1], [1,0,-1]], port_config);
