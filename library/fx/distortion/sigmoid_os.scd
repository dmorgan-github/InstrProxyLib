// Oversampled sigmoid distortion via DynGen.
// Requires: SigmoidShaper.send(s) called once after server boot.

(
synth: {|in|

    var sig;
    var drive, mix, os, asym;

    drive = \sigmoid_drive.kr(0.0, spec: ControlSpec(0,  1,  \lin, 0,  0.0, units:"sigmoidos"));
    mix   = \sigmoid_mix.kr  (1.0, spec: ControlSpec(0,  1,  \lin, 0,  1.0, units:"sigmoidos"));
    os    = \sigmoid_os.kr   (2,   spec: ControlSpec(1,  16, \lin, 1,  2,   units:"sigmoidos"));
    asym  = \sigmoid_asym.kr (0.0, spec: ControlSpec(-1, 1,  \lin, 0,  0.0, units:"sigmoidos"));

    sig = SigmoidShaper.ar(in, drive, mix, os, asym);

    sig
}
)
