(
var synth = {|freq|
    var sig;
    var kink = { |phase, skew|
        Select.ar(phase > skew, [
            0.5 * (phase / skew),
            0.5 * (1 + ((phase - skew) / (1 - skew)))
        ]);
    };
    
    var skew = \skew.kr(0.5);
    var phase = Phasor.ar(0, freq * SampleDur.ir);
    var warpedPhase = kink.(phase, skew);
    sig = SinOsc.ar(DC.ar(0), cos(warpedPhase * 2pi).neg );
    sig * 0.2
};
(
    synth: synth,
    credit: "https://scsynth.org/t/fm-synthesis-algorithms/11607/4"
)
)