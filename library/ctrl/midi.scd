(
var ctrl = Environment.make({|self|

    var actions = Dictionary();
    self.know = true;

    self.onAction = {|self, action, func|
        actions.put(action, func);
        self
    };

    self.connect = {|self, device, name, cb|

        fork({

            var dest, src, out;
            var sources, destinations;

            // MIDIClient.list is async
            MIDIClient.list;
            0.5.wait;

            sources = MIDIClient.sources;
            destinations = MIDIClient.destinations;

            src = sources.select({|e|
                e.device.toLower.contains(device.asString.toLower)
            });

            if (src.size == 0) {
                "midi source not found".throw;
            } {
                if (src.size > 1) {
                    if (name.notNil) {
                        var result = src.select({|e| e.name.asString.toLower.contains(name.asString.toLower) });
                        if (result.size > 0) {
                            src = result[0]
                        }{
                            "unable to find src % with %".format(device, name).throw
                        }
                    } {
                        "multiple ports for src device".throw
                    }
                } {
                    src = src[0]
                };
            };

            dest = destinations.select({|e| 
                e.device.asString.toLower.contains(device.asString.toLower) 
            });

            if (dest.size == 0) {
                "midi destination not found".throw;
            }{
                if (dest.size > 1) {
                    if (name.notNil) {
                        var result = dest.select({|e| e.name.asString.toLower.contains(name.asString.toLower) });
                        if (result.size > 0) {
                            dest = result[0]
                        }{
                            "unable to find dest % with %".format(device, name).throw
                        }
                    }{
                        "multiple ports for dest device".throw
                    }
                } {
                    dest = dest[0]
                };
            };

            out = MIDIOut.newByName(dest.device, dest.name).connect;
            MIDIIn.connect(device: src);

            self.src = src.debug("src");
            self.dest = dest.debug("dest");
            self.out = out.debug("out");

            cb.(self)
        });
    };

    self.note = {|self, chan=0|
        
        var srcId, note;
        var key = self.src.name;
        var noteonkey = "%_%_noteon".format(key, chan).asSymbol.debug("noteon");
        var noteoffkey = "%_%_noteoff".format(key, chan).asSymbol.debug("noteoff");
        srcId = self.src.uid.debug("src uid");

        if (note.isNil) {
            note = (0..110);
        };

        MIDIdef.noteOn(noteonkey, {|vel, note, chan|
            actions['noteOn'].(note, vel, chan)
        }, noteNum:note, chan:chan, srcID: srcId)
        .fix;

        MIDIdef.noteOff(noteoffkey, {|vel, note, chan|
            actions['noteOff'].(note, chan);
        }, noteNum:note, chan:chan, srcID: srcId)
        .fix;

        self;
    };

    self.bend = {|self, chan=0, bendmid=8191, bendmin=(-12), bendmax=12|
        var key = self.src.name;
        var bendkey = "%_%_bend".format(key, chan).asSymbol.debug("bend");
        var srcId = self.src.uid.debug("src uid");

        MIDIdef.bend(bendkey, {|val, chan|
            val = val.linlin(0, bendmid * 2, bendmin, bendmax);
            actions['bend'].(val, chan);
        }, chan:chan, srcID: srcId)
        .fix;

        self;
    };

    self.cc = {|self, chan=0, ccNums|

        var key = self.src.name;
        var cckey = "%_%_cc".format(key, chan).asSymbol.debug("cc");
        var srcId = self.src.uid.debug("src uid");

        MIDIdef.cc(cckey, {|val, num, chan|
            actions['cc'].(num, val, chan);
        }, ccNum:ccNums, chan:chan, srcID:srcId)
        .fix;

        self;
    };

    // TODO: Update to find defs based on key prefix
    self.disconnect = {|self|
        //var noteonkey = "%_noteon".format(key).asSymbol;
        //var noteoffkey = "%_noteoff".format(key).asSymbol;
        //var bendkey = "%_bend".format(key).asSymbol;
        //var cckey = "%_cc".format(key).asSymbol;
        //[noteonkey, noteoffkey, bendkey, cckey].do({|mykey| MIDIdef(mykey).permanent_(false).free });
    };

});

(func: { ctrl })
)
