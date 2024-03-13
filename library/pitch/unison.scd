(
synth: {
    var numvoices = ~numvoices ?? 2;
    var freq = \freq.ar(261).lag(\glis.kr(0));
    var detunehz = \detunehz.kr(0);
    var detunedepth = \detunedepth.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "pitch"));
    // 1000 * 2.pow({ (0.05/12).sum3rand } ! 2).sort
    var detune = LFNoise2.kr( {detunehz}.dup(numvoices.debug("numvoices")) ).bipolar(detunedepth).midiratio;
    //var detune = 2.pow({ (detunedepth/12).sum3rand } ! numvoices.debug("numvoices") );
    freq = freq * detune;
    freq = Vibrato.ar(freq, \vrate.ar(6), \vdepth.ar(0.0));
    freq
},
presets: [

    preset1: [
        detunehz: 0.25,
        detunedepth: 0.15
    ]

]
)


