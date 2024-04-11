(
synth: {|in|

    var sig = in;

    var lowshelfFreq = \lowshelfFreq.kr(30, spec:InstrControlSpec(30, 4000, \exp, 0, 30, "eq", sort:0)).lag(0.1);
    var hishelfFreq = \hishelfFreq.kr(12000, spec:InstrControlSpec(4000, 16000, \lin, 0, 12000, "eq", sort:10)).lag(0.1);
            
    sig = BLowShelf.ar(sig, lowshelfFreq, rs:1, db:-40 );

    [60, 120, 250, 500, 1000, 2000, 4000, 8000].do({|hz, i|
        var key = "hz%".format(hz).asSymbol;
        sig = BPeakEQ.ar(sig, hz, db:key.kr(0, spec:InstrControlSpec(-45, 24, \lin, 0, 0, "eq", sort:(i+1))));
    });
    sig = BHiShelf.ar(sig, hishelfFreq, rs: 1, db:-40);

    sig = in.blend(sig, \eq_mix.kr(1, spec:InstrControlSpec(0, 1, \lin, 0, 1, units:"eq", sort:100)));
    sig;
}
)
