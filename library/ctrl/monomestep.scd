(
var func = {

    var grid;
    var server, stepvals, ptrn, cb, connect;
    var prevXY;
    var cols = 16, rows = 8;
    var alpha = 0.3;
    var numsteps = 16;

    stepvals = numsteps.collect({\});//[0, 1, 0, 2, 1, 4, 0, 5];

    connect = {

        var grid;
        var result = Deferred();
        grid = MonomeGrid(); // if we don't want to change rotation, we can leave the argument out
    
        s.waitForBoot({
            MonomeGrid.setAddCallback({arg serial, port, prefix;
                ("grid added: " ++ serial ++ " " ++ port ++ " " ++ prefix).debug("monome grid");
                if( serial == MonomeGrid.getConnectedDevices[0], {
                    cols = grid.cols;
                    rows = grid.rows;
                });
                result.value = grid;
            });
            grid.connect(0);
        });
        result
    };

    cb = {|x, y, z|


        if (z == 1 and: {x < numsteps} ) {

            var prev = stepvals[x];
            var val = rows-1-y;

            if (val == prev) {
                // switching off this step
                // insert a rest and turn off lights
                stepvals[x] = \;
                grid.led(x, y, 0);
            } {
                // update button
                stepvals[x] = val;
                grid.led(x, y, 15 * alpha);
            };

            if (prev.isRest.not) {
                prev = rows-1-prev;
                grid.led(x, prev, 0);
                
            };
        }
    };

    Routine({
        var def;
        "connecting...".inform;
        def = connect.();
        def.wait();
        grid = def.value;
        "connected...".inform;
        grid.key({|x,y,z|
            var pos = x + (y * cols);
            cb.(x, y, z);
        });
    }).play;

    server = Server.default;
    prevXY = [-1,-1];

    ptrn = Pspawner({|sp|

        inf.do({|i|
            var evt;
            var step = i.mod(numsteps);
            var stepval = stepvals.wrapAt(step);

            evt = Pbind(
                \step, Pn(step, 1),
                \stepval, Pn(stepval, 1),
                \display, Pfunc({
                    server.bind({
                        numsteps.do({|i|
                            if (i == step) {
                                if (stepval.isRest.not) {
                                    var y = rows-1-stepval;
                                    grid.led(step, y, 15);
                                }
                            }{
                                var other = stepvals.wrapAt(i);
                                if (other.isRest.not ) {
                                    var y = rows-1-other;
                                    grid.led(i, y, 15 * alpha );   
                                }  
                            }
                        })
                    });
                    1
                }) 
            );
            sp.seq(evt);
        })
    });
    ptrn
};

(func: func)
)