
# Guild to scad files

### polychannel_route
```
```
Main polychannel for MFDA routing. Adds a few arguments for tracking component 
connections. These arguments however do not add any functionality, only used for
documenting.

### lef_helper.scad

This file is used to help generate LEF files for the MFDA flow. For the file to be 
generated you need to create a module called lef.
```
module lef() {
    // lef_statements
}
```
Remeber to add the following line to the component file.
```
use <lef_helper.scad>
```

The valid statements for SCAD -> LEF include
```
lef_size(X_size, Y_size)
lef_layer(layer_name)
lef_port(port_name, direction, geometry, pts, layer(optional))
lef_obs(geometry, pts, layer(optional))
```
 - direction - can equal "INPUT", "OUTPUT", "INOUT"
 - geometry - The only valid geometry currently is "RECT"
 - pts - is a list of pts such that [x0, y0, x1, y1, ... ]

lef_port and lef_obs are to be used with the lef_layer like other transformations in 
openscad.
```
lef_layer("met1")
    lef_obs(...) ;
```

### Parameteric scad objects

All objects will need to have xpos, ypos, zpos, and orientation as their first
four arguements. The xpos, ypos, and zpos reference position of the "bottom left"
corner of the object. Valid orientations are "N, S, FS, FN", currently "W, E, FW, FE" 
are not currently working correctly.

All objects use millimeters as the reference measurement unit, however most objects will
be defined in terms of pixels for the target 3D printer and base layer height (which is
multiplied to render in mm). Platform definion are as follows:
 - px 
    - pixel pitch (mm)
 - layer 
    - layer height (mm)
 - lpv 
    - layer per via (layers), number of layer offset between routing layers
 - chan_w, chan_h 
    - main channel width (pixels) and height (layers)
 - shape 
    - main channel shape, "cube" or "sphere" are valid
 - pitch 
    - center to center distance (pixels) of routing channels (for supporting implementations)
 - clr 
    - color of object
 - layer_offset
    - number of layers to offset z direction

#### p_serpentine_obj
```
module p_serpentine_obj(xpos, ypos, zpos, orientation,
    L1, L2, turns,
        //standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, 
    no_obj=false, floor_area=false, chan_layers=2, clr="RosyBrown", layer_offset=20, 
    alt=0, rot=0)
```

 - L1 **(required)**
    - length of each segement orthoganal to outlet direction
 - L2 **(required)**
    - length of each segement toward the direction of the outlet
 - turns **(required)**
    - number of bends of each serpentine
 - no_obj=false 
    - removes object to render the area only
 - floor_area=false 
    - unsupported
 - chan_layers=2 
    - number of routing layers
 - alt=0
    - alternating serpentine path implementation, set true or 1 to use
 - rot=0
    - rotated serpentine implementation, set true or 1 to use

#### p_valve.scad
```
module p_valve(
    xpos, ypos, zpos, orientation, 
    valve_r, mem_th, fl_chm_h, pn_chm_h, inport_center=false, out_len=30, 
    fl_extra_sp = "fill", fl_chan_down_layers=30, pn_extra_sp="fill", 
    pn_chan_up_layers=30, rot_pn=false, extra_sp = 0, 
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", 
    pitch=30, offset_layers=10, rot=false, no_obj=false, floor_area=false)
```

 - valve_r **(required)**
    - valve radius (pixels)
 - mem_th **(required)**
    - membrane thickness (layers)
 - fl_chm_h **(required)**
    - fluid chamber height (layers)
 - pn_chm_h **(required)**
    - pneumatic chamber height (layers)
 - inport_center
    - whether to put the "in" port at the center
    - set "true" or "false"
 - out_len
    - unsupported
 - fl_extra_sp
    - number of "fill"
    - extra length of fluid IOs outside the valve radius, "fill" brings to edge of valve
 - fl_chan_down_layers
    - length down of pneumatic IOs
 - pn_extra_sp
    - number of "fill"
    - extra length of pneumatic IOs outside the valve radius, "fill" brings to edge of valve
 - pn_chan_up_layers
    - length up of pneumatic IOs
 - rot_pn
    - true or false
    - rotate the pneumatic input and outputs to be in same orientation as fluid side
 - extra_sp

#### p_valve_4way.scad
```
module p_valve_4way(
    xpos, ypos, zpos, orientation, 
    valve_r, mem_th, fl_chm_h, pn_chm_h, out_len=30, fl_out_h=10, fl_out_len=10, 
    pn_out_len=10, fl_extra_sp=10, pn_extra_sp=10, pn_up_layers=10, rot_pn=false,
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, 
    offset_layers=10, no_obj=false, floor_area=false)
```

 - valve_r **(required)**
    - valve radius (pixels)
 - mem_th **(required)**
    - membrane thickness (layers)
 - fl_chm_h **(required)**
    - fluid chamber height (layers)
 - pn_chm_h **(required)**
    - pneumatic chamber height (layers)
 - out_len
    - unsupported
 - fl_extra_sp
    - number of "fill"
    - extra length of fluid IOs outside the valve radius, "fill" brings to edge of valve
 - fl_chan_down_layers
    - length down of pneumatic IOs
 - pn_extra_sp
    - number of "fill"
    - extra length of pneumatic IOs outside the valve radius, "fill" brings to edge of valve
 - pn_chan_up_layers
    - length up of pneumatic IOs
 - rot_pn
    - true or false
    - rotate the pneumatic input and outputs to be in same orientation as fluid side
 - extra_sp

#### p_chamber.scad
```
module p_chamber(xpos, ypos, zpos, orientation,
    chm_r, chm_h,
    chm_len=0, conn_ch_w=14, conn_ch_h=10, conn_ch_l=20, 
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, 
    offset_layers=10, $fn=50, rot=false, no_obj=false, floor_area=false)
```

 - chm_r **(required)**
 - chm_h **(required)**
 - chm_l
 - conn_ch_w
 - conn_ch_h
 - conn_ch_l

#### multi_in_chamber.scad
```
module multi_in_chamber(xpos, ypos, zpos, orientation,
    num_inputs, input_sp, chm_h, chm_l, 
    chan_out_w, chan_out_h, has_nozzle=false, nozzle_l,
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube",
    pitch=30, rot=false, no_obj=false, floor_area=false
)
```
 - num_inputs **(required)**
 - input_sp **(required)**
 - chm_h **(required)**
 - chm_l **(required)**

#### p_tall_mixer.scad
```
module p_tall_mixer(xpos, ypos, zpos, orientation,
    mix_l, mix_w, mix_h,
    chan_io_len=20, chan_tran_len=10, mix_z_offset=0,
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, 
    no_obj=false, floor_area=false)
```
A simple mixer that reduces the time of mixing two fluids by reducing the channel width.
 - mix_l **(required)**
    - Lenght of the mixer
 - mix_w **(required)**
    - Mininum width of the mixer device
 - mix_h **(required)**
    - Height of the mixer channel

#### p_sqeeze_valve.scad
```
module p_squeeze_valve(xpos, ypos, zpos, orientation,
    mem_th, fl_chm_h,
        // fluid channel parameters
    fl_ext_len=30, fl_tran_len=5, fl_ext_th_len=4, 
        // pneumatic channel parameters
    pn_ch_w=14, pn_pad = 10, pn_len = 30, pn_bttm_chm_h=20, 
        // set if transition state
    no_out_transition=false, no_in_transition=false,
        // extra center spacing if needed when inport_center=false
    extra_sp = 0,
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30,
    offset_layers=10, rot=false, no_obj=false, floor_area=false)
```
 - mem_th **(required)**
    - Membrane thickness of squeezez valve
 - fl_chm_h **(required)**
    - Channel height of the fluid side of the squeeze valve.

#### p_pump.scad
```
module p_pump(xpos, ypos, zpos, orientation,
    r1=46, r2=46, r3=46,
    th1 = 10, th2 = 10, th3 = 10,
    fl_h1=10, fl_h2=10, fl_h3=10,
    pn_h1=14, pn_h2=14, pn_h3=14,
    len_sp=30, pn_out_len=20, 
    fl_extra_sp=4, pn_extra_sp="fill",
    fl_out_h=10, pn_out_h=10, ends_ex_len=10,
    dwn_chan_h=0, dwn_chan_w=0,
    port_chan_h=0, port_chan_w=0,
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, 
    offset_layers=10, rot=false, no_obj=false, floor_area=false)
```
This module is developed as a perstalitic pump using 3 membrane valves. The enumerated variables
    refer to a specific valve along the pump with 1 closest to the input, 2 in the center, and 3
    near the output.
 - r1, r2, r3
    - Radius of valves
 - th1, th2, th3
    - Thickness of the membrane of the valves
 - fl_h1, fl_h2, fl_h3
    - Height of the fluid chamber side (bottom) of the valves
 - pn_h1, pn_h2, pn_h3
    - Height of the pneumatic chamber side (top) of the valves
 - len_sp
 - pn_out_len
 - fl_extra_sp, pn_extra_sp
 - fl_out_h, pn_out_h
 - ends_ex_len
 - dwn_chan_h, dwn_chan_w
 - port_chane_h, port_chane_w

#### p_sqeeze_pump.scad
```
module p_squeeze_pump(xpos, ypos, zpos, orientation,
    mem_th, fl_chm_h,
    valve_sp=30,
        // fluid channel parameters
    fl_ext_len=30, fl_tran_len=5, fl_ext_th_len=4, 
        // pneumatic channel parameters
    pn_ch_w=14, pn_pad = 14, pn_len = 40, pn_bttm_chm_h=20, 
        // set if transition state
    no_out_transition=false, no_in_transition=false,
        // extra center spacing if needed when inport_center=false
    extra_sp = 0,
        // standard arguments
    px=7.6e-3, layer=10e-3, lpv=20, chan_h=10, chan_w=14, shape="cube", pitch=30, 
    offset_layers=10, no_obj=false, floor_area=false)
```

#### reservior.scad
```
module p_reservoir(xpos, ypos, zpos, orientation,
    p1_dir="z+", p2_dir="z+", 
    port_len1=50, port_len2=-1, 
    p1_offset=[0,0], p2_offset=[0,0], 
    size=[300, 300, 250], edge_rounding=0.5, 
    center=true, clr="gray",
        // standard arguments
    px=0.0076, layer=0.010, chan_w=14, chan_h=10, rot=false, pitch=30,
    layer_offset=10, $fs=0.04, $fa=1)
```

```
module reservoir(size=[300, 300, 250], edge_rounding=0.5, center=true, clr="gray",
    p1_dir="z+", p2_dir="z+", port_len1=50, port_len2=-1,
    p1_offset=[0,0], p2_offset=[0,0],
    chan_w=14, chan_h=10, 
        // standard arguments
    px=0.0076, layer=0.010, $fs=0.04, $fa=1) {
```

#### pinhole.scad
```
module pinhole(d=106*layer, l=200*px, orth=0, ychan_z_angle=0)
```

#### optical_view.scad
```
module optical_view(xpos, ypos, zpos, orientation,
    r_ch=20, i_depth=10, d_depth=6, d_ch_distance=10, num_of_ch=5, init_path_len=27,
    px=7.6e-3, layer=10e-3, lpv=20, pitch=30, fn=30, offset_layer=55,
    chan=[10, 10, 14], shape="cube", center_chambers=false, flip_z=false, ren_lef=false)
```


### lef_helper config

All settings for the lef_helper are defined in the lef_scad_config.scad that need the
following variables.
```
layer = [ ... ] // list (array) of strings of named layers
// layers are list sequentially bottom to top

platform_config = [
["lpv", value], // layer per via, number of manufacturing layers spacing routing layers
["px", value], // base pixel size in mm
["layer", value], // base layer size in mm
["pitch", value], // center to center distance between routing paths, in pixels
["via_w", value], // via size, in pixels
["bottom_layers", value] // number of layer offset before first routing layers
] ;

io_loc_layer = // being developed
```

