include <block_valve.scad>
include <block_resistor.scad>
include <block_mixer.scad>

// edge intersection example
width = 128;
config = create_port_config(collision_offset = [1,1], flow_cross_section = [10, 10], io_offset = 1, width = width, show_boundary=true);
radius = 10;
//for (i = [-1,1], j = [-1,1]) {
//     inp = [-i, -j, 0];
//     translate(width*[(i+1)/2, (j+1)/2, 0])
//     block_resistor(inp, -inp, port_config=config);
//     // block_valve(radius=radius,
//     //             flow_out=inp, flow_in=-inp,
//     //             control_in = [[j,0, 0], [1,1]],
//     //             control_out = [[-j,0, 0], [-1, 1]],
//     //             port_config=config);
// }

// for (i = [-1,1], j = [-1,1]) {
//     inp = [0, -j, -i];
//     translate([0, 0, 200])
//     translate(width*[0, (j+1)/2, (i+1)/2])
//     block_resistor(inp, -inp, port_config=config);
//     // block_valve(radius=radius,
//     //             flow_out=inp, flow_in=-inp, port_config=config,
//     //             control_in = [[1, 0, 0], [1,1]],
//     //             control_out = [[-1, 0, 0], [-1, 1]]);
// }
rotate([0,0,45])
 for (i = [-1,1], j = [-1,1], k=[-1,1]) {
     inp = [-k, -j, -i];
     translate(width*[-1, -1, -1])
     translate(width*[(k+1)/2, (j+1)/2, (i+1)/2])
     block_resistor(inp, inp, port_config=config);
     // block_valve(radius=radius,
     //             flow_out=inp, flow_in=-inp, port_config=config,
     //             control_in = [[1, 0, 0], [1,1]],
     //             control_out = [[-1, 0, 0], [-1, 1]]);
 }

//translate([1200, 0,0]) {
//translate(width*[1,1,1])
//block_valve(radius=radius,
//            flow_out=[0,-1,-1], flow_in=[-1, 0, -1],
//            control_in = [[0, 1, 0], [1,1]],
//            control_out = [[0, -1, 0], [-1, 1]],
//            port_config=config);
//translate(width*[0, 1, 0]) {
//    block_resistor([0, -1, 0], [1,0,1], port_config=config);
//    // port_demonstrator(config);
//}
//
//translate(width*[1, 0, 0])
//
//block_mixer([1,1,0],[0,1,1], [-1,0,0], port_config=config);
//
//translate(width*[-4, 0, 0])
//port_demonstrator(config);
//
//translate(width*[0, 0, 0])
//block_resistor([1,0,0], [0,1,0], port_config=config);
//
//}
//
//
//translate(width*[15, 0, 0]) {
//    width = 80;
//config = create_port_config(width = width, show_boundary=true);
//    translate(width/2*[1,1,1])
//port_demonstrator(config);
//block_mixer([1,1,0],[0,1,1], [-1,0,0], port_config=config);
//}
