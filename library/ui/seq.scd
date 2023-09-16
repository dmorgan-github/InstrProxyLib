(
var update = {|node, prop, default=1|
    var val, controller;
    val = Ref(node.get(prop) ?? default);
    controller = SimpleController(val);
    controller.put(\value, {|obj, what, args|
        //obj.value;//.debug(prop);
        node.set(prop, obj.value);
    });
    val;
};

var func = {|node|

    var view = View().layout_(VLayout().margins_(1).spacing_(2)).background_(Color.black);
    var valsview = MultiSliderView().background_(Color.clear);
    var modsview = MultiSliderView().background_(Color.clear);
    var probview = MultiSliderView().background_(Color.clear);
    var vals, mod, prob, start, len, bar, beats, stretch;
    var valmin, valmax, valsunmapped, modsunmapped;
    var color = node.color;
    var proxy, key;

    key = "%_%".format(node.key, "seq").asSymbol;

    proxy = Pdef(key);
    if (proxy.source.isNil) {
        node.set(\vals, 16.collect({ rrand(0, 9) }), \stretch, 0.25);
        node.source = proxy;
    };

    vals = update.(node, 'vals', [0]);
    mod = update.(node, 'mod', [0]);
    prob = update.(node, 'prob', [1]);
    start = update.(node, 'start', 0);
    len = update.(node, 'len', 4);
    bar = update.(node, 'bar', 4);
    beats = update.(node, 'beats', 4);
    stretch = update.(node, 'stretch', 0.25);
    valmin = update.(node, 'valmin', 0);
    valmax = update.(node, 'valmax', 9);

    valsunmapped = [valmin.value, valmax.value, \lin, 1].asSpec.unmap(vals.value);//  vals.value.linlin(valmin.value, valmax.value, 0, 1);
    modsunmapped = [0, 4, \lin, 1].asSpec.unmap(mod.value);

    proxy.source = Pbind(\degree, Pkey(\val)) <> Pbind(
        \vals, Pfunc({|evt|
            var vals = evt['vals'] ?? [0];
            var mods = evt['mod'] ?? [0];
            var procs = [\none, \rotate, \mirror, \reverse, \pyramid];//.wrapAt(proc);
            mods.asArray.do({|mod|
                if (mod > 0) {
                    var proc = procs.wrapAt(mod);
                    vals = vals.perform(proc)//.debug(proc);
                }
            });
            vals;
        }),
        \start, Pfunc({|evt|
            var start = evt['start'] ?? 0;
            start.asInteger;
        }),
        \items, Pfunc({|evt|
            var vals = evt['vals'];
            var start = evt['start'].wrapAt(vals.size);
            var len = evt['len'] ?? inf;
            //[start, len].postln;
            if (len == inf) {
                vals = vals[start..]
            }{
                vals = vals[start..].wrapExtend(len.asInteger)
            };
            vals
        }),
        \index, Prout({|inval|
            var cache = inval['start'] ?? 0;
            var index = cache;
            // if start changes we need to jump to the new start
            inf.do({
                var current = inval['start'];
                if (cache != cache) {
                    cache = current;
                    index = cache;
                };
                inval = index.embedInStream(inval);
                index = index + 1;
            })
        }),
        \probs, Prout({|inval|
            var index = 0;
            inf.do({
                var probs = inval['prob'] ?? [1];
                var prob = probs.asArray.wrapAt(index);
                if(prob.coin) {
                    prob = 1
                } {
                    prob = \
                };
                inval = prob.embedInStream(prob);
                index = index + 1;
            })
        }),
        \dur, Pfunc({|evt|
            var bar = evt['bar'] ?? 4;
            var beats = evt['beats'] ?? 4;
            var dur = bar/beats;
            dur
        }),
        \val, Prout({|inval|
            var i = 0;
            inf.do({
                var items = inval['items'];
                var val = items.wrapAt(i);
                inval = val.embedInStream(inval);
                i = i + 1;
            });
            inval;
        })
    );

    // vals
    view.layout.add(
        VLayout(
            StaticText().string_("vals"),
            HLayout(
                VLayout(
                    NumberBox()
                    .fixedWidth_(30)
                    .action_({|ctrl|
                        var myvals = valsview.value;
                        var size = ctrl.value.clip(1, 128).asInteger;
                        myvals = [valmin.value, valmax.value, \lin, 1].asSpec.map(myvals);
                        vals.value_(myvals.wrapExtend(size)).changed(\value);
                        valsview.value = vals.value;
                    })
                    .clipLo_(1)
                    .value_(vals.value.size),
                    NumberBox()
                    .fixedWidth_(30)
                    .action_({|ctrl|
                        var myvals;
                        valmin.value_(ctrl.value).changed(\value);
                        // rescale the values
                        myvals = valsview.value;
                        myvals = [valmin.value, valmax.value, \lin, 1].asSpec.map(myvals);
                        vals.value_(myvals).changed(\value);
                    })
                    .value_(valmin.value),
                    NumberBox()
                    .fixedWidth_(30)
                    .action_({|ctrl|
                        var myvals;
                        valmax.value_(ctrl.value).changed(\value);
                        // rescale the values
                        myvals = valsview.value;
                        myvals = [valmin.value, valmax.value, \lin, 1].asSpec.map(myvals);
                        vals.value_(myvals).changed(\value);
                    })
                    .value_(valmax.value),
                    Button()
                    .action_({|ctrl|
                        // get current values
                        var myvals = valsview.value;
                        var size = myvals.size;
                        // create random values
                        myvals = size.collect( { rrand(valmin.value.asInteger, valmax.value.asInteger) } );
                        // update vals
                        vals.value_(myvals).changed(\value);
                        // unmap to 0-1 range
                        myvals = [valmin.value, valmax.value, \lin, 1].asSpec.unmap(myvals);
                        // update sliderview
                        valsview.value = myvals;
                    })
                ),
                valsview
                .elasticMode_(1)
                .value_(valsunmapped)
                .isFilled_(true)
                .fillColor_(color)
                .onResize_({|ctrl|
                    var width = ctrl.bounds.width;
                    var num = ctrl.value.size;
                    var size = width/num;
                    ctrl.thumbSize = size;
                })
                .action_({|ctrl|
                    //[valmin.value, valmax.value].postln;
                    var valsmapped = [valmin.value, valmax.value, \lin, 1].asSpec.map(ctrl.value);
                    vals.value_(valsmapped).changed(\value);
                })
            )
        )
    );
    // mod
    view.layout.add(
        VLayout(
            StaticText().string_("mods"),
            HLayout(
                VLayout(
                    NumberBox()
                    .action_({|ctrl|
                        var mymod = modsview.value;
                        var size = ctrl.value.clip(1, 128).asInteger;
                        mymod = [0, 4, \lin, 1].asSpec.map(mymod);
                        mod.value_(mymod.wrapExtend(size)).changed(\value);
                        modsview.value = mod.value;
                    })
                    .clipLo_(1)
                    .value_(mod.value.size)
                    .fixedWidth_(30)
                ),
                modsview
                .elasticMode_(1)
                .fixedWidth_(300)
                .isFilled_(true)
                .fillColor_(color)
                .value_(modsunmapped)
                .onResize_({|ctrl|
                    var width = ctrl.bounds.width;
                    var num = ctrl.value.size;
                    var size = width/num;
                    ctrl.thumbSize = size;
                })
                .action_({|ctrl|
                    var modsmapped = [0, 4, \lin, 1].asSpec.map( ctrl.value );
                    mod.value_(modsmapped).changed(\value);
                })
            )
        )
    );
    // prob
    view.layout.add(
        VLayout(
            StaticText().string_("probs"),
            HLayout(
                VLayout(
                    NumberBox()
                    .action_({|ctrl|
                        var myprob = probview.value;
                        var size = ctrl.value.clip(1, 128).asInteger;
                        prob.value_(myprob.wrapExtend(size)).changed(\value);
                        probview.value = prob.value;
                    })
                    .clipLo_(1)
                    .value_(prob.value.size)
                    .fixedWidth_(30)
                ),
                probview
                .elasticMode_(1)
                .value_(prob.value.asArray)
                .isFilled_(true)
                .fillColor_(color)
                .onResize_({|ctrl|
                    var width = ctrl.bounds.width;
                    var num = ctrl.value.size;
                    var size = width/num;
                    ctrl.thumbSize = size;
                })
                .action_({|ctrl|
                    prob.value_(ctrl.value).changed(\value);
                })
            )
        )
    );

    view.layout.add(
        VLayout(
            LevelSlider("start", spec:[0, 64, \lin, 1, 0].asSpec)
            .action_({|ctrl|
                start.value_(ctrl.value).changed(\value)
            })
            .value_(start.value),
            LevelSlider("len", spec:[0, 64, \lin, 1, 1].asSpec)
            .action_({|ctrl|
                len.value_(ctrl.value).changed(\value)
            })
            .value_(len.value),
            LevelSlider("bar", spec:[0, 64, \lin, 1, 4].asSpec)
            .action_({|ctrl|
                bar.value_(ctrl.value).changed(\value)
            })
            .value_(bar.value),
            LevelSlider("beats", spec:[0, 64, \lin, 1, 4].asSpec)
            .action_({|ctrl|
                beats.value_(ctrl.value).changed(\value)   
            })
            .value_(beats.value),
            LevelSlider("stretch", spec:[1/16, 8, \lin, 0, 0.25].asSpec)
            .action_({|ctrl|
                stretch.value_(ctrl.value).changed(\value)
            })
            .value_(stretch.value)
        )
    );
    view;
};

(func: func)
)
