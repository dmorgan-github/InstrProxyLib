/////////////////////////////////////////////////////////////////////
// buffer slicer
// numslices, numbeats
Spec.add(\numslices, ControlSpec(1, 256, \lin, 1, 8));
Spec.add(\numbeats, ControlSpec(1, 64, \lin, 1, 4));
(
func: {

    Pbind(
        \legato, Pfunc({|evt|
            var val = evt.use({ ~legato.value });
            if (val.notNil) {
                val
            } {
                1
            }
        }),
        \atk, Pfunc({|evt|
            var atk = evt.use({ ~atk.value });
            if (atk.isNil) {
                atk = 0.01;
            };
            atk
        }),
        \rel, Pfunc({|evt|
            var rel = evt.use({ ~rel.value });
            if (rel.isNil) {
                rel = 0.01;
            };
            rel;
        }),
        \suslevel, 1,
        \buf, Pfunc({|evt|
            var buf = evt.use({ ~buf.value });
            if (buf.isNumber) {
                buf = Buffer.cachedBufferAt(Server.default, buf.asInteger);
            };
            buf
        }),
        \numslices, Pfunc({|evt|
            var numslices = evt.use({ ~numslices.value });
            if (numslices.isNil) {
                numslices = 8;
            };
            numslices
        }),
        \numbeats, Pfunc({|evt|
            var numbeats = evt.use({ ~numbeats.value });
            if (numbeats.isNil) {
                numbeats = 2;
            };
            numbeats;
        }),
        \start, Pfunc({|evt|
            var start = evt.use({ ~startPos.value });
            if (start.isNil) {
                start = 0;
            };
            start;
        }),
        \end, Pfunc({|evt|
            var end = evt.use({ ~endPos });
            if (end.isNil) {
                end = 1;
            };
            end;
        }),
        \bufdur, Pfunc({|evt|
            var bufdur = evt.use({ ~bufdur.value });
            if (bufdur.isNil) {
                var buf = evt[\buf];
                var start = evt[\start] * buf.numFrames;
                var end = evt[\end] * buf.numFrames;
                var frames = end - start;
                bufdur = frames/buf.sampleRate;
            };
            bufdur;
        }),
        \rate, Pfunc({|evt|
            var rate = evt.use({ ~speed.value });
            if (rate.isNil) {
                var buf = evt['buf'];
                var bufdur = evt['bufdur'];
                var dur = evt['numbeats'] * thisThread.clock.beatDur;
                rate = (bufdur/dur);
                rate;// = rate * thisThread.clock.beatDur;
            };
            rate;
        }),
        \slices, Pfunc({|evt|
            var slices = evt.use({ ~slices.value });
            if (slices.isNil) {
                var numslices = evt.use({ ~numslices.value });
                slices = (0..numslices-1)/numslices;
            };
            slices;
        }),
        \dur, Pfunc({|evt|
            var numslices = evt.use({ ~numslices });
            var numbeats = evt.use({ ~numbeats });
            numbeats/numslices;
        }),
        \sustain, Pfunc({|evt|
            var sustain = evt.use({ ~sustain.value });
            var legato = evt.use({ ~legato.value }) ?? 1;
            var dur = evt['dur'];
            var val;
            if (sustain.notNil) {
                val = sustain
            } {
                val = dur * thisThread.clock.beatDur * legato
            }
        }),
        \startPos, Plazy({|evt|
            var val = evt.use({ ~slices.value });
            var start = evt.use({ ~start.value });
            var end = evt.use({ ~end.value });
            //var filter = evt[\slicesfilter];
            //if (filter.notNil) {
            //    val = filter.(val);
            //};
            Pseq(val, 1).linlin(0, 1, start, end);
        }),
        \loopprob, Pfunc({|evt|
            var val = evt.use({ ~loopprob.value });
            if (val.isNil) {
                val = 0
            };
            val
        }),
        \endPos, Pfunc({|evt|
            var bufdur = evt.use({ ~bufdur.value });
            var slicedur = evt[\dur];
            var loopprob = evt.use({ ~loopprob.value }) ?? 0;
            var loopdurs = evt.use({ ~loopdurs.value });
            var result;

            if (loopdurs.isNil) {
                loopdurs = [1/2, 1/4, 1/8];
            } {
                loopdurs = loopdurs.asArray;
            };

            result = loopprob.asArray.collect({|val|
                if (val.coin) {
                    var val = evt[\startPos] + ((slicedur * loopdurs.choose)/bufdur);
                    val
                }{
                    1;
                    //evt[\startPos] + (slicedur/bufdur)
                }
            });
            result//.debug("result");
        })
    )
};
)

