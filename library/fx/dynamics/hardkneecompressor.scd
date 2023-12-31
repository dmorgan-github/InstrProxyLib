

/*
(
    // https://nathan.ho.name/posts/negative-compression/
    var compGain;
    compGain = { |in, threshold, slope, attack = 0.05, release = 0.3|
        var inArray, amplitude;
        inArray = if(in.isArray) { in } { [in] };
        amplitude = (Amplitude.ar(inArray, attack, release).sum / inArray.size.sqrt).max(-100.dbamp).ampdb;
        ((amplitude - threshold).max(0) * (slope - 1)).lag(attack).dbamp;
    };
    
    {
        var snd;
        snd = SinOsc.ar(440) * Env.perc(0.01, 1.0).ar;
        snd = snd * compGain.(snd, threshold: -10, slope: -2, attack: 0.1, release: 0.3);
        (snd * -6.dbamp) ! 2;
    }.play(fadeTime: 0);
)
*/

// https://scsynth.org/t/multiband-compressor/3753/4
(
func: { |in|
    var sig;
    var attack = \comp_atk.kr(0.01, spec:ControlSpec(0.01, 1, \lin, 0, 0.01, "compress"));
    var release = \comp_rel.kr(0.1, spec:ControlSpec(0.01, 1, \lin, 0, 0.1, "compress"));
    var threshold = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, "compress"));
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, "compress"));
	var amplitudeDb, gainDb, gain;
	amplitudeDb = Amplitude.ar(in, attack, release).ampdb;
	gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
	sig = in * gainDb.dbamp;
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "compress")));
    sig;
};
)



