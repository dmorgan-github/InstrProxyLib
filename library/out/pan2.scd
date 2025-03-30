(
synth: {|in|

    var sig;
    if (~synth_channels.debug("out/pan2/synth_channels") == 1) {
        in = in.asArray.sum;
    };

    sig = Pan2.ar(in,
        pos:\synth_pan.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "stereo"))
    );

    sig;

};
)
