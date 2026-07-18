(
synth: {|freq, gate|
    
    var sig, ctrls, mod;
    var op1ratio = \op1ratio.kr(1, spec:ControlSpec(0.5, 20, \lin, 0, 1, units:"op1"));
    var op2ratio = \op2ratio.kr(1, spec:ControlSpec(0.5, 20, \lin, 0, 1, units:"op2"));
    var op3ratio = \op3ratio.kr(1, spec:ControlSpec(0.5, 20, \lin, 0, 1, units:"op3"));
    var op1 = \op1.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"op1"));
    var op2 = \op2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"op2")).lincurve(0, 1, 0, 4, 8);
    var op3 = \op3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"op3")).lincurve(0, 1, 0, 4, 8);
    var mod1_1, mod1_2, mod1_3;
    var mod2_1, mod2_2, mod2_3;
    var mod3_1, mod3_2, mod3_3;
    var slice;
    var op1out = \op1out.kr(1, spec:ControlSpec(0, 1, \lin, 1, 1, "op1"));
    var op2out = \op2out.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "op2"));
    var op3out = \op3out.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "op3"));

    mod1_1 = \mod1_1.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod1")).lincurve(0, 1, 0, 1, 4);
    mod1_2 = \mod1_2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod1"));
    mod1_3 = \mod1_3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod1"));

    mod2_1 = \mod2_1.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod2"));
    mod2_2 = \mod2_2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod2")).lincurve(0, 1, 0, 1, 4);
    mod2_3 = \mod2_3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod2"));

    mod3_1 = \mod3_1.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod3"));
    mod3_2 = \mod3_2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod3"));
    mod3_3 = \mod3_3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod3")).lincurve(0, 1, 0, 1, 4);

    ctrls = [
        [freq * op1ratio, 0, op1],
        [freq * op2ratio, 0, 
            Env.adsr(
                \op2atk.kr(0.01, spec: ControlSpec(0, 1, \lin, 0, 0.01, units:"op2")), 
                \op2dec.kr(0.2, spec: ControlSpec(0, 1, \lin, 0, 0.2, units:"op2")), 
                \op2suslevel.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"op2")), 
                \op2rel.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"op2")),
                curve: [
                    \op2atkcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"op2")),
                    \op2deccurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"op2")),
                    \op2relcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"op2"))
                ]
            ).ar(gate:gate) * op2],
        [freq * op3ratio, 0, 
            Env.adsr(
                \op3atk.kr(0.01, spec:ControlSpec(0, 1, \lin, 0, 0.01, units:"op3")), 
                \op3dec.kr(0.2, spec:ControlSpec(0, 1, \lin, 0, 0.2, units:"op3")), 
                \op3suslevel.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"op3")), 
                \op3rel.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"op3")),
                curve: [
                    \op3atkcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"op3")),
                    \op3deccurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"op3")),
                    \op3relcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"op3"))
                ]
            ).ar(gate:gate) * op3],
        [freq, 0, 0],
        [freq, 0, 0],
        [freq, 0, 0],
    ];

    mod = [
        [mod1_1, mod1_2, mod1_3, 0, 0, 0],
        [mod2_1, mod2_2, mod2_3, 0, 0, 0],
        [mod3_1, mod3_2, mod3_3, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0]
    ].collect(_ * (pi/2) );

    slice = [0, 1, 2];
    sig = FM7.ar(ctrls, mod).collect({|v| (v.slice( slice ).asArray * [op1out, op2out, op3out] ).sum });
    sig * 0.7
}
)