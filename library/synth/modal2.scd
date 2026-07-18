(
synth: {|freq, gate, aeg|

    var sig, exciter;
    var strikeAtk, strikeDec, strikeCurve, exBlend, excBright;
    var bright, damp;
    var dispersion, position, thumpAmp, thumpDec;

    // ── Exciter (frame_drum-style) ─────────────────────────────────────────
    strikeAtk   = \strike_atk.kr  (0.001, spec: ControlSpec(0, 0.1, \lin, 0, 0.001, units:"modal2"));
    strikeDec   = \strike_dec.kr  (0.005, spec: ControlSpec(0, 0.5, \lin, 0, 0.005, units:"modal2"));
    strikeCurve = \strike_curve.kr(-4,    spec: ControlSpec(-8, 8, \lin, 0, -4,    units:"modal2"));
    exBlend     = \exblend.kr     (-0.5,  spec: ControlSpec(-1, 1, \lin, 0, -0.5,  units:"modal2"));
    excBright   = \excbright.kr   (0.7,   spec: ControlSpec(0, 1,  \lin, 0, 0.7,   units:"modal2"));

    // ── String params (live-modulatable) ───────────────────────────────────
    bright = \brightness.kr(0.6,  spec: ControlSpec(0, 1, \lin, 0, 0.6,  units:"modal2"));
    damp   = \damping.kr   (0.85, spec: ControlSpec(0, 1, \lin, 0, 0.85, units:"modal2"));

    // ── String params (build-time; override via ~tilde-vars) ───────────────
    dispersion = ~dispersion ?? 0.4;
    position   = ~position   ?? 0.25;
    thumpAmp   = ~thumpAmp   ?? 1.5;
    thumpDec   = ~thumpDec   ?? 2.0;

    // Strike: percussive impulse ↔ noise burst, LPF for hardness.
    exciter = EnvGen.ar(Env.perc(strikeAtk, strikeDec, 0.05, strikeCurve), gate);
    exciter = XFade2.ar(exciter, BrownNoise.ar(exciter), exBlend);
    exciter = LPF.ar(exciter, excBright.linexp(0, 1, 100, 16000));

    // Allow upstream override
    exciter = ~exciter ?? exciter;

    sig = StiffString.ar(
        exciter,
        freq,
        damping:    damp,
        brightness: bright,
        dispersion: dispersion,
        position:   position,
        thumpAmp:   thumpAmp,
        thumpDec:   thumpDec
    );

    sig = LeakDC.ar(sig.tanh) * 0.5;

    sig
},
credit: "StiffString inspired by Mutable Instruments Rings (Emilie Gillet)"
)
