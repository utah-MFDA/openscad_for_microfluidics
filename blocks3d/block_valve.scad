include <BOSL2/std.scad>
include <ports.scad>

module block_valve(
    // port connections
    flow_in,
    flow_out,
    control_in,
    control_out,
    port_config,
    passthrough = [], // array of control port pairs
    // dimensions
    radius = 20,
    control_depth = 6,
    membrane_depth = 1,
    flow_depth = 3,
    // bezier shape control
    bezier_center_sharpness = 8,
    bezier_sharpness = 20,
    bezier_step = 10,
    bezier_clearance = 1,
    bezier_countersink = 1,
    bezier_io_spacing = 360/48,
    // interconnect parameters
)
{
    // Configuration
    width = struct_val(port_config, "width");
    port_io_offset = struct_val(port_config, "io_offset");
    port_flow_cross_section = struct_val(port_config, "flow_cross_section");
    port_control_cross_section = struct_val(port_config, "control_cross_section");
    debug = struct_val(port_config, "debug");
    debug_center = struct_val(port_config, "debug_center");

    valve_depth = flow_depth + membrane_depth + control_depth;

    // Parameter checking
    assert(is_flow_port(flow_in));
    check_flow_port(flow_out);
    assert (!(port_io_offset == 0 && flow_out == flow_in),
             "conflicting input/output flow ports");
    assert(control_in != control_out, "confliction input/output control ports");
    assert(is_control_port(control_in));
    check_control_port(control_out);

    center = [width/2, width/2, width/2];

    module valve() {
        $fa = 360/48;
        translate([0, 0, control_depth + membrane_depth])
        cylinder(h=flow_depth, r=radius);

        cylinder(h=control_depth, r=radius);
    }

    function control_line_anchor(face, offset, size, spacing) =
        // this is gross, simplify the expressions.
        let (top_angle = 90*(offset.y) - face.z*spacing * (offset.y*offset.x*2.5 - 2*(1 - face.z)/2) )
        let (side_angle = 90*(1-face.x) + spacing*(-4.5 + 7*(offset.x + 1)/2+(offset.y + 1)/2) )
        let (bottom_angle = 90*(2-face.y) + spacing*(-5.5 + 7*(-offset.x + 1)/2 + 2*(offset.y + 1)/2))
        let (angle = face.z != 0 ? top_angle:
                     face.x != 0 ? side_angle:
                                   bottom_angle)
        let (target = [cos(angle)*radius,
                       sin(angle)*radius,
                       -valve_depth + control_depth - size.y/2])
        let (target_normal = [cos(angle), sin(angle), 0])
        [target, target_normal];

    module control_line(face, offset)
    {
        size = port_control_cross_section;
        control_line_junction(face, offset, port_config);
        anchor_offsets = control_line_anchor(face, offset, size, bezier_io_spacing);
        anchor_offset = anchor_offsets[0];
        anchor_normal = anchor_offsets[1];
        targets = control_line_target(face, offset, port_config);
        target = targets[0];
        target_normal = targets[1];
        last_normal = targets[2];
        control = [anchor_offset,
                    anchor_offset + bezier_sharpness * anchor_normal,
                    target + bezier_sharpness * target_normal,
                    target];
        if (debug) debug_bezier(control, N=len(control)-1);
        else bezier_sweep(square(size, center=debug_center), control, bezier_step, last_normal=last_normal);
    }

    function fluid_line_angle(port, inout) =
        let (angle = atan2(port.y, port.x))
        let (regular_angle = angle + (port.z-sign(inout)/2)*bezier_io_spacing)
        let (top_angle = 180*((1+inout)/2)-2.5*bezier_io_spacing)
        let (start_angle = port.x == 0 && port.y == 0 ? top_angle : regular_angle)
        start_angle;

    module fluid_input(port, clearance=2)
    {
        size = port_flow_cross_section;
        start = [0,0,0];
        start_normal = [0, 0, 1];
        targets = fluid_line_target(port, 1, port_config);

        target = targets[0];
        target_normal = targets[1];
        last_sweep_normal = targets[2];
        angle = fluid_line_angle(port, 1);
        angle_vec = [cos(angle), sin(angle), 0];
        top_first_normal = -angle_vec;
        if (port == [0, 0, 1]) {
            path(size, [start, center_sharpness*start_normal, last_sweep_normal],
                       [target, sharpness*target_normal, last_sweep_normal ]);
        } else if (port.z < 0) {
            end = radius+clearance+size.y/2;
            top_last_normal = angle_vec;
            top_bridge = end * angle_vec;
            bottom_bridge = top_bridge + [0,0,-valve_depth];
            path(size, [start, bezier_center_sharpness*start_normal, top_first_normal],
                   [top_bridge, bezier_center_sharpness*start_normal, top_last_normal]);
            // bridge
            bridge = [top_bridge, top_bridge + [0,0,-valve_depth/2],
                      bottom_bridge];
            if (debug) debug_bezier(bridge, N=len(bridge)-1);
            else bezier_sweep(square(size, center=debug_center), bridge, normal=top_last_normal);
            if (port == [0, 0, -1]) {
                // bottom part
                path(size, [bottom_bridge, sharpness*[0, 0, -1],top_last_normal],
                           [target, sharpness*target_normal, [-1,0,0]]);
            } else{
                path(size, [bottom_bridge, bezier_sharpness*[0, 0, -1],top_last_normal],
                           [target, bezier_sharpness*target_normal, last_sweep_normal]);
            }
        } else if (port.z == 0) {
            edge = [0, 0, clearance+size.y/2] + radius*angle_vec;
            normal_len = min(bezier_sharpness, (norm(port)*width/2-radius)/2);
            path(size, [start, bezier_center_sharpness*start_normal,top_first_normal],
                       [edge, -bezier_center_sharpness*angle_vec, [0, 0, 1]]);

            path(size, [edge, bezier_center_sharpness*angle_vec,[0, 0, 1]],
                       [target, bezier_sharpness*target_normal, last_sweep_normal]);
        } else {
            path(size, [start, bezier_center_sharpness*start_normal, top_first_normal],
                       [target, bezier_sharpness*target_normal, last_sweep_normal]);
        }
    }

    module fluid_output(port,
                        sharpness=bezier_sharpness,
                        countersink=bezier_countersink,
                        step=bezier_step,
                        clearance=bezier_clearance)
    {
        size=port_flow_cross_section;
        fluid_line_junction(port, -1, port_config);
        targets = fluid_line_target(port, -1, port_config);
        target = targets[0];
        target_normal = targets[1];
        last_sweep_normal = targets[2];
        angle = fluid_line_angle(port, -1);
        output_offset = [cos(angle) * radius, sin(angle) * radius, -flow_depth+size.y/2];
        start_normal = [cos(angle), sin(angle), 0];
        start = output_offset;
        normal_len = min(sharpness, (norm(port)*width/2-radius)/2);
        translate(start)
        rotate([0, 0, angle])
        cube([countersink, size.x, size.y], center=true);
        if (port == [0, 0, 1]) {
            bend_begin = center + (radius + clearance + size.y/2)*start_normal;
            path(size, [start, start_normal, [0,0,-1]],
                       [bend_begin, [0, 0, -1], start_normal]);
            path(size, [bend_begin, sharpness*[0, 0, 1], start_normal],
                       [target, sharpness*target_normal, last_sweep_normal]);
        } else if (port == [0, 0, -1]) {
            bend_begin = [0, 0, -valve_depth]+ radius+clearance+size.y/2*start_normal;
            path(size, [start, clearance*start_normal, [0,0,1]],
                       [bend_begin, valve_depth/2*[0,0,1], start_normal]);
            path(size, [bend_begin, sharpness*[0,0,-1], start_normal],
                       [target, sharpness*target_normal, -last_sweep_normal]);
        } else {
            path(size, [start, sharpness*start_normal,[0, 0, 1]],
                       [target, sharpness*target_normal, last_sweep_normal]);
        }
    }
    translate(center) {

        // outer boundary
        if (struct_val(port_config, "show_boundary")) {
            %cube(width, center=true);
        }

        // valve chambers
        translate([0, 0, -valve_depth])
        valve();

        // fluid flow connections
        color("purple")
        fluid_input(flow_in);
        color("blue")
        fluid_output(flow_out);
        color("mediumpurple")
        fluid_line_input_junction(flow_in, port_config);
        color("skyblue")
        fluid_line_output_junction(flow_out, port_config);

        // control connections
        color("green")
        control_line(control_in[0], control_in[1]);
        color("orange")
        control_line(control_out[0], control_out[1]);
    }

}

