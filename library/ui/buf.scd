/*
~indices = Buffer(s);
~feature = Buffer(s);
FluidBufOnsetSlice.processBlocking(s,~src,indices:~indices,metric:9,threshold:0.2);
FluidBufOnsetFeature.processBlocking(s,~src,features:~feature,metric:9);
FluidWaveform(~src,~indices,~feature,bounds:Rect(0,0,1600,400),lineWidth:2);


var view = View().layout_(VLayout(
    FluidWaveform(~drums,
        waveformColor:Color.cyan,
        imageBuffer:~mags,
        imageColorScheme:1,
        imageColorScaling:1
    ).asView.background_(Color.clear)
));
view.front;

*/

(
func: {arg node;

    var key = node.key;
    var refresh, skipjack;
    var bufspec, dorefresh;
    var bufnumView, srView, numframesView, durView;
    var id;
    var oscdef;
    var osckey;
    var cursorcolor;
    var watcher; 
    var view;
    var sfv;
    var buf;
    var dragSink;
    var loadBuf;

    id = UniqueID.next;
    oscdef = "bufpos_%".format(id).asSymbol;
    osckey = 'bufpos';
    cursorcolor = Color(0.84076716899872, 0.8562139749527, 0.69819803237915);

    bufnumView = StaticText();
    srView = StaticText();
    numframesView = StaticText();
    durView = StaticText();

    loadBuf = {
        buf = node.get(\buf);
        if (buf.notNil) {

            if (buf.isNumber) {
                buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
            };

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
                bufnumView.string = buf.bufnum;
                srView.string = buf.sampleRate;
                numframesView.string = buf.numFrames;
                durView.string = buf.duration;
            }.defer
        };    
    };

    view = View().layout_(VLayout().margins_(0).spacing_(0));//.minSize_(Size(300, 150));
    sfv = SoundFileView()
    .resize_(1)
    .gridOn_(false)
    .drawsRMS_(false)
    .drawsCenterLine_(true)
    .drawsBoundingLines_(false)
    .gridColor_(Color.black)
    .background_(Color.black)
    .waveColors_([node.color, node.color])
    .gridResolution_(0.0)
    .timeCursorOn_(true)
    .timeCursorColor_(cursorcolor)
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
            B.read(val, cb:{|buf|
                node.set(\buf, buf)
            })
        };
        if (val.isKindOf(Buffer)) {
            node.set(\buf, val)
        }
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

    view.layout.add(sfv);
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

    // TODO: this is very inneficient
    // but i'm not sure how to render buffer
    // updates without reloading
    refresh = {
        buf.loadToFloatArray(action:{arg a;
		    {
			    sfv.setData(a, channels: buf.numChannels);
		    }.defer
	    })
    };

    // we'll refresh the display only for smaller buffers
    dorefresh = (node.get(\dorefresh) == 1);
    if (dorefresh) {
        skipjack = SkipJack(refresh, dt: 1, name:"%_%".format(node.key, id));
    };

    node.set(\bufposreplyid, id);
    OSCdef(oscdef, {arg msg;
        var val = msg[4];
        var replyid = msg[2];
        {
            if (replyid == id) {
                if (val.notNil) {
                    sfv.timeCursorPosition = val;
                }
            }
        }.defer;
    }, osckey);

    node.addDependant(watcher);
    loadBuf.();

    view
    .resize_(1)
    .onClose_({
        "close".debug(\buf);
        node.removeDependant(watcher);
        if (skipjack.notNil) {
            skipjack.stop;
        };
        OSCdef(oscdef).free;
    });
}
)


