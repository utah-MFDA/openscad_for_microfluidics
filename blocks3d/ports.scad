include <BOSL2/std.scad>

// cell_dimensions = struct_val(port_config, "cell_dimensions");
// port_io_offset = struct_val(port_config, "io_offset");
// port_collision_offset = struct_val(port_config, "collision_offset");
// port_flow_cross_section = struct_val(port_config, "flow_cross_section");
// port_control_cross_section = struct_val(port_config, "control_cross_section");
// port_top_spacing = struct_val(port_config, "top_spacing");
// port_side_spacing = struct_val(port_config, "side_spacing");
// debug = struct_val(port_config, "debug");
// debug_center = struct_val(port_config, "debug_center");

function create_port_config(
    cell_dimensions = [80, 80, 80],
    io_offset = 3,
    collision_offset = [3, 5],
    flow_cross_section = [4,8],
    control_cross_section = [6,8],
    top_spacing = [3/16, 3/8],
    side_spacing = [1/4, 1/4],
    minimum_thickness = 4,
    debug = false,
    debug_center=true,
    show_boundary=false) = struct_set([], [
    "cell_dimensions", cell_dimensions,
    "io_offset", io_offset,
    "collision_offset", collision_offset,
    "flow_cross_section", flow_cross_section,
    "control_cross_section", control_cross_section,
    "top_spacing", top_spacing,
    "side_spacing", side_spacing,
    "debug", debug,
    "debug_center", debug_center,
    "show_boundary", show_boundary,
    "minimum_thickness", minimum_thickness
]);

function diagonal(v) = [
    for (i=[0:len(v)-1])
        [for (j=[0:len(v)-1])
             i == j ? v[i] : 0]];

function v_min(a, b) =
    assert(len(a) == len(b))
    [for (i = [0:len(a)-1]) min(a[i], b[i]) ];

function v_max(a, b) =
    assert(len(a) == len(b))
    [for (i = [0:len(a)-1]) max(a[i], b[i]) ];
function v_min(a, b) =
    assert(len(a) == len(b))
    [for (i = [0:len(a)-1]) min(a[i], b[i]) ];

function port_tangent_clamp(port, delta) =
    [port[0], v_min(port[1], delta), port[2]];

function port_position(target) = target[0];
function port_tangent(target) = target[1];
function port_normal(target) = target[2];
function port_tangent_scale(scalar, target) = [target[0], scalar*target[1], target[2]];
function port_mirror(target) = [target[0], -target[1], target[2]];
function port_translate(center, target) = [center, [0,0,0], [0,0,0]] + target;
function vecrotate_xy(a) = [
                        [cos(a), sin(a), 0],
                        [-sin(a), cos(a), 0],
                        [0, 0, 1]];
function port_rotate_xy(angle_xy, target) =
    let (transform = vecrotate_xy(angle_xy))
    [for (t = target) t*transform];

module check_flow_port(port) {
    assert(len(port) == 3, "incorrect flow port components");
    assert(abs(port.x) <= 1, "flow port vector x component greater than 1");
    assert(abs(port.y) <= 1, "flow port vector y component greater than 1");
    assert(abs(port.z) <= 1, "flow port vector z component greater than 1");
    assert(port != [0, 0, 0], "invalid center flow port") ;
}

// I can't get these to work as functions
function assert_flow_port(port) =
    assert(len(port) == 3, "incorrect flow port components")
    assert(abs(port.x) <= 1, "flow port vector x component greater than 1")
    assert(abs(port.y) <= 1, "flow port vector y component greater than 1")
    assert(abs(port.z) <= 1, "flow port vector z component greater than 1")
    assert(port != [0, 0, 0], "invalid center flow port")
    true;

function is_flow_port(port) =
    len(port) == 3 && port != [0, 0, 0]
        && (abs(port.x) == 1 || abs(port.x) == 0)
        && (abs(port.y) == 1 || abs(port.y) == 0)
        && (abs(port.z) == 1 || abs(port.z) == 0);

function is_port_face(port) = sum(v_abs(port)) == 1;
function is_port_edge(port) = sum(v_abs(port)) == 2;
function is_port_corner(port) = sum(v_abs(port)) == 3;

module check_control_port(port) {
    assert(len(port) == 2, "control port struct must have two components");
    face = port[0];
    offset = port[1];
    assert(len(face) == 3, "face vector must have three components");
    assert(norm(face) == 1, "control port must be on face");
    assert(len(offset) == 2, "face offset must have two components");
    assert(abs(offset.x) == 1, "face x offset must be 1");
    assert(abs(offset.y) == 1, "face y offset must be 1");
}

// I can't get these to work as functions
function assert_control_port(port) =
    assert(len(port) == 2, "control port struct must have two components")
    let (face = port[0], offset = port[1])
    assert(len(face) == 3, "face vector must have three components")
    assert(norm(face) == 1, "control port must be on face")
    assert(len(offset) == 2, "face offset must have two components")
    assert(abs(offset.x) == 1, "face x offset must be 1")
    assert(abs(offset.y) == 1, "face y offset must be 1")
    true;

function is_control_port(port) =
    len(port) == 2 &&
    len(port[0]) == 3 &&
    norm(port[0]) == 1 &&
    len(port[1]) == 2 &&
    abs(port[1].x) == 1 &&
    abs(port[1].y) == 1;

// This geometry provides a bridging junction over the crossings to guarantee
// clearance. Each cell should instantiate a junction for each connection.
// fluid_line_target function will return the connection geometry relative to the
// junction.
module control_line_junction(face, offset, port_config) {
    debug = struct_val(port_config, "debug");
    size = struct_val(port_config, "control_cross_section");

    a = control_line_target(face, offset, port_config);
    b = control_line_target_raw(face, offset, port_config);
    generic_path(square(size, center=true), [a[0], -a[1], a[2]],
               [b[0], b[1], b[2]], splinesteps = 2, debug=debug);
    // path(size, [a[0], -a[1], a[2]],
    //            [b[0], b[1], b[2]], splinesteps = 2, debug=debug);
}

module fluid_line_input_junction(port, port_config) {
    fluid_line_junction(port, 1, port_config);
}

module fluid_line_output_junction(port, port_config) {
    fluid_line_junction(port, -1, port_config);
}
module fluid_line_junction(port, io, port_config) {
    debug = struct_val(port_config, "debug");
    size = struct_val(port_config, "flow_cross_section");
    a = fluid_line_target(port, io, port_config);
    b = fluid_line_target_raw(port, io, port_config);
    generic_path(square(size, center=true), port_tangent_scale(-1, a), b, splinesteps=2);
    // path(size, port_tangent_scale(-1, a), b, splinesteps=2);
}

function fluid_line_input_target(port, port_config, min_length=2) =
    fluid_line_target(port, 1, port_config, min_length);

function fluid_line_output_target(port, port_config, min_length=2) =
    fluid_line_target(port, -1, port_config, min_length);

// This is the point that defines the junction connection point where cells should attach lines.
function fluid_line_target(port, io, port_config, min_length=2) =
    let (size = struct_val(port_config, "flow_cross_section"))
    let (cell_dimensions = struct_val(port_config, "cell_dimensions"))
    let (io_offset = struct_val(port_config, "io_offset"))
    let (collision_offset = struct_val(port_config, "collision_offset"))
    let (target = fluid_line_target_raw(port, io, port_config))
    // corners and edges parallel to Z-axis need extra length for orthogonal crossing
    let (ch_width = io_offset > 0 ? 2*size.x + 2*io_offset : size.x)
    let (length =  abs(port.x) + abs(port.y) == 2
                    ? collision_offset.x + ch_width : 0)
    [target[0] + (min_length + length) * unit(target[1]), target[1], target[2]];

function round_div2(io, v) = (io*v + v%2)/2;
// This is the point where fluid lines from different cell_dimensionss meet.
function fluid_line_target_raw(port, io, port_config) =
    assert(is_flow_port(port))
    assert(abs(io) == 1)
    assert(!is_undef(port_config))
    let (cell_dimensions = struct_val(port_config, "cell_dimensions"))
    let (size = struct_val(port_config, "flow_cross_section"))
    let (io_offset = struct_val(port_config, "io_offset"))
    let (collision_offset = struct_val(port_config, "collision_offset"))
    let (is_top = (norm(port) == 1 && (port.z != 0)))
    let (base = v_mul(cell_dimensions/2, port))
    let (angle = atan2(port.y, port.x))
    let (io_spacing = io_offset == 0 ? 0
                        : (io_offset + size.x)/2)
    let (collision_spacing = [ port.z*(size.x + collision_offset.x)/2,
                                port.x*port.y*(size.y + collision_offset.y)/2 ])
    let (offset = io_spacing + collision_spacing.x)
    let (side = [offset*cos(90 + angle),
                 offset*sin(90 + angle),
                 collision_spacing.y])
    let (top = [0, io_spacing*port.z, 0])
    let (target_offset = is_top ? top : side)
    let (target = base + target_offset)
    let (target_normal = is_top ? [0, 0, -port.z] : [-cos(angle), -sin(angle), 0])
    let (last_sweep_normal = is_top ? [-1, 0, 0] : [0, 0, 1])
    [target, target_normal, last_sweep_normal];

function control_line_target(face, offset, port_config) =
    let (on_face = control_line_target_raw(face, offset, port_config))
    port_translate(2*port_tangent(on_face), on_face);

function control_line_target_raw(face, offset, port_config) =
    let (cell_dimensions = struct_val(port_config, "cell_dimensions"))
    let (top_spacing = struct_val(port_config, "top_spacing"))
    let (side_spacing = struct_val(port_config, "side_spacing"))
    let (spacing = width * (face.z != 0 ? top_spacing : side_spacing))
    // positive or negative based sign of one-hot.
    let (dir = face.x + face.y + face.z)
    // place on face.
    let (updown = (dir+1)*width/2-width/2)
    // orthogonal bezier anchor
    let (normal = -face)
    // position on the face)
    let (face_offset = offset * diagonal([dir, 1]))
    let (spot = spacing * diagonal(face_offset))
    let (target = face.z != 0 ? [spot.x, spot.y, updown] :
                         face.x != 0 ? [updown, spot.x, spot.y] :
                                [spot.x, updown, spot.y])
    let (last_normal = face.z != 0 ? [0, -face.z*offset.y, 0] :
                          face.x != 0 ? [0, 0, 1] :
                                        [0, 0, 1])
    [target + normal, normal, last_normal];

module port_demonstrator(port_config)
{
    cell_dimensions = struct_val(port_config, "cell_dimensions");

    %cube(cell_dimensions, center=true);
    for (i = [-1:1], j = [-1:1], k = [-1:1], m = [-1,1]) {
        p = [i, j, k];
        if (p != [0,0,0]) {
            color( m == 1 ? "purple" : "blue")
            fluid_line_junction(p, m, port_config);
        }
    }

    // for (i = [-1,1], j = [[0,0,i], [0,i,0], [i,0,0]], m = [-1,1], n = [-1,1]) {
    //     color("orange")
    //     control_line_junction(j, [m,n], port_config);
    // }

}

// Least squares regression on a single variable is the arithmetic mean
// This minimizes the angle alignment between the component and exterior ports.
function posang(a) = (modang(a) + 360) % 360;
function minimize_angle(ports, anchors, port_config) =
    // BOSL2 likes to use +-180, but stripping the sign to only positive removes
    // problems when crossing the boundary
    let (cell_dimensions = struct_val(port_config, "cell_dimensions"))
    let (port_angles = [for (port = ports)
                            let (a = port_position(port))
                            posang(atan2(a.y, a.x))])
    let (anchor_angles = [for (anchor = anchors)
                            let (a = port_position(anchor))
                            posang(atan2(a.y, a.x))])
    let (diff = port_angles - anchor_angles)
    modang(180+sum(diff)/len(diff));

module segment_path(size, delta) {
    assert(len(delta) >= 1);
    next = delta[0];
    assert(sum(next) == norm(next), "delta must be a orthogonal vector");
    cross = v_mul(size,  v_abs(unit(next) - [1,1,1]));
    cube(cross + next);

    if (len(delta) > 1) {
        translate(next)
        segment_path(size, slice(delta, 1, -1));;
    }
}

module bend(size, cross) {
    bezier_sweep(square(cross, center=debug_center), bend_path(size));
}

function bend_path(size) =
     [[0,0,0], [0, 0, size.y], [0, 0, size.y], [size.x, 0, size.y]];

module path(size, start, end, splinesteps=16, debug=false, debug_center=false, clamp_tangent=false) {
    generic_path(square(size, center=!debug_center),
                    start, end, splinesteps, debug, clamp_tangent);
}

function path_clamp(start, end) =
    let (delta = port_position(start) - port_position(end))
    [port_tangent_clamp(start, delta/2), port_tangent_clamp(end, -delta/2)];

function path_bezier(start, end) =
    [port_position(start),
       port_position(start) + port_tangent(start),
       port_position(end) + port_tangent(end),
       port_position(end)];

module generic_path(shape, start, end, splinesteps=16, debug=false, clamp_tangent=false) {
    clamped = clamp_tangent ? path_clamp(start, end) : [start, end];
    start_clamped = clamped.x;
    end_clamped = clamped.y;
    control = path_bezier(start_clamped, end_clamped);
    if (debug) debug_bezier(control, N=len(control)-1);
    else bezier_sweep(shape, control, splinesteps=splinesteps,
                      normal=port_normal(start), last_normal=port_normal(end));
}

module fluid_line(shape, margin, dimensions, exterior_target, component_target, sharpness, debug=false) {
    // this assumes that the face vector is perpendicular to the component face plane
    face = port_tangent(component_target);
    orientation = port_normal(component_target);
    // create a basis relative to the orientation of the component
    basis = [cross(face, orientation), face, orientation];
    faces = [basis.x*dimensions.x/2, basis.y*dimensions.y/2, basis.z*dimensions.z/2];

    // setup endpoint
    exterior = port_position(exterior_target);
    end = port_tangent_scale(sharpness, exterior_target);

    // check if external port lies above the face planes
    // inner product of the normal to the plane and the offset vector from normal origin
    front = basis.y * (exterior - faces.y) > 0;
    behind = -basis.y * (exterior + faces.y) > 0;
    above = basis.z * (exterior - faces.z) > 0;
    below = -basis.z * (exterior + faces.z) > 0;
    right = basis.x * (exterior - faces.x) > 0;
    left = -basis.x * (exterior + faces.x) > 0;

    start = port_tangent_scale(margin, component_target);

    if (front) {
        start = port_tangent_scale(sharpness, component_target);
        generic_path(shape, start, end, debug=debug);
    } else if (above && !left) {
        start2 = [start[0], start[1], -basis.z];
        corner = [v_mul(start[0], [1,1,0]) + basis.z * margin + faces.z,
                    margin*basis.y,
                    basis.z];
        generic_path(shape, start2, corner, debug=debug);
        corner2 = [corner[0], -corner[1], basis.z];
        generic_path(shape, corner2, end, debug=debug);
    } else if (below && !right) {
        corner = [v_mul(start[0], [1,1,0]) - (basis.z * margin + faces.z),
                    margin*basis.y,
                    -basis.z];
        generic_path(shape, start, corner, debug=debug);
        corner2 = [corner[0], -corner[1], basis.z];
        generic_path(shape, corner2, end, debug=debug);
    } else if (right && !above) {
        corner = [v_mul(start[0], [0,1,1]) + (basis.x * margin + faces.x),
                    margin*basis.y,
                    basis.z];
        generic_path(shape, start, corner, debug=debug);
        generic_path(shape, port_mirror(corner), end, debug=debug);
    } else if (left && !below) {
        corner = [v_mul(start[0], [0,1,1]) - (basis.x * margin + faces.x),
                    margin*basis.y,
                    basis.z];
        generic_path(shape, start, corner, debug=debug);
        generic_path(shape, port_mirror(corner), end, debug=debug);
    } else if (behind) {
        // completely behind, get around the back corner as well
        corner = [v_mul(start[0], [0,1,1]) + (basis.x * margin + faces.x),
                    margin*basis.y,
                    basis.z];
        generic_path(shape, start, corner, debug=debug);
        back = [-faces.y + (basis.x * margin + faces.x),
                    margin*basis.y,
                    basis.z];
        generic_path(shape, port_mirror(corner), back, debug=debug);
        generic_path(shape, port_mirror(back), end, debug=debug);
    } else {
        // degenerate case completely inside the component
        assert(!(front || behind || below || above || right || left));
        assert(false);
    }
}
/*
function component_port_basis(face, orientation, dimensions) =
    [cross(face, orientation), orientation, face];

function component_port_faces(basis, dimensions) =
    [v_mul(basis.x, dimensions/2), v_mul(basis.y, dimensions/2), v_mul(basis.z, dimensions/2)];

function component_port_dimensions(face, orientation, dimensions) =
    let (basis = component_port_basis(face, orientation, dimensions))
    let (faces = component_port_faces(basis, dimensions))
    [for (f = faces) sum(f)];

function face_turnaround(face, orientation, dimensions, side, margin) =
    let (basis = component_port_basis(face, orientation, dimensions))
    let (faces = component_port_faces(basis, dimensions))
    let (relative = [for (f = faces) sum(f)])
    let (edge = (relative.x+margin) * side.x + (relative.y+margin) * side.y)
    [relative.z + edge, -margin*basis.z, basis.z];

function turnaround(shape, margin, dimensions, exterior_target, component_target, sharpness, debug=false) {

    // this assumes that the face vector is perpendicular to the component face plane
    face = port_tangent(component_target);
    orientation = port_normal(component_target);
    // create a basis relative to the orientation of the component
    basis = [cross(face, orientation), face, orientation];
    faces = [basis.x*dimensions.x/2, basis.y*dimensions.y/2, basis.z*dimensions.z/2];

    // setup endpoint
    exterior = port_position(exterior_target);
    end = port_tangent_scale(sharpness, exterior_target);
    turnarounds = [
        // above
        [faces.y + (basis.z * margin + faces.z), margin*basis.y, basis.z],
        // right
        [faces.y - (basis.z * margin + faces.z), margin*basis.y, basis.y],
        // below
        [faces.y + (basis.x * margin + faces.x), margin*basis.y, basis.z],
        // left
        [faces.y - (basis.x * margin + faces.x), margin*basis.y, basis.z],
    ] ;

    // check if external port lies above the face planes
    // inner product of the normal to the plane and the offset vector from normal origin
    front = basis.y * (exterior - faces.y) > 0;
    behind = -basis.y * (exterior + faces.y) > 0;
    above = basis.z * (exterior - faces.z) > 0;
    below = -basis.z * (exterior + faces.z) > 0;
    right = basis.x * (exterior - faces.x) > 0;
    left = -basis.x * (exterior + faces.x) > 0;

    start = port_tangent_scale(margin, component_target);

    if (front) {
        start = port_tangent_scale(sharpness, component_target);
        generic_path(shape, start, end, debug=debug);
    } else if (above && !left) {
        start2 = [start[0], start[1], -basis.z]];
        corner = trunarounds[0];
        generic_path(shape, start2, corner, debug=debug);
        corner2 = [corner[0], -corner[1], basis.z];
        generic_path(shape, corner2, end, debug=debug);
    } else if (below && !right) {
        corner = turnarounds[1];
        generic_path(shape, start, corner, debug=debug);
        corner2 = [corner[0], -corner[1], basis.z];
        generic_path(shape, corner2, end, debug=debug);
    } else if (right && !above) {
        corner = turnarounds[2];
        generic_path(shape, start, corner, debug=debug);
        generic_path(shape, port_mirror(corner), end, debug=debug);
    } else if (left && !below) {
        corner = turnarounds[3];
        generic_path(shape, start, corner, debug=debug);
        generic_path(shape, port_mirror(corner), end, debug=debug);
    } else if (behind) {
        // completely behind, get around the back corner as well
        corner = [faces.y + (basis.x * margin + faces.x),
                    margin*basis.y,
                    basis.z];
        generic_path(shape, start, corner, debug=debug);
        back = [-faces.y + (basis.x * margin + faces.x),
                    margin*basis.y,
                    basis.z];
        generic_path(shape, port_mirror(corner), back, debug=debug);
        generic_path(shape, port_mirror(back), end, debug=debug);
    } else {
        // degenerate case completely inside the component
        assert(!(front || behind || below || above || right || left));
        assert(false);
    }
}
*/
