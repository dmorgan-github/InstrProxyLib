(
synth: {|in|

    var gain, sig, hi, lo;
    sig = in;
    sig = HPF.ar(sig, \softclip_hpf.kr(20, spec: ControlSpec(20, 8000, \exp, 0, 20, "softclip")));
    sig = LPF.ar(sig, \softclip_lpf.kr(20000, spec: ControlSpec(1000, 20000, \exp, 0, 20000, "softclip")));
    gain = \softclip_drive.kr(1, spec: ControlSpec(1, 100, \lin, 0, 1, units:"softclip"))
    sig = SoftClipAmp8.ar(sig, gain);// * (gain.reciprocal.sqrt);
    sig = LeakDC.ar(sig) * gain.reciprocal.sqrt;
    sig = in.blend(sig, \softclip_mix.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "softclip")));
    sig
}
)
