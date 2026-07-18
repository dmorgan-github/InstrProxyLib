(
func: {|node|

	var view = View();
	var baseview;
    var keys = Order.new;

    var defaultScale = \majorPentatonic;
    var scale = Scale.at(defaultScale);
    var map, rows, cols, buttons, hilight;
    var keyboard, grid, func, scales;
    var keyboardview, update;
    var mode = node.get(\kbmode) ?? \push;
    var order;
    var root;
    var octaveVal;

    var palette = QPalette()
    .window_(Color.magenta)
    .windowText_(Color.green)
    .button_(Color.black)
    .buttonText_(Color.white )
    .base_(Color.blue)
    .baseText_(Color.yellow)
    .highlight_(Color.cyan)
    .highlightText_(Color.magenta);

    palette.setColor(Color.black, \shadow);
    palette.setColor(Color.black, \dark);
    palette.setColor(Color.black, \middark);

    octaveVal = (node.get(\octave) ?? 3).debug("octave");
    root = (node.get(\root) ?? 0).debug("root");

    // TODO: wtf
    if ( node.get(\scale).isKindOf(Scale) ) {
        var temp;
        scale = node.get(\scale);
        temp = Scale.all.parent.select({|s| s.name == scale.name.asString });
        if (temp.size > 0) {
            defaultScale = temp.keys.as(Array)[0]
        }
    };

    //if (node.get(\scale).isKindOf(Scale)) {
        //scale = node.get(\scale);
        //defaultScale = scale.name;
    //};

    order = node.get(\kb_toggle);
    if (order.isNil) {
        order = Order();
        node.set(\kb_toggle, order);    
    };

    map = [
		'z', 's', 'x', 'd', 'c',
		'v', 'g', 'b', 'h', 'n',
		'j', 'm', 'q', '2', 'w',
		'3', 'e', 'r', '5', 't',
		'6', 'y', '7', 'u', 'i'
	];

	rows = 5;
	cols = 5;

	buttons = rows * cols;

    hilight = {
        if (scale.isKindOf(Scale)) {
            scale.degrees;
        }{
            scale
        }
    };

    keyboardview = View().fixedSize_(200@100);

    update = {

        var obj = {|label, borderColor, borderSize, background|

            var holder = SCViewHolder();
            var view = StaticText()
            .string_(label)
            .align_(\center)
            .background_(background)
            .mouseDownAction_({|ctrl|
                ctrl.background = Color.white    
            })
            .mouseUpAction_({|ctrl|
                ctrl.background = background
            });
        
            var border = UserView(bounds:Rect(width:50, height:50))
            .background_(borderColor)
            .layout_(VLayout(view).margins_(borderSize))
            ;
        
            holder.view_(border);
        };


        keyboard = buttons.collect({arg i;

            var label;
            var color = Color.grey.alpha_(0.3);
            var num = buttons-i;
            num = buttons - num;
            label = map[num];
            if (hilight.().includes(num.mod(12))) {
                color = node.color;
                color.alpha_(0.5);
            };

            /*
            obj.(label, Color.white, 1, color);
            */

            Button()
            .palette_(palette)
            .states_([[label, nil, color], [label, nil, Color.white.alpha_(0.9)]])
            //.fixedWidth_(20)
            .mouseDownAction_({arg ctrl;
                var octave = (node.get(\octave) ?? 3);
                if (mode == \push) {
                    var note = 12 * octave + num + root;
                    var vel = num.linlin(0, 24, 127, 100);
                    node.on(note, vel);
                    ctrl.value = 1;
                };
            })
            .mouseUpAction_({arg ctrl;
                //var note = 12 * octave + num + root;
                if (mode == \push) {
                    ctrl.value = 1;
                };
            })
            .action_({|ctrl|
                var octave = (node.get(\octave) ?? 3);
                var note = 12 * octave + num + root;
                if (ctrl.value == 1) {
                    // toggle mode
                    var vel = num.linlin(0, 24, 127, 100);
                    order.put(i, 1);
                    node.on(note, vel);
                } {
                    //[i, \toggle_off].postln;
                    order.removeAt(i);
                    node.off(note);
                }
            })
            .value_(order[i]);
        });

        grid = rows.collect({arg i;
            cols.collect({arg j;
                var num = cols * i + j;
                keyboard[buttons-1-num];
            }).reverse;
        });

        keyboardview.children.do({|child|
            child.remove
        });

        keyboardview.layout = VLayout(
            GridLayout.rows(*grid).margins_(0).spacing_(0),
        ).margins_(0).spacing_(0);

    };

    scales = {
        var names = Scale.names.select({|scale| Scale.at(scale).pitchesPerOctave == 12 });
        var default = names.detectIndex({|n| n == defaultScale});
        PopUpMenu().items_([""] ++ names).action_({|ctrl|
            if (ctrl.item != "") {
                scale = Scale.at(ctrl.item.asSymbol);
                update.();
            }
        })
        .background_(Color.clear)
        .value_(default+1);
    };

    update.();

	view = view
    .name_('kb')
	.layout_(VLayout(
        HLayout(
            scales.(),
            Button()
            .states_([  ["push", nil, Color.clear.alpha_(0.5)], ["toggle", nil, Color.clear.alpha_(0.5)] ] )
            .action_({|ctrl|
                if (ctrl.value == 1) {
                    mode = \toggle
                }{
                    mode = \push
                };
                node.set(\kbmode, mode);
            })
            .value_( if (mode == \push) {0}{1} )
        ),
        keyboardview,

        LevelSlider('octave', spec:[1, 8, \lin, 1, 4].asSpec, color:node.color)
        .action_({|ctrl|
            node.set('octave', ctrl.value);
        })
        .mouseDownAction_({|ctrl, x, y, mod, num, count|
            false    
        })
        .value_(octaveVal)

    ).spacing_(2).margins_(2))
    .mouseDownAction_({|ctrl, x, y, mod, num, count|
        \active.debug("kb");
        if (num == 1) {
            Menu(
                MenuAction("A", { "A selected".postln }),
                MenuAction("B", { "B selected".postln }),
                MenuAction("C", { "C selected".postln }),
            ).front;
        };
        keyboardview.focus(true)
    })
    //.mouseOverAction_({|ctrl|
    //    \mouseover.postln;    
    //})
	.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
		var val = map.indexOf(char.asSymbol);

		if (val.isNil.not) {
            var vel = val.linlin(0, 24, 127, 100);
			var num = val;
            var octave = (node.get(\octave) ?? 3);
			var note = 12 * octave + val + root;
            if (keys[note].isNil) {
                keys[note] = 1;
                node.on(note, vel);
                if (num < keyboard.size) {
                    keyboard[num].value = 1;
                };
            } {
                if (mode == \toggle) {
                    keys.removeAt(note);
                    node.off(note);
                    if (num < keyboard.size) {
                        keyboard[num].value = 0;
                    };
                }
            }
		};
		true;
	})
	.keyUpAction_({arg ctrl, char;
		var val = map.indexOf(char.asSymbol);
        if (mode == \push) {
            if (val.isNil.not) {
                var num = val;
                var octave = (node.get(\octave) ?? 3);
                var note = 12 * octave + val + root;
                keys.removeAt(note);
                node.off(note);
                if (num < keyboard.size) {
                    keyboard[num].value = 0;
                };
                true;
            }
        };
        true
	})
    .resize_(1)
	.onClose_({arg ctrl;
        //
	});

    view
}
)
