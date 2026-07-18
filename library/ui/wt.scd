(
var func = {|node|

    var waveDir = "/Users/david/Documents/supercollider/workspace/media/wavetables_2048";
    var key = node.key;
    var buf = node.get('buf').debug("wt buffer");
    var data;
    var selected, loadBuffer;
    var model = Ref(1);
    var sc = SimpleController(model);
    var numFrames = 2048;
    var numWaves = 1;
    var waveColor = Color.fromHexString("#26A69A");
    var filterColor = Color.fromHexString("#FF7043");
    var wfView, waveNum, palette, uv, ctrlCutoff, ctrlRes, ctrlFeg, ctrlAeg, ctrlFamt, bufSelect;
    var famtVal, cutoffVal, resVal, waveNumVal;
    var updateSelected;
    var view, win;
    var width = 200, height = 100;
    var offsetX, offsetY;

    var tmp_path, img;

    /*
    view = View(bounds:Rect(width:width, height:height))
    .name_(key)
    .background_(Color.black)
    .layout_(VLayout().margins_(5).spacing_(5));
    */

    win = Window("test", bounds:Rect(top: Window.screenBounds.height/2, left: 100, width:width, height:height), border: false);//.front;
    win.setTopLeftBounds( win.bounds.top_(Window.screenBounds.height/2).left_(100), 0 );

    \a.postln;

    view = View(/*parent: win,*/ bounds:Rect(width:width, height:height))
    .name_(key)
    .background_(Color.black)
    .layout_(VLayout().margins_(5).spacing_(5));

    famtVal = 0.5;//node.get('famt').linlin(-1, 1, 0, 1);
    cutoffVal = node.get('cutoff');//.explin(20, 20000, 0, 1);
    resVal = node.get('res');
    waveNumVal = 1;

    \b.postln;

    updateSelected = {
        var start = numFrames * (waveNumVal-1);
        var end = start + (numFrames-1);
        data[start..end]
    };

    loadBuffer = {|path|

        var img;
        var imgpath;

        if (path.notNil) {

            imgpath = PathName(path);
            imgpath = "%%.%".format(imgpath.pathOnly, imgpath.fileNameWithoutExtension, "png");
            img = Image.open(imgpath.debug("image"));

            uv.drawFunc = {
                var scale = min(
                    uv.bounds.width  / img.width,
                    uv.bounds.height / img.height
                );
                var w = img.width  * scale;
                var h = img.height * scale;
                var x = (uv.bounds.width  - w) / 2;
                var y = (uv.bounds.height - h) / 2;
                img.drawInRect(Rect(x, y, w, h));
            };
            uv.onResize = { uv.refresh };
            uv.refresh;
        };

        /*
        if (buf.notNil) {
            buf.loadToFloatArray(action: {|array|
                data = array;
                numWaves = (data.size/numFrames).asInteger.debug("num waves");
                {
                    waveNumVal = node.get('pos');
                    if (waveNumVal.isNumber) {
                        waveNumVal = waveNumVal.linlin(0, 1, 0, numWaves).asInteger + 1;
                    } {
                        waveNumVal = 1;   
                    };
                    selected = updateSelected.();
                    waveNum.clipHi_(numWaves);
                    waveNum.value_(waveNumVal);
                    uv.refresh;
                    uv.toolTip_(buf.path);
                }.defer;
                nil
            });
        };
        */
        nil
    };


    \c.postln;

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

    sc
    .put('wavenum', {|obj, what, val|
        var start, end;
        //val.debug('wavenum');
        if (data.notNil) {
            val = val.asInteger -1;
            start = val * numFrames;
            end = start + numFrames -1;
            [start, end].debug("start end");
            selected = data[start..end];
            uv.refresh;
            val = val.linlin(0, numWaves, 0, 1);
            node.set('pos', val)
        }
    })
    .put('famt', {|obj, what, val|
        val = val.linlin(0, 1, -1, 1);
        //val.debug('famt');
        node.set('famt', val)
    })
    .put('cutoff', {|obj, what, val|
        //val = val.linexp(0, 1, 20, 20000);
        //val.debug('cutoff');
        node.set('cutoff', val)
    })
    .put('res', {|obj, what, val|
        //val.debug('res');
        node.set('res', val)  
    })
    .put('bufferSelected', {|obj, what, val|
        var path = val;
        Buffer.read(Server.default, path, action: {|buffer|
            buf = buffer;
            node.set('buf', buf);
            { loadBuffer.(path) }.defer;
            nil
        })
    });

    ctrlCutoff = Knob()
    .color_( [Color.clear, filterColor, Color.clear, filterColor ] )
    .action_({|ctrl|  
        model.changed('cutoff', ctrl.value)
    })
    .value_(cutoffVal);

    ctrlRes = Knob()
    .color_( [Color.clear, filterColor, Color.clear, filterColor ] )
    .action_({|ctrl|
        model.changed('res', ctrl.value)
    })
    .value_(resVal);

    ctrlFamt = Knob()
    .centered_(true)
    .color_( [Color.clear, filterColor, Color.clear, filterColor ] )
    .action_({|ctrl|  
        model.changed('famt', ctrl.value)
    })
    .value_(famtVal);

    // ctrlAeg = UiModule('aeg').(node).minWidth_(150).maxHeight_(75);
    // ctrlFeg = UiModule('aeg').(node, 'f').minWidth_(150).maxHeight_(75);

    uv = UserView(bounds:Rect(width:350, height:175)).minSize_(Size(350, 175));//.minWidth_(100);

    /*
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
                x = (i+1).linlin(0, 2047, 0, width);
                y = v;
                Pen.lineTo(x@y);
                Pen.stroke;
                Pen.moveTo(x@y);
            })
        }
    };
    */

    bufSelect = Button()
    .palette_(palette)
    .background_(waveColor)
    .fixedHeight_(10)
    .fixedWidth_(10)
    .states_([ [nil, nil, waveColor] ])
    .action_({|ctrl|
        var cancelFunc;
        var okFunc = {|path|
            model.changed('bufferSelected', path);
        };
        Dialog.openPanel(okFunc, cancelFunc, multipleSelection: false, path: waveDir);
    });

    // waveNum = NumberBox()
    // .font_(Font(size:25))
    // .palette_(palette)
    // .background_(Color.clear)
    // .minWidth_(52)
    // .decimals_(0)
    // .clipLo_(1)
    // .clipHi_(numWaves)
    // .stringColor_(waveColor)
    // .normalColor_(waveColor)
    // .action_({|ctrl|
    //     model.changed('wavenum', ctrl.value)
    // })
    // .value_(waveNumVal);

    /*
    view.layout.add(
        HLayout(
            StaticText()
            .string_(key)
            .stringColor_( Color.white )
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
        )
    );
    */

    /*
    view.layout.add(
        GridLayout.rows(
            [
                VLayout(
                    bufSelect,
                    waveNum
                ).margins_(0).spacing_(0), 
                uv, 
                ctrlAeg
            ],
            [ctrlFamt, HLayout(ctrlCutoff, ctrlRes), ctrlFeg ]
        )
    );
    */

    view.layout.add(bufSelect);
    view.layout.add(uv);

    loadBuffer.defer;

    //win.asView.front;
    view.front;

};

(func: func)
)