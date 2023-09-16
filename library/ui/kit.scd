(
var func = {|node|
    var key = "%_kit".format(node.key).asSymbol;
    var sfvs;
    var view = View().layout_(VLayout()).background_(Color.black);
    var grid = GridLayout();
    var cols = 3, rows = 2;
    var num = cols * rows;
    var pdv;
    // TODO: is this is best way to do this?
    var ptrn = Pdef(key);
    var showBuf;
    var cursorcolor;
    var pos = node.get(\pos);
    var bufs = node.get(\bufs);
    var color = node.color;

    showBuf = {|sfv, buf, pos|
        buf.loadToFloatArray(action:{|a|
            {
                var frame = buf.numFrames * pos;
                sfv.setData(a, channels: buf.numChannels);
                sfv.timeCursorPosition = frame;
            }.defer
        });
    };
   
    if (pos.isNil) {
        pos = Array.fill(rows * cols, 0);
        node.set(\pos, pos);
    };
    if (bufs.isNil) {
        bufs = Array.fill(rows * cols, nil);
        node.set(\bufs, bufs);
    };

    pdv = UiModule('pdv').(ptrn, 'index');
    cursorcolor = Color(0.84076716899872, 0.8562139749527, 0.69819803237915);

    sfvs = num.collect({|i|
        var buf, bufs, sfv = SoundFileView();
        var tc = pos[i];
        sfv
        .gridOn_(false)
        .drawsRMS_(false)
        .drawsCenterLine_(true)
        .drawsBoundingLines_(false)
        .gridColor_(Color.black)
        .background_(Color.black)
        .waveColors_([color, color])
        .gridResolution_(0.0)
        .timeCursorOn_(true)
        .timeCursorColor_(cursorcolor)
        .canReceiveDragHandler_({|view|
            //TODO: validate
            true;
        })
        .receiveDragHandler_({|view, x, y|
            var val = View.currentDrag.value;
            B.read(val, channels:[0], cb:{|buf|
                var bufs = node.get(\bufs);
                var pos = node.get(\pos);
                bufs[i] = buf;
                showBuf.(sfv, buf, pos[i]);
                node.set(\bufs, bufs)
            })
        })
        .action_({|ctrl|
            var index = i;
            var buf = bufs[index];
            if (buf.notNil) {
                var tc = ctrl.timeCursorPosition/buf.numFrames;
                pos[index] = tc;
                node.set(\pos, pos);
            }
        });

        bufs = node.get(\bufs);
        if (bufs.notNil) {
            buf = bufs[i];
            if (buf.notNil) {
                showBuf.(sfv, buf, pos[i])
            };
        };
        sfv
    });

    rows.do({|i|
        cols.do({|j|
            var index = (i * rows) + j + i;
            var sfv = sfvs[index];
            grid.add(sfv, i, j);
        })
    });

    node.source = Pbind(
        \buf, Pfunc({|evt|
            var bufs = evt['bufs'] ?? [];
            var index = evt['index'];
            var val = \rest;
            if (index.notNil and: index.isRest.not) {
                val = bufs.wrapAt(index.asInteger);
                if (val.isNil) {
                    val = \rest;
                }
            };
            val;
        }),
        \startPos, Pfunc({|evt|
            var pos = evt['pos'] ?? [];
            var index = evt['index'];
            var val = 0;
            if (index.notNil and: {index.isRest.not}) {
                val = pos.wrapAt(index);
                if (val.isNil) {
                    val = 0;
                };
            };
            val;
        }),
        \finish, {|evt|
            {
                var index = evt['index'];
                if (index.notNil and: {index.isRest.not}) {
                    index.asArray.do({|val|
                        if (val.notNil and: {val.isRest.not}) {
                            var sfv = sfvs[val];
                            if (sfv.isNil.not and: {sfv.isClosed.not}) {
                                //sfv.background = Color.white;
                                sfv.waveColors = [Color.white, Color.white];
                                {
                                    //sfv.background = Color.black
                                    sfv.waveColors = [color, color];
                                }.defer(0.1);
                            }
                        }
                    })
                };
                1
            }.defer(s.latency)
        }
    ) <> ptrn
    ;

    view.layout.add(grid);
    view.layout.add(pdv);
    view;
};

(
func: func
)


)
