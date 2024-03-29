(
synth: {|freq, gate, aeg|

    var voices = ~voices;
    var velamt = ~velamt ?? 0;
    var vel = ~vel ?? 1;
    var envmode = ~fenvmode.debug("feg fenvmode");
    var keyamt = \keyamt.kr(0, spec: InstrControlSpec(0, 1, \lin, 0, 0, "filter", sort:8));
    var cutoff = \cutoff.kr(2000, spec: InstrControlSpec(100, 16000, \exp, 0, 2000, "filter", sort:9));
    var res = \res.kr(0.1, spec:InstrControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:10));
    var fadd = \fadd.kr(0, spec:InstrControlSpec(0, 1, \lin, 0, 0, units:"filter", sort:11)).linlin(0, 1, 0, 4000);
    var basefreq = 48.midicps;
    var cutoffratio, feg;

    if (envmode == \follow) {
        feg = aeg;
    } {
        var fatkcurve = \fatkcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:5));
        var fdeccurve = \fdeccurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:6));
        var frelcurve = \frelcurve.kr(-1, spec: InstrControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:7));

        var atk = \fatk.kr(0, spec: InstrControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:1));
        var dec = \fdec.kr(0.2, spec: InstrControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:2));
        var suslevel = \fsuslevel.kr(1, spec: InstrControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:3));
        var rel = \frel.kr(0.2, spec: InstrControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:4));
        var curve = [fatkcurve, fdeccurve, frelcurve];
        //var curve = [fatkcurve, frelcurve];
        var ts = \fts.kr(1);

        if (voices == \mono) {
            var sus = \fsustain.kr(1, spec:InstrControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:1));
            feg = Env(
                [0, 1, suslevel, suslevel, 0],
                [
                    atk,
                    dec,
                    sus,
                    rel
                ],
                curve:curve
            ).ar(gate:gate, timeScale: ts);

        }{
            feg = Env.adsr(
                atk,
                dec,
                suslevel,
                rel,
                curve:curve
            ).ar(gate:gate, timeScale: ts);//.linlin(0, 1, 1, 0.1);
        };
    };

    cutoffratio = Select.kr(freq < basefreq, [
        basefreq + ((freq - basefreq) * keyamt),
        basefreq - ((basefreq - freq) * keyamt)
    ]);
    cutoffratio = cutoffratio / basefreq;

    //[cutoff, vel, velamt].postln;

     // apply velocity to cutoff
    cutoff = cutoff * (1 + (vel * velamt));
    // apply key tracking
    cutoff = cutoff * cutoffratio;
    // apply envelope
    cutoff = cutoff * feg;
    // apply add value
    cutoff = cutoff + fadd;

    cutoff = cutoff.clip(20, 20000);

    [cutoff, res]

}
)
