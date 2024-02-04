(
var synth = {|in, gate|

    var frange;
    var cutoff = \cutoff.kr(2000, spec: InstrControlSpec(100, 16000, \exp, 0, 2000, "filter", sort:9));
    var res = \res.kr(0.1, spec:InstrControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:10));
    var envamt = \envamt.kr(0, spec:InstrControlSpec(-1, 1, \lin, 0, 0, units:"filter", sort:11));
    var fcurve = \fcurve.kr(0, spec:InstrControlSpec(-20, 20, \lin, 0, 0, units: "filter", sort:12));

    var atk = \fatk.kr(0, spec: InstrControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:1));
    var dec = \fdec.kr(0.2, spec: InstrControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:2));
    var suslevel = \fsuslevel.kr(1, spec: InstrControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:3));
    var rel = \frel.kr(0.2, spec: InstrControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:4));
    var atkcurve = \fatkcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:5));
    var deccurve = \fdeccurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:6));
    var relcurve = \frelcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:7));
    var env = Env.adsr(atk, dec, suslevel, rel, curve:[atkcurve, deccurve, relcurve]).ar(gate:gate);

    frange = Select.kr(envamt >= 0, [ 20, 20000 ]);
    frange = (frange - cutoff) * abs(envamt) + cutoff;

    //[frange, cutoff].poll;

    MoogFF.ar(
        in, 
        env.linlin(0, 1, cutoff, frange).clip(20, 20000), 
        res.linlin(0, 1, 0, 4).clip(0.0, 4.0)
    );
};

(synth:synth)
)
