
/*

https://scsynth.org/t/magnituderesponseview-filterkernels/5907

k = SOSKernel.new;
j = FOSKernel.new;
j.setFrequency(1000);
v = k.view;
v.kernels = [k, j];

s.boot;
b = Buffer.read(s, "/Users/david/Documents/supercollider/patches/20220527_2-6db.wav");

(
[1,2].do({ arg chns;
    SynthDef("soskernel-ctrl-"++chns.asString, { |inbus=2, outbus=0, bufnum, rate=1.0, t_trig=1, startPos=0, loop=1, amp=1.0, bypass=0|
        var coefs, coefsctl,fx,dry,z;
        coefs = 0!5;
        coefsctl = \coefs.kr(coefs);

        dry = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, t_trig, startPos, loop, Done.freeSelf);
        // dry = In.ar(inbus,chns);
        fx = SOS.ar(dry, *coefsctl);
        Out.ar(outbus, ((dry*bypass)+((1-bypass)*fx)) * amp);
    }).add;
});
)

k=SOSKernel.new;
k.coefs;
a=Synth("soskernel-ctrl-2", [\coefs, k.coefs, \bufnum, b.bufnum]);

a.trace;

a.set(\amp, 0.7);
a.set(\amp, 1);

v=k.view;
v.action={|view,kernel| a.set(\coefs, kernel.coefs, \bypass, 1 - kernel.enabled.binaryValue); };

(
v.action={|view,kernel,changed|
    //changed.postln;
    case
    { changed == \coefs or:{ changed == \filterKey } } {
        a.set(\coefs, kernel.coefs);
    }
    { changed == \bypass } {
        a.set(\bypass, 1 - kernel.enabled.binaryValue);
    };
};
)

s.dumpOSC(1);
s.dumpOSC(0);

k.filterClass_(BLowPass); a.set(\coefs, k.coefs);
k.setFrequency(2300.0); a.set(\coefs, k.coefs);
k.setFrequency(5200.0); a.set(\coefs, k.coefs);
k.setQ(0.7); a.set(\coefs, k.coefs);
k.setQ(2.5); a.set(\coefs, k.coefs);
k.setQ(1.2); a.set(\coefs, k.coefs);

k.selectFilterType(\BPeakEQ);
k.setFrequency(2300.0);
k.setGain(3.0);
a.set(\coefs, k.coefs);

k.setQ(0.7); a.set(\coefs, k.coefs);
k.setFrequency(5200.0); a.set(\coefs, k.coefs);
k.setGain(3.5); a.set(\coefs, k.coefs);
k.filterClass_(BHiShelf); a.set(\coefs, k.coefs);
k.setFrequency(1000.0); a.set(\coefs, k.coefs);
k.setGain(3.5); a.set(\coefs, k.coefs);
k.setQ(2.4); a.set(\coefs, k.coefs);
k.setQ(0.7); a.set(\coefs, k.coefs);

a.set(\bypass, 1);
a.set(\bypass, 0);
k.frequency_(1000.0);
k.q_(0.7);
k.gain_(0.0);
k.paramsChanged;
k.changed(\freq);
a.set(\coefs, k.coefs);
v.refresh

a.free;
b.free;
*/
/*
(
["",
    \BLowPass,
    \BHiPass,
    \BAllPass,
    \BBandPass,
    \BBandStop,
    \BPeakEQ,
    \BLowShelf,
    \BHiShelf,
    \LowBoost
].indexOf(\BPeakEQ)
)
*/

// https://bitbucket.org/blackrain-audio/magnituderesponseview/src/master/
(
func: {|node|

    var view, kernel, coefs, sosfiltertype, sosfreq, enabled;

    sosfiltertype = node.get(\sosFilterKey);
    view = View().layout_(VLayout().spacing_(0).margins_(0));
    kernel = SOSKernel.new(sampleRate:Server.default.sampleRate);
    kernel.filterClass_(BLowPass);
    kernel.enabled = true;

    coefs = node.get(\coefs);
    sosfreq = node.get(\sosfreq);
    enabled = node.get(\sos_mix) ?? 1;

    if (sosfiltertype.notNil) {
        kernel.selectFilterType(sosfiltertype);
    };

    if (sosfreq.notNil) {

        var sosgain = node.get(\sosgain);
        var sosq = node.get(\sosq);
        var a0 = coefs[0];
        var a1 = coefs[1];
        var a2 = coefs[2];
        var b1 = coefs[3];
        var b2 = coefs[4];

        if (sosfreq.notNil) {
            kernel.setFrequency(sosfreq);
        };

        if (sosgain.notNil){
            kernel.setGain(sosgain);
        };

        if (sosq.notNil){
            kernel.setQ(sosq);
        };

        if (enabled.notNil) {
            kernel.enabled = enabled.asBoolean;
        };

        kernel.setCoefs(a0, a1, a2, b1, b2);
    };

    kernel.view(view)
    .action_( {|view, kernel|
        node.set(
            \coefs, kernel.coefs,
            \sos_mix, kernel.enabled.binaryValue,
            \sosfreq, kernel.frequency,
            \sosgain, kernel.gain,
            \sosq, kernel.q,
            \sosFilterKey, kernel.filterKey
        );
    });

    view
    .minSize_(Size(420, 220))
    .onClose_({
        kernel.snapshot.debug("kernel.snapshot")
    })
    .name_(node.key)
    .front
};
)
