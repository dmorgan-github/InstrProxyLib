(
synth: {|gate|

    var atk = \atk.kr(0.01, spec:InstrControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:0));
    var sus = \sustain.kr(1, spec: InstrControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:1));
    var rel = \rel.kr(0.01, spec: InstrControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:3));

    //var ts = \ts.kr(1);
    var curve = [
        \atkcurve.kr(0, spec: InstrControlSpec(-8, 8, \lin, 0, 0, units:"aeg", sort:4)),
        \relcurve.kr(0, spec: InstrControlSpec(-8, 8, \lin, 0, 0, units:"aeg", sort:6))
    ];
    
    var env = Env.linen(
        attackTime:atk,
        sustainTime:sus,
        releaseTime:rel,
        curve:curve
    );

    env;
    //var env = Env([0, 0, 1, 1, 0], [0, atk, sus, rel], curve:curve);
    //var aeg = env.ar(gate: gate, doneAction:Done.freeSelf, timeScale:ts);
    //aeg;
}
)