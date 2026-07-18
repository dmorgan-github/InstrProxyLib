/*

(
var path = "/Users/david/Documents/supercollider/projects/orchard/lumirra/16 rings/scurve.wav";
var outFile;
var signal = Signal.newClear(0);
var vals;
var sigmoid = { |x, curve|
    var safeDenom = max(1 - curve, 0.0001);
    var k = 2 * curve / safeDenom;
    (1 + k) * x / (1 + (k * x.abs));
};

Array.interpolation(64, 0, 1).collect({|num|
    Array
    .interpolation(2048, -1, 1)
    .collect({|v| sigmoid.(v, num) });    
}).do({|v|
   signal = signal.addAll( v.as(Signal) )    
});

outFile = SoundFile(path)
.headerFormat_("WAV")
.sampleFormat_("float")
.numChannels_(1)
.sampleRate_(48000);

if(outFile.openWrite.notNil) {
    outFile.writeData(signal);
    outFile.close;
} {
    "Couldn't write output file".warn;
};

)
*/



(
var synth = {|in|

    var sig, divs = 64, node, temp;
    //var mix = \shaper_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "shaper"));
    var curve = \shaper_curve.kr(0.5, spec:ControlSpec(0, 1, -6, 0, 0.5, "shaper"));
    var logain = \shaper_logaindb.kr(-10, spec:ControlSpec(-60, 0, \lin, 0, -10, "shaper"));
    var higain = \shaper_higaindb.kr(-10, spec:ControlSpec(-60, 0, \lin, 0, -10, "shaper"));
    var hishelf = \shaper_hishelf.kr(6000, spec:ControlSpec(1000, 8000, \lin, 0, 6000, "shaper"));
    var loshelf = \shaper_loshelf.kr(80, spec:ControlSpec(20, 1000, \lin, 0, 80, "shaper"));
    var vol = \shaper_vol.kr(0, spec:ControlSpec(-20, 0, \lin, 0, 0, "shaper"));
    var buf = \shaper_buf.kr;
    
    var sigmoid = { |x, curve|
        var safeDenom = max(1 - curve, 0.0001);
        var k = 2 * curve / safeDenom;
        (1 + k) * x / (1 + (k * x.abs));
    };

    node = ~node;
    temp = Library.at('fx/distortion/shaper/buf');
    if (temp.isNil) {
        Buffer.read(Server.default, "/Users/david/Documents/supercollider/media/wavetables_4096/scurve.wav", action: {|b|
            node.set(\shaper_buf, b);
            Library.put('fx/distortion/shaper/buf', b);
        })
    } {
         node.set(\shaper_buf, temp);    
    };

    sig = in;
    sig = OscOS.ar(buf, sig.linlin(-1, 1, 0, 1), buf_divs: divs, buf_loc: curve, oversample: 1);
    //sig = sig.tanh;
    //sig = SoftClipAmp8.ar(sig);
    sig = SoftClipper8.ar(sig);
    sig = BLowShelf.ar(sig, loshelf, 1, logain);
    sig = BHiShelf.ar(sig, hishelf, 1, higain);
    //sig = LeakDC.ar(sig) * \shaper_postgain.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "shaper"));
    sig = LeakDC.ar(sig);// * (curve.linlin(0, 1, 1, 50).reciprocal.sqrt);
    //sig = in.blend(sig, mix) * vol.dbamp;
    sig * vol.dbamp
};

(synth: synth)
)
