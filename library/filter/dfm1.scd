(
synth: {|in, gate, freq, aeg|

    var feg = DMModule('filter/feg2').envir_(currentEnvironment);
    var cutoff, res;
    #cutoff, res = feg.(freq, gate, aeg);
    DFM1.ar(in, cutoff, res.clip(0.0, 1.4))
}
)
