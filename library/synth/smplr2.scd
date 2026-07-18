// smplr2.scd
// Drop-in replacement for smplr.scd that adds a LIVE playback position on '/bufpos'.
//
// It keeps XPlayBuf for the AUDIO and runs a parallel Phasor purely to report the
// playhead position for a UI.
//
// Why not a pure stock-UGen looper (the earlier approach): on long buffers a
// Phasor/BufRd reader carries its phase in single-precision float (float32, all
// scsynth audio wires are float32). Several million frames into a multi-minute
// buffer the phase resolution is only ~0.5 frame, so cubic interpolation reads
// quantized positions and crossfades comb into audible HF splatter. That is exactly
// the precision problem XPlayBuf solves with a double-precision phase, and it cannot
// be reproduced with stock UGens. So we let XPlayBuf do the audio (no compromise),
// and use a Phasor ONLY for the position readout, where single precision is plenty.
//
// The parallel Phasor mirrors XPlayBuf's playhead (same loop region, rate, trigger).
// It never touches the audio, so it introduces none of that splatter; it can drift a
// tiny amount from XPlayBuf's exact sample position on very long loops, which is
// inaudible/invisible for a UI scrubber.
(
synth: {|freq, gate|

    var updateFreq = 15;
    var dur, dir, rate, sig, pos, rateF, loopFrames;
    var replyid = \bufposreplyid.kr(-1);
    var loop = \loop.kr(0);
    var buf = \buf.kr(0, spec:ControlSpec(units:"buf"));
    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);
    var numchannels = ~numchannels ?? {1};
    var bufsamplerate = BufSampleRate.ir(buf);
    var bufratescale = BufRateScale.kr(buf);
    var numframes = max(BufFrames.kr(buf), 1);
    var start = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"sampler"));
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"sampler") );
    var fadeTime = \fadeTime.kr(0.0);
    var xfadeTime = \xfadeTime.kr(0.0);
    var trigger = \trigger.tr(1);

    rate = (freq/root);
    dir = Select.kr(
        \rev.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"sampler")) > 0.5,
        [1, -1]
    );

    trigger = Changed.kr(start) + Changed.kr(end) + \trigger.tr(1);
    start = start * numframes;
    end = end * numframes;
    dur = (end - start) / bufsamplerate;

    // ---- audio: unchanged from smplr.scd (XPlayBuf, double-precision phase) ----
    sig = XPlayBuf.ar(
        numchannels,
        buf,
        rate: rate * dir,            // automatically adjusted to bufratescale by XPlayBuf
        trigger: trigger,
        startPos: start / bufsamplerate,
        loopDur: dur,
        loop: loop,
        fadeTime: fadeTime,
        xFadeTime: xfadeTime,
    );

    // ---- position readout for the UI (parallel; does NOT touch the audio) ----
    // Mirror XPlayBuf's playhead: loop [start, start+loopFrames] at the same rate,
    // reset on the same trigger. Reports the current frame being played.
    loopFrames = end - start;
    rateF = (rate * dir).asArray[0] * bufratescale;      // frames/sample (mono readout)
    pos = Phasor.ar(trigger, rateF, start, start + loopFrames, start);
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, A2K.kr(pos)], replyid);

    sig;
}
)
