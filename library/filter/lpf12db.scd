(
synth: {|in, gate, freq, aeg|

    //var velamt = ~velamt ?? 0;
    //var vel = ~vel ?? 1;
    var feg = Module('filter/feg3').envir_(currentEnvironment);
    var cutoff, res;
    #cutoff, res = feg.(freq, gate, aeg);
    res = res.linlin(0, 1, 1.4, 0.05);
    //vel = vel * velamt;
    //cutoff = cutoff * vel.linlin(0, 1, 1, 2).lag(0.1);//(vel ** SinOsc.ar(1, phase: 1.5pi).unipolar  ).clip(1, 2);
    BLowPass.ar(in, cutoff.clip(20, 20000), rq:res.clip(0.05, 1.4));
}
)
