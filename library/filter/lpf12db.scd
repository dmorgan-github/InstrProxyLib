(
synth: {|in, gate, freq, aeg|

    var feg = DMModule('filter/feg').envir_(currentEnvironment);
    var cutoff, res;
    #cutoff, res = feg.(freq, gate, aeg);
    res = res.linlin(0, 1, 1.4, 0.05);
    BLowPass.ar(in, cutoff, rq:res.clip(0.05, 1.4));
}
)
