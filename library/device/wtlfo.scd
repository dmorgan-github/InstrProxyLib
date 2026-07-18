(

var waves = "/Users/david/Documents/supercollider/media/wavetables_4096/waves.wav";
var scopeView = {|node|

    //var node = t(16).stuff.lfo2;
    var view, stethoscope, scopeview;
    var numchannels, palette;
    var color = Color.gray;
    node = node.tryPerform(\node) ?? {node};

    palette = QPalette();
    palette.setColor(Color.clear, \window, \active);
    palette.setColor(Color.clear, \highlight, \active);

    numchannels = 1;//node.numChannels;
    scopeview = View().layout_(VLayout().margins_(0).spacing_(0));
    //scopeview.background = Color.green;

    stethoscope = Stethoscope.new(Server.default, view:scopeview).style_(0)
    .index_(node.bus.index)
    .numChannels_(numchannels)
    .cycle_(Server.default.sampleRate / 300)
    .yZoom_(1)
    .xZoom_(1);

    4.do({
        scopeview.children[0].children[0].remove
    });
    scopeview.children[0].children[0].waveColors_([color, Color.white]);
    scopeview.children[0].children[2].remove;
    scopeview.children[0].children[1].remove;
    scopeview.children[0].children[0].background = Color.black;//Color.new255(77, 77, 77);

    view = View().layout_(VLayout().spacing_(0).margins_(0));
    view.layout.add(scopeview);
    view.onClose = { stethoscope.free.debug("free stethoscope")  };
    view;
};

var func = {|key|

    var obj;
    var node, makeGui, makeLfo;
    var data;
    var numFrames = 4096;
    var numWaves = 1;//(buf.numFrames/numFrames).asInteger;

    node = NodeProxy();
    node[0] = {
        var buf = \wtlfobuf.kr;
        //var lfoSend = \lfoSend.kr(1);
        var freq = \lfoRate.kr(1/2);
        var reset = \lfoReset.tr(1);
        var divs = BufFrames.kr(buf)/numFrames;
        var pos = \lfoBufPos.kr(0);
        var min = \lfoLo.kr(0);
        var max = \lfoHi.kr(1);
        //var val = \lfoVal.kr(0.5);
        var depth = \lfoDepth.kr(1);
        var phase = Phasor.ar(reset, freq * SampleDur.ir, start: 0, end: 1, resetPos: 0);
        /*
        Serum-style stretch/squeeze distortions, which are achieved by bending the phasor before mapping onto the wavetable
        */
        var sig = OscOS.ar(
            bufnum: buf,
            phase: phase,
            buf_divs: divs,
            buf_loc: pos,
            oversample: 0
        );
        //sig = val * 2.pow( sig * depth );
        sig = sig.linlin(-1, 1, min, max);
        sig;
    };

    makeGui = {|node|

        var view;
        var model = Ref(1);
        var sc = SimpleController(model);
        var palette;
        var stack = StackLayout().mode_(1);
        var windowname = key ?? "wtlfo";
        var offsetX, offsetY;
        var width = 125, height = 125;

        var win = Window(windowname, 
            bounds:Rect(top: Window.screenBounds.height/2, left: 100, width:width, height:height), 
            border: false
        );//.front;

        //#A07855
        var waveColor = Color.white;//Color.fromHexString("#50586C");
        // #D4B996
        var knobColor = Color.fromHexString("#DCE2F0");
        var ctrlLfoVal, ctrlLfoRate, ctrlLfoDepth, ctrlWaveNum, uv, ctrlLfoLo, ctrlLfoHi;
        var lfoVal, lfoRate, lfoDepth, waveNumVal, lfoLo, lfoHi;
        var selected, updateSelected, start, end;

        palette = QPalette()
        .window_(Color.clear)
        .windowText_(Color.grey(0.5))
        .baseText_(Color.grey(0.5))
        .button_(Color.clear)
        .highlight_(Color.clear);

        palette.base = Color.black;
        palette.setColor(Color.black, \shadow);
        palette.setColor(Color.black, \dark);
        palette.setColor(Color.black, \middark);

        lfoVal = node.get('lfoVal');
        lfoRate = node.get('lfoRate');
        lfoDepth = node.get('lfoDepth');
        lfoLo = node.get('lfoLo');
        lfoHi = node.get('lfoHi');
        waveNumVal = node.get('lfoBufPos').linlin(0, 1, 0, numWaves-1).asCompileString.asInteger;

        start = waveNumVal * numFrames;
        end = start + numFrames;
        selected = data[start..end];

        sc
        .put('wavenum', {|obj, what, val|
            var start, end;
            if (data.notNil) {
                val = val.asInteger;
                start = val * numFrames;
                end = start + numFrames;
                selected = data[start..end];
                uv.refresh;
                val = val.linlin(0, numWaves-1, 0, 1);
                node.set('lfoBufPos', val.postln);
            }
        })
        .put('val', {|obj, what, val|
            val.debug("lfoVal");
            node.set('lfoVal', val)
        })
        .put('depth', {|obj, what, val|
            val.debug("lfoDepth");
            node.set('lfoDepth', val)
        })
        .put('rate', {|obj, what, val|
            val.debug("lfoRate");
            node.set('lfoRate', val)   
        })
        .put('lo', {|obj, what, val|
            val.debug("lfoLo");
            node.set('lfoLo', val)    
        })
        .put('hi', {|obj, what, val|
            val.debug("lfoHi");
            node.set('lfoHi', val)     
        });

        view = View(parent:win, bounds:width@height)
        .name_(windowname)
        .background_(Color.black)
        .layout_(VLayout().margins_(5).spacing_(5));

        ctrlWaveNum = NumberBox()
        .font_(Font(size:25))
        .palette_(palette)
        .background_(Color.clear)
        .minWidth_(52)
        .decimals_(0)
        .clipLo_(0)
        .clipHi_(numWaves-1)
        .stringColor_(waveColor)
        .normalColor_(waveColor)
        .action_({|ctrl|
            model.changed('wavenum', ctrl.value)
        })
        .value_(waveNumVal);

        ctrlLfoVal = Knob()
        .background_(Color.blue)
        .color_( [Color.clear, knobColor, Color.clear, knobColor ] )
        .action_({|ctrl|  
            model.changed('val', ctrl.value)
        })
        .value_(lfoVal);

        ctrlLfoRate = Knob()
        .color_( [Color.clear, knobColor, Color.clear, knobColor ] )
        .action_({|ctrl|  
            model.changed('rate', ctrl.value)
        })
        .value_(lfoRate);

        ctrlLfoDepth = Knob()
        .color_( [Color.clear, knobColor, Color.clear, knobColor ] )
        .action_({|ctrl|  
            model.changed('depth', ctrl.value)
        })
        .value_(lfoDepth);

        ctrlLfoLo = NumberBox()
        .palette_(palette)
        .background_(Color.clear)
        .stringColor_(waveColor)
        .normalColor_(waveColor)
        .decimals_(2)
        .action_({|ctrl|
            model.changed('lo', ctrl.value)
        })
        .value_(lfoLo);

        ctrlLfoHi = NumberBox()
        .palette_(palette)
        .background_(Color.clear)
        .stringColor_(waveColor)
        .normalColor_(waveColor)
        .decimals_(2)
        .action_({|ctrl|
            model.changed('hi', ctrl.value)
        })
        .value_(lfoHi);

        uv = UserView().fixedHeight_(60);
        uv.drawFunc = {|uview|
            var x, y;
            var pad = 5;
            var height = uview.bounds.height;
            var width = uview.bounds.width;
            if (selected.notNil) {
                var vals = selected.linlin(-1, 1, height-pad, pad);
                Pen.color = waveColor;
                Pen.moveTo(0@vals[0]);
                vals[1..].do({|v, i|
                    x = (i+1).linlin(0, numFrames-1, 0, width);
                    y = v;
                    Pen.lineTo(x@y);
                    Pen.stroke;
                    Pen.moveTo(x@y);
                })
            }
        };

        stack.add(uv);
        stack.add( scopeView.(node) );

        view.layout.add(
            VLayout(

                HLayout(
                    StaticText()
                    .string_(windowname)

                    //.stringColor_( Color.white.alpha_(0.5) )
                    .stringColor_( Color.white )
                    //.background_(node.color)
                    .mouseDownAction_({|ctrl, x, y|
                        offsetX = x;
                        offsetY = y;
                    })
                    .mouseMoveAction_({|ctrl, x, y|
                        var width, height;
                        var bounds = ctrl.bounds;
                        var screen = ctrl.mapToGlobal(Point(x, y));// - ctrl.bounds.origin;
                        var screenX = screen.x - offsetX;
                        var screenY = screen.y - offsetY;
                        width = view.bounds.width;
                        height = view.bounds.height;
                        win.setTopLeftBounds(Rect(left:screenX, top:screenY, width: width, height: height), menuSpacer:0);
                    })
                ),

                HLayout(ctrlWaveNum, stack, nil).spacing_(0).margins_(0),
                HLayout(ctrlLfoLo, ctrlLfoHi, ctrlLfoRate).spacing_(2).margins_(0)
            )
        );
        
        //view.front;
        win.asView.front;
    };

    if (true /*Library.at('wtlfo').isNil*/) {
        Buffer.read(Server.default, 
            path: waves,
            action:{|buf|
                node.set(\wtlfobuf, buf.debug("wtlfo buf"));
                buf.loadToFloatArray(action: {|array|
                    data = array;
                    numWaves = (data.size/numFrames).asInteger.debug("num waves");
                    Library.put(\wtlfo, \buf, buf);
                    Library.put(\wtlfo, \data, data);
                    Library.put(\wtlfo, \numwaves, numWaves);
                });
            }
        );
    }{
        data = Library.at(\wtlfo, \data);
        numWaves = Library.at(\wtlfo, \numwaves)
    };

    if (node.respondsTo('view').not) {
        node.addUniqueMethod('view', {|self|
            makeGui.(self, 'wtlfo');
        });
    };

    /*
    if (node.respondsTo('key_').not) {
        node.addUniqueMethod('key_', {|self, argKey| key = argKey });
    };
    */

    node;
};

(func: func)
)