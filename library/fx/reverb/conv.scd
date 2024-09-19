(
    synth: {|in|
        
        var sig, input;
        var spectrums = ~spectrums.postln;
        var fftsize = ~fftsize ?? 2048;
        var lpf, hpf;
        //var size = in.size;
        fftsize.debug("conv fftsize");
        input = \conv_input.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "conv"));
        in = LPF.ar(in, \conv_lpf.kr(20000, spec:ControlSpec(80, 20000, \lin, 0, 20000, "conv")));
        in = HPF.ar(in, \conv_hpf.kr(20, spec:ControlSpec(20, 12000, \lin, 0, 20, "conv")));
        sig = spectrums.collect({|buf, i|
            PartConv.ar(in.wrapAt(i) * input, fftsize, buf.bufnum)
        });
        sig = Splay.ar(sig, spread:\conv_width.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"conv")) );
        sig = in.blend(sig, \conv_mix.kr(0.4, spec:ControlSpec(0, 1, \lin, 0, 0.4, "conv")));
        sig;
    }
)