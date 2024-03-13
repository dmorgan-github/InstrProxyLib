(
var midi = Module('ctrl/midi').();

var ctrl = Environment.make({|self|

    self.know = true;

    self.cc = {|self, node ...assoc|
        midi.connect("Intech Studio", nil, {|ctrl|
             ctrl.cc("intech_%".format(node.key).asSymbol, 0, node, *assoc)
        });
    };

    self.disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { ctrl } )
)