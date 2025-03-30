(
synth: {

    var sig;
    var n = 2;
    var ft = 0.05;
    var updateFreq = 15;
    var numChannels = ~numchannels ?? 2;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var ratelag = \lag.kr(0.5);

    var rate = \rate.kr(1, spec:ControlSpec(0.125, 4, \lin, 0, 1, "xloopr")).lag(ratelag);
    var start = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"xloopr"));//.lag(0.01);///.poll(label:\startPos);
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"xloopr") ).max(start);//.lag(0.1);
    var wav = \wav.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"xloopr"));
    var numframes = BufFrames.kr(buf);

    var sawrate = rate * BufSampleRate.kr(buf) / (absdif(start, end) * numframes);
    var phase = Select.ar(wav, [ LFSaw.ar(sawrate, 1), VarSaw.ar(sawrate.abs * 0.5) ]);
    // does this really work?
    var trig = Trig1.ar(
        (1-(phase < Delay1.ar(phase)) +
        //( (phase < Delay1.ar(phase) ) +
        //( (phase > Delay1.ar(phase) ) * (rate.sign < 0) )
        ( Changed.ar(phase > Delay1.ar(phase) ) )
    ), ControlDur.ir);

    var index = Stepper.ar(trig, 0, 0, n-1);
    var gates = n.collect({|i|
        InRange.ar(index, i-0.5, i+0.5);
    });

    var lag = 1/ft.asArray.wrapExtend(2);
    var envs = Slew.ar(gates, lag[0], lag[1]).sqrt;
    phase = phase.range(start * numframes, end * numframes) * gates.poll;
    sig = BufRd.ar(numChannels, buf, phase, loop:0);
    sig = sig * envs;

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase.sum % numframes], replyid);
    sig.sum!2;
}
)


 
