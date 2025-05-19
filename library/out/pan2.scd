(
synth: {|in|
    var sig;
    sig = Pan2.ar(in,
        pos:\synth_pan.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "stereo"))
    );
    sig;
};
)
