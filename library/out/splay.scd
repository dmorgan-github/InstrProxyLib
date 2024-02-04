(
synth: {|in|
    var sig = Splay.ar(in,
        spread:\synth_width.kr(1),
        center:\synth_pan.kr(0)
    );
    sig;
};
)
