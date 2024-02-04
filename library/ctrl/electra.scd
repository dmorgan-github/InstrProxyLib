(
    var midi = Module('ctrl/midi').();
    
    ~ctrl = Environment.make({|self|
    
        self.know = true;
        
        self.start = {|self, t|
            //[node, chan, assoc].debug("******");
            if (t.notNil) {
                midi.connect("Electra Controller", "Electra Port 1", {|ctrl|
                    (0..7).do({|i|
                        var key = "t%".format(i+1);
                        var nums = (1..4) + (4 * i);
                        ctrl.control(key, 0, nums, {|num, val|
                            var action = (num-1).mod(4);
                            var node = t[i+1];
                            if (node.notNil) {
                                switch(action, 
                                    0, {
                                        if (val > 0) {
                                            node.play
                                        }{
                                            node.stop
                                        }
                                    },
                                    1, {
                                        var amp = val.linlin(0, 127, 0, 2);
                                        node.set(\amp, amp)
                                    },
                                    2, {
                                        var pan = val.linlin(0, 127, -1, 1);
                                        node.set(\center, pan)
                                    },
                                    3, {
                                        var width = val.linlin(0, 127, 0, 1);
                                        node.set(\spread, width)
                                    }
                                )
                            }
                        }); 
                    });
                });
            } {
                "t is nil".warn
            }
        };
    
        self.disconnect = {|self, node|
            var key = node.key;
            midi.disconnect(key);
        }
    });
    )




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
