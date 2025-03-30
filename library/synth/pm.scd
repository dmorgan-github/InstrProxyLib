(
synth: {|freq, gate|

    var mod, carratio, sig;

    mod = {
        var ratio = \mratio.kr(1, spec:InstrControlSpec(0.5, 20, \lin, 0, 1, units:"pm", sort:0));
        var fb = \mfb.kr(0, spec:InstrControlSpec(-1, 1.5, \lin, 0, 0, units:"pm", sort:1));
        var index = \mindex.kr(1, spec:InstrControlSpec(0, 100, \lin, 0, 1, units:"pm"));

        var sig;
        var indexmod = ~mindexmod.value(freq, gate);

        if (indexmod.isNil) {

            var atk = \matk.kr(0.01, spec:InstrControlSpec(0, 2, \lin, 0, 0.01, units:"pm", sort:3));
            var dec = \mdec.kr(0.3, spec:InstrControlSpec(0, 2, \lin, 0, 0.3, units:"pm", sort:5));
            var suslevel = \msuslevel.kr(1, spec:InstrControlSpec(0, 1, \lin, 0, 0.7, units:"pm", sort:6));
            var rel = \mrel.kr(0.2, spec:InstrControlSpec(0, 8, \lin, 0, 0.2, units:"pm", sort:7));

            var atkcurve = \matkcurve.kr(-4, spec:InstrControlSpec(-8, 8, \lin, 0, -4, units:"pm", sort:8));
            var deccurve = \mdeccurve.kr(-4, spec:InstrControlSpec(-8, 8, \lin, 0, -4, units:"pm", sort:9));
            var relcurve = \mrelcurve.kr(-4, spec:InstrControlSpec(-8, 8, \lin, 0, -4, units:"pm", sort:10));
            var curve = [atkcurve, deccurve, relcurve];

            indexmod = Env.adsr(
                attackTime:atk,
                decayTime:dec,
                sustainLevel:suslevel,
                releaseTime:rel,
                curve:curve
            ).ar(gate:gate);// * index;//.linlin(0, 1, start, end);
        };
        
        sig = SinOscFB.ar(freq * ratio, fb);
        sig = sig * (indexmod * index);
        sig;
    };

    carratio = \cratio.kr(1, spec:InstrControlSpec(0.5, 20, \lin, 0, 1, units:"pm", sort:11));
    sig = SinOsc.ar(freq * carratio, mod.().mod(2pi));
    sig
}
)
