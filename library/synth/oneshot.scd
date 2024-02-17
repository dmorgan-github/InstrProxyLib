(

/*
    SynthDef("sampPlay" ++ numch, { |bufnum, gate = 1, amp = 1, vol = 1, start = 0, out|
        var	phase = Line.ar(0, BufFrames.kr(bufnum), BufDur.kr(bufnum), doneAction: 2),
        sig = BufRd.ar(numch, bufnum, phase, loop: 0, interpolation: 4),
        // sig = PlayBuf.ar(numch, bufnum, BufRateScale.ir(bufnum), startPos: start,
        // loop: 0, doneAction: 2),
        eg = EnvGen.kr(Env.asr(0.01, amp, 0.02), gate, doneAction: 2);
        SendReply.ar(Impulse.ar(15), '/phase', phase);
        sig = sig * eg * vol;
        if(numch == 1) { sig = sig ! 2 };
        Out.ar(out, sig);
    }).add;
*/

synth: {|freq|

     var root = \rootfreq.kr(60.0.midicps,
        spec:ControlSpec(20, 20000, \exp, 0, 60.0.midicps, units:"oneshot")
    ).clip(20, 20000);
    var numchannels = ~numchannels ?? 1;
	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var start = \startPos.kr(0) * numframes;
    var dir = Select.kr(\rev.kr(0,
        spec: ControlSpec(0, 1, \lin, 1, 0, "oneshot") ) > 0.5, [1, -1]);

    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"oneshot"));
    var rate = Select.kr(pitched, [
        \rate.kr(1, spec:ControlSpec(0.125, 4, \lin, 0, 1, "oneshot")),
        freq/root
    ]);

    var sig = PlayBuf.ar(
        numchannels.debug("numchannels"),
        buf,
        BufRateScale.kr(buf) * rate * dir,
        1,
        start,
        loop:0,
        doneAction:Done.freeSelf
    );
    sig;
},
props: (
    freeself: true,
    hasgate: false
)
)
