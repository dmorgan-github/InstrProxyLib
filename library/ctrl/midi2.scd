(
var ctrl = Environment.make({|self|

    self.know = true;

    self.connect = {|self, device, name, cb|

        //var def = Deferred();

        fork({

            var dest, src, out;
            var sources, destinations;

            // MIDIClient.list is async
            MIDIClient.list;
            0.5.wait;
            //def.value = \done;

            sources = MIDIClient.sources;
            destinations = MIDIClient.destinations;

            src = sources.select({|e|
                e.device.toLower.contains(device.asString.toLower)
            });

            src = if (src.size > 1) {
                if (name.notNil) {
                    var result = src.select({|e| e.name.asString.toLower.contains(name.asString.toLower) });
                    if (result.size > 0) {
                        result[0]
                    }{
                        "unable to find src % with %".format(device, name).throw
                    }
                } {
                    "multiple ports for src device".throw
                }
            } {
                src[0]
            };

            dest = destinations.select({|e| 
                e.device.asString.toLower.contains(device.asString.toLower) 
            });

            dest = if (dest.size > 1) {
                if (name.notNil) {
                    var result = dest.select({|e| e.name.asString.toLower.contains(name.asString.toLower) });
                    if (result.size > 0) {
                        result[0]
                    }{
                        "unable to find dest % with %".format(device, name).throw
                    }
                }{
                    "multiple ports for dest device".throw
                }
            } {
                dest[0]
            };

            out = MIDIOut.newByName(dest.device, dest.name).connect;
            out.latency = 0;
            MIDIIn.connect(device: src);

            self.src = src.debug("src");
            self.dest = dest.debug("dest");
            self.out = out.debug("out");

            cb.(self)
        });
    };

    self.note = {|self, key, chan=0, node, note|
        
        var srcId;
        var noteonkey = "%_noteon".format(key).asSymbol.debug("noteon");
        var noteoffkey = "%_noteoff".format(key).asSymbol.debug("noteoff");

        if (note.isNil) {
            note = (0..110);
        };

        srcId = self.src.uid.debug("src uid");
        MIDIdef.noteOn(noteonkey, {|vel, note, chan|
            node.on(note, vel);
        }, noteNum:note, chan:chan, srcID: srcId)
        .fix;

        MIDIdef.noteOff(noteoffkey, {|vel, note, chan|
            node.off(note);
        }, noteNum:note, chan:chan, srcID: srcId)
        .fix;
        self;
    };

    self.bend = {|self, key, chan=0, func, bendmid=8191, bendmin=(-12), bendmax=12|
        var bendkey = "%_bend".format(key).asSymbol.debug("bend");
        var srcId = self.src.uid.debug("src uid");

        MIDIdef.bend(bendkey, {|val|
            val = val.linlin(0, bendmid * 2, bendmin, bendmax);
            func.(val);
        }, chan:chan, srcID: srcId)
        .fix;
        self;
    };

    self.control = {|self, key, chan, ccNums, func|
        var srcId;
        var cckey = "%_control".format(key).asSymbol.debug("control");
        srcId = self.src.uid.debug("src uid");

        MIDIdef.cc(cckey, {|val, num, chan|
            func.(num, val)
        }, ccNum:ccNums, chan:chan, srcID:srcId);
    };

    // node needs to be an obj with get/set methods
    // obj should have getSpec
    // assoc =  'prop' -> <ccnum>
    self.cc = {|self, key, chan, node ...assoc|

        var cckey = "%_cc".format(key).asSymbol.debug("cc");
        var props, ccNums;
        var order, srcId, out;

        //props = pairs.select({|a, i| i.even});
        //ccNums = pairs.select({|a, i| i.odd});
        props = assoc.collect({|a| a.key });
        ccNums = assoc.collect({|a| a.value });
        order = Order.newFromIndices(props.asArray, ccNums.asArray);
        srcId = self.src.uid.debug("src uid");
        out = self.out.debug("out");

        //[key, chan, node, assoc].debug("********");

        MIDIdef.cc(cckey, {|val, num, chan|
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
        }, ccNum:ccNums, chan:chan, srcID:srcId)
        .fix;

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
                    //[node.key, \curent, current, \cc, ccval].debug(ctrl);
                    try {
                        out.control(chan, num, ccval);
                    } {|err|
                        "midi out: %".format(err).warn;
                    }
                }
            }
        });
    };

    self.disconnect = {|self, key|
        var noteonkey = "%_noteon".format(key).asSymbol;
        var noteoffkey = "%_noteoff".format(key).asSymbol;
        var bendkey = "%_bend".format(key).asSymbol;
        var cckey = "%_cc".format(key).asSymbol;
        [noteonkey, noteoffkey, bendkey, cckey].do({|mykey| MIDIdef(mykey).permanent_(false).free });
    };

});

(func: { ctrl })
)
