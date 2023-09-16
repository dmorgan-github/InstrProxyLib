(
synth: {|freq, gate, aeg|

    var harm = \harm.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "plaits"));
    var timbre = \timbre.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "plaits"));
    var morph = \morph.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"));
    var engine = \engine.kr(0, spec:ControlSpec(0, 15, \lin, 1, 0, "plaits"));
    //var trigger = \trig.tr(1);
    var decay = \lpg_decay.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"));
    var fmmod = \fm_mod.kr(0, spec: ControlSpec(-1, 1, \lin, 0, 0, "plaits"));
    var timbremod = \timb_mod.kr(0, spec: ControlSpec(-1, 1, \lin, 0, 0, "plaits"));
    var morphmod = \morph_mod.kr(0, spec: ControlSpec(-1, 1, \lin, 0, 0, "plaits"));
    var lpg = \lpg.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"));
    var level = \level.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "plaits"));
    //var level = \level.kr(0.5);
    var slice = ~slice ?? [0, 1];

    var note = A2K.kr(freq).cpsmidi;
    var sig;

    sig = MiPlaits.ar(note,
        engine: engine,
        harm: harm,
        timbre: timbre,
        morph: morph,
        trigger: gate,
        level: level.squared,
        fm_mod: fmmod,
        timb_mod: timbremod,
        morph_mod: morphmod,
        decay: decay,
        lpg_colour: lpg
    );
    sig = sig.slice(slice.debug("slice"));
    sig.asArray.flatten;//.asArray.flatten.sum
},
doc:"
0:virtual_analog_engine
1:waveshaping_engine
2:fm_engine
3:grain_engine
4:additive_engine
5:wavetable_engine
6:chord_engine
7:speech_engine
8:swarm_engine
9:noise_engine
10:particle_engine
11:string_engine
12:modal_engine
13:bass_drum_engine
14:snare_drum_engine
15:hi_hat_engine
"
)


