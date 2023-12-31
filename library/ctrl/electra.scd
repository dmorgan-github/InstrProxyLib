(

var midi = Module('ctrl/midi').();

var electra = Environment.make({
    ~cc = {|self, node, chan ...assoc|
        //[node, chan, assoc].debug("******");
        midi.connect("electra", "port 1", {|ctrl|
             ctrl.cc(node.key, chan, node, *assoc)
        });
    };

   ~disconnect = {|self, node|
        var key = node.key;
        midi.disconnect(key);
    }
});

( func: { electra } )
)
