(
// Claude assisted extraction of bd from plaits dsp
var id = \plaitsBD;
var synth = {|freq, gate|
    var h = \harmonics.kr(0.3);
    DynGen.ar(1, id, params: [
        f0:       freq.asArray[0] / SampleRate.ir,   // -> _f0
        tone:     \timbre.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"bd") ),                // -> _tone
        decay:    \morph.kr(0.6, spec:ControlSpec(0, 1, \lin, 0, 0.6, units:"bd") ),                 // -> _decay
        accent:   \accent.kr(0.9, spec:ControlSpec(0, 1, \lin, 0, 0.9, units:"bd") ),
        attackFM: min(h*4, 1),
        selfFM:   (h*4-1).clip(0,1),
        trig:     gate,
    ])!2
};

(synth: {
    var path, def;
    "compiling...".debug(id);
    path = Module.libraryDir ++ "eel/%.eel".format(id);
    def = DynGenDef(id);
    def.load(path);
    def.send;
    synth
}.()
)
)