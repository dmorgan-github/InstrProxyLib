
(
synth: {|gate|
    var buf = \envbuf.kr(0);
    var ts = \envbufts.kr(1);
    var phase = Line.ar(0, BufFrames.kr(buf), ts);
    var env = BufRd.ar(1, buf, phase, 0, 4);
    FreeSelf.kr(Done.kr(phase));
    env;
},
props: (
    hasgate: false
)
)


