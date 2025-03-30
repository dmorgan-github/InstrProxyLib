(
var synth = {|freq, gate, aeg|
    
    var env;
    var keytrack = ~keytrack.debug("keytrack") ?? 0;
    var voices = ~voices;
    var keytrackamt = \keytrackamt.kr(1);

    var atk = \fatk.kr(0, spec: InstrControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:1));
    var dec = \fdec.kr(0.2, spec: InstrControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:2));
    var suslevel = \fsuslevel.kr(1, spec: InstrControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:3));
    var rel = \frel.kr(0.2, spec: InstrControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:4));
    var atkcurve = \fatkcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:5));
    var deccurve = \fdeccurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:6));
    var relcurve = \frelcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:7));
    var cutoff = \cutoff.kr(2000, spec: InstrControlSpec(100, 16000, \exp, 0, 2000, "filter", sort:9));
    var fend = 1;//\fend.kr(1, spec:InstrControlSpec( 0, 1, \lin, 0, 1, units:"filter", sort:11));
    var famt = \famt.kr(0.3, spec: InstrControlSpec(-1, 1, \lin, 0, 0.3, units:"filter", sort:10 ));
    var res = \res.kr(0.1, spec: InstrControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:12));

    if (keytrack == 1) {
        cutoff = freq * keytrackamt;
    };

    //if (~voices == \mono) {
    //    gate = (1 - \trig.tr(0)) * gate
    //};

    env = Env.adsr(
        atk,
        dec,
        suslevel,
        rel,
        curve:[atkcurve, deccurve, relcurve]
    ).ar(gate:gate);

    fend = 1 * (10 ** famt);
    [ (cutoff * env.linlin(0, 1, 1, fend) ).clip(20, 20000), res]
};

(synth: synth)
)
