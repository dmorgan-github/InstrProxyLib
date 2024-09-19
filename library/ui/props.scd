(
func: {|node, index|

    var sliders = ();
    var height = 20;
    var color = node.color;
    //var fxnode = if (node.respondsTo(\node)) { node.node }{ node };
    var fxnode = node.tryPerform(\node) ?? {node};
    var scroll;
    var getSpec, getKeys, getGroups, getView;
    var nodewatcher;

    scroll = ScrollView().hasBorder_(false)
    .autohidesScrollers_(false)
    .hasVerticalScroller_(true)
    .hasHorizontalScroller_(false);

    getSpec = {|key|
        var specs = node.getSpec;
        var spec = if (specs.isNil) {nil} { specs[key] };
        if (spec.isNil) {
            spec = [0, 1, \lin, 0, 0].asSpec;
        };
        spec
    };

    getKeys = {

        var keys;
        keys = {

            if (index.notNil) {
                fxnode.objects[index].controlNames.collect({|cn| cn.name})
            } {
                var wtf;
                var except = List.new;
                var controlKeys;

                if (node.isKindOf(InstrProxy)){
                    var names = fxnode.controlNames.collect({|cn| cn.name.asSymbol });
                    except.addAll(names);
                };

                try({
                    //except.debug("except....");
                    node.controlKeys(except:except);
                }, {|err|
                    "node.controlKeys (use bufnum): %".format(err).postln;
                    err.throw;
                })
            };
        }.value;

        keys = keys
        .select({|key|
            node.get(key).isNumber
        })
        .reject({|key|
            [\gate,
                \trig,
                \out,
                \in,
                \bufposreplyid,
                \levelreplyid,
                \fadeTime,
                \envbuf,
                //\buf,
                //\amp,
                \spread,
                //\vol,
                \bend,
                \vel
            ].includes(key)
            or: {
                key.asString.beginsWith("wet")
            }
        }).asArray
    };

    getGroups = {

        var dict, keys;
        var returnVal = List.new;

        dict = ();
        keys = getKeys.();

        keys.do({|key|
            var spec, unit, list;
            spec = getSpec.(key);
            unit = spec.units.asSymbol;
            list = dict[unit];
            if (list.isNil) {
                list = List.new;
                dict.put(unit, list);
            };
            list.add(key);
        });

        dict.keysDo({|key|
            dict[key] = dict[key].sort({|a, b|
                var specA = getSpec.(a);
                var specB = getSpec.(b);
                var sorta = if (specA.respondsTo('sort')) {
                    specA.sort
                }{
                    a
                };
                var sortb = if (specB.respondsTo('sort')) {
                    specB.sort
                }{
                    b
                };

                sorta < sortb;
            })
        });

        dict.keys.asArray.sort.do({|key|
            returnVal.add(key -> dict[key]);
        });

        returnVal;
    };

    getView = {

        var view, groups;
        var mysliders;
        groups = getGroups.();
        view = View().layout_(VLayout().margins_(0).spacing_(0));

        groups.do({|assoc|

            var group = assoc.key;
            var mykeys = assoc.value;
            var rec = false;

            view.layout.add(
                StaticText()
                .string_(group.asString.toUpper)
                .stringColor_(Color.white)
                .background_(Color.clear)
            );

            mysliders = mykeys.collect({|key, i|
                var spec = getSpec.(key);
                var buf = List();
                var val = node.get(key);
                if (val.isNil) {
                    val = spec.default;
                };
                [key, LevelSlider(key, spec:spec, color:color)
                    .maxHeight_(height)
                    .action_({|ctrl|
                        var val = node.get(key);
                        if (val != ctrl.value) {
                            node.set(key, ctrl.value);
                        };
                    })
                    .keyDownAction_({|ctrl, char, mod|
                        //[char, mod, unicode, keycode, key].postln

                        /*
                        var tdef = "%_lfo".format(key).asSymbol;

                        if (char == $d) { // stop and clear
                            Tdef(tdef).stop.clear
                        };

                        if (mod == 131072) { // shift
                            var reso = 1/8;
                            var maxbeats = 64;
                            var iter = maxbeats * reso.reciprocal;
                            rec = rec.not;
                            if (rec) {
                                Tdef(tdef).stop.clear;
                                buf = List();
                                ctrl.background_(Color.red.alpha_(0.1));
                                Tdef(tdef, {
                                    iter.do({
                                        var val = node.get(key);
                                        buf.add(val);
                                        reso.wait;
                                    });
                                }).play
                            } {
                                Tdef(tdef).stop.clear;
                                ctrl.background_(Color.clear);
                                Tdef(tdef, {
                                    // TODO: make sure pseq extension not used in library
                                    var seq = Pseq(buf.asArray, inf).asStream;
                                    inf.do({
                                        var next = seq.next;
                                        node.set(key, next);
                                        reso.wait;
                                    })
                                }).play
                            };
                            //rec.debug("lfo rec".format(key));
                        };
                        */
                    })
                    .value_(val)
                ]
            }).flatten;

            mysliders.pairsDo({|key, slider|
                sliders[key] = slider;
                view.layout.add(slider);
            });
        });

        view.layout.add(nil);
        view
    };

    try({
        scroll.canvas = getView.();
    }, {|err|
        "% getView".format(err).error;
    });

    nodewatcher = {|obj, what, vals|
        if (what == \set) {
            vals.pairsDo({|k, v|
                if (v.isNumber) {
                    var slider = sliders[k];
                    if (slider.notNil and: {slider.value != v}) {
                        {
                            slider.value = v;
                        }.defer
                    };
                }
            })
        }
    };

    node.addDependant(nodewatcher);
    scroll
    .background_(Color.black)
    .minHeight_(150)
    .minWidth_(100)
    .resize_(1)
    .onClose_({
        node.removeDependant(nodewatcher);
    })
}
)
