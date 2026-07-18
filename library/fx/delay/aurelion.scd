(
synth: { |in|

    var sig = in;
    var time, feedback, lfofreq, lfodepth, lfoshape, lfophase;
    var bpfreq, bpbw;
    var lfoHz, lfoDepthPct, bpHz, bpBwOct, fbAmt;
    var lfo, dtime, ratioR;

    // ── Parameters (all 0..1) ──────────────────────────────────────────────
    time     = \delay_time.kr    (0.4, spec: ControlSpec(0.001, 10, \exp, 0, 0.4, "delay"));
    ratioR    = \delay_ratioR.kr   (1.0, spec: ControlSpec(1, 2, \lin, 0, 1, "delay"));
    feedback = \delay_feedback.kr(0.4790, spec: ControlSpec(0, 1, \lin, 0, 0.4790, "delay"));
    lfofreq  = \delay_lfofreq.kr (0, spec: ControlSpec(0, 1, \lin, 0, 0, "delay"));
    lfodepth = \delay_lfodepth.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "delay"));
    lfoshape = \delay_lfoshape.kr(0.0000, spec: ControlSpec(0, 1, \lin, 0, 0.0000, "delay"));
    lfophase = \delay_lfophase.kr(0.2233, spec: ControlSpec(0, 1, \lin, 0, 0.2233, "delay"));
    bpfreq   = \delay_bpfreq.kr  (0.5000, spec: ControlSpec(0, 1, \lin, 0, 0.5000, "delay"));
    bpbw     = \delay_bpbw.kr    (1.0000, spec: ControlSpec(0, 1, \lin, 0, 1.0000, "delay"));

    // ── Remap 0..1 → DSP ranges ────────────────────────────────────────────
    fbAmt        = feedback.linlin(0, 1, 0, 2);          // 0 .. 200%
    lfoHz        = lfofreq.linexp(0, 1, 0.01, 10);       // 0.01 .. 10 Hz
    lfoDepthPct  = lfodepth;                              // 0..1 fraction of time
    bpHz         = bpfreq.linexp(0, 1, 20, 20000);       // 20 Hz .. 20 kHz centre
    bpBwOct      = bpbw.linexp(0, 1, 0.1, 6);            // 0.1 .. 6 octaves wide

    // ── LFO ────────────────────────────────────────────────────────────────
    lfo = LFO.kr(lfoHz, lfoshape, lfophase);

    // ── Delay time, smoothed and modulated ─────────────────────────────────
    dtime       = time.varlag(0.2, warp: \sin);
    lfoDepthPct = lfoDepthPct.lag(0.2);
    dtime       = dtime * (1 + (lfo * lfoDepthPct));
    dtime       = dtime.clip(0.0001, 20.0);

    // ── Feedback delay: DC block + soft saturation + bandpass in the loop ─
    sig = FbC({ |fb|
        var fx = (fb * fbAmt) + in;
        fx = LeakDC.ar(fx);
        fx = fx.tanh;                               // soft saturation
        fx = BBandPass.ar(fx, bpHz, bpBwOct);       // band-pass colours each repeat
        fx
    }, 22.0, dtime * [1, ratioR]);

    Splay.ar(sig, \delay_width.kr(1) );
},
presets: ()
)
