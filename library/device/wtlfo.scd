(
var func = {|key, path|

    var lfo;
    var numframes = 4096;
    var replyid = UniqueID.next;
    var oscdef, oscpath;
    var buildView;
    var buildLfo;

    oscpath = "/%_lfo_%".format(key, replyid).asSymbol;

    lfo = Ndef(key);
    buildLfo = {|buf|

        \buildLfo.debug('wtlfo');

        lfo[0] = {
            var lfoSend = \lfoSend.kr(1);
            var freq = \lfoRate.kr(1/2);
            var reset = \lfoReset.tr(1);
            var buf = \buf.kr(0);
            var divs = BufFrames.kr(buf)/numframes;
            var start = \lfoStartPos.kr(0);
            var end = \lfoEndPos.kr(1);
            var pos = \lfoBufPos.kr(0);
            var phase = Phasor.ar(reset, freq * SampleDur.ir, start: start, end: end, resetPos: start);
            var sig = OscOS.ar(
                bufnum: buf,
                phase: phase,
                buf_divs: divs,
                buf_loc: pos,
                oversample: 1
            );
            sig = \lfoVal.kr(0.5) * 2.pow( sig * \lfoDepth.kr(1) );
            sig = sig.clip(0, 1);
            //sig = sig.linlin(-1, 1, 0, 1);
            SendReply.kr(Impulse.kr(60) * lfoSend, oscpath, [phase, sig, divs, pos]);
            sig    
        };

        lfo.addDependant( {|obj, what|
            if (what == \free) {
                \free.debug("wtlfo");
                buf.free;
            }
        });
    };

    if (lfo.get(\buf).isNil) {
        Buffer.read(Server.default, path: path, action: {|buf|
            lfo.set(\buf, buf);
            buildLfo.(buf)
        });
    };

    buildView = {

        var uv, sfv, view, rect, stack, sf;
        var bufpos = -1;
        var width = 200, height = 200;
        var waveView, listView, scrollView, listWidth = 100;
        var spacing = 0.01, yMin, yMax;

        view = View(bounds:Rect(0, 0, width+listWidth, height))
        .name_("% lfo".format(key))
        .layout_(VLayout().spacing_(0).margins_(0));

        waveView = View(bounds:Rect(0, 0, width, height))
        .layout_(VLayout().spacing_(0).margins_(0));

        scrollView = ScrollView().maxWidth_(listWidth).minWidth_(listWidth);
        listView = View()
        .layout_(VLayout().spacing_(1).margins_(1));

        rect = Rect(0, 0, 8, 8);

        sfv = SoundFileView.new(bounds: Rect(0, 0, width, height))
        .background_(Color.black)
        .gridColor_(Color.black)
        .background_(Color.black)
        .waveColors_([Color.white.alpha_(0.7), Color.white.alpha_(0.7)])
        .gridResolution_(0.0)
        .timeCursorOn_(false)
        .spacing_(spacing)
        .drawsCenterLine_(false)
        .drawsBoundingLines_(false);

        sf = SoundFile();
        sf.openRead(path);

        sfv.soundfile = sf;
        sfv.read(0*numframes, numframes);

        uv = UserView(bounds:Rect(0, 0, width, height))
        .background_(Color.clear)
        .drawFunc = {
            Pen.addOval(rect); 
            Pen.color = Color.blue;
            Pen.draw;
        };

        {
            var numwaves;
            numwaves = (sf.numFrames/numframes).asInteger;
            numwaves.do({|i|
                var v = SoundFileView()
                .background_(Color.black)
                .gridColor_(Color.black)
                .background_(Color.black)
                .waveColors_([Color.white.alpha_(0.7), Color.white.alpha_(0.7)])
                .gridResolution_(0.0)
                .timeCursorOn_(false)
                .spacing_(0.1)
                .drawsCenterLine_(false)
                .drawsBoundingLines_(false)
                .mouseDownAction_({|ctrl|
                    sfv.read(i*numframes, numframes);
                    lfo.set(\lfoBufPos, i/(numwaves-1) )
                })
                .toolTip_(i+1);

                v.soundfile = sf;
                v.read(i*numframes, numframes);
                listView.layout.add(v)
            });
            scrollView.canvas = listView;
        }.();

        stack = StackLayout(uv, sfv).mode_(1);
        waveView.layout.add(stack);
        view.layout.add(HLayout( scrollView, waveView ));
        
        yMin = height * spacing;
        yMax = height - yMin;

        oscdef = OSCdef(oscpath, {|msg, b, c, d|
            var phase = msg[3];
            var val = msg[4];
            var divs = msg[5];
            var pos = msg[6];

            var x = phase.linlin(0, 1, 0, width);
            var y = val.linlin(0, 1, yMax, yMin);

            if (pos != bufpos) {
                {
                    var startFrame = sf.numFrames * pos;
                    var div = (divs * pos).floor;
                    sfv.read(div*numframes, numframes);
                }.defer;
                bufpos = pos;
            };

            {
                rect.origin = Point(x, y);
                uv.refresh
            }.defer
            
        }, oscpath);

        view.onClose_({
            \close.debug("wtlfo");
            lfo.set(\lfoSend, 0);
            sf.close;
            oscdef.free;
        });
    };

    lfo.addUniqueMethod(\view, {
        lfo.set(\lfoSend, 1);
        buildView.();
    });

    lfo
};

(
    func: func,
    doc: "/Users/david/Documents/supercollider/media/wavetables_4096/4096.wav"
)
)