/*
(
//https://scsynth.org/t/demand-rate-tutorial/11363/14?u=droptableuser
var rampToSlope = { |phase|
    var history = Delay1.ar(phase);
    var delta = (phase - history);
    delta.wrap(-0.5, 0.5);
};

var rampToTrig = { |phase|
    var history = Delay1.ar(phase);
    var delta = (phase - history);
    var sum = (phase + history);
    var trig = (delta / sum).abs > 0.5;
    Trig1.ar(trig, SampleDur.ir);
};

var getSubSampleOffset = { |phase, slope, trig|
    var sampleCount = phase - (slope < 0) / slope;
    Latch.ar(sampleCount, trig);
};

var accumulatorSubSample = { |trig, subSampleOffset|
    var hasTriggered = PulseCount.ar(trig) > 0;
    var accum = Duty.ar(SampleDur.ir, trig, Dseries(0, 1)) * hasTriggered;
    accum + subSampleOffset;
};

var multiChannelTrigger = { |numChannels, trig|
    numChannels.collect{ |chan|
        PulseDivider.ar(trig, numChannels, numChannels - 1 - chan);
    };
};

var multiChannelAccumulator = { |triggers, subSampleOffsets|
    triggers.collect{ |localTrig, i|
        accumulatorSubSample.(localTrig, subSampleOffsets[i]);
    };
};

SynthDef(\paulStretch, { |sndBuf|

    var numChannels = 2;

    var fftSize, fftDuration, tFreq;
    var stepPhase, stepSlope, stepTrigger;
    var triggers, subSampleOffsets, accumulator;
    var overlap, maxOverlap;
    var windowSlopes, windowPhases;
    var posRate, pos;
    var rate, grainPhases, delayedPhases;
    var sigs, chain, sig;

    fftSize = 8192;
    fftDuration = fftSize * SampleDur.ir;
    tFreq = 1 / fftDuration * numChannels;

    stepPhase = Phasor.ar(DC.ar(0), tFreq * SampleDur.ir);
    stepSlope = rampToSlope.(stepPhase);
    stepTrigger = rampToTrig.(stepPhase);

    // distribute triggers round-robin across the channels
    triggers = multiChannelTrigger.(numChannels, stepTrigger);

    // calculate sub-sample offset per multichannel trigger
    subSampleOffsets = getSubSampleOffset.(stepPhase, stepSlope, triggers);

    // create a multichannel accumulator with sub-sample accuracy
    accumulator = multiChannelAccumulator.(triggers, subSampleOffsets);

    overlap = \overlap.kr(1);
    maxOverlap = min(overlap, numChannels);

    windowSlopes = Latch.ar(stepSlope, triggers) / max(0.001, maxOverlap);
    windowPhases = (windowSlopes * accumulator).clip(0, 1);

    posRate = \posRate.kr(1);
    pos = Phasor.ar(
        trig: DC.ar(0),
        rate: posRate * BufRateScale.kr(sndBuf) * SampleDur.ir / BufDur.kr(sndBuf),
        start: \posLo.kr(0),
        end: \posHi.kr(1)
    );

    rate = \rate.ar(1);
    grainPhases = Latch.ar(rate, triggers) * accumulator;
    grainPhases = grainPhases + Latch.ar(pos * BufFrames.kr(sndBuf), triggers);

    sigs = BufRd.ar(
        numChannels: 1,
        bufnum: sndBuf,
        phase: grainPhases,
        loop: 1,
        interpolation: 4
    );

    sigs = sigs.collect{ |localSig, i|
        chain = FFT(LocalBuf(fftSize), localSig, hop: 1.0, winsize: fftSize / 2);
        chain = PV_Diffuser(chain, 1 - triggers[i]);
        IFFT(chain);
    };
    
    sigs = PanAz.ar(2, sigs, \pan.kr(0));
    sig = sigs.sum;

    sig = sig * \amp.kr(-15).dbamp;

    sig = sig * Env.asr(0.001, 1, 0.001).ar(Done.freeSelf, \gate.kr(1));

    sig = LeakDC.ar(sig);
    sig = Limiter.ar(sig);
    Out.ar(\out.kr(0), sig);
}).add;
)

~sndBuf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
x = Synth(\paulStretch, [

    \sndBuf, ~sndBuf,

    \overlap, 2,

    \rate, 1,

    \posRate, 1 / 1,
    \posLo, 0,
    \posHi, 1,

    \amp, -15,
    \out, 4

]);
)

x.free

*/


(
// http://sccode.org/1-5d6
// Based on the Paul's Extreme Sound Stretch algorithm by Nasca Octavian PAUL
// https://github.com/paulnasca/paulstretch_python/blob/master/paulstretch_steps.png
//
// By Jean-Philippe Drecourt
// http://drecourt.com
// April 2020
// see comment: http://sccode.org/1-5d6#c1012
synth: {|freq|

    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var bufnum = \buf.kr(0);
    var start = \startPos.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "paulstretch"));
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "paulstretch"));
    var bufFrames = BufFrames.kr(bufnum);
    var bufdur = BufDur.kr(bufnum);

    var envBufnum = {
        if (~psenvbuf.isNil.debug("psenvbuf")) {
            var server = Server.default;
            var envBuf = Buffer.alloc(server, server.sampleRate, 1);
            var envSignal = Signal.newClear(server.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
            envBuf.loadCollection(envSignal);
            ~psenvbuf = envBuf;
        };
        ~psenvbuf;
    }.();

    //var pan = \pan.kr(0);
    var stretch = \stretchamt.kr(50, spec: ControlSpec(1, 100, \lin, 0, 50, "paulstretch"));
    var window = \window.kr(0.25);
    var amp = 1;

    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);

    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"paulstretch"));

    var rate = Select.kr(pitched, [
        1,
        (freq ?? root)/root
    ]).asArray[0];

    var trigPeriod, sig, chain, trig, pos, fftSize;

	// Calculating fft buffer size according to suggested window size
	fftSize = 2**floor(log2(window*SampleRate.ir));
	// Grain parameters
	// The grain is the exact length of the FFT window
	trigPeriod = fftSize/SampleRate.ir;
	trig = Impulse.ar(1/trigPeriod);
    pos = Demand.ar(trig, 0, demandUGens: Dseries(start, trigPeriod/(stretch*bufdur))).wrap(start, end);
	// Extraction of 2 consecutive grains
	// Both grains need to be treated together for superposition afterwards
	sig = [GrainBuf.ar(1, trig, trigPeriod, bufnum, rate, pos, envbufnum: envBufnum),
		GrainBuf.ar(1, trig, trigPeriod, bufnum, rate, pos + (trigPeriod/(2*stretch*bufdur)), envbufnum: envBufnum)] * amp;
	// FFT magic
	sig = sig.collect({ |item, i|
		chain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
		// PV_Diffuser is only active if its trigger is 1
		// And it needs to be reset for each grain to get the smooth envelope
		chain = PV_Diffuser(chain, 1 - trig);
		item = IFFT(chain, wintype: -1);
	});
	// Reapply the grain envelope because the FFT phase randomization removes it
	sig = sig*PlayBuf.ar(1, envBufnum, 1/(trigPeriod), loop:1);
	// Delay second grain by half a grain length for superposition
	sig[1] = DelayC.ar(sig[1], trigPeriod/2, trigPeriod/2);
	// Panned output
	//Out.ar(out, Pan2.ar(Mix.new(sig), pan));
    //Mix.new(sig)

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, pos * bufFrames], replyid);

    sig.sum!2
}
)