include <lef_scad_config.scad>

ren_th = 0.1 ;

port_clr1 = "red" ;
port_clr2 = "blue" ;

module lef_obs(geometry, pts, px=undef, layer=undef, lpv=undef, chan_def=undef)
{
    px = !px ? get_config("px") : px;
    lpv = !lpv ? get_config("lpv") : lpv;
    layer = !layer ? get_config("layer") : layer;
    chan_def = !chan_def ? get_config("chan_def") : chan_def;

    assert(geometry=="RECT" || geometry=="rect");

    %lef_rect(pts*px, layer*lpv, px, layer, lpv, layer, chan_def) ;
}

module lef_port(port_name="", direction="", geometry="", pts=false, center=true, px=undef, layer_h=undef, layer=undef, lpv=undef, chan_def=undef)
{
    px = !px ? get_config("px") : px;
    lpv = !lpv ? get_config("lpv") : lpv;
    layer = !layer ? get_config("layer") : layer;
    chan_def = !chan_def ? get_config("chan_def") : chan_def;
    layer_h = !layer_h ? chan_def[1] : layer_h;

    assert(geometry=="RECT" || geometry=="rect");

    port_center = (
      len(pts)==4 ? [
        (pts[0]+pts[2])/2,
        (pts[1]+pts[3])/2,
        (pts[0]+pts[2])/2,
        (pts[1]+pts[3])/2
      ] : (len(pts)==2 ?
        (!is_num(pts[0]) ?
          [
            (pts[0][0]+pts[1][0])/2,
            (pts[0][1]+pts[1][1])/2,
            (pts[0][0]+pts[1][0])/2,
            (pts[0][1]+pts[1][1])/2,
          ] :
          (center ?
           pts : pts - chan_def/2))
      : [])
      ) ;


    chan_centered = (
      len(pts) == 4 ? [
          -chan_def[0]/2,
          -chan_def[0]/2,
          chan_def[0]/2,
          chan_def[0]/2,
      ] :
        (!is_num(pts) == 2 ? [
            -chan_def[0]/2,
            -chan_def[0]/2,
            chan_def[0]/2,
            chan_def[0]/2,
          ] :
          [
            chan_def[0],
            chan_def[0]
          ]
          )
    );

    if(len(pts)==4){
      color(port_clr1)
      lef_rect(
          (port_center + chan_centered )*px,
          layer_h*layer,
          px=px, layer=layer, lpv=lpv, chan_def=chan_def
          ) ;
      color(port_clr2, 0.6)
            lef_rect(
            pts*px,
            layer * (lpv-1),
            px=px, layer=layer, lpv=lpv, chan_def=chan_def
          ) ;
    } else if(len(pts)==2)
    {
      if(is_num(pts[0])){
        color(port_clr1)
        lef_rect(
            pts*px,
            layer_h*layer, // get channel height
            center=center,
    px=px, layer=layer, lpv=lpv, chan_def=chan_def
            ) ;
        color(port_clr2, 0.6)
        lef_rect(
            (pts*px),
            layer*(lpv-1),
            center=center,
    px=px, layer=layer, lpv=lpv, chan_def=chan_def
          ) ;
      } else {
        color(port_clr1)
        lef_rect(
            (port_center + chan_centered)*px,
            layer_h*layer, // get channel height
            center=center,
    px=px, layer=layer, lpv=lpv, chan_def=chan_def
          ) ;
        color(port_clr2, 0.6)
    lef_rect(
        [pts[0],pts[1],
        pts[0]+via_w,
        pts[1]+via_w]*px,
            layer_h*(lpv-1),
            center=center,
    px=px, layer=layer, lpv=lpv, chan_def=chan_def
          ) ;
      }
    }
}

module lef_rect(pts, th=ren_th, center=true, px=undef, lpv=undef, layer=undef, chan_def=undef)
{
    px = !px ? get_config("px") : px;
    lpv = !lpv ? get_config("lpv") : lpv;
    layer = !layer ? get_config("layer") : layer;
    chan_def = !chan_def ? get_config("chan_def") : chan_def;

    w  = (len(pts)==2 ?
          (!is_num(pts[0]) ? abs(pts[0][0] - pts[1][0]):
            chan_def[0]*px):
        (len(pts)==4?abs(pts[0] - pts[2]):0));
    h  = (len(pts)==2 ?
          (!is_num(pts[0]) ? abs(pts[0][1] - pts[1][1]):
            chan_def[1]*layer):
        (len(pts)==4?abs(pts[1] - pts[3]):0));
    ox = (len(pts)==2 ?
          (!is_num(pts[0]) ? abs(pts[0][0]):
            (center ? pts[0]-chan_def[0]/2*px:pts[0])):
        (len(pts)==4?abs(pts[0]):0));
    oy = (len(pts)==2 ?
          (!is_num(pts[0]) ? abs(pts[0][1]):
            (center ? pts[1]-chan_def[0]/2*px:pts[0])):
        (len(pts)==4?abs(pts[1]):0));

    translate([ox, oy, 0])
        cube([w, h, th]) ;
}
module lef_layer_index(layer_index, px=undef, layer=undef, lpv=undef, chan_def=undef)
{
    px = !px ? get_config("px") : px;
    lpv = !lpv ? get_config("lpv") : lpv;
    layer = !layer ? get_config("layer") : layer;
    chan_def = !chan_def ? get_config("chan_def") : chan_def;
    l_off = layer * lpv * layer_index;

    translate([0,0,l_off])
        children() ;
}

module lef_layer(layer_name, px=undef, layer=undef, lpv=undef, chan_def=undef)
{
    layer_index = get_layer_index(layer_name);
    lef_layer_index(layer_index, px, layer, lpv, chan_def)
    children();
}

module lef_size(X, Y, px=undef, layer=undef, lpv=undef, chan_def=undef)
{
    px = !px ? get_config("px") : px;
    lpv = !lpv ? get_config("lpv") : lpv;
    layer = !layer ? get_config("layer") : layer;
    chan_def = !chan_def ? get_config("chan_def") : chan_def;

    cube([X*px, Y*px, layer*0.1]);
}

function get_layer_index(x) = search([x], layers)[0] ;

function get_config(prop) = platform_config[search([prop], platform_config)[0]][1] ;

function get_io_layer(x1, x2) = io_loc_layer[x1][x2] ;


lef_size(200, 200) ;

lef_layer("met1")
    lef_obs("RECT", [0,0,100,120]) ;
lef_layer("met2")
    lef_obs("RECT", [0,0,100,120]) ;

lef_layer("met2")
    lef_port("", "", "RECT", [14,14,28,38]) ;

lef_layer_index(get_layer_index("met2"))
    lef_port("", "", "RECT", [14,44,30,62]) ;

lef_layer_index(get_layer_index("met2"))
    lef_port("", "", "RECT", [44,24]) ;

