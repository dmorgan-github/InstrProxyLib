(
    synth: {|in|
        
        var spectrums = ~spectrums.postln;
        var fftsize = 2048;
        var size = in.size;
        var input = \conv_input.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, "conv"));
        var sig = spectrums.collect({|buf, i|
            PartConv.ar(in.wrapAt(i) * input, fftsize, buf.bufnum)
        });

        sig = in.blend(sig, \conv_mix.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, "conv")));
        sig;
    }
)