(

var cols = 16;
var rows = 8;
var kbrows = 7;
var kbcols = 12;

var connect = {

    var grid;
    var result = Deferred();
    grid = MonomeGrid(); // if we don't want to change rotation, we can leave the argument out

    s.waitForBoot({
        var cols = 16, rows = 8;
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

var getGridVals = {|scale='major'|
    var hilight;
    var scalevals;
    var vals, root = 'c0'.namemidi;
    scalevals = Scale.at(scale).degrees;
    hilight = kbcols.collect({|num|
        scalevals.includes(num)        
    });

    vals = rows.collect({|i|
        var start = root + (kbcols * i);
        kbcols.collect({|j|
            if (hilight[j]) {
                start + j
            } {
                nil
            }   
        })
    });
    vals.reverse
};

var func = {|self|

    var setup, cb, grid;
    var keys = Array.fill(kbcols*rows, {0});
    var node;
    var data = ();

    self.know = true;
    self.data = {
        data
    };
    self.node = {
        node;
    };
    self.node_ = {|self, val|
        node = val;
        if (data[node.key].isNil) {
            data[node.key] = (
                keys: Array.fill(kbcols*rows, {0}),
                kbMode: self.kbMode
            );    
        };
        keys = data[node.key]['keys'];
        self.kbMode = data[node.key]['kbMode'];
        self.wake;
        // TODO: wake, reset button state
    };
    self.kbMode = \press;
    self.gridVals = getGridVals.(scale:'major');
    self.setScale = {|self, scale|
        self.gridVals = getGridVals.(scale:scale);
        self.wake
    };
    self.wake = {
        \wake.debug("monomekb");
        grid.all(0);        
        rows.do({|y|
            kbcols.do({|x|
                var pos = x + (y * kbcols);
                var val = keys[pos];
                if (val == 1) {
                    grid.led(x, y, 15)
                } {
                    if (self.gridVals[y][x].notNil) {
                        grid.led(x, y, 2)   
                    }
                }
            })
        });
        grid.key({|x,y,z|
            var pos = x + (y * cols);
            cb.(x, y, z);
        })
    };
    self.sleep = {
        \sleep.debug("monomekb");
        grid.all(0);
        grid.key(nil)
    };
    
    self.onKbPress = {|self, x, y, z|
        if (self.node.notNil) {
            var note = self.gridVals[y][x];
            if (z == 1) {
                if (note.notNil) {
                    self.node.on(note)
                };
                1
            }{
                if (note.notNil) {
                    self.node.off(note);
                    0.2
                } {
                    0
                }
            }
        };
        nil;
    };

    cb = {|x, y, z|

        var kbX = x.mod(kbcols);
        var pos = kbX + (y * kbcols);

        // only respond to configured cols
        if (x < kbcols) {
            if (z == 1) {
                var alpha = 1;
                if (self.kbMode == \toggle) {
                    keys[pos] = 1 - keys[pos];
                    alpha = keys[pos];
                };

                alpha = self.onKbPress(x, y, z);
                if (alpha.notNil and: {alpha.isNumber} ) {
                    grid.led(x, y, 15 * alpha);
                }
            }{
                if (self.kbMode == \press) {
                    var alpha = self.onKbPress(x, y, 0);
                    if (alpha.notNil and: {alpha.isNumber}) {
                        grid.led(x, y, 0);
                    }
                }
            }
        }
    };

    setup = {
        Routine({
            var def;
            "connecting...".inform;
            def = connect.();
            def.wait();
            grid = def.value;
            "connected...".inform;
            self.wake();
        }).play
    };

    setup.()
};

(func: { Environment.make(func) }  )
)