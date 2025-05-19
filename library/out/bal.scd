(
synth: {|in|
    var sig = in;
    sig = Splay.ar(sig);
    sig = Balance2.ar(
        left: sig[0],
        right: sig[1],
        pos: \synth_pan.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "stereo"))
    );
    sig;
};
)
