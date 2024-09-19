(
synth: {|in|
    var thresh = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, units:"compressor"));
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, units:"compressor"));
    var atk = \comp_atk.kr(0.02, spec:ControlSpec(0.001, 0.1, \lin, 0, 0.02, units:"compressor"));
    var rel = \comp_rel.kr(0.1, spec:ControlSpec(0.01, 1, \lin, 0, 0.1, units:"compressor"));
    var knee = \comp_knee.kr(6, spec:ControlSpec(1, 20, \lin, 0, 6, "compressor"));
    var makeup = \comp_makeup.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, "compressor"));
    var sig;
    var replyid = \levelreplyid.kr(-1);
    //var control = max(abs(in[0]), abs(in[1]));
    //var sig = SoftKneeCompressor.ar(in, control, thresh, ratio.reciprocal, knee, atk, rel, makeUp:makeup);
    // input (also used as control)
    sig = SoftKneeCompressor.ar(in, thresh:thresh, ratio:ratio.reciprocal, knee:knee, attack:atk, release:rel, makeUp:makeup);
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"compressor")));
    SendReply.kr(Impulse.kr(10) * (replyid > 0), '/compresslevel', [Amplitude.kr(sig - in).lag(0, 1)], replyID: replyid); // Gain Reduction measurement
    sig;
},
view: 'compress'
)


/*
(
synth: {|in|
    var gain;
    var thresh = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, units:"compander")).dbamp;
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, units:"compander")).reciprocal;
    var atk = \comp_atk.kr(0.005, spec:ControlSpec(0.001, 0.1, \lin, 0, 0.01, units:"compander"));
    var rel = \comp_rel.kr(0.1, spec:ControlSpec(0.1, 1, \lin, 0, 0.1, units:"compander"));
    var sig = Compander.ar(in, in, thresh, 1, ratio, atk, rel);
    //gain = 1/(((1.0-thresh) * ratio) + thresh); // make up
    //sig = sig * gain;
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"compander")));
    sig;
}
)

// https://scsynth.org/t/multiband-compressor/3753/4
(
func: { |in|
    var sig;
    var attack = \comp_atk.kr(0.01, spec:ControlSpec(0.01, 1, \lin, 0, 0.01, "compress"));
    var release = \comp_rel.kr(0.1, spec:ControlSpec(0.01, 1, \lin, 0, 0.1, "compress"));
    var threshold = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, "compress"));
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, "compress"));
    var amplitudeDb, gainDb, gain;
    amplitudeDb = Amplitude.ar(in, attack, release).ampdb;
    gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
    sig = in * gainDb.dbamp;
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "compress")));
    sig;
};
)

*/