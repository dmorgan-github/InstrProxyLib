/*
Array.interpolation(512, -1, 1).collect({|v| 

    var sigmoid = { |x, curve|
        var safeDenom = max(1 - curve, 0.0001);
        var k = 2 * curve / safeDenom;
        (1 + k) * x / (1 + (k * x.abs));
    };

    sigmoid.(v, 0.9)

}).plot
*/
(
var synth = {|in|

    var mix = \shaper_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "shaper"));
    var curve = \shaper_curve.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "shaper"));
    var logain = \shaper_logaindb.kr(-10, spec:ControlSpec(-60, 0, \lin, 0, -10, "shaper"));
    var higain = \shaper_higaindb.kr(-10, spec:ControlSpec(-60, 0, \lin, 0, -10, "shaper"));
    var hishelf = \shaper_hishelf.kr(4000, spec:ControlSpec(1000, 8000, \lin, 4000, "shaper"));
    var loshelf = \shaper_loshelf.kr(80, spec:ControlSpec(20, 1000, \lin, 80, "shaper"));
    
    var sigmoid = { |x, curve|
        var safeDenom = max(1 - curve, 0.0001);
        var k = 2 * curve / safeDenom;
        (1 + k) * x / (1 + (k * x.abs));
    };

    var sig = in;
    sig = sigmoid.(sig, curve);
    //sig = sig.tanh;
    //sig = SoftClipAmp8.ar(sig);
    sig = SoftClipper8.ar(sig);
    sig = BLowShelf.ar(sig, loshelf, 1, logain);
    sig = BHiShelf.ar(sig, hishelf, 1, higain);
    sig = LeakDC.ar(sig) * \shaper_postgain.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "shaper"));
    sig = in.blend(sig, mix);
    sig;
};

(synth: synth)
)