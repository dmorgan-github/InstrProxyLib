(
var synth = {

    var rampToTrig = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        var sum = (phase + history);
        var trig = (delta / sum).abs > 0.5;
        Trig1.ar(trig, SampleDur.ir);
    };

    var rampToSlope = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        delta.wrap(-0.5, 0.5);
    };

    var multiChannelTrigger = { |numChannels, trig|
        numChannels.collect{ |chan|
            PulseDivider.ar(trig, numChannels, numChannels - 1 - chan);
        };
    };

    var getSubSampleOffset = { |phase, trig|
        var slope = rampToSlope.(phase);
        var sampleCount = phase - (slope < 0) / slope;
        Latch.ar(sampleCount, trig);
    };

    var accumulatorSubSample = { |trig, subSampleOffset|
        var accum = Duty.ar(SampleDur.ir, trig, Dseries(0, 1));
        accum + subSampleOffset;
    };

    var multiChannelAccumulator = { |triggers, subSampleOffsets|
        triggers.collect{ |localTrig, i|
            var hasTriggered = PulseCount.ar(localTrig) > 0;
            var localAccum = accumulatorSubSample.(localTrig, subSampleOffsets[i]);
            localAccum * hasTriggered;
        };
    };

    var multiChannelDemand = { |triggers, demandUgen, paramRange|
        var demand = demandUgen;
        triggers.collect{ |localTrig|
            Demand.ar(localTrig, 0, demand)
        }.linexp(0, 1, paramRange[0], paramRange[1]);
    };

    var channelMask = { |triggers, numChannels, channelMask, centerMask|
        var panChannels = Array.series(numChannels, -1 / numChannels, 2 / numChannels).wrap(-1.0, 1.0);
        var panPositions = panChannels.collect { |pos| Dser([pos], channelMask) };
        Demand.ar(triggers, 0, Dseq(panPositions ++ Dser([0], centerMask), inf));
    };

    var transferFunc = { |phase, skew|
        phase = phase.linlin(0, 1, skew.neg, 1 - skew);
        phase.bilin(0, skew.neg, 1 - skew, 1, 0, 0);
    };

    var unitGaussian = { |phase, index|
        var cosine = cos(phase * 0.5pi) * index;
        exp(cosine.neg * cosine);
    };

    var unitHanning = { |phase|
        1 - cos(phase * pi) / 2;
    };

    var gaussianWindow = { |phase, skew, index|
        var warpedPhase = transferFunc.(phase, skew);
        var gaussian = unitGaussian.(warpedPhase, index);
        var hanning = unitHanning.(warpedPhase);
        gaussian * hanning;
    };

    var getRandomPeriods = { |rate, randomness|
        var randomPeriod = Ddup(2, (2 ** (Dwhite(-1.0, 1.0) * randomness))) / rate;
        Duty.ar(randomPeriod, DC.ar(0), 1 / randomPeriod);
    };

    var rampToRandom = { |rate, randomness|
        var randomPeriod = getRandomPeriods.(rate, randomness);
        var trig = Changed.ar(randomPeriod) > 0;
        var phase = Duty.ar(SampleDur.ir, trig, Dseries(0, 1)) * (randomPeriod * SampleDur.ir);
        (phase - SampleDur.ir).wrap(0, 1);
    };

    var numChannels = 10;
    var sndBuf = \buf.kr(0);

    var stepTrigger, stepPhase, stepSlope, subSampleOffsets;
    var triggers, accumulator, overlaps, maxOverlaps, chanMask;
    var windowSlopes, windowPhases, grainWindows;
    var posRate, posRateMod, pos;
    var rate, rateMod, grainPhases;
    var sigs, sig;

    stepPhase = rampToRandom.(\tFreq.kr(8), \randomness.kr(1));
    stepTrigger = rampToTrig.(stepPhase);
    stepSlope = rampToSlope.(stepPhase);

    // distribute triggers round-robin across the channels
    triggers = multiChannelTrigger.(numChannels, stepTrigger);

    // calculate sub-sample offset per multichannel trigger
    subSampleOffsets = getSubSampleOffset.(stepPhase, triggers);

    // create a multichannel accumulator with sub-sample accuracy
    accumulator = multiChannelAccumulator.(triggers, subSampleOffsets);

    overlaps = multiChannelDemand.(triggers, Dwhite(0, 1), \overlapRange.kr([1, 1]));
    maxOverlaps = min(overlaps, numChannels);

    windowSlopes = Latch.ar(stepSlope, triggers) / max(0.001, maxOverlaps);
    windowPhases = (windowSlopes * accumulator).clip(0, 1);

    chanMask = channelMask.(triggers, numChannels - 1, \channelMask.kr(1), \centerMask.kr(1));

    grainWindows = gaussianWindow.(windowPhases, \skew.kr(0.5), \index.kr(0));

    posRateMod = SinOsc.ar(\posRateMF.kr(1));
    posRate = \posRate.kr(1) + (posRateMod * \posRateMD.kr(0));

    pos = Phasor.ar(
        trig: DC.ar(0),
        rate: posRate * BufRateScale.kr(sndBuf) * SampleDur.ir / BufDur.kr(sndBuf),
        start: \posLo.kr(0),
        end: \posHi.kr(1)
    );

    rateMod = SinOsc.ar(\rateMF.kr(1));
    rate = \rate.kr(1) + (rateMod * \rateMD.kr(0));

    grainPhases = (Latch.ar(rate, triggers) * accumulator) + Latch.ar(pos * BufFrames.kr(sndBuf), triggers);

    sigs = BufRd.ar(
        numChannels: 1,
        bufnum: sndBuf,
        phase: grainPhases,
        loop: 1,
        interpolation: 4
    );

    sigs = sigs * grainWindows;

    sigs = PanAz.ar(2, sigs, chanMask * \panMax.kr(0.8));
    sig = sigs.sum;

    //sig = sig * \amp.kr(-20).dbamp;
    //sig = sig * Env.asr(0.001, 1, 0.001).ar(Done.freeSelf, \gate.kr(1));
    //sig = LeakDC.ar(sig);
    sig;

};

(
    synth: synth,
    credits: "https://scsynth.org/t/sub-sample-accurate-granulation-with-random-periods/10346"
)

)