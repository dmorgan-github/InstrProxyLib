(
var midi = Module('ctrl/midi').();

var ctrl = Environment.make({|self|

    self.know = true;

    self.note = {|self, node, chan=0|
        var key = node.key;
        midi.connect("microlab", nil, {|ctrl|
            ctrl.note(key, chan, node);
            ctrl.bend(key, chan, {|v| node.set(\bend, v) })
        });
    };

    /*
    ~cc = {|self, node, chan ...assoc|
        //[node, chan, assoc].debug("******");
        MidiCtrl.connect("microlab", "microlab", {|ctrl|
             ctrl.cc(node.key, chan, node, *assoc)
        });
    };
    */

    self.disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { ctrl } )
)
