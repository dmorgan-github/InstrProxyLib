(
var func = {|key, obj|

    var model = Ref();
    var simpleController = SimpleController(model);
    var ctrl, armed, quant, events, ptrn;
    var arm, stopRecording, quantize, durs, stretch=1, metro, setPtrn, buildView;

    armed = false;
    quant = 4;
    events = Order();

    ptrn = Pdef("%_midirec".format(key).asSymbol, 
        Pbind(
            \phase, Pseries(),
            \dur, Pfunc({|evt|
                var phase = evt['phase'];
                var vals = evt['durs'] ?? [1];
                var val = vals.wrapAt(phase);
                val
            }),
            \sustain, Pfunc({|evt|
                var phase = evt['phase'];
                var vals = evt['sustains'] ?? [1];
                var val = vals.wrapAt(phase);
                val
            }),
            \midinote, Pfunc({|evt|
                var phase = evt['phase'];
                var vals = evt['midinotes'] ?? [0];
                var val = vals.wrapAt(phase);
                val
            }),
        )
    )
    .quant_(quant);

    arm = {
        armed = true;
        events.clear;
        metro.play;

        // listen for midi events
        ctrl = SimpleController(obj);
        ctrl.put(\noteOn, {|model, what, data|
            var ts = Date.getDate.rawSeconds.round(0.001);
            events.put(ts, \on -> data)
        });

        ctrl.put(\noteOff, {|model, what, data|
            var ts = Date.getDate.rawSeconds.round(0.001);
            events.put(ts, \off -> data )
        });
    };

    stopRecording = {
        var ts = Date.getDate.rawSeconds.round(0.001);
        if (armed) {
            events.put(ts, \end -> 1 );
            armed = false;
            setPtrn.();
        };
        ctrl.remove;
        metro.stop;
    };

    quantize = {|resolution=0.125|
        var vals = durs.debug("durs");// * stretch.debug("stretch");
        vals = vals.round(resolution.debug("resolution"));
        ptrn.set(\durs, vals);
    };

    setPtrn = {

        var sustain = Order();
        var dict = Dictionary();
        var onsets = events.array.collect({|v, i| if ( (v.key == \on).or(v.key == \end)  ) {true} {false} });
        var midinote = events.array.select({|v| v.key == \on }).collect({|v| v.value[0] });
        durs = events.indices.select({|v, i| onsets[i] }).differentiate[1..];
        stretch = TempoClock.default.beatDur.reciprocal;

        events.do({|v, i, k|
            if (v.key == \on) {
                var note = v.value[0];
                dict[note] = k -> i;
            } {
                if (v.key == \off) {
                    var note = v.value[0];
                    var kv = dict[note];
                    var sus = i - kv.value;
                    sustain.put(kv.key, sus);
                    dict.removeAt(note)
                }
            }
        });

        ptrn.set(
            \midinotes, midinote,
            \durs, durs,
            \sustains, sustain.as(Array),
            \stretch, stretch
        );
    };

    {
        "init metronome".debug("midirec");
        SynthDef(\metronome, {
            var freq = \freq.kr(440);
            var amp = \amp.kr(-6.dbamp);
            var dec = 0.02;
            var env = Env.perc(0.001, dec).kr(doneAction: 2); 
            var sig = SinOsc.ar(freq) * env * amp; 
            sig = Pan2.ar(sig, 0);
            Out.ar(\out.kr(0), sig);
        }).add;

        metro = Pdef(\metro, 
            Pbind(
                \instrument, \metronome, 
                \amp, -6.dbamp * [1, 0.5, 0.5, 0.5].pseq, 
                \dur, 1, 
                \octave, [7, 6, 6, 6].pseq, 
                \out, 4
            )
        ).quant_(quant);

        "osc listening".debug("midirec");
        OSCdef('midirec', func:{|msg|
            var val = msg[1];
        
            if (val > 0) {
                arm.();
                "arm".debug("midirec");
            }{
                stopRecording.();
                "end".debug("midirec");
            }
        }, path: '/midirec');
    }.();

    buildView = {

        var view = View(bounds:Rect(width:100, height:100)).layout_(VLayout());
        var uv = UserView(bounds:Rect(0, 0, 100, 100));
        var rect = Rect(0, 0, 75, 75);
        var colors = [Color.white, Color.red];
        var state = 0;
        var currentColor = colors[state];

        uv.background_(Color.clear)
        .drawFunc_({
            Pen.addOval(rect); 
            Pen.color = currentColor;
            Pen.draw;
        })
        .mouseDownAction = { |ctrl, x, y|
            state = 1 - state;
            model.changed(\rec, state);
            currentColor = colors.wrapAt(state);
            uv.refresh;
        };

        view.layout.add(uv);
        view.front
    };

    ptrn.addUniqueMethod('arm', {|self|
        model.changed(\rec, 1);
        self
    });

    ptrn.addUniqueMethod('stopRecording', {|self|
        model.changed(\rec, 0);
        self
    });

    ptrn.addUniqueMethod('quantize', {|self, resolution=0.125|
        quantize.(resolution);
        self
    });

    ptrn.addUniqueMethod('events', {|self|
        events
    });

    ptrn.addUniqueMethod('durs', {|self|
        durs
    });

    ptrn.addUniqueMethod(\view, {
        buildView.()
    });

    simpleController.put(\rec, {|obj, what, val|
        if (val == 1) {
            \rec.postln;
            arm.();
        }{
            \stop.postln;
            stopRecording.();
            quantize.(0.125);
        }
    });

    ptrn;
};

(func: func)
)