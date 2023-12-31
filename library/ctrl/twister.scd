(
var midi = Module('ctrl/midi').();

var ctrl = Environment.make({|self|

    self.know = true;

    self.twist = {|self, node ...assoc|
        midi.connect("twister", nil, {|ctrl|
             ctrl.cc("mf_twist_%".format(node.key).asSymbol, 0, node, *assoc)
        });
    };

    self.click = {|self, func|
        midi.connect("twister", nil, {|ctrl|
            ctrl.control('mf_click', 3, (0..16), func)
        });
    };

    self.disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { ctrl } )
)



