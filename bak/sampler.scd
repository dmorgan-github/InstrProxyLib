(
synth: {|freq, gate|

    var dur, dir, rate, sig;
    var replyid = \bufposreplyid.kr(-1);
    var loop = \loop.kr(0);
    var buf = \buf.kr(0, spec:ControlSpec(units:"buf"));
    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);
    var numchannels = ~numchannels ?? {1};
    var bufsamplerate = BufSampleRate.ir(buf);
    var bufratescale = BufRateScale.kr(buf);
    var numframes = max(BufFrames.kr(buf), 1);
    var startPos = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"sampler")).clip(0, 1);
    var endPos = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"sampler") ).clip(0, 1);
    var fadeTime = 0;//\fadeTime.kr(0.0);
    var xfadeTime = \xfadeTime.kr(0.0);
    var trigger, start, end;
    
    rate = (freq/root);
    dir = Select.kr(
        \rev.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"sampler")) > 0.5,
        [1, -1]
    );

    trigger = Changed.kr(startPos) + Changed.kr(endPos) + \trigger.tr(1);
    start = startPos * numframes;
    end = endPos * numframes;
    dur = (end - start) / bufsamplerate;

    // looping whole file with crossfade 
    dur = Select.kr( (endPos-startPos) < 1, [ dur-xfadeTime, dur ]);

    sig = XPlayBuf.ar(
        numchannels, 
        buf,
        rate: rate * dir, //automatically adjusted to bufratescale
        trigger: trigger,
        startPos: start.lag(0.01) / bufsamplerate,
        loopDur: dur.lag(0.01),
        loop: loop,
        fadeTime: fadeTime,
        xFadeTime: xfadeTime,
    );

    //SendReply.kr(Impulse.kr(updateFreq) * (replyid > 0), '/bufpos', [0, phase], replyid);

    sig;
}
)



