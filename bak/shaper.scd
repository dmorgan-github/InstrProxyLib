(
var listener = {|node, curve|

    if (node.notNil) {
        var sc, buf, makeCurve, vals;

        makeCurve = {|curve|
            var vals, buf;
            curve = curve.clip(1, 100);
            vals = Array.interpolation(2048, -1, 1).collect({|v|
                if (v < 0) {
                    v.lincurve(-1, 0, -1, 0, curve)
                } {
                    v.lincurve(0, 1, 0, 1, curve.neg)
                }
            });
            vals = vals.as(Signal);
            vals;
        };

        if (node.getHalo.notNil) {
            sc = node.getHalo['shaper_ctrl'];
        };

        if (sc.isNil) {
            sc = SimpleController(node);
            node.addHalo(\shaper_ctrl, sc);
        };

        buf = node.get(\shaper_buf);
        vals = makeCurve.(curve);
        if (buf.isNil) {
            buf = Buffer.loadCollection(Server.default, vals);
        } {
            buf.loadCollection(vals);    
        };
        node.set(\shaper_buf, buf);

        /*
        sc.put(\set, {|obj, what, val|
            var index = val.indexOf(\shaper_curve);
            if (index.notNil) {
                var curve = val[index+1];
                var buf = node.get('shaper_buf');
                var vals = makeCurve.(curve);
                buf.loadCollection(vals);
                node.set(\shaper_buf, buf);
            }
        })
        */
    }
};

var func = {|in|

    var sig, vals;
    var buf = \shaper_buf.kr();
    var loshelf = \shaper_lowshelf_freq.kr(200, spec: InstrControlSpec(20, 200, \lin, 0, 200, "shaper", sort:0));
    var loshelfdb = \shaper_lowshelf_db.kr(-10, spec: InstrControlSpec(-60, 0, \lin, 0, 0, "shaper", sort: 1));
    var postgain = \shaper_postgain.kr(0.3, spec: InstrControlSpec(0, 1, \lin, 0, 0.5, "shaper", sort: 2));
    var mix = \shaper_mix.kr(0.5, spec: InstrControlSpec(0, 1, \lin, 0, 0.5, "shaper", sort: 3));
    var curve = ~curve ?? 10;//  \shaper_curve.kr(10);

    var node = ~node;

    listener.(node, curve);

    sig = ShaperOS.ar(buf, BLowShelf.ar(in, loshelf, db:loshelfdb), oversample:2 ) * postgain;
    LeakDC.ar(sig) * curve.reciprocal.sqrt
};

(func: func)

)