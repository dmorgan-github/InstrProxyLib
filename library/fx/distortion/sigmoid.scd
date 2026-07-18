(
synth: {|in|

    var sig, drive, mix;

    drive = \sigmoid_drive.kr(0.0, spec: ControlSpec(0, 1, \lin, 0, 0.0, units:"sigmoid"))
        .linexp(0, 1, 1, 100);

    mix = \sigmoid_mix.kr(1.0, spec: ControlSpec(0, 1, \lin, 0, 1.0, units:"sigmoid"));

    // Sigmoid shaper: tanh produces a smooth symmetric saturation.
    // Output compensation by 1/√drive keeps perceived level roughly constant
    // as drive sweeps.
    sig = (in * drive).tanh;
    sig = LeakDC.ar(sig) * drive.sqrt.reciprocal;
    sig = XFade2.ar(in, sig, mix * 2 - 1);

    sig
}
)
