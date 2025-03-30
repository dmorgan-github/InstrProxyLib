(
synth: {|in, gate, freq, aeg|

    var lpg, coffset, coffsetlfodepth, coffsetlforate;
    var cscale, cscalelfodepth, cscalelforate;
    var fatk = \fatk.kr(0, spec: InstrControlSpec(0, 1, \lin, 0, 0.0, units:"lpg", sort:0));
    var frel = \frel.kr(0.05, spec: InstrControlSpec(0, 1, \lin, 0, 0.05, units:"lpg", sort:1));
    var fatkcurve = \fatkcurve.kr(-4, spec: InstrControlSpec(-8, 8, \lin, 0, -4, units:"lpg", sort:2));
    var frelcurve = \frelcurve.kr(-4, spec: InstrControlSpec(-8, 8, \lin, 0, -4, units:"lpg", sort:3));
    var feg;

    if (~voices == \mono) {
        gate = (1 - \trig.tr(0)) * gate
    };

    feg = Env(
        [0, 1, 0],
        [fatk, frel],
        curve: [
            fatkcurve,
            frelcurve
        ]
    ).ar(gate: gate);

    coffset = \controloffset.kr(0.1, spec: InstrControlSpec(0, 1, \lin, 0, 0.1, units:"lpg", sort:4));
    cscale = \controlscale.kr(0.1, spec: InstrControlSpec(0, 1, \lin, 0, 0.1, units:"lpg", sort:7));

    lpg = LPG.ar(in,
        controlinput: feg,
        controloffset: coffset.clip(0, 1), //coffset.clip(0, 1),
        controlscale: cscale.clip(0, 1), //cscale.clip(0, 1),
        vca: \vca.kr(0.1, spec: InstrControlSpec(0, 1, \lin, 0, 0.1, units: "lpg", sort:11)),
        resonance: \res.kr(0.2, spec: InstrControlSpec(0, 1, \lin, 0, 0.2, units:"lpg", sort:12)).linlin(0, 1, 0, 1.8),
        lowpassmode:1,
        linearity: \linearity.kr(1, spec: InstrControlSpec(0, 1, \lin, 0, 1, units:"lpg", sort:13))
    );

    lpg;
}
)


