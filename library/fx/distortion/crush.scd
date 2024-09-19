/*


https://scsynth.org/t/real-bit-crushing-of-samples/9844/6?u=droptableuser

(
a = Bus.audio(s, 2);

SynthDef(\bitCrusher, { |out = 4, in, wet = 1, amp = 0.1, bits = 32,
    resampleRate = 22050, lag = 0, gate = 1|
    var sig, inSig = In.ar(in, 2);
    sig = inSig.round(2 ** (1 - bits)); // bit crushing
    sig = Latch.ar(sig, Impulse.ar(resampleRate)); // resampling
    // lagging smoothes
    sig = sig.lag(lag * 0.001);
    Out.ar(out, ((1 - wet) * inSig + (sig * wet)) * amp * EnvGate(gate: gate));
}).add;

)

// start before
y = Synth(\bitCrusher, [in: a, resampleRate: 24000]); // start with half nyquist on your system


SynthDescLib.global[\bitCrusher].makeGui

// start src second, added to head 
x = { Out.ar(a, SinOsc.ar(200 * [1, 1.01])) }.play;


// audible bit crushing
y.set(\bits, 3)

// resampling
y.set(\resampleRate, 2001)

y.set(\resampleRate, 399)

// lagging, more analogue sound
y.set(\lag, 0.5)

y.set(\wet, 0.3)

y.release(3)

x.free;



(
    a = Bus.audio(s, 2);
    
    SynthDef(\bitCrusher_2, { |out = 4, bits = 3, margin = 0.05, strength = 1.0,
        resampleRate = 22050, lag = 0, mix = 1, amp = 0.1|
    
        var sig, inSig = In.ar(a, 2), round, diff, resolution;
        resolution = 2 ** (1 - bits);
        round = inSig.round(resolution); // bit crushing
        // compare lang method 'softround'
        diff = round - inSig;
        sig = Select.ar(abs(diff) > margin, [inSig, inSig + (strength * diff) ]);
    
        sig = Latch.ar(sig, Impulse.ar(resampleRate)); 
        sig = sig.lag(lag * 0.001);
    
        ReplaceOut.ar(out, ((1 - mix) * inSig + (sig * mix)) * amp);
    }, metadata: (
        specs: (
            mix: [0, 1, \lin, 0, 1],
            amp: [0, 0.3, \lin, 0, 0.3],
            bits: [1, 8, \lin, 1, 3],
            margin: [0, 1, 3, 0, 0.05],
            strength: [0, 1, \lin, 0, 1],
            resampleRate: [20, 22050, \exp, 0, 22050],
            lag: [0, 50, 3, 0, 0]
        )
    )
    ).add;
)
    
// start GUI

SynthDescLib.global[\bitCrusher_2].makeGui

// start src
x = { Out.ar(a, SinOsc.ar(200 * [1, 1.01])) }.play

x.free;
*/

(
var func = {|in| 
    var crush = \crush.kr(16, spec:ControlSpec(1, 16, \lin, 0, 16, units: "crush"));
    var fx = in.round(0.5 ** (crush-1)); 
    in.blend(fx, \crush_mix.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"crush" ) )  )
};

(func: func)
)