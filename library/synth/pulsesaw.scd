(
synth: {|freq, gate, aeg|

    var oscmix = \oscmix.kr(0.5, spec:InstrControlSpec(0,1,\lin,0, 0.5, units:"osc", sort:0));
    var noise = \noise.kr(0, spec:InstrControlSpec(0, 1, \lin, 0, 0, units: "osc", sort:1));
    var pw = \pw.kr(0.5, spec:InstrControlSpec(0, 1, \lin, 0, 0.5, units: "osc", sort:2));
    var pwenvamt = \pwenvamt.kr(0, spec:InstrControlSpec(0, 1, \lin, 0, 0, units: "osc", sort:3));
    var pulsefreqratio = \pulsefreqratio.kr(1, spec:InstrControlSpec(0.25, 4, \lin, 0, 1, units:"osc", sort:14));
    var sawfreqratio = \sawfreqratio.kr(1, spec:InstrControlSpec(0.25, 4, \lin, 0, 1, units:"osc", sort:15));
    var fold = \fold.kr(1, spec:InstrControlSpec(1, 20, \lin, 0, 1, units:"osc", sort:17));

    var ffreq = \ffreq.kr(2000, spec:InstrControlSpec(20, 20000, \exp, 0, 2000, units: "filter", sort:4));
    var envamt = \fenvamt.kr(0, spec:InstrControlSpec(-1, 1, \lin, 0, 0, units: "filter", sort:5));
    var res = \res.kr(0.5, spec:InstrControlSpec(0, 1, \lin, 0, 0.2, units: "filter", sort:6));
    var fcurve = \fcurve.kr(0, spec:InstrControlSpec(-20, 20, \lin, 0, 0, units: "filter", sort:16));
    var fdrive = \fdrive.kr(1, spec:InstrControlSpec(1, 20, \lin, 0, 1, units: "filter", sort: 18));
    
    var matk = \matk.kr(0.01, spec:InstrControlSpec(0, 4, \lin, 0, 0.01, units:"env", sort:7));
    var mdec = \mdec.kr(0.1, spec:InstrControlSpec(0, 4, \lin, 0, 0.1, units:"env",  sort:8));
    var msuslevel = \msuslevel.kr(1, spec:InstrControlSpec(0, 1, \lin, 0, 1, units:"env", sort:9));
    var mrel = \mrel.kr(0.1, spec:InstrControlSpec(0, 4, \lin, 0, 0.1, units:"env", sort:10));
    var mcurve = [
        \matkcurve.kr(0, spec:InstrControlSpec(-100, 100, \lin, 0, 0, units:"env", sort:11)), 
        \mdeccurve.kr(0, spec:InstrControlSpec(-100, 100, \lin, 0, 0, units:"env", sort:12)),
        \mrelcurve.kr(0, spec:InstrControlSpec(-100, 100, \lin, 0, 0, units:"env", sort:13))
    ];
    
    var cutoff, sig, sig1, sig2;
    var env = Env.adsr(matk, mdec, msuslevel, mrel, curve: mcurve).ar(gate: gate);

    pw = pw * (1 + (env * pwenvamt));
    sig1 = Pulse.ar(freq * pulsefreqratio, pw.clip(0, 1));
    sig2 = Saw.ar(freq * sawfreqratio);

    sig = [
        sig1,
        sig2,
    ];

    sig = SelectX.ar(noise, [
        SelectX.ar(oscmix, sig),
        WhiteNoise.ar
    ]);

    sig = Fold.ar(sig * fold.clip(1, 20), -1, 1);

    cutoff = Select.kr(envamt >= 0, [ 20, 20000 ]);
    cutoff = (cutoff - ffreq) * abs(envamt) + ffreq;
    sig = RLPF.ar((sig * fdrive.clip(1, 20)).tanh, env.lincurve(0, 1, ffreq, cutoff, fcurve).clip(20, 20000), res.linlin(0, 1, 1, 0.001));
    sig;
},
presets: [
    preset1: [
        fcurve:-11.52,
        fenvamt: -0.808, 
        ffreq: 1990.8108347031, 
        matk: 0.128,
        matkcurve: 0, 
        mdec: 0.1,
        mdeccurve: 0, 
        mrel: 0.568,
        mrelcurve: 0, 
        msuslevel: 1,
        noise: 0,
        oscmix: 0.462, 
        pulsefreqratio: 1, 
        pw: 0.5,
        pwenvamt: 0, 
        res: 0.532,
        sawfreqratio: 1
    ]
]
)


