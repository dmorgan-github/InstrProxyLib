(
// adapted from: https://scsynth.org/t/using-a-signal-window-as-an-envelop/8901/2
var multiChannelTrigger = { |overlap, trig|
    overlap.collect{ |num|
        PulseDivider.ar(trig, overlap, num);
    };
};

var multiChannelPhase = { |triggers, windowRate|
    triggers.collect{ |localTrig, i|
        var hasTriggered = PulseCount.ar(localTrig) > 0;
        var localPhase = Sweep.ar(localTrig, windowRate * hasTriggered);
        localPhase * (localPhase < 1);
    };
};

var func = {|freq|

    var sig, env;
    var overlap = ~overlap ?? 5;
    var trig, trigs;
    var posphase, windowphase;
    var grainamp;

    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var numframes = BufFrames.kr(buf);
    var ratescale = BufRateScale.kr(buf);
    var pbstretch = \pbstretch.kr(50, spec:ControlSpec(1, 100, \lin, 0, 20, units:"grainr") );
    var trigrate = \grainrate.kr(20, spec:ControlSpec(0.125, 20, \lin, 0, 20, units:"grainr") );
    var prob = \prob.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"grainr"));
    var startPos = \startPos.kr(0) * numframes;
    var endPos = \endPos.kr(1) * numframes;
    var dur = (endPos - startPos)/BufSampleRate.kr(buf);

    var root = \rootfreq.kr(60.0.midicps,
        spec:ControlSpec(20, 20000, \exp, 0, 60.0.midicps, units:"grainr")
    ).clip(20, 20000);

    var pbrate =  freq/root;
    var polarity_mod, polarity_prob, polarity;

    overlap.debug("overlap");
    trig = Impulse.ar(trigrate);
    trigs = multiChannelTrigger.(overlap, trig);
    trigs = CoinGate.ar(prob, trigs);
    
    windowphase = multiChannelPhase.(trigs, trigrate/overlap);
    env = IEnvGen.ar(Env([0, 1, 0], [0.5, 0.5], \sin), windowphase);

    posphase = LFSaw.ar((dur * pbstretch).reciprocal, iphase: 1).linlin(-1, 1, startPos, endPos);// * numframes;
    posphase = (posphase * ( 1.01 ** LFNoise2.ar( {rrand(1.0, 2.0)}.dup(overlap) ) )).clip(startPos, endPos);
    sig = PlayBuf.ar(1, buf, pbrate * ratescale, trigs, posphase, loop: 1);

    // https://discord.com/channels/813532499262701678/813532541302210680/1207218776970366977
    polarity_mod = 1;
    polarity_prob = Drand([-1 + Diwhite(0, polarity_mod, inf), 1], inf) * -1;
    polarity_prob = (polarity_prob * 2 - 1);
    polarity = Demand.ar(trigs, 0, polarity_prob);

    grainamp = polarity;//( 1.01 ** LFNoise2.ar( {rrand(1.0, 2.0)}.dup(overlap) ) );
    sig = sig * env * grainamp;

    sig = Splay.ar(sig, 0.5) * 1/overlap;
    sig = HPF.ar(sig, \hpf.kr(60, spec: ControlSpec( 1, 90, \lin, 0, 60, units:"grainr" ) ));

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, posphase], replyid);

    sig;

};

(func: func)
)