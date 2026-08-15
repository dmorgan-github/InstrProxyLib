(
// Claude assisted extraction of sd from plaits dsp
var id = \plaitsSD;
var synth = {|freq, gate|
    DynGen.ar(1, id, params: [
        f0:       freq.asArray[0] / SampleRate.ir,   // -> _f0
        tone:      \timbre.kr(0.9, spec:ControlSpec(0, 1, \lin, 0, 0.9, units:"sd")),      // TIMBRE = brightness
        decay:     \morph.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, units:"sd")),       // MORPH = decay
        snappy:    \harmonics.kr(0.8, spec:ControlSpec(0, 1, \lin, 0, 0.8, units:"sd")),   // HARMONICS
        accent:    \accent.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"sd")),
        trig:      gate
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