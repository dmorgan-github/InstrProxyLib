(
var synth = {|in|
    
    var signal, cutoff, width, lpfCutoff, hpfCutoff,
    lpfPoles, lpfCoef, hpfPoles, hpfCoef, ampPow, ampMul, amp;
    
    //cutoff = MouseX.kr(0, 1);
    //width = MouseY.kr(0, 0.5);

    cutoff = \cutoff.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "djfilter"));
    width = \width.kr(0.25, spec: ControlSpec(0, 0.5, \lin, 0, 0.5, "djfilter"));

    lpfCutoff = cutoff.linexp(0, 1 - width, 40, 20000);
    hpfCutoff = cutoff.linexp(0 + width, 1, 20, 10000);
    
    signal = in;//WhiteNoise.ar([1, 1]);
    
    // LPF
    lpfCoef = exp(-2pi * lpfCutoff * SampleDur.ir);
    lpfPoles = 3;
    lpfPoles.do{
        signal = OnePole.ar(signal, lpfCoef);
    };
    
    // HPF
    hpfCoef = exp(-2pi * hpfCutoff * SampleDur.ir);
    hpfPoles = 7;
    hpfPoles.do{
        signal = signal - OnePole.ar(signal, hpfCoef);
    };
    
    // Amplitude Compensation:
    ampPow = (cutoff * 2).fold(0, 1);
    ampMul = cutoff.fold(0, 0.7).linlin(0, 0.7, 6, -6).dbamp;
    amp = width.linlin(0, 0.5, 15, -15).dbamp.pow(ampPow) * ampMul;
    signal = signal * amp;

    in.blend(signal, \djfilter_mix.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "djfilter") )  )

};

(
    synth: synth,
    credit: "https://discord.com/channels/813532499262701678/813532541302210680/1359750650656723136"
)
)