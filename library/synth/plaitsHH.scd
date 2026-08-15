(
// Claude assisted extraction of hh from plaits dsp
var id = \plaitsHH;
var synth = {|freq, gate|
    DynGen.ar(1, id, params: [
        f0:       freq.asArray[0] / SampleRate.ir,   // -> _f0
        tone:      \timbre.kr(0.7, spec:ControlSpec(0, 1, \lin, 0, 0.7, units:"hh")),      // TIMBRE = brightness
        decay:     \morph.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, units:"hh")),       // MORPH = decay
        noisiness: \harmonics.kr(0.2, spec:ControlSpec(0, 1, \lin, 0, 0.2, units:"hh")),   // HARMONICS
        accent:    \accent.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"hh")),
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