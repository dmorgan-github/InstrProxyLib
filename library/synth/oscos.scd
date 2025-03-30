(
synth: {|freq, gate|
var sig, pos, phase, posdepth, posrate;
var buf = \buf.kr(0);
var samplesize = \samplesize.kr(2048);
var numframes = BufFrames.kr(buf);
var divs = numframes/samplesize;// \divs.kr(1);
pos = \pos.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "wt"));
//posdepth = \poslfodepth.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "wt") ) + 1;
//posrate = \poslforate.kr(0, spec:ControlSpec(0, 220, \lin, 0, 0, "wt") );
//pos = pos \* (posdepth \*\* SinOsc.ar(posrate) );

    phase = LFSaw.ar(freq, 1).linlin(-1, 1, 0, 1);
    sig = OscOS.ar(
        bufnum: buf,
        phase: phase,
        buf_divs: divs,
        buf_loc: pos.value.clip(0, 1),
        oversample: 4
    );

    //OscOS3.ar(sound_buf, phase_buf, freq, phase, sync_trig, buf_divs, buf_loc, num_chans, chan_loc, phase_buf_divs, phase_buf_loc, oversample, mul, add)
    sig

}
)
