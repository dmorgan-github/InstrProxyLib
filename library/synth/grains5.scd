(
var synth = {|freq|

    var sig;
    var numvoices = 5;
    var replyid = \bufposreplyid.kr(-1);
    var pan, grainamp, rate, detune, pos, durmod, phase;
    var trig = CoinGate.ar(\prob.kr(1) , Impulse.ar( \grainrate.ar(20) ));

    var graindur = \graindur.kr(0.1);//LFNoise2.ar( 1!numvoices ).range(0.01, 0.5);
    var buf = \buf.kr;
    var bufdur = BufDur.kr(buf);
    var samplerate = BufSampleRate.kr(buf);
    var scale = BufRateScale.kr(buf);
    var start = bufdur * \startPos.kr(0);
    var end = bufdur * \endPos.kr(1);
    var dur = (end - start) * \pbstretch.kr(16);
    var voicespread = \voicespread.kr(1);

    pos = LFTri.ar(
        dur.reciprocal * scale * 0.5,
        iphase: 3
    );
    // add some slight randomness to the position
    pos = pos + LFNoise2.ar( \jitterrate.kr(0.1).dup(numvoices) ).bipolar(\jitterdepth.kr(0.01));
    // spread the positions of the voices
    pos = pos + Latch.kr( { voicespread.sum3rand }.dup(numvoices), Changed.kr(voicespread) + Impulse.kr(0) );
    pos = pos.clip(-1, 1).range(start, end);

    pan = PinkNoise.ar(1).range(-1.0, 1.0);
    grainamp = LFNoise2.ar(0.1.dup(numvoices)).range(0.5, 0.6);// * [1, 2, 0, 0, 0];
    rate = \rate.kr(1);
    detune = LFNoise2.kr(0.25.dup(numvoices)).bipolar(0.15).midiratio;

    sig = TGrains.ar(
        numChannels: 2,
        trigger: trig,
        bufnum: buf,
        rate: rate * detune,
        centerPos: pos,
        dur: graindur,
        pan: pan,
        amp: grainamp,
        interp:4
    );
   
    SendReply.kr(Impulse.kr(15), '/bufpos', [pos, grainamp], replyid + [0, 1]);
    sig = Splay.ar(sig, spread: 1);
    sig
};

(synth: synth)
)