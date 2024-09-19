(
synth: {|freq|

    var sig, sync;
    var vel = ~vel ?? 0;
    var velamt = ~velamt ?? 0.55;

    var clip = \clip.kr(0, spec:InstrControlSpec(0, 1, \lin, 0, 0, units:"squine", sort: 0));
    var skew = \skew.kr(0, spec:InstrControlSpec(0, 1, \lin, 0, 0, units:"squine", sort: 1));

    //var skewlfodepth = \skewlfodepth.kr(0, spec:InstrControlSpec(0, 1, \lin, 0, 0, units:"squine", sort: 2)) + 1;
    //var skewlforate = \skewlforate.kr(0, spec:InstrControlSpec(0, 20, \lin, 0, 0, units:"squine", sort: 3));
    //skew = skew * (skewlfodepth ** SinOsc.ar(skewlforate));

    sync = \hardsync.kr(0);
    vel = 1+(vel * velamt);

    skew = skew * vel;
    clip = clip * vel;

    sig = Squine.ar(freq, clip.clip(0, 1), skew.clip(0, 1), sync);
    sig;
}
)