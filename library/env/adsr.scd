(
synth: {|gate|

    var aeg, env, curve, ts;
    var atk = \atk.kr(0.005, spec:InstrControlSpec(0, 8, \lin, 0, 0.005, units:"aeg", sort:0));
    var dec = \dec.kr(0.2, spec:InstrControlSpec(0, 1, \lin, 0, 0.2, units:"aeg", sort:1));
    var suslevel = \suslevel.kr(0.7, spec:InstrControlSpec(0, 1, \lin, 0, 0.7, units:"aeg", sort:2));
    var rel = \rel.kr(1, spec: InstrControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:3));
    ts = \ts.kr(1);

    curve = [
        \atkcurve.kr(-4, spec: InstrControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:4)),
        \deccurve.kr(-4, spec: InstrControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:5)),
        \relcurve.kr(-4, spec: InstrControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:6))
    ];

    env = Env.adsr(
        attackTime:atk * ts,
        decayTime:dec * ts,
        sustainLevel:suslevel,
        releaseTime:rel * ts,
        curve:curve
    );

    env;

    //aeg = env.ar(doneAction:Done.freeSelf, gate:gate, timeScale:ts);
    //aeg;
}
)
