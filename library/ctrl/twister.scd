(
var ctrl = Environment.make({|self|

    var midi;
    self.know = true;

    midi = Module('ctrl/midi').();
    midi
    .onAction('cc', {|num, val, chan|
        if (num < 8) {
            var track = T.tracks[num+1];
            if (track.notNil) {
                val = val.linlin(0, 127, -60, 2).dbamp;
                track.set(\vol, val)
            };
        };
    })
    .connect("twister", nil, {|ctrl|
        var chan = 0;
        ctrl.cc(chan, (0..15));
        (0..15).do({|i|
            var val = 1;
            var track = T.tracks[i+1];
            if (track.notNil) {
                val = track.get(\vol) ?? 1;
                val = val.linlin(-60.dbamp, 2.dbamp, 0, 127);
                ctrl.out.control(chan, i, val);     
            }
        })
        
    });

    self.disconnect = {|self|
        midi.disconnect();
    }
});

( func: { ctrl } )
)



