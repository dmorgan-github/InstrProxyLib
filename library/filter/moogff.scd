(
synth: {|in, gate, freq, aeg|

    var velamt = ~velamt ?? 0;
    var vel = ~vel.debug("vel") ?? 1;
    var feg = Module('filter/feg3').envir_(currentEnvironment);
    var cutoff, res, gain;
    #cutoff, res = feg.(freq, gate, aeg);
    vel = vel * velamt;
    cutoff = cutoff * vel.linlin(0, 1, 1, 2).lag(0.1);//(vel ** SinOsc.ar(1, phase: 1.5pi).unipolar  ).clip(1, 2);
    MoogFF.ar(in, cutoff.clip(20, 20000), gain:res.linlin(0, 1, 0, 4).clip(0.0, 4.0));
}
)
