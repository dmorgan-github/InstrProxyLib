(
var func = {|node|

    var buf;
    var view, sfv;
    var uv, stack;
    var grains, id = UniqueID.next;
    var oscdef, osckey, watcher, loadBuf;
    var bufnumView, srView, numframesView, durView;
    var color;

    oscdef = "bufpos_%".format(id).asSymbol;
    osckey = 'bufpos';
    color = node.color;

    bufnumView = DragSource().background_(Color.clear);//.object_(buf).string_("buffer")
    srView = StaticText();
    numframesView = StaticText();
    durView = StaticText();

    grains = [
        (x: 100, y: 200, color:Color.rand),
        (x: 200, y: 200, color:Color.rand),
        (x: 50, y: 200, color:Color.rand),
        (x: 50, y: 200, color:Color.rand),
        (x: 50, y: 200, color:Color.rand)
    ];

    uv = UserView();
    uv.background_(Color.clear);
    uv.drawFunc = {|uview|
        grains.do({|g|
            var x, y, color;
            x = g['x'];
            y = g['y'];
            color = g['color'];

            Pen.fillColor = color;
            Pen.fillOval(Rect.aboutPoint(Point(x, y), 5, 5));
        });
    };
    uv.acceptsMouse = false;
    uv.animate = true;

view = View().layout_(VLayout());

sfv = SoundFileView()
.resize_(1)
.gridOn_(false)
.drawsRMS_(false)
.drawsCenterLine_(true)
.drawsBoundingLines_(false)
.gridColor_(Color.black)
.background_(Color.black)
.waveColors_([color, color])
.background_(Color.clear)
.gridResolution_(0.0)
.mouseUpAction_({|ctrl, x, y|
    var val = ctrl.selection(0);
    var start = val[0];
    var len = val[1];
    var end = start + len;
    var numframes = buf.numFrames;
    var startPos = start/numframes;
    var endPos = end/numframes;

    //[startPos, endPos].debug(\pos);
    if (endPos <= startPos) {
        var start = startPos * numframes;
        var size = numframes - start;
        endPos = 1;
        ctrl.setSelection(0, [start, size])
    };
    node.set('endPos', endPos, 'startPos', startPos);
});

sfv.setSelectionColor(0, Color.white.alpha_(0.2));
sfv.canReceiveDragHandler = {|view|
    //TODO: validate
    true;
};
sfv.receiveDragHandler = {|view, x, y|
    var val = View.currentDrag.value;
    if (val.isString) {
        // granular synths require mono buffer
        // TODO: remove dependency on B
        B.read(val, [0], cb:{|buf|
            node.set(\buf, buf)
        })
    };
    if (val.isKindOf(Buffer)) {
        node.set(\buf, val)
    }
};

loadBuf = {
    buf = node.get(\buf);

    if (buf.notNil) {

        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
        };

        if (buf.notNil) {
            buf.loadToFloatArray(action:{|a|
                {
                    var startPos = node.get(\startPos) ?? {0};
                    var endPos = node.get(\endPos) ?? {1};
                    var numframes, selstart, selend, selsize;
                    numframes = buf.numFrames;
                    selstart = startPos * numframes;
                    selend = endPos * numframes;
                    selsize = selend - selstart;

                    sfv.setData(a, channels: buf.numChannels);
                    sfv.setSelection(0, [selstart, selsize]);
                }.defer
            });

            {
                bufnumView.object = buf;
                bufnumView.string = buf.bufnum;
                bufnumView.align = \right;

                srView.string = buf.sampleRate;
                numframesView.string = buf.numFrames;
                durView.string = buf.duration;
            }.defer
        }
    };    
};

watcher = {|obj, what, vals|
    if (what == \set) {
        vals.pairsDo({|k, v|
            if (k == \buf) {
                loadBuf.();
            }
        })
    };
};
node.addDependant(watcher);
node.set(\bufposreplyid, id);
loadBuf.();

OSCdef(oscdef, {|msg|
    var val = msg[3..];
    var replyid = msg[2];
    {
        val.do({|v, i|
            if (replyid == (id)) {
                var pos = v/buf.duration;
                var x = uv.bounds.width * pos;
                grains[i].x = x;
            };
                if (replyid == (id+1)) {
                    var y = uv.bounds.height * v;
                    grains[i].y = uv.bounds.height - y;
                };
            })
            
        }.defer;
    }, osckey);

    stack = StackLayout(
        uv,
        sfv
    )
    .mode_(1);
    view.layout.add(stack);
    view.layout.add(
        HLayout(nil,
            bufnumView,
            StaticText().string_(" | "),
            srView,
            StaticText().string_(" | "),
            numframesView,
            StaticText().string_(" | "),
            durView
        ).spacing_(2).margins_(2)
    );


    view
    .resize_(1)
    .onClose_({
        node.removeDependant(watcher);
        OSCdef(oscdef).free;
    })
};

(func: func)
)
