(
synth: {|in, gate, freq, aeg|

    //var velamt = ~velamt ?? 0;
    //var vel = ~vel ?? 1;
    var feg = Module('filter/feg3').envir_(currentEnvironment);
    var cutoff, res;
    var dist = \lpf_dist.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units: "filter"));
    #cutoff, res = feg.(freq, gate, aeg);
    //vel = vel * velamt;
    //cutoff = cutoff * vel.linlin(0, 1, 1, 2).lag(0.1);//(vel ** SinOsc.ar(1, phase: 1.5pi).unipolar  ).clip(1, 2);
    LPF18.ar(in, cutoff.clip(20, 20000), res:res, dist: dist);
}
)