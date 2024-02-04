(
var synth = {|freq, gate, aeg|
    
    var frange, env;
    var envmode = ~fenvmode.debug("feg fenvmode");

    var cutoff = \cutoff.kr(2000, spec: InstrControlSpec(100, 16000, \exp, 0, 2000, "filter", sort:9));
    var fstart = \fstart.kr(1, spec:InstrControlSpec( 0, 1, \lin, 0, 1, units:"filter", sort:10 ) );
    var fend = \fend.kr(1, spec:InstrControlSpec( 0, 1, \lin, 0, 1, units:"filter", sort:11));
    var res = \res.kr(0.1, spec:InstrControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:12));

    if (envmode == \follow) {
        env = aeg
    } {
        var atk = \fatk.kr(0, spec: InstrControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:1));
        var dec = \fdec.kr(0.2, spec: InstrControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:2));
        var suslevel = \fsuslevel.kr(1, spec: InstrControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:3));
        var rel = \frel.kr(0.2, spec: InstrControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:4));
        var atkcurve = \fatkcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:5));
        var deccurve = \fdeccurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:6));
        var relcurve = \frelcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:7));
        env = Env.adsr(atk, dec, suslevel, rel, curve:[atkcurve, deccurve, relcurve]).ar(gate:gate);
    };

    [ (cutoff * env.linlin(0, 1, fstart, fend) ).clip(20, 20000), res]
};

(synth: synth)
)
