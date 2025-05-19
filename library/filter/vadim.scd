(
synth: {|in, gate, freq, aeg|

    //var velamt = ~velamt ?? 0;
    //var vel = ~vel ?? 1;
    var feg = Module('filter/feg3').envir_(currentEnvironment);
    var cutoff, res, type;
    #cutoff, res = feg.(freq, gate, aeg);
    type = \ftype.kr(0, spec: InstrControlSpec(0, 5, \lin, 1, 0, units:"filter", sort:0));
    //vel = vel * velamt;
    //cutoff = cutoff * vel.linlin(0, 1, 1, 2).lag(0.1);//(vel ** SinOsc.ar(1, phase: 1.5pi).unipolar  ).clip(1, 2);
    // https://github.com/madskjeldgaard/portedplugins/issues/28
    VadimFilter.ar(in, cutoff.clip(20, 20000) * 0.33333333, res, type);
}
)
