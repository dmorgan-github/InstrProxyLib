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


/*
// amount must be >= -1 and < 1 !


(
https://scsynth.org/t/share-your-waveshapers/3185/2?u=droptableuser
f = { |x, amount = 0|
	var k = 2 * amount / (1 - amount);
	(1 + k) * x / (1 + (k * x.abs));
};

{ |x| f.(x, 0.5) }.plotGraph(500, -1, 1);
)


{ |x| f.(x, -0.9) }.plotGraph(500, -1, 1);

{ |x| f.(x, 0) }.plotGraph(500, -1, 1);

{ |x| f.(x, 0.9) }.plotGraph(500, -1, 1);


(
SynthDef(\flexShape, { |out = 0, in, mix = 1, amount = 0, amp = 1|
	var sig = In.ar(in, 2), k = 2 * amount / (1 - amount);
	sig = (1 + k) * sig / (1 + (k * sig.abs));
	XOut.ar(out, mix, sig * amp);
}).add;
)

// start silently
y = Synth(\flexShape);


// default amount = 0, no change
x = { SinOsc.ar(300 + [0, 0.1], 0, 0.2) }.play

y.set(\amount, 0.5, \amp, 0.3)

y.set(\amount, 0.9, \amp, 0.1)

x.release;
y.free
*/


(
var synth = {|in|

    //var mix = \shaper_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "shaper"));
    var curve = \shaper_curve.kr(0.5, spec:ControlSpec(0, 1, -6, 0, 0.5, "shaper"));
    var logain = \shaper_logaindb.kr(-10, spec:ControlSpec(-60, 0, \lin, 0, -10, "shaper"));
    var higain = \shaper_higaindb.kr(-10, spec:ControlSpec(-60, 0, \lin, 0, -10, "shaper"));
    var hishelf = \shaper_hishelf.kr(4000, spec:ControlSpec(1000, 8000, \lin, 0, 4000, "shaper"));
    var loshelf = \shaper_loshelf.kr(80, spec:ControlSpec(20, 1000, \lin, 0, 80, "shaper"));
    var vol = \shaper_vol.kr(0, spec:ControlSpec(-20, 0, \lin, 0, 0, "shaper"));
    
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
    //sig = LeakDC.ar(sig) * \shaper_postgain.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "shaper"));
    sig = LeakDC.ar(sig) * (curve.linlin(0, 1, 1, 50).reciprocal.sqrt);
    //sig = in.blend(sig, mix) * vol.dbamp;
    sig * vol.dbamp;
};

(synth: synth)
)


