(
var func = {|freq|

	var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0, spec:ControlSpec(units:"buf"));
    var numchannels = ~numchannels ?? {1};

    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);
    var startPos = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"sampler")).clip(0, 1);
    var endPos = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"sampler") ).clip(0, 1);
    var index, on, dir, trigger, rate;
    var lag = \xfadeTime.kr(0.1);
    var n = 2; // alternative for safemode

    var phase, startFrame, endFrame;
    var numframes = BufFrames.kr(buf);
    var bufratescale = BufRateScale.kr(buf);
    var sawrate;

    var bufrd, cf, sig;

    rate = (freq/root)[0];
    dir = Select.kr(
        \rev.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"sampler")) > 0.5,
        [1, -1]
    );

    startFrame = startPos * numframes;
    endFrame = endPos * numframes;

    sawrate = rate * BufSampleRate.kr(buf) / absdif(startFrame, endFrame);
    phase = (LFSaw.ar(sawrate * dir, 1)).range(startFrame, endFrame);// * numframes;

    trigger = Select.ar(dir > 0, [  
        phase < (startFrame + 1),
        phase > (endFrame - 1)  
    ]) + Changed.kr(startFrame) + Changed.kr(endFrame) + Changed.kr(dir) + Impulse.kr(0);

    index = Stepper.ar( trigger, 0, 0, n-1 );
    on = n.collect({ |i|
        InRange.ar(index, i-0.5, i+0.5 );
    });
    
    //lag = 1/lag.asArray.wrapExtend(2);

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);

    /*
    on.collect({ |on, i| 
        BufRd.ar(numchannels, buf, phase, interpolation: 4)
            ( Slew.ar(on, lag[0], lag[1] ) * 0.5pi ).sin
    }).sum;
    */

    bufrd = BufRd.ar(numchannels, buf, phase, interpolation: 4);
    cf = Env.asr(lag, 1, lag, 0).ar(gate: [on[0], on[1]].poll );
    sig = cf.collect({|e| bufrd * e });
    sig.sum;


    //PlayBuf.ar(2, buf, rate, startPos: startFrame ).poll;
    //BufRd.ar(numchannels.debug("numchannels"), buf, phase, interpolation: 4)
};


(func: func)
)