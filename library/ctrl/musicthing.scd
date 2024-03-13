(
var midi = Module('ctrl/midi').();

var ctrl = Environment.make({|self|

    self.know = true;

    self.cc = {|self, node ...assoc|
        midi.connect("Music Thing m0 Plus", nil, {|ctrl|
             ctrl.cc("musicthing_%".format(node.key).asSymbol, 0, node, *assoc)
        });
    };

    self.disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { ctrl } )
)