
(
var func = {

    var connect, init, attach;
    var rateView, depthView, waveView, performView;
    var initLfo;
    var lfos = Array.newClear(indexedSize: 4);
    var arc;

    initLfo = {|ring, lfo|

        var sc;
        var centerLed = 0;
        var currentLed = 0;
        var centerLedVal = 8;
        var currentLedVal = 15;
        var init;

        if ( lfo.getHalo(\simpleController).notNil ) {
            sc = lfo.getHalo(\simpleController);
        }{
            sc = SimpleController(lfo);
            lfo.addHalo(\simpleController, sc);
        };

        sc.put(\xy, {|obj, what, val| 
            var y = val[1];
            y = y.linlin(0, 1, -31, 31).asInteger;
            if (currentLed == centerLed) {
                arc.led(ring, centerLed, centerLedVal);
            }{
                arc.led(ring, currentLed, 0);
            };
            arc.led(ring, y, currentLedVal);
            arc.refresh;
            currentLed = y;
        });

        sc.put(\set, {|obj, what, val|
            var index = val.indexOf(\lfoVal);
            if ( index.notNil ) {
                var lfoval = val[index+1];
                lfoval = lfoval.linlin(0, 1, -31, 31).asInteger;
                arc.led(ring, centerLed, 0);
                arc.led(ring, lfoval, centerLedVal );
                centerLed = lfoval;
            }
        });

        init = {
            var lfoval = lfo.get(\lfoVal);
            if (lfoval.notNil) {
                lfoval = lfoval.linlin(0, 1, -31, 31).asInteger;
                arc.led(ring, lfoval, centerLedVal);
                centerLed = lfoval;
            }
        };

        // set initial center value;
        init.();

        // export
        Environment.make({|self|
            self.know = true;
            self.sc = { sc };
            self.lfo = { lfo };
            self.centerLed = { centerLed };
            self.delta = {|self, delta|
                var lfoval = lfo.get(\lfoVal);
                lfoval = lfoval + ( (1/512) * delta.sign );
                lfoval = lfoval.clip(0, 1);
                lfo.set(\lfoVal, lfoval )   
            };
            self.detach = {
                lfo.removeDependant(sc)
            };
        });
    };

    connect = {
        var arc;
        var result = Deferred();
        arc = MonomeArc(); // if we don't want to change rotation, we can leave the argument out

        Server.default.waitForBoot({
            arc.connect();
            result.value = arc;
        });

        arc.delta({|ring, delta|
            var lfo = lfos[ring];
            if (lfo.notNil) {
                lfo.delta(delta)
            };
        });

        result
    };

    attach = {|ring, lfo|
        var arclfo = initLfo.(ring, lfo);
        lfos.put(ring, arclfo)
    };

    init = {
        fork({
            var def;
            "connecting to arc...".inform;
            def = connect.();
            def.wait();
            arc = def.value;
            "connected...".inform
        });
    };

    init.();

    // export
    Environment.make({|self|
        self.know = true;
        self.arc = { arc };
        self.lfos = { lfos };
        self.attach = {|self, ring, lfo|
            attach.(ring, lfo)    
        };
    });
};

(func: func)
)



