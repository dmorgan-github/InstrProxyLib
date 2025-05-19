(
func: {|node|

    var cnt;
    var lastx, lasty;
    var zoomy = 10, zoomx = 5;
    var mousedown = false;
    var view, scope, scopeview;
    var numchannels, palette,  xslider, yslider;
    var color = node.color;
    //node = if (node.respondsTo(\node)) {node.node}{node};
    node = node.tryPerform(\node) ?? {node};
    cnt = node.get(\scope_style) ?? {0};

    palette = QPalette();
    palette.setColor(Color.clear, \window, \active);
    palette.setColor(Color.clear, \highlight, \active);

    numchannels = node.numChannels;
    scopeview = View().layout_(VLayout().margins_(0).spacing_(0))
    //.maxHeight_(150)
    ;
    scope = Stethoscope.new(s, view:scopeview).style_(cnt)
    .index_(node.bus.index)
    .numChannels_(numchannels)
    .cycle_(s.sampleRate / 300)
    .yZoom_(10)
    .xZoom_(5);

    4.do({
        scopeview.children[0].children[0].remove
    });
    scopeview.children[0].children[0].waveColors_([color, Color.white]);
    scopeview.children[0].children[2].remove;
    scopeview.children[0].children[1].remove;
    scopeview.children[0].children[0].background = Color.black;//Color.new255(77, 77, 77);
    scopeview.mouseDownAction_({|ctrl, x, y, mod, num, count|
        lastx = x;
        lasty = y;

        if (count == 2) {
            cnt = cnt + 1;
            cnt = cnt.mod(3);
            scope.style = cnt;
            node.set(\scope_style, cnt)
        };
    });
    
    view = View()
    .maxHeight_(200)
    .layout_(HLayout(
        VLayout(
            scopeview, 
            HLayout(

                StaticText().string_("x"),

                NumberBox()
                .action_({|ctrl|
                    var zoom = ctrl.value.clip(1, 10);
                    scope.xZoom = zoom;
                })
                .minDecimals_(2)
                .clipHi_(10)
                .clipLo_(1)
                .maxWidth_(45)
                .value_(5.0)
                .palette_(palette)
                .background_(Color.clear)
                ,

                StaticText().string_("y"),
                NumberBox()
                .action_({|ctrl|
                    var zoom = ctrl.value.clip(1, 10);
                    scope.yZoom = zoom;
                })
                .palette_(palette)
                .background_(Color.clear)
                .minDecimals_(2)
                .clipHi_(10)
                .clipLo_(1)
                .maxWidth_(45) 
                .value_(10.0),


                /*
                StaticText().string_("c"),
                NumberBox()
                .action_({|ctrl|
                    var val = ctrl.value.clip(1, 1000);
                    scope.cycle = s.sampleRate / val;
                })
                .palette_(palette)
                .background_(Color.clear)
                .minDecimals_(2)
                .clipHi_(1000)
                .clipLo_(0.01)
                .maxWidth_(45) 
                .value_(300),
                */

                nil

            ).margins_(0).spacing_(10)

            //.palette_(sliderpalette)
        ).margins_(0).spacing_(0),
               //.palette_(sliderpalette)
    ).margins_(0).spacing_(0));
    scopeview.onClose = {   
        scope.free 
    };
    view.onClose = { 
        //scope.free.debug("scope free");
    };
    view
}
)
