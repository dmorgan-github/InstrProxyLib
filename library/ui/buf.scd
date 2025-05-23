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

/*
https://scsynth.org/t/live-monitoring-for-buffer-contents-quarks-plugins-or-ways-to-do-it/7918/3
(
var width = Window.screenBounds.width;
var channels = 2;
var wc = width * channels, wc2 = wc * 2;
var shift = (wc2 * 0.9).round(2).asInteger;
var index = 0;

d = FloatArray.newClear(wc2);

v = SoundFileView(nil, Rect(800, 200, 500, 400)).front
.alloc(width * 2, 2)
.gridOn_(false);

OSCdef(\recSummary, { |msg|
	var chan = msg[3..];
	chan = (chan ++ chan.neg).as(FloatArray);
	d.overWrite(chan, index);
	index = index + (channels * 2);
	if(index >= wc2) {
		// shift everything left
		d.overWrite(d[shift..], 0);
		d.overWrite(FloatArray.fill(shift, 0), wc2 - shift);
		index = wc2 - shift;
		defer { v.setData(d, startFrame: 0, channels: channels) };
	} {
		defer { v.set(index div: 2, chan) };
	};
}, '/recSummary', s.addr);

a = {
	var sig = ~sxs.node.ar*0.5;// SoundIn.ar(Array.series(channels, 0, 1));
	var trig = Impulse.ar(32);  // speed of updates
	var sampleCount = Phasor.ar(trig, 1, 1, 10e34, 1);
	// using FOS here as an integrator
	// because Integrator's coefficient is control rate only
	var runningSum = FOS.ar(sig.squared, DC.ar(1), DC.ar(0), Delay1.ar(trig) <= 0);
	var rms = (runningSum / sampleCount).sqrt;

	SendReply.ar(trig, '/recSummary', rms);

	// RecordBuf.ar( you fill in this part  );

	sig * 0.1
}.play;

v.onClose = { a.release; OSCdef(\recSummary).free };
)

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
    var color = node.color;
    var onsetsbtn, onsets;
    var onsetcolors = [
        Color.new255(10, 147, 150),
        Color.new255(148, 210, 189),
        Color.new255(233, 216, 166),
        Color.new255(238, 155, 0),
        Color.new255(202, 103, 2),
        Color.new255(187, 62, 3),
        Color.new255(174, 32, 18),
        Color.new255(155, 34, 38)
    ];
    var start, size;
    var startCtrl, sizeCtrl;

    id = UniqueID.next;
    oscdef = "bufpos_%".format(id).asSymbol;
    osckey = 'bufpos';
    cursorcolor = Color(0.84076716899872, 0.8562139749527, 0.69819803237915);

    /*
    onsets = node.get(\onsets);
    if (onsets.isNil) {
        onsets = 8.collect({ 0 });
        node.set(\onsets, onsets)
    };
    */

    bufnumView = DragSource().background_(Color.clear);//.object_(buf).string_("buffer")
    srView = StaticText();
    numframesView = StaticText();
    durView = StaticText();
    startCtrl = LevelSlider(\start);
    sizeCtrl = LevelSlider(\size);

    loadBuf = {
        buf = node.get(\buf);
        if (buf.notNil) {

            if (buf.isNumber) {
                buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
            };

            if (buf.notNil) {
                
                {
                    buf.loadToFloatArray(action:{|a|
                        //{
                            var startPos = node.get(\startPos) ?? {0};
                            var endPos = node.get(\endPos) ?? {1};
                            var numframes, selstart, selend, selsize;
                            numframes = buf.numFrames;
                            selstart = startPos * numframes;
                            selend = endPos * numframes;
                            selsize = selend - selstart;

                            startCtrl.value_(selstart/numframes);
                            sizeCtrl.value_(selsize/numframes);

                            sfv.setData(a, channels: buf.numChannels);
                            sfv.setSelection(0, [selstart, selsize]);

                        //}.defer
                    });
                }.fork(AppClock);

                {
                    bufnumView.object = buf;
                    bufnumView.string = buf.bufnum;
                    bufnumView.align = \right;
                    bufnumView.maxWidth_(50);

                    srView.string = buf.sampleRate;
                    numframesView.string = buf.numFrames;
                    durView.string = buf.duration.trunc(0.0001);
                };//.defer
            }
        };    
    };

    view = View().layout_(VLayout().margins_(1).spacing_(1));//.fixedHeight_(80);//.minSize_(Size(300, 150));
    sfv = SoundFileView()
    //.minHeight_(150)
    .resize_(1)
    .gridOn_(false)
    //.drawsRMS_(false)
    //.drawsCenterLine_(true)
    .drawsBoundingLines_(false)
    .gridColor_(Color.black)
    .background_(Color.black)
    .waveColors_([color.alpha_(0.7), color.alpha_(0.7)])
    .rmsColor_(color)
    .peakColor_(color)
    .gridResolution_(0.0)
    .timeCursorOn_(true)
    .timeCursorColor_(cursorcolor)
    .currentSelection_(0)
    .mouseUpAction_({|ctrl, x, y|

        var num = sfv.currentSelection;
        var val = ctrl.selection(num);
        var start = val[0];
        var len = val[1];

        if (num > 0) {
            var size = 250, onset;
            onset = start / buf.numFrames;
            ctrl.setSelection(num, [start, size]);
            ctrl.setSelectionColor(num, onsetcolors[num] );
            onsets = onsets[num-1] = onset;
            node.set(\onsets, onsets);
        } {
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
        }
    });
    sfv.setSelectionColor(0, Color.white.alpha_(0.2));
    sfv.canReceiveDragHandler = {|view|
        //TODO: validate
        true;
    };
    sfv.receiveDragHandler = {|view, x, y|
        var val = View.currentDrag.value;
        if (val.isString) {
            // TODO: update to new
            //"load buf".debug("buf.scd");
            fork({
                // TODO: should be dynamic numchannels
                var result = B.read(val, [0, 1]);
                result.wait;
                buf = result.value;
                node.set(\buf, buf);
                node.set(\bufpath, val)
            });
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

    onsetsbtn = 8.collect({|num|
        Button()
        .maxWidth_(20) 
        .states_( [ [num, nil, onsetcolors[num].copy.alpha_(0.3) ], [num, nil, onsetcolors[num] ] ] )
        .action_({|ctrl|
            if (ctrl.value == 1) {
                sfv.currentSelection = num;
                onsetsbtn.do({|btn, i|
                    if (i != num) {
                        btn.value = 0
                    }    
                })
            }
        })
    });

    //view.layout.add(HLayout(*onsetsbtn));
    view.layout.add( HLayout(
        startCtrl
        .action_({|ctrl|
            var val = ctrl.value;
            var numframes = buf.numFrames;
            var startPos = val * numframes;
            start = startPos.floor.asInteger;
            sfv.setSelectionStart(0, start)
        }),

        sizeCtrl
        .action_({|ctrl| 

            var val = ctrl.value;
            var numframes = buf.numFrames;
            size = (val * numframes).floor.asInteger;
            sfv.setSelectionSize(0, size)
        })
    ));

    view.layout.add(sfv);
    /*
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
    */

    // TODO: this is very inneficient
    // but i'm not sure how to render buffer
    // updates without reloading
    refresh = {
        \refresh.debug("buf.scd");
        buf.loadToFloatArray(action:{arg a;
		    {
			    sfv.setData(a, channels: buf.numChannels);
		    }.defer
	    })
    };

    // we'll refresh the display only for smaller buffers
    dorefresh = (node.get(\dorefresh) == 1);
    if (dorefresh) {
        skipjack = SkipJack(refresh, dt: 1, name:"%_%".format(node.key, id), autostart:true).debug("start");
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
    .background_(Color.white.alpha_(0.15))
    .onClose_({
        "close".debug(\buf);
        node.removeDependant(watcher);
        node.set(\bufposreplyid, -1);
        if (skipjack.notNil) {
            skipjack.debug("stop");
            skipjack.stop;
        };
        OSCdef(oscdef).free;
    });
}
)


