(
var synth = {|freq|

    var sig = [-12, -5, 0, 12, 19, 24, 28, 31, 36].collect({|v, i|
        Squine.ar(freq * v.midiratio, skew: 0.3, initphase: 1)
    });

    var amps = [-2, -12.9, -9.1, -15.3, -24.9, -18.7, -26.4, -28.9, -36.9].dbamp;
    var keys = ['sub', 'fifth', 'fund', 'oct1', 'oct1_5th', 'oct2', 'oct2_M3', 'oct2_5th', 'oct3' ];

    amps = keys.collect({|v, i|
        var amt = amps[i];
        NamedControl.kr(v, amt, spec: InstrControlSpec(0, 1, \lin, 0, amt, sort: i))
    });

    sig = sig * amps.normalizeSum;
    Splay.ar(sig, spread: 0.5);
    
};

(synth: synth)
)