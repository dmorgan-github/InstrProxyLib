// Inharmonic string via DynGen. Requires:
//   1) DynGen extension installed
//   2) `InharmonicString.send(s)` evaluated once after server boot,
//      before this synth is built/played.

(
synth: {|freq, gate, aeg|

    var sig, exciter;
    var strikeAtk, strikeDec, strikeCurve, exBlend, excBright;
    var damping, brightness, structure, position;

    // ── Exciter (frame_drum-style strike) ──────────────────────────────────
    strikeAtk   = \strike_atk.kr  (0.001, spec: ControlSpec(0, 0.1, \lin, 0, 0.001, units:"inh"));
    strikeDec   = \strike_dec.kr  (0.005, spec: ControlSpec(0, 0.5, \lin, 0, 0.005, units:"inh"));
    strikeCurve = \strike_curve.kr(-4,    spec: ControlSpec(-8, 8, \lin, 0, -4,    units:"inh"));
    exBlend     = \exblend.kr     (-0.5,  spec: ControlSpec(-1, 1, \lin, 0, -0.5,  units:"inh"));
    excBright   = \excbright.kr   (0.7,   spec: ControlSpec(0, 1, \lin, 0, 0.7,    units:"inh"));

    // ── String params (all live-modulatable through DynGen) ────────────────
    damping    = \damping.kr   (0.7,  spec: ControlSpec(0, 1, \lin, 0, 0.7,  units:"inh"));
    brightness = \brightness.kr(0.6,  spec: ControlSpec(0, 1, \lin, 0, 0.6,  units:"inh"));
    structure  = \structure.kr (0.6,  spec: ControlSpec(0, 1, \lin, 0, 0.6,  units:"inh"));
    position   = \position.kr  (0.25, spec: ControlSpec(0, 1, \lin, 0, 0.25, units:"inh"));

    exciter = EnvGen.ar(Env.perc(strikeAtk, strikeDec, 1.0, strikeCurve), gate);
    exciter = XFade2.ar(exciter, BrownNoise.ar(exciter), exBlend);
    exciter = LPF.ar(exciter, excBright.linexp(0, 1, 100, 16000));

    exciter = ~exciter ?? exciter;

    //exciter = Impulse.ar(1);

    sig = InharmonicString.ar(
        in:         exciter,
        freq:       freq,
        damping:    damping,
        brightness: brightness,
        structure:  structure,
        position:   position
    );

    sig = LeakDC.ar(sig);

    sig
},
credit: "InharmonicString via DynGen, after Mutable Instruments Rings string.cc (Emilie Gillet)"
)
