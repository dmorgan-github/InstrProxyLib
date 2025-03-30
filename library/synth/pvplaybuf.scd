(
var fftsize = 8192, hop = 0.25, win = 0;
var func = {|freq|

    var rate, offset;
    var sig, chain, localbuf;
    var bufs = \buf.kr([0, 0]);

    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);

    rate = \rate.kr(1, spec: ControlSpec(-4.0, 4.0, \lin, 0, 1));
    offset = \offset.kr(0);
    //freq.poll/root;

    localbuf = { LocalBuf.new(fftsize) } !2; 
    chain = PV_PlayBuf(localbuf, bufs.postln, rate:rate, offset:offset, loop: 1); 
    sig = IFFT(chain, win); 
    sig;
};
(synth: func)
)