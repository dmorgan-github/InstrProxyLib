(
var view;
var numvoices = 5;
var proxy = EventPatternProxy();
var model = (
    bar: 4,

    specs: (
        dur: ControlSpec(1, 32, \lin, 1, 4),
        steps: ControlSpec(1, 16, \lin, 1, 4),
        prob: ControlSpec(0, 1, \lin, 0, 1),
        bar: ControlSpec(0.5, 32, \lin, 0.25, 8),
        tempo: ControlSpec(0.25, 5, \lin, 0, 1)
    ),

    mapBar: {|self, val|
        var spec = self['specs']['bar'];
        val = spec.map(val);
        self[\bar] = val;
        self.changed(\bar, val);
    },

    unmapBar: {|self|
        var spec = self['specs']['bar'];
        spec.unmap(self['bar'])
    },

    getBar: {|self|
        self['bar']
    },

    unmapTempo: {|self|
        var tempo = TempoClock.default.tempo;
        var spec = self['specs']['tempo'];
        var val = spec.unmap(tempo);
        val;
    },

    mapTempo: {|self, val|
        var spec = self['specs']['tempo'];
        val = spec.map(val);
        TempoClock.default.tempo = val;
        self.changed(\tempo, val);
    },

    getTempo: {|self|
        TempoClock.default.tempo
    },

    mapParamVal: {|self, index, key, val|
        var id = "%_%".format(key, index).asSymbol;
        val = self['specs'][key].map(val);
        self[id] = val;
        self.changed(id, val);
    },

    unmapParamVal: {|self, index, key|
        var id = "%_%".format(key, index).asSymbol;
        var item = self[id] ?? 1;
        var val = self['specs'][key].unmap(item);
        val;
    },

    getParamVal: {|self, index, key|
        var id = "%_%".format(key, index).asSymbol;
        self[id] ?? 1;
    },

    setParamVal: {|self, index, key, val|
        var id = "%_%".format(key, index).asSymbol;
        self[id] = val;
        self.changed(id, val);
    }
);

// add specs for each item - this will facilitate midi controllers
numvoices.do({|i|
    model[\specs]["dur_%".format(i).asSymbol] = model['specs']['dur'];
    model[\specs]["steps_%".format(i).asSymbol] = model['specs']['steps'];
    model[\specs]["prob_%".format(i).asSymbol] = model['specs']['prob']; 
});

// TODO: remove dependency on get/addSpec
proxy.addSpec(*model[\specs].asPairs);

view = {|model|

    var listener;
    var topPanel = VLayout();
    var gridlayout = GridLayout();
    var main = VLayout(topPanel, gridlayout);
    var view = View().layout_(VLayout(main)).background_(Color.black).minWidth_(400);
    var barlabel = StaticText().string_(model.getBar).fixedWidth_(35);
    var tempolabel = StaticText().string_(model.getTempo).fixedWidth_(35);

    var knobcolors = [ Color.clear, Color.grey, Color(0.1, 0.1, 0.1), Color.grey ];
    var palette = QPalette();
    var knobs = (), labels = ();

    listener = {|obj, action, vals| 
        if (action == \set) {
            var knob = knobs[vals[0]];
            var label = labels[vals[0]];
            if (knob.notNil) {
                var mapped;
                var ids = vals[0].asString.split($_);
                var key = ids[0].asSymbol;
                var index = ids[1].asInteger;
                //[key, index, vals[0], model[vals[0]] ].postln;
                mapped = model.unmapParamVal(index, key);
                {
                    knob.value = mapped;
                    label.string = vals[1];
                }.defer
            }
        } 
    };
    proxy.addDependant(listener);

    palette.setColor(Color.clear, \window, \normal);
    palette.setColor(Color.clear, \highlight, \normal);

    topPanel.add(
        HLayout(
            VLayout(
                Knob()
                .action_({|ctrl|
                    model.mapBar(ctrl.value);
                    barlabel.string = model.getBar;
                })
                .palette_(palette)
                .color_(knobcolors)
                .value_(model.unmapBar),
                HLayout(StaticText().string_("bar"), barlabel)
            ),
            VLayout(
                Knob()
                .action_({|ctrl|
                    model.mapTempo(ctrl.value);
                    tempolabel.string = model.getTempo;
                })
                .color_(knobcolors)
                .value_(model.unmapTempo),
                HLayout(StaticText().string_("tempo"), tempolabel)
            ),
            Button().action_({|ctrl|
                if (ctrl.value == 1) {
                    proxy.play
                }{
                    proxy.stop
                }
            }),
            nil
        )
    );
    numvoices.do({|i|
        var durlabel = StaticText().string_(model.getParamVal(i, \dur)).fixedWidth_(30);
        var stepslabel = StaticText().string_(model.getParamVal(i, \steps)).fixedWidth_(30);
        var prob = model.getParamVal(i, \prob) ?? [1];
        var msv = MultiSliderView().palette_(palette).background_(Color.clear);
        var nb = NumberBox().palette_(palette).background_(Color.clear);
        var durknob = Knob();
        var stepknob = Knob();

        knobs["dur_%".format(i).asSymbol] = durknob;
        knobs["steps_%".format(i).asSymbol] = stepknob;
        labels["dur_%".format(i).asSymbol] = durlabel;
        labels["steps_%".format(i).asSymbol] = stepslabel;

        gridlayout.add(VLayout(
            durknob
            .color_(knobcolors)
            .action_({|ctrl|
                model.mapParamVal(i, \dur, ctrl.value);
                durlabel.string = model.getParamVal(i, \dur);
            })
            .value_( model.unmapParamVal(i, \dur) ),
            HLayout(StaticText().string_("dur"), durlabel)
        ), i, 0);

        gridlayout.add(VLayout(
            stepknob
            .color_(knobcolors)
            .action_({|ctrl|
                model.mapParamVal(i, \steps, ctrl.value);
                stepslabel.string = model.getParamVal(i, \steps);
            })
            .value_( model.unmapParamVal(i, \steps) ),
            HLayout(StaticText().string_("steps"), stepslabel)
        ), i, 1);

        gridlayout.add(HLayout(
            msv
            .value_(prob)
            .valueThumbSize_(0.5)
            .elasticMode_(1)
            .action_({|ctrl|
                model.setParamVal(i, \prob, ctrl.value);
            }),

            nb
            .value_(prob.size)
            .minSize_(25)
            .clipLo_(1)
            .decimals_(0)
            .action_({|ctrl|
                var vals = msv.value;
                var size = ctrl.value.clip(1, 128).asInteger;
                prob = vals.wrapExtend(size);
                model.setParamVal(i, \prob, prob);
                msv.value = prob;
            })
        ), i, 2);
    });
    view
    .onClose_({
        proxy.removeDependant(listener)
    });
};

proxy.source = Ppar(numvoices.collect({|i|
    var index = 0;
    Plazy({|evt|

        var instrs = evt['instrs'] ?? [];
        var instr = instrs.wrapAt(i) ?? ();
        var bar = evt[\bar] ?? 4;
        var dur = evt["dur_%".format(i).asSymbol] ?? 4;
        var steps = evt["steps_%".format(i).asSymbol] ?? 4;
        var amp = evt["amp_%".format(i).asSymbol] ?? 0;
        var probs = evt["prob_%".format(i).asSymbol] ?? [1];

        if (i == 4) {
            dur = evt["dur_%".format(0).asSymbol];
            steps = evt["steps_%".format(0).asSymbol];
        };

        Pchain(
            Pn(instr, inf),
            Pbind(
                \dur, dur/steps,
                \mask, Prout({|inval|
                    inf.do({|j|
                        var val;
                        if ( probs.wrapAt(index).coin ) {
                            val = 1
                        }{
                            val = Rest();
                        };
                        inval = val.embedInStream(inval);
                        index = index + 1;
                    })
                })
            )
        ).finDur(bar)
    }).repeat
})
);
proxy.envir = model;
proxy.addUniqueMethod(\view, {|self| view.(self.envir) });
proxy.addUniqueMethod(\ui, {|self| self.view.front });
proxy.addUniqueMethod(\instrs, {|self, instrs| self.set(\instrs, instrs) });

(
func: { proxy },
doc: "
~seq = DMModule('device/seq').()
(
~seq.instrs([
    [midinote: 0, legato: 0.1, amp: 1].p <> ~m2,
    [midinote: 1, legato: 0.1, amp: 1].p <> ~m2,
    [midinote: 2, legato: 0.5, amp: 1].p <> ~m2,
    [midinote: 3, legato: 0.1, amp: 1].p <> ~m2,
])
)
~seq.ui;
~seq.play;
~seq.stop;
"
)
)

