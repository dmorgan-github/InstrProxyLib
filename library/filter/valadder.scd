(
synth: {|in, gate, freq, aeg|

    var feg = DMModule('filter/feg').envir_(currentEnvironment);
    var cutoff, res, type, overdrive;
    #cutoff, res = feg.(freq, gate, aeg);
    type = \ftype.kr(0, spec: DMControlSpec(0, 5, \lin, 1, 0, units:"filter", sort:0));
    overdrive = \foverdrive.kr(0, spec:DMControlSpec(0, 1, \lin, 0, 0, "filter", sort:100));
    // https://github.com/madskjeldgaard/portedplugins/issues/28
    VALadder.ar(in, cutoff * 0.33333333, res, overdrive, type);
}
)
