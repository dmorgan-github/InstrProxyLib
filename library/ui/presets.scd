(
func: {|node|

    var morphbeats = 20;
    var frompresetview, topresetview;

    var buttons = 16.collect({|i|
        var color_active = Color.white.alpha_(0.9);
        var color_saved = Color.green.alpha_(0.9);
        var color_empty = Color.clear.alpha_(0.9);
        var issaved = Preset.getPreset(node, i).notNil;
        var color_init = if (issaved) {color_saved}{color_empty};

        //[node, i, issaved].postln;

        Button()
        .action_({|ctrl|
            buttons.do({|btn, j|
                if (i != j) {
                    if (btn.value == 1) {
                        btn.states = [ [nil, nil, color_saved ], [nil, nil, color_active ] ]
                    };
                    btn.value = 0;
                }
            });

            if (ctrl.value == 1) {
                var preset = Preset.getPreset(node, i);
                if (preset.isNil) {
                    //log.("% preset %".format(\save, i));
                    Preset.addCurrent(node, i);
                } {
                    //log.("% preset %".format(\morph, i));
                    Preset.apply(node, i);
                };
            }{
                // button stays on
                ctrl.value = 1
            }
        })
        .mouseDownAction_({|ctrl, x, y, mod, num, count|
            // 262144 ctrl delete
            // 131072 shift overwrite
            // 524288 option
            if (mod == 262144) {
                //log.("% preset %".format(\remove, i));
                Preset.remove(node, i);
                ctrl.states = [ [nil, nil, color_empty ], [nil, nil, color_active ] ];
            };
            if (mod == 131072) {
                //log.("% preset %".format(\overwrite, i));
                Preset.addCurrent(node, i);
            };
        })
        .states_([ [nil, nil, color_init ], [nil, nil, color_active ] ])
        //.value_( if(issaved.postln) {1} {0} )
        .maxSize_(Size(12, 12))
        //.maxHeight_(12)
    });

    View().layout_(

        VLayout(

            GridLayout.rows(
                buttons
                //buttons[0..15],
                //buttons[14..27]
            ).margins_(0).spacing_(0),

            LevelSlider(\morph, [0, 127, \lin, 1, 0].asSpec, node.color)
            .maxHeight_(20)
            .action_({|ctrl|
                //ctrl.value.postln;
                var val = ctrl.value;
                var num = Preset.getPresets(node).size;
                var index = val.linlin(0, 127, 0, num-1);
                index = index.floor;
                {
                    buttons.do({|b, i|
                        b.value = 0;
                        if (i == index) {
                            b.value = 1
                        }
                    })
                }.defer;
                Preset.morph2(node, val)
            })

            /*
            NumberBox()
            .action_({|ctrl|
                morphbeats = ctrl.value;
            })
            .toolTip_("morph time")
            .fixedWidth_(25)
            .value_(morphbeats)
            .background_(Color.clear),
            */

            /*
            frompresetview = NumberBox()
            .value_(0)
            .clipLo_(0)
            .clipHi_(13)
            .minDecimals_(0)
            .fixedWidth_(25)
            .background_(Color.clear)
            ,
            */

            /*
            LevelSlider("blend", [0, 1].asSpec)
            //.orientation_(\horizontal)
            //.thumbSize_(0.7)
            .action_({|ctrl|
                var from = frompresetview.value.asInteger;
                var to = topresetview.value.asInteger;
                DMPreset.blend(node, from, to, ctrl.value);
            }),
            topresetview = NumberBox()
            .value_(0)
            .clipLo_(0)
            .clipHi_(13)
            .minDecimals_(0)
            .fixedWidth_(25)
            .background_(Color.clear)
            */

        ).margins_(2).spacing_(2),

    )
    .resize_(1)
};
)
