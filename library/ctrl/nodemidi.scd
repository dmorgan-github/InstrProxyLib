(
/*
convenience object for wiring midi to a single node
*/
var ctrl = Environment.make({|self|

    var midi = Module('ctrl/midi').();
    var nodes = Order();

    self.know = true;

    self.midi = midi;

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
            var node = nodes[chan];
            node.on(note, vel) 
        })
        .onAction('noteOff', {|note, chan|
            var node = nodes[chan];
            node.off(note) 
        })
        .onAction('bend', {|val, chan|
            //[\bend, val].debug("nodemidi.scd");
            var node = nodes[chan];
            node.bend(val)
        })
        .connect(device, name);
        self;

    };

    self.note = {|self, obj, chan=0|
        //node = obj;
        nodes.put(chan, obj);
        midi.note(chan);
        midi.bend(chan);
        self;
    };

    // ~mu.cc( t(5), [atk -> 34, dec -> 35] )
    self.cc = {|self, obj, kv, chan=0|
        var props, ccNums, order;
        var node = obj;
        nodes.put(chan, node);
        kv = kv.sort({|a, b| b.value > a.value });
        props = kv.collect({|a| a.key }).as(Array);
        ccNums = kv.collect({|a| a.value }).as(Array);
        order = Order.newFromIndices(props, ccNums);

        midi.onAction('cc', {|num, val, chan|
            var mapped, ctrl, spec, filter;
            var node = nodes[chan];
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
        //MIDIClient.init;
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
                    ccval = ccval.asInteger;
                    try {
                        //[chan, num, ccval].debug("nodemidi");
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
