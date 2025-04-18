(
var superSaw = { |freq, mix, detune|
    var detuneCurve = { |x|
        (10028.7312891634 * x.pow(11)) -
        (50818.8652045924 * x.pow(10)) +
        (111363.4808729368 * x.pow(9)) -
        (138150.6761080548 * x.pow(8)) +
        (106649.6679158292 * x.pow(7)) -
        (53046.9642751875 * x.pow(6)) +
        (17019.9518580080 * x.pow(5)) -
        (3425.0836591318 * x.pow(4)) +
        (404.2703938388 * x.pow(3)) -
        (24.1878824391 * x.pow(2)) +
        (0.6717417634 * x) +
        0.0030115596
    };
    var centerGain = { |x| (-0.55366 * x) + 0.99785 };
    var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };
    var center = SawOS.ar(freq, oversample: 2);
    var freqs = [
        (freq - (freq * (detuneCurve.(detune)) * 0.11002313)),
        (freq - (freq * (detuneCurve.(detune)) * 0.06288439)),
        (freq - (freq * (detuneCurve.(detune)) * 0.01952356)),
        (freq + (freq * (detuneCurve.(detune)) * 0.01991221)),
        (freq + (freq * (detuneCurve.(detune)) * 0.06216538)),
        (freq + (freq * (detuneCurve.(detune)) * 0.10745242))
    ];
    var side = freqs.collect{ |freq| SawDPW.ar(freq, Rand(-1, 1)) }.sum;
    var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));
    HPF.ar(sig, freq);
};

var func = {|freq|
    var sig;
    sig = superSaw.(freq, \mix.kr(0), \dtune.kr(0));
    sig;
};

(
    synth: func,
    credits: "https://scsynth.org/t/array-size-as-argument-within-synthdef/11443/2"
)

)