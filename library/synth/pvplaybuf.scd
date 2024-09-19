(
var fftsize = 8192, hop = 0.25, win = 0;
var func = {
    var sig, chain, localbuf;
    var bufs = \buf.kr([0, 0]);
    localbuf = { LocalBuf.new(fftsize) } !2; 
    chain = PV_PlayBuf(localbuf, bufs.postln, \rate.kr(1, spec: ControlSpec(-4.0, 4.0, \lin, 0, 1)), loop: 1); 
    sig = IFFT(chain, win); 
    sig;
};
(synth: func)
)