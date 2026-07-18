(
synth: {|in, gate, freq, aeg|

    var sig;
    //var velamt = ~velamt ?? 0;
    //var vel = ~vel.debug("vel") ?? 1;
    var feg = Module('filter/feg3').envir_(currentEnvironment);
    var cutoff, res, gain;
    var drive = \fdrive.kr(0).clip(0, 1).linlin(0, 1, 1, 6);//, spec:ControlSpec(-120, 18, \lin, 0, 0, "filter"));

    #cutoff, res = feg.(freq, gate, aeg);
    //vel = vel * velamt;
    //cutoff = cutoff * vel.linlin(0, 1, 1, 2).lag(0.1);//(vel ** SinOsc.ar(1, phase: 1.5pi).unipolar  ).clip(1, 2);
    sig = MoogVCF.ar(in * drive, fco: cutoff.clip(20, 20000), res: res);
    //sig = in.blend(sig, \filter_mix.kr(1, spec: InstrControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:50)  ) );
    sig
}
)
