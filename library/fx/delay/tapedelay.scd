(
func: {|in|

    var buf;
    var fb;
    var phase;
    var speed, sig;
    var fx;
    var numFrames;
    var length = ~length ?? 8;

    numFrames = SampleRate.ir * length.debug("length");
    speed = \tapedelay_speed.kr(1, spec:ControlSpec(1/16, 16, \lin, 0, 1)).reciprocal;
    buf = LocalBuf(numFrames, 1).clear;
    phase = Phasor.ar(DC.ar(0.0), speed, 0.0, numFrames);
    fb = BufRd.ar(1, buf, phase: phase, loop: 1, interpolation: 4);
    fx = fb * \tapedelay_fb.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5)) + in.sum;
    IBufWr.ar(inputArray: fx, bufnum: buf, phase: phase, interp: 4);

    sig = in + fb;
    sig = Splay.ar(sig);
    sig

}
)
