(
var func = {|in|

    var buf, sig, vals;
    var loshelf = \dist_lowshelf_freq.kr(200, spec: InstrControlSpec(20, 200, \lin, 0, 200, "shaper", sort:0));
    var loshelfdb = \dist_lowshelf_db.kr(-10, spec: InstrControlSpec(-60, 0, \lin, 0, 0, "shaper", sort: 1));
    var postgain = \dist_postgain.kr(0.3, spec: InstrControlSpec(0, 1, \lin, 0, 0.5, "shaper", sort: 2));
    var mix = \dist_mix.kr(0.5, spec: InstrControlSpec(0, 1, \lin, 0, 0.5, "shaper", sort: 3));
    var curve = ~curve ?? 10;
    curve.debug("dist curve");
    vals = Array.interpolation(2048, -1, 1).collect({|v|
        if (v < 0) {
            v.lincurve(-1, 0, -1, 0, curve)
        } {
            v.lincurve(0, 1, 0, 1, curve.neg)
        }
    });
    vals = vals.as(Signal);
    // improve so that we are not littering a bunch of buffers around
    buf = Buffer.loadCollection(Server.default, vals);
    sig = in.blend( ShaperOS.ar(buf, BLowShelf.ar(in, loshelf, db:loshelfdb) ) * postgain, mix);
    LeakDC.ar(sig)

};

(func: func)
)
