(
var func = {
    var proxy = EventPatternProxy();
    var config;
    var model = Ref(1);
    var sc = SimpleController(model);
    var palette, itemLayout;
    var phaseMsv, degreeMsv, octaveMsv, mtransposeMsv, legatoMsv, durMsv, maskMsv;
    var degreeSpec = [-7, 7];
    var octaveSpec = [2, 8];
    var mtransposeSpec = [-7, 7];
    var durSpec = [1, 8];

    var view = View(bounds:Rect(width:400, height:100))
    .layout_(VLayout().margins_(1).spacing_(1))
    .deleteOnClose_(false);

    var phaseStr = "(0..15)";
    var degreeStr = "[3, 3, 2, 3, 4, 5, 4, [0, 1] ].lace(16)";
    var octaveStr = "[ [5, 4], [3, 4, 4] ].lace(16).stutter(2).reverse";
    var legatoStr = "[0.5, 0.9, 0.9].wrapExtend(16)";
    var maskStr = "[1, 0, 1, 0, 1].wrapExtend(32)";
    var mtransposeStr = "[0, 1, 3, 2].stutter(32)";
    var durStr = "[1]";

    var phaseVals = phaseStr.interpret;
    var degreeVals = degreeStr.interpret;
    var octaveVals = octaveStr.interpret;
    var legatoVals = legatoStr.interpret;
    var maskVals = maskStr.interpret;
    var mtransposeVals = mtransposeStr.interpret;
    var durVals = durStr.interpret;
    var thumbsize = 7;

    proxy.set(
        'phase', phaseVals, 
        'degree', degreeVals, 
        'octave', octaveVals, 
        'legato', legatoVals, 
        'mask', maskVals, 
        'mtranspose', mtransposeVals,
        'dur', durVals
    );

    phaseVals = phaseVals.linlin(0, phaseVals.size-1, 0, 1);
    degreeVals = degreeVals.linlin(-7, 7, 0, 1);
    octaveVals = octaveVals.linlin(2, 8, 0, 1);
    mtransposeVals = mtransposeVals.linlin(-7, 7, 0, 1);
    durVals = durVals.linlin(1, 8, 0, 1);

    palette = QPalette()
    .window_(Color.clear)
    .windowText_(Color.grey(0.5))
    .baseText_(Color.grey(0.5))
    .highlight_(Color.clear);
    palette.base = Color.black;
    palette.setColor(Color.black, \shadow);

    sc.put(\phase, {|obj, what, vals| 
        var size = vals.size;
        vals = vals.linlin(0, 1, 0, size-1);//.debug("phase");
        proxy.set(\phase, vals)
    });
    sc.put(\degree, {|obj, what, vals| 
        vals = vals.linlin(0, 1, degreeSpec[0], degreeSpec[1]).round;//.debug("degree");
        //vals.debug("degree");
        proxy.set(\degree, vals)
    });
    sc.put(\octave, {|obj, what, vals| 
        vals = vals.linlin(0, 1, octaveSpec[0], octaveSpec[1]).round;//.debug("octave");
        proxy.set(\octave, vals)
    });
    sc.put(\mtranspose, {|obj, what, vals|
        vals = vals.linlin(0, 1, mtransposeSpec[0], mtransposeSpec[1]);
        proxy.set(\mtranspose, vals)
    });
    sc.put(\legato, {|obj, what, vals| 
        //vals.debug("legato");
        proxy.set(\legato, vals)
    });
    sc.put(\dur, {|obj, what, vals| 
        vals = vals.linlin(0, 1, durSpec[0], durSpec[1]);//.debug("dur");
        proxy.set(\dur, vals)
    });
    sc.put(\mask, {|obj, what, vals| 
        proxy.set(\mask, vals)
    });

    phaseMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(true)
    .thumbSize_(thumbsize)
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\phase, vals);
    })
    .value_(phaseVals)
    .size_(phaseVals.size);

    degreeMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(true)
    .thumbSize_(thumbsize)
    .reference_( 0.5.dup(degreeVals.size) )
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\degree, vals);
    })
    .value_(degreeVals)
    .size_(degreeVals.size);

    octaveMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(true)
    .thumbSize_(thumbsize)
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\octave, vals);
    })
    .value_(octaveVals)
    .size_(octaveVals.size);

    mtransposeMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(true)
    .thumbSize_(thumbsize)
    .reference_( 0.5.dup(mtransposeVals.size) )
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\mtranspose, vals);
    })
    .value_(mtransposeVals)
    .size_(mtransposeVals.size);

    legatoMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(true)
    .thumbSize_(thumbsize)
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\legato, vals);
    })
    .value_(legatoVals)
    .size_(legatoVals.size);

    durMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(true)
    .thumbSize_(thumbsize)
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\dur, vals);
    })
    .value_(durVals)
    .size_(durVals.size);

    maskMsv = MultiSliderView()
    .elasticMode_(0)
    .isFilled_(false)
    .thumbSize_(thumbsize)
    .action_({|ctrl|
        var vals = ctrl.value;
        model.changed(\mask, vals);
    })
    .value_(maskVals)
    .size_(maskVals.size);

    itemLayout = {|msv, label, str, action|

        var tf = TextField()
        .palette_(palette) 
        .action_(action)
        .value_( str );

        tf.setContextMenuActions(
            MenuAction("ramp up", {
                var val = "(0..15)";
                tf.value = val;
            }),
            MenuAction("ramp down", { 
                var val = "(0..15).reverse";
                tf.value = val;
            }),
            MenuAction("sine", {
                var val = "all {:sin(x/pi), x <- (0..31)}.linlin(-1, 1, 0, 16)";
                tf.value = val
            })
        );

        msv.setContextMenuActions (
            MenuAction("config", {})
        );

        HLayout( 
            StaticText().string_(label),
            VLayout(
                msv,
                tf
            )
        );
    };

    config = [

        [phaseMsv, "p", phaseStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            var size = vals.size;
            phaseMsv.valueAction = vals.linlin(0, size-1, 0, 1)
        }],

        [degreeMsv, "d", degreeStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            var size = vals.size;
            degreeMsv.reference_( 0.5.dup(size) );
            degreeMsv.valueAction = vals.linlin(degreeSpec[0], degreeSpec[1], 0, 1)
        }],

        [octaveMsv, "o", octaveStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            octaveMsv.valueAction = vals.linlin(octaveSpec[0], octaveSpec[1], 0, 1)
        }],

        [mtransposeMsv, "m", mtransposeStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            var size = vals.size;
            mtransposeMsv.reference_( 0.5.dup(size) );
            mtransposeMsv.valueAction = vals.linlin(mtransposeSpec[0], mtransposeSpec[1], 0, 1)
        }],

        [legatoMsv, "l", legatoStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            var size = vals.size;
            legatoMsv.valueAction = vals
        }],

        [durMsv, "r", durStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            var size = vals.size;
            durMsv.valueAction = vals.linlin(durSpec[0], durSpec[1], 0, 1)
        }],

        [maskMsv, "k", maskStr, {|ctrl|
            var vals = ctrl.value.interpret.asArray;
            maskMsv.valueAction = vals;
        }]
    ].do({|v|
        view.layout.add( itemLayout.(v[0], v[1], v[2], v[3]))
    });

    proxy.addUniqueMethod(\view, { view.front });

    proxy.source = Pbind(*[
        incr: Prout({|inval|
            var val = 0;
            inf.do({
                var step = inval['step'] ?? 1;
                inval = val.embedInStream(inval);
                val = val + step;
            })
        }),
        phase: Pfunc({|evt|
            var phase = evt['incr'];
            var vals = (evt['phase'] ?? 0).asArray;
            vals.wrapAt(phase);
            //phase
        }),
        //phase: Pseries(),
        octave: Pfunc({|evt|
            var phase = evt['phase'];
            var vals = (evt['octave'] ?? 4).asArray;
            vals.wrapAt(phase)
        }),
        legato: Pfunc({|evt|
            var phase = evt['phase'];
            var vals = (evt['legato'] ?? 0.7).asArray;
            vals.wrapAt(phase)    
        }),
        mask: Pfunc({|evt|
            var phase = evt['phase'];
            var vals = (evt['mask'] ?? 1).asArray;
            var val = vals.wrapAt(phase);
            if (val.coin) {1} {\};
        }),
        mtranspose: Pfunc({|evt|
            var phase = evt['phase'];
            var vals = (evt['mtranspose'] ?? 0).asArray;
            vals.wrapAt(phase)      
        }),
        degree: Pfunc({|evt|
            var phase = evt['phase'];
            var vals = (evt['degree'] ?? 0).asArray;
            vals.wrapAt(phase);
        }),
        dur: Pfunc({|evt|
            var phase = evt['phase'];
            var vals = (evt['dur'] ?? 1).asArray;
            vals.wrapAt(phase)      
        })
    ]);

    proxy;
};

(func: func)
)