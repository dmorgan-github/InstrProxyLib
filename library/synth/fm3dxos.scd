// Oversampled variant of fm3dx.scd: same control interface, using the DynGen
// `fm7dxOS` engine. Adds one control, \os (0..4 -> 1/2/4/8/16x oversampling),
// which reduces aliasing at high feedback / modulation index. Self-registers
// the \fm7dxOS DynGenDef on compile.
(
var id = \fm7dxOS;
var synth = {|freq, gate|

    var sig, params, a1, a2, a3, mscale;
    var op1ratio = \op1ratio.kr(1, spec:ControlSpec(0, 31, \lin, 0, 1, units:"op1"));
    var op2ratio = \op2ratio.kr(1, spec:ControlSpec(0, 31, \lin, 0, 1, units:"op2"));
    var op3ratio = \op3ratio.kr(1, spec:ControlSpec(0, 31, \lin, 0, 1, units:"op3"));

    var inharm = { |x| ((0.01 * (10 ** (x / 0.99 * 2.005))) - 0.01) * 0.99 };
    var op1fine = inharm.(\op1fine.kr(0, spec:ControlSpec(0, 0.99, \lin, 0, 0, units:"op1")));
    var op2fine = inharm.(\op2fine.kr(0, spec:ControlSpec(0, 0.99, \lin, 0, 0, units:"op2")));
    var op3fine = inharm.(\op3fine.kr(0, spec:ControlSpec(0, 0.99, \lin, 0, 0, units:"op3")));

    var op1 = \op1.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"op1"));
    var op2 = \op2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"op2")).lincurve(0, 1, 0, 4, 4);
    var op3 = \op3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"op3")).lincurve(0, 1, 0, 4, 4);
    var mod1_1, mod1_2, mod1_3;
    var mod2_1, mod2_2, mod2_3;
    var mod3_1, mod3_2, mod3_3;
    var slice;
    var op1out = \op1out.kr(1, spec:ControlSpec(0, 1, \lin, 1, 1, "op1"));
    var op2out = \op2out.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "op2"));
    var op3out = \op3out.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "op3"));

    var os = \os.kr(2, spec:ControlSpec(0, 4, \lin, 1, 2, units:"os")); // 0..4 -> 1/2/4/8/16x

    mod1_1 = \mod1_1.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod1")).lincurve(0, 1, 0, 1, 4);
    mod1_2 = \mod1_2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod1"));
    mod1_3 = \mod1_3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod1"));

    mod2_1 = \mod2_1.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod2"));
    mod2_2 = \mod2_2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod2")).lincurve(0, 1, 0, 1, 4);
    mod2_3 = \mod2_3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod2"));

    mod3_1 = \mod3_1.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod3"));
    mod3_2 = \mod3_2.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod3"));
    mod3_3 = \mod3_3.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"mod3")).lincurve(0, 1, 0, 1, 4);

    // operator amplitudes (envelopes identical to the FM7 version)
    a1 = op1;
    a2 = Env.adsr(
            \op2atk.kr(0.01, spec: ControlSpec(0, 1, \lin, 0, 0.01, units:"op2")),
            \op2dec.kr(0.2, spec: ControlSpec(0, 1, \lin, 0, 0.2, units:"op2")),
            \op2suslevel.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"op2")),
            \op2rel.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"op2")),
            curve: [
                \op2atkcurve.kr(-4, spec:ControlSpec(-20, 20, \lin, 0, -4, units:"op2")),
                \op2deccurve.kr(-4, spec:ControlSpec(-20, 20, \lin, 0, -4, units:"op2")),
                \op2relcurve.kr(-4, spec:ControlSpec(-20, 20, \lin, 0, -4, units:"op2"))
            ]
        ).ar(gate:gate) * op2;
    a3 = Env.adsr(
            \op3atk.kr(0.01, spec:ControlSpec(0, 1, \lin, 0, 0.01, units:"op3")),
            \op3dec.kr(0.2, spec:ControlSpec(0, 1, \lin, 0, 0.2, units:"op3")),
            \op3suslevel.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"op3")),
            \op3rel.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"op3")),
            curve: [
                \op3atkcurve.kr(-4, spec:ControlSpec(-20, 20, \lin, 0, -4, units:"op3")),
                \op3deccurve.kr(-4, spec:ControlSpec(-20, 20, \lin, 0, -4, units:"op3")),
                \op3relcurve.kr(-4, spec:ControlSpec(-20, 20, \lin, 0, -4, units:"op3"))
            ]
        ).ar(gate:gate) * op3;

    // FM7's mod matrix was scaled by pi/2; fm7dx takes the same values, so keep it.
    mscale = 2pi;//pi/2;
    params = [
        \f1, freq * (op1ratio + op1fine),
        \f2, freq * (op2ratio + op2fine),
        \f3, freq * (op3ratio + op3fine),
        \a1, a1, \a2, a2, \a3, a3,
        \m11, mod1_1 * mscale, \m12, mod1_2 * mscale, \m13, mod1_3 * mscale,
        \m21, mod2_1 * mscale, \m22, mod2_2 * mscale, \m23, mod2_3 * mscale,
        \m31, mod3_1 * mscale, \m32, mod3_2 * mscale, \m33, mod3_3 * mscale,
        \os, os
    ];

    slice = [0, 1, 2];
    sig = DynGen.ar(6, id, params: params).collect({|v| (v.slice( slice ).asArray * [op1out, op2out, op3out] ).sum });
    sig * 0.7
};

(synth: {
    var path, def;
    "compiling...".debug(id);
    path = Module.libraryDir ++ "eel/%.eel".format(id);
    def = DynGenDef(id);
    def.load(path);
    def.send;
    synth
}.()
)

)
