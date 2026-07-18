(
synth: {|freq, gate|
    var pitch = 'E0'.namecps;
    var phaseatk = \pmatk.kr(0.01, spec: ControlSpec(0, 1, \lin, 0, 0.01, units:"kick"));
    var phaserel = \pmrel.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units:"kick"));
    var phaseamt = \pmamt.kr(20, spec: ControlSpec(0, 1000, \lin, 0, 20, units:"kick"));
    var pitchatk = \pitchatk.kr(0.001, spec: ControlSpec(0, 1, \lin, 0, 0.001, units:"kick"));
    var pitchrel = \pitchrel.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"kick"));
    var pitchmul = \pitchmod.kr(3, spec: ControlSpec(0, 20, \lin, 0, 3, units:"kick"));

    var phase = Env.perc(phaseatk, phaserel).ar(gate: gate) * phaseamt;
    var pitchmod = Env.perc(pitchatk, pitchrel).ar(gate: gate) * pitchmul;
    var sig = SinOsc.ar(pitch * pitchmod, phase.mod(2pi));
    sig
}
/*
phaseamt: 10.0 
phaseatk: 0.001 
phaserel: 0.5 
pitchatk: 0.001 
pitchrel: 0.02
pitchmod: 5
*/
)