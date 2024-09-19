(
var midi = Module('ctrl/midi').();

var ctrl = Environment.make({|self|

    self.know = true;

    midi.connect("Music Thing m0 Plus", nil);

    self.cc = {|self, node ...assoc|
        midi.cc("musicthing_%".format(node.key).asSymbol, 0, node, *assoc)
    };

    self.note = {|self, on, off|
        var obj = ();
        var chan = 0;
        var key = "musicthing_%".format(chan).asSymbol;
        obj[\on] = {|self, note, vel|
            on.(note, vel)    
        };
        obj[\off] = {|self, note|
            off.(note)
        };
        midi.note(key, chan, obj)
    };

    self.disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { ctrl } )
)