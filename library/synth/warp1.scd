(
var synth = {|freq| 
    
    var sig;
    var numchannels = ~numchannels ?? 2;
    var root, start = 0, end = 1;
    var pbstretch = \pbstretch.kr(1);
    var phase, rate, sawrate;
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0, spec:ControlSpec(units:"buf"));
    var numframes = max(BufFrames.kr(buf), 1);
    var winsize = \winsize.kr(0.5);
    var overlaps = \overlaps.kr(8);
    var winrandratio = \winrandratio.kr(0.1);

    start = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"sampler"));
    end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"sampler") );

    root = \rootfreq.kr(60.0.midicps).clip(20, 20000);

    rate = freq/root;
    sawrate = pbstretch.reciprocal * BufSampleRate.kr(buf) / (absdif(start, end) * numframes);
    phase = (LFSaw.ar(sawrate, 1)).range(start, end);

    SendReply.kr(Impulse.kr(updateFreq) * (replyid > 0), '/bufpos', [0, phase * numframes], replyid);

    sig = Warp1.ar(
        numChannels: numchannels.debug("warp1: numchannels"),
        bufnum: buf,
        pointer: phase,
        freqScale: rate,
        windowSize: winsize,
        overlaps: overlaps,
        windowRandRatio: winrandratio,
        interp: 4
    );

    sig;
};
(synth: synth)
)