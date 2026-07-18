(
var func = {

    Environment.make({|self|

        var ctrl, armed, obj;
        self.know = true;
        armed = false;

        self.obj = {|self| obj };
        self.obj_ = {|self, val| obj = val; self};

        ~quant = 4;
        ~ptrns = List();
        ~events = Order();

        ~ptrn = Pbind(
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
        );

        ~init = {|self|

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

            self.metro = Pdef(\metro, 
                Pbind(
                    \instrument, \metronome, 
                    \amp, -6.dbamp * [1, 0.5, 0.5, 0.5].pseq, 
                    \dur, 1, 
                    \octave, [7, 6, 6, 6].pseq, 
                    \out, 4
                )
            ).quant_(self.quant);

            "osc listening".debug("midirec");
            OSCdef('midirec', func:{|msg|
                var val = msg[1];
            
                if (val > 0) {
                    self.arm;
                    "arm".debug("midirec");
                }{
                    self.end;
                    "end".debug("midirec");
                }
            }, path: '/midirec');
        };

        ~setPtrn = {|self|

            var p = EventPatternProxy().source_(self.ptrn);
            var sustain = Order();
            var dict = Dictionary();
            var onsets = self.events.array.collect({|v, i| if ( (v.key == \on).or(v.key == \end)  ) {true} {false} });
            var midinote = self.events.array.select({|v| v.key == \on }).collect({|v| v.value[0] });
            self.durs = self.events.indices.select({|v, i| onsets[i] }).differentiate[1..];
            self.stretch = TempoClock.default.beatDur.reciprocal;

            self.events.do({|v, i, k|
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

            [midinote].debug("wtf");

            p.set(
                \midinotes, midinote,
                \durs, self.durs,
                \sustains, sustain.as(Array),
                \stretch, self.stretch
            );

            self.ptrns.add(p)
        };

        ~quantize = {|self, resolution=0.125|
            var durs = self.durs;
            var stretch = self.stretch;
            var vals = durs * stretch;
            vals = vals.round(resolution);
            if (self.ptrns.last.isNil) {
                "no pattern".warn;
            } {
                self.ptrns.last.set(\durs, vals, \stretch, 1);
            };
            self
        };

        ~arm = {|self|

            armed = true;
            self.events.clear;
            self.metro.play;

            ctrl = SimpleController(obj);

            ctrl.put(\noteOn, {|model, what, data|
                var ts = Date.getDate.rawSeconds.round(0.001);
                self.events.put(ts, \on -> data)
            });

            ctrl.put(\noteOff, {|model, what, data|
                var ts = Date.getDate.rawSeconds.round(0.001);
                self.events.put(ts, \off -> data )
            });

            self;

        };

        ~end = {|self|
            var ts = Date.getDate.rawSeconds.round(0.001);
            if (armed) {
                self.events.put(ts, \end -> 1 );
                armed = false;
                self.setPtrn();
            };
            ctrl.remove;
            self.metro.stop;
            self;
        };

        self.init();
    })
};

(func: func)
)