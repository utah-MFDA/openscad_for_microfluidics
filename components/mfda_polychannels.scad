use <../polychannel/polychannel.scad>
use <lef_helper.scad>

module polychannel_mfda(
    params,
    shape,
    px=get_config("px"),
    layer=get_config("layer"),
    lpv=get_config("lpv"),
    bot_layers=get_config("bottom_layers"),
    n_rot=true,
    report_len=false,
    chan_name="",
    chan_devices="",
    relative_positions=false,
    clr="lightblue",
    center=true,
    show_only_shapes=false
    )
{
    conv_params = (n_rot?
        [for(i=[0:1:len(params)-1])
            [params[i][0],
            [params[i][1][0]*px, params[i][1][1]*px, params[i][1][2]*layer],
            [params[i][2][0]*px, params[i][2][1]*px, 
                get_layer_index(params[i][2][2])*lpv*layer+bot_layers*layer],
            [0, [0, 0, 1]]]
        ] : 
        [for(i=[0:1:len(params)-1]) 
            [params[i][0],
            [params[i][1][0]*px, params[i][1][1]*px, params[i][1][2]*layer],
            [params[i][2][0]*px*pitch, params[i][2][1]*px*pitch, 
                get_layer_index(params[i][2][2])*lpv*layer+bot_layers*layer],
            params[i][3]]
        ]
   ) ;
        
    polychannel(conv_params,relative_positions,clr,center,show_only_shapes);
    
    if(report_len)
        echo(chan_name, polychannel_len_calc(params_px)) ;
}

module polychannel_mfda_by_row(
    params,
    shape,
    px=get_config("px"),
    layer=get_config("layer"),
    lpv=get_config("lpv"),
    bot_layers=get_config("bottom_layers"),
    pitch=get_config("pitch"),
    n_rot=true,
    report_len=false,
    chan_name="",
    chan_devices="",
    relative_positions=false,
    clr="lightblue",
    center=true,
    show_only_shapes=false
    )
{
    conv_params = (n_rot?
        [for(i=[0:1:len(params)-1])
            [params[i][0],
            [params[i][1][0]*px, params[i][1][1]*px, params[i][1][2]*layer],
            [params[i][2][0]*px*pitch, params[i][2][1]*px*pitch, 
                get_layer_index(params[i][2][2])*lpv*layer+bot_layers*layer],
            [0, [0, 0, 1]]]
        ] : 
        [for(i=[0:1:len(params)-1]) 
            [params[i][0],
            [params[i][1][0]*px, params[i][1][1]*px, params[i][1][2]*layer],
            [params[i][2][0]*px*pitch, params[i][2][1]*px*pitch, 
                get_layer_index(params[i][2][2])*lpv*layer+bot_layers*layer],
            params[i][3]]
        ]
   ) ;
        
    polychannel(conv_params,relative_positions,clr,center,show_only_shapes);
    
    if(report_len)
        echo(chan_name, polychannel_len_calc(params_px)) ;
}


module polychannel_px_pts(
    pts,
    shape,
    dimm,
    px=7.6e-3,
    layer=10e-3,
    n_rot=true,
    report_len=false,
    chan_name="",
    relative_positions=false, 
    clr="lightblue", 
    center=true, 
    show_only_shapes=false
    )
{
    params_px = (n_rot?
    [for(i=[0:1:len(pts)-1]) 
        [shape,
        dimm,
        [pts[i][0]*px, pts[i][1]*px, pts[i][2]*layer],
        [0, [0, 0, 1]]]
    ]
    : // else
    [for(i=[0:1:len(pts)-1]) 
        [shape,
        dimm,
        [pts[i][2][0]*px, pts[i][2][1]*px, pts[i][2][2]*layer],
        pts[i][1]]
    ]  
    ); // n_rot?

    polychannel(params_px,relative_positions,clr,center,show_only_shapes);
    
    if(report_len)
        echo(chan_name, polychannel_len_calc(params_px)) ;
}

module polychannel_px(
    params,
    px=7.6e-3,
    layer=10e-3,
    n_rot=true,
    report_len=false,
    chan_name="",
    relative_positions=false, 
    clr="lightblue", 
    center=true, 
    show_only_shapes=false
    )
{
    params_px = (n_rot?
    [for(i=[0:1:len(params)-1]) 
        [params[i][0],
        [params[i][1][0]*px, params[i][1][1]*px, params[i][1][2]*layer],
        [params[i][2][0]*px, params[i][2][1]*px, params[i][2][2]*layer],
        [0, [0, 0, 1]]]
    ]
    :
    [for(i=[0:1:len(params)-1]) 
        [params[i][0],
        [params[i][1][0]*px, params[i][1][1]*px, params[i][1][2]*layer],
        [params[i][2][0]*px, params[i][2][1]*px, params[i][2][2]*layer],
        params[i][3]]
    ]  
    ); // n_rot?

    polychannel(params_px,relative_positions,clr,center,show_only_shapes);
    
    if(report_len)
        echo(chan_name, polychannel_len_calc(params_px)) ;
}

ch_sz = [14, 14, 10] ;

polychannel_mfda([
    ["cube", ch_sz, [0, 0, "met1"]],
    ["cube", ch_sz, [0, 0, "met2"]],
    ["cube", ch_sz, [0, 30, "met2"]],
    ["cube", ch_sz, [20, 50, "met3"]]
    ]) ;
      
polychannel_mfda_by_row([
    ["cube", ch_sz, [1, 0, "met1"]],
    ["cube", ch_sz, [1, 0, "met2"]],
    ["cube", ch_sz, [1, 3, "met2"]],
    ["cube", ch_sz, [2, 5, "met3"]]
    ]) ;
