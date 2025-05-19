(
synth: {
    var bend, freqbend, freq;
    var glis = \glide.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"pitch"));
    var in_freq = \freq.ar(261).lag(glis);
    var detune = \detunehz.kr(0,
        spec: ControlSpec(0, 10, \lin, 0, 0, units:"pitch")) * PinkNoise.ar(0.007).range(0.9, 1.1);

    //detune = detune * Select.kr( in_freq > 130, [0, 1] );
    detune = detune * in_freq.linlin(130, 261, 0, 1);
    bend = \bend.ar(0, spec: ControlSpec(-12, 12, \lin, 0, 0, units:"pitch")).midiratio;
    freqbend = in_freq * bend;
    freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune],
        \vrate.ar(6, spec: ControlSpec(0, 440, \lin, 0, 6, units:"pitch")),
        \vdepth.kr(0.0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"pitch")),
        delay: \vdelay.kr(0, spec: ControlSpec(0, 2, \lin, 0, 0, units:"pitch"))
    );
    freq
}
)