(
synth: {|gate|

    var env, aeg;
    var atk = \atk.kr(0.01, spec:InstrControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:0));
    var suslevel = \suslevel.kr(1, spec:InstrControlSpec(0, 1, \lin, 0, 1, units:"aeg", sort:2));
    var rel = \rel.kr(1, spec: InstrControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:3));

    //var ts = \ts.kr(1);
    var curve = [
        \atkcurve.kr(-4, spec:InstrControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:4)),
        \relcurve.kr(-4, spec: InstrControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:6))
    ];

    env = Env.asr(
        attackTime: atk,
        sustainLevel: suslevel,
        releaseTime:rel,
        curve:curve
    );

    env;

    //aeg = env.ar(doneAction:Done.freeSelf, gate:gate, timeScale:ts);
    //aeg;
}
)
