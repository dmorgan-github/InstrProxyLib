(
var func = {|node|
    var title = node.key;
    var model = Ref(1);
    var sc = SimpleController(model);
    var opView;
    var colors = [Color.new255(100, 98, 149), Color.new255(126, 164, 167), Color.new255(200, 96, 68)];
    var palette;
    var view = View(bounds:Rect(width:200, height: 200)).name_(title)
    .background_(Color.black)
    .layout_(VLayout());

    palette = QPalette()
    .window_(Color.clear)
    .windowText_(Color.grey(0.5))
    .baseText_(Color.grey(0.5))
    .button_(Color.clear)
    .highlight_(Color.clear);

    palette.base = Color.black;
    palette.setColor(Color.black, \shadow);
    palette.setColor(Color.black, \dark);
    palette.setColor(Color.black, \middark);

    sc
    .put('ratioCoarse', {|obj, what, val|
        var op = val[0]+1;
        var ratio = val[1];
        var key = "op%ratio".format(op).asSymbol;
        var current = node.get(key);
        var fine = current.mod(1);
        var new = ratio + fine;
        node.set(key, new);
    })
    .put('ratioFine', {|obj, what, val|
        var op = val[0]+1;
        var ratio = val[1];
        var key = "op%ratio".format(op).asSymbol;
        var current = node.get(key);
        var int = current.asInteger;
        var new = int + ratio;
        node.set(key, new);
    })
    .put('amp', {|obj, what, val|
        var key = "op%".format( val[0] +1 ).asSymbol;
        if (key == 'op1') {
            val = val[1];//.lincurve(0, 1, 0, 1, 8);    
        } {
            val = val[1];//.linlin(0, 1, 0, 8);
        };
        node.set(key, val)
    })
    .put('fb', {|obj, what, val|
        var mod = val[0];
        var key = "mod%_%".format(mod+1, mod+1).asSymbol;
        val = val[1];//.linlin(0, 1, 0, 1);
        node.set(key, val)
    })
    .put('mod', {|obj, what, val|
        var op = val[0];
        var mod = val[1];
        var key = "mod%_%".format(op+1, mod+1).asSymbol;
        node.set(key, val[2]);
    })
    .put('opOut', {|obj, what, val|
        var op = val[0];//.debug("opout");
        var out = val[1];
        node.set("op%out".format(op+1).asSymbol, out);
    });

    opView = {|op, mods|

        var opAmp, opFb;
        var opRatioCoarse, opRatioFine;
        var modA, modB;
        var view = View().layout_(VLayout().margins_(0).spacing_(0));
        var opkey = "op%".format(op+1).asSymbol;
        var opColor = colors[op];
        var ratioCoarse, ratioFine, opVal, opFbVal, modAVal, modBVal, opOut, opOutVal;
        var modNums = [1, 2, 3].reject({|v| v == (op+1) });

        ratioCoarse = node.get( "%ratio".format(opkey).asSymbol );
        ratioFine = ratioCoarse.mod(1);
        ratioCoarse = ratioCoarse.asInteger;
        opVal = node.get( opkey );
        //if (opkey != 'op1') {
        //    opVal = opVal.linlin(0, 4, 0, 1);
        //};

        opFbVal = node.get("mod%_%".format(op+1, op+1).asSymbol );
        modAVal = node.get("mod%_%".format(op+1, modNums[0]).asSymbol );
        modBVal = node.get("mod%_%".format(op+1, modNums[1]).asSymbol );
        opOutVal = node.get("%out".format(opkey).asSymbol);

        opRatioCoarse = NumberBox()
        .palette_(palette)
        .background_(Color.clear)
        .font_(Font(size:32))
        .decimals_(0)
        .clipLo_(0)
        .clipHi_(20)
        .stringColor_(opColor)
        .normalColor_(opColor)
        .action_({|ctrl|
            model.changed('ratioCoarse', [op, ctrl.value])        
        })
        .value_(ratioCoarse);

        opRatioFine = NumberBox()
        .palette_(palette)
        .background_(Color.clear)
        .font_(Font(size:13))
        .decimals_(3)
        .clipLo_(0)
        .clipHi_(0.999)
        .step_(0.001)
        .scroll_step_(0.001)
        .shift_scale_(100)
        .ctrl_scale_(10)
        .alt_scale_(10)
        .minWidth_(50)
        .stringColor_(opColor)
        .normalColor_(opColor)
        .action_({|ctrl|
            model.changed('ratioFine', [op, ctrl.value])        
        })
        .value_(ratioFine);

        opAmp = Slider()
        .background_(Color.clear)
        .thumbSize_(3)
        .knobColor_(opColor)
        //.alt_scale_(0.01)
        .action_({|ctrl|
            model.changed('amp', [op, ctrl.value])        
        })
        .value_(opVal.debug("opval"));

        opFb = Slider()
        .background_(Color.clear)
        .thumbSize_(3)
        .knobColor_(opColor)
        .step_(0.001)
        .action_({|ctrl|
            model.changed('fb', [op, ctrl.value])        
        })
        .value_(opFbVal);

        modA = Button()
        .palette_(palette)
        .background_(Color.clear)
        .states_([ 
            [nil, colors[ mods[0] ], Color.grey.alpha_(0.4)  ],
            [nil, nil, colors[ mods[0] ].copy  ] 
        ])
        .action_({|ctrl|
            model.changed('mod', [op, mods[0], ctrl.value])        
        })
        .maxWidth_(10)
        .value_(modAVal);

        modB = Button()
        .palette_(palette)
        .background_(Color.clear)
        .states_([ 
            [nil, colors[ mods[0] ], Color.grey.alpha_(0.4)  ],
            [nil, nil, colors[ mods[1] ].copy  ] 
        ])
        .action_({|ctrl|
            model.changed('mod', [op, mods[1], ctrl.value])        
        })
        .maxWidth_(10)
        .value_(modBVal); 

        opOut = Button()
        .palette_(palette)
        .background_(Color.clear)
        .states_( [ ["☀︎", Color.grey, Color.clear], ["☀︎", opColor, Color.clear] ] )
        .maxWidth_(10)
        .font_(Font(size:15))
        .action_({|ctrl|
            model.changed('opOut', [op, ctrl.value])
        })
        .value_(opOutVal);

        view.layout.add(
            HLayout(
                VLayout(
                    opRatioCoarse,
                    opRatioFine,
                ).margins_(0).spacing_(0),
                HLayout(
                    opAmp,
                    opFb,
                ).margins_(0).spacing_(0),
                HLayout(
                    UiModule('aeg').(node, if(op > 0) {opkey}{nil}  ).minWidth_(150).maxHeight_(75),
                    VLayout(
                        opOut,
                        modA,
                        modB
                    )
                ).margins_(0).spacing_(0)
            ).margins_(0).spacing_(0)
        );

        view;
    };

    view.layout.add(
        opView.(2, [0, 1])
    );
    view.layout.add(
        opView.(1, [0, 2])
    );
    view.layout.add(
        opView.(0, [1, 2])
    );
    view.front;    
};

(func: func)
)