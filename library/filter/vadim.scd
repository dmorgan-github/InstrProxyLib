(
synth: {|in, gate, freq, aeg|

    var feg = Module('filter/feg2').envir_(currentEnvironment);
    var cutoff, res, type;
    #cutoff, res = feg.(freq, gate, aeg);
    type = \ftype.kr(0, spec: InstrControlSpec(0, 5, \lin, 1, 0, units:"filter", sort:0));
    // https://github.com/madskjeldgaard/portedplugins/issues/28
    VadimFilter.ar(in, cutoff * 0.33333333, res, type);
}
)
