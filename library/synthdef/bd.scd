(
// https://sccode.org/1-5in
SynthDef.new(\bazedrum, {
    arg out = 0, outlevel=0.5, freq = 50, wet=0.5, q = 220, clicklevel =0, decaytrig = 0.1,
        decayfreq = 0.21, mulfreq =2 , decayamp = 1, dist = 17;

    var envtrig, envfreq, envamp, trigger,click, sig;

    envtrig = EnvGen.ar(Env.perc(1/10**5, decaytrig, 1, -9));
    envfreq = EnvGen.kr(Env.perc(0.003, decayfreq, mulfreq, -5));
    envamp = EnvGen.kr(Env.perc(0.003, decayamp,1, 2),doneAction:2);
    freq = freq * (1 + envfreq);
    trigger = envtrig*HPF.ar(PinkNoise.ar,40)+(envtrig*2);
    click = HPF.ar(envtrig*WhiteNoise.ar,2000*(1-envtrig),clicklevel);
    sig = BPF.ar(trigger, freq,1/q, sqrt(q)*5);
    sig = sig + click;

    sig = LeakDC.ar(sig* envamp,0.996);
    sig = Balance2.ar(sig, (sig*dist).tanh/3, (wet*2)-1);
    sig = Mix.ar(sig/2)*outlevel;

    out = 4;

    Out.ar(out, sig!2);
}).play;

)