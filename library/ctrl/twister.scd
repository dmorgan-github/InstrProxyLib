(
var midi = Module('ctrl/midi').();

var ctrl = Environment.make({|self|

    self.know = true;
    midi.connect("twister");

    // ~twister = M('ctrl/twister').()
    // ~twister.twist(~t[4].node, \softclip_drive -> 0)
    self.cc = {|self, node ...assoc|
        midi.cc("mf_twist_%".format(node.key).asSymbol, 0, node, *assoc)
    };

    self.note = {|self, on, off|
        var obj = ();
        var chan = 1;
        var key = "mf_twist_%".format(chan).asSymbol;
        obj[\on] = {|self, note, vel|
            on.(note, vel)    
        };
        obj[\off] = {|self, note|
            off.(note)
        };
        midi.note(key, chan, obj)
    };

    self.click = {|self, func|
        midi.control('mf_click', 3, (0..16), func)
    };

    self.disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { ctrl } )
)



