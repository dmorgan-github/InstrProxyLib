(
/*
this is a convenience object for wiring midi to a single node
*/
var ctrl = Environment.make({|self|

    var midi = Module('ctrl/midi').();
    var node;

    self.know = true;

    self.addAction = {|self, action, func|
        midi.onAction(action, func);
        self;
    };

    self.construct = {|self, device, name|
        // provide default behavior to assume playing a node
        // these actions can be overridden
        // before calling .note
        midi
        .onAction('noteOn', {|note, vel, chan| 
            node.on(note, vel) 
        })
        .onAction('noteOff', {|note, vel, chan| 
            node.off(note) 
        })
        .onAction('bend', {|val, chan| 
            node.set(\bend, val) 
        });
        .connect(device, name);
        self;
    };

    self.note = {|self, obj, chan=0|
        node = obj;
        midi.note(chan) ;
        self;
    };

    // ~mu.cc( t(5), [atk:34, dec:35] )
    self.cc = {|self, obj, kv, chan=0|
        var props, ccNums, order;
        node = obj;
        kv = kv.as(Dictionary);
        props = kv.collect({|v, k| k }).as(Array);
        ccNums = kv.collect({|v, k| v }).as(Array);
        order = Order.newFromIndices(props, ccNums);

        midi.onAction('cc', {|num, val, chan|
            var mapped, ctrl, spec, filter;
            ctrl = order[num];
            if (ctrl.isFunction) {
                ctrl.(val)
            } {
                spec = node.getSpec[ctrl];
                if (spec.isNil) {
                    spec = [0, 1].asSpec;
                };
                mapped = spec.map(val/127);
                node.set(ctrl, mapped);
            }    
        });

        // try to initialze device with current values
        order.indices.do({|num|
            var spec, min, max, current, ccval;
            var ctrl = order[num];

            if (ctrl.isFunction) {
            }{
                spec = node.getSpec[ctrl];
                if (spec.isNil) {
                    spec = [0, 1].asSpec;
                };

                min = spec.minval;
                max = spec.maxval;
                current = node.get(ctrl);
                if (current.notNil) {
                    // don't know how to unmap to a range that is not 0-1
                    if (spec.warp.isKindOf(ExponentialWarp)) {
                        ccval = current.explin(min, max, 0, 127);
                    }{
                        ccval = current.linlin(min, max, 0, 127);
                    };
                    try {
                        midi.out.control(chan, num, ccval);
                    } {|err|
                        "midi out: %".format(err).warn;
                    }
                }
            }
        });

        midi.cc(chan, ccNums);

        self;
    };

    self.disconnect = {|self|
        midi.disconnect();
    }
});

( func: {|device, name| ctrl.construct(device, name) } )
)