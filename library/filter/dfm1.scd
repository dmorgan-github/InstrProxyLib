(
synth: {|in, gate, freq, aeg|

    //var velamt = ~velamt ?? 0;
    //var vel = ~vel ?? 1;
    var feg = Module('filter/feg3').envir_(currentEnvironment);
    var cutoff, res;
    var inputgain = \finputgain.kr(1, spec:ControlSpec(1, 2, \lin, 0, 1, "filter" ) ).clip(1, 2);
    #cutoff, res = feg.(freq, gate, aeg);
    //vel = vel * velamt;
    //cutoff = cutoff * vel.linlin(0, 1, 1, 2).lag(0.1);//(vel ** SinOsc.ar(1, phase: 1.5pi).unipolar  ).clip(1, 2);
    DFM1.ar(in, cutoff.clip(20, 20000), res.clip(0.0, 1.4), inputgain: inputgain)
}
)
