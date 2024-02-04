(
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

/*
var getGridVals = {|scale='major', interval=7, root=24|
    var vals;
    var degrees, data, size;
    root = root ?? {'c1'.namemidi};
    interval = interval ?? {7};
    degrees = (Scale.at(scale.asSymbol).degrees ++ (Scale.at(scale.asSymbol).degrees + 12))[..7];
    size = degrees.size;
    data = degrees.collect({|degree|
        var val = root + degree + (interval * (0..(size-1)));
        val.nearestInScale(degrees);
    });
    data
};
*/

var getGridVals = {|scale='major', interval=7, root=24|

    var result, degrees, nearestInScale;
    var stepsPerOctave;    

    if (scale.isKindOf(Symbol)) {
        scale = Scale.at(scale.asSymbol);
    } {
        if (scale.isKindOf(Array)) {
            scale = Scale(scale)
        }
    };

    stepsPerOctave = scale.stepsPerOctave;
    degrees = scale.degrees;

    // find the closest value in the scale less than or equal to current value
    nearestInScale = {|degree, scale, stepsPerOctave=12|

        var root, key, result;
        root = degree.trunc(stepsPerOctave);
        key = degree % stepsPerOctave;
        result = key;

        if (scale.includes(key).not ) {
            scale.do({|v, i|
                if (key > v and: {key < scale.wrapAt(i+1)} ) {
                    result = v;
                }  
            });
        };    
        result + root
    };

    // ensure we have 8 values for the y axis even if the scale has less than 8 degrees
    // there is probably a more elegant way to do this
    degrees = ( scale.degrees ++ (scale.degrees + 12) )[..7];
    result = degrees.collect({|v|
        var temp = root + v;
        var list = [];
        8.do({
            temp = nearestInScale.(temp, degrees, stepsPerOctave);
            list = list.add(temp);
            temp = temp + interval;
        });
        list;
    });

    result;
};

var getHilights = {|vals, root=24|

    var degreevals, result;
    "getHilights".postln;
    degreevals = (root + [0, 12, 24, 36, 48, 60, 72, 84]);
    result = vals.collect({|row|
        row.collect({|v|
            //[degreevals, v].debug("*************");
            degreevals.asInteger.includes(v.asInteger)
        })    
    });
    result.reverse
};

var func = {|self|

    var setup, cb, grid;
    var cols = 16;
    var rows = 8;
    var kbcols = 8;
    var keys = Array.fill(kbcols*rows, {0});
    var node;
    var data = ();
    var gridvals, hilights, interval=7, scale=\major, root=24;

    self.know = true;

    gridvals = getGridVals.(scale, interval, root);
    hilights = getHilights.(gridvals);

    self.data = { data };
    self.node = { node };
    self.kbMode = \press;
    self.gridVals = { gridvals };
    self.hilights = { hilights };
    self.scale = { scale };
    self.root = { root };
    self.interval = { interval };

    self.setNode = {|self, argNode, argInterval=7|
        node = argNode;
        interval = argInterval;
        scale = node.get(\scale) ?? Scale.major;
        root = 24 + (node.get(\root) ?? 0);

        [\scale, (root + scale.degrees).midiname, \root, root, \interval, interval].debug("grid");
        gridvals = getGridVals.(scale, interval, root);
        hilights = getHilights.(gridvals, root);
        self.wake;
    };

    self.wake = {

        \wake.debug("monomekb");

        grid.all(0);  
        // restore toggled keys
        rows.do({|y|
            kbcols.do({|x|
                var pos = x + (y * kbcols);
                var val = keys[pos];
                if (val == 1) {
                    grid.led(x, y, 15)
                } {
                    if (hilights[y][x]) {
                        grid.led(x, y, 3)    
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
            var row = kbcols-1-y;
            var note = gridvals[row][x];
            if (z == 1) {
                self.node.on(note)
            }{
                self.node.off(note)
            }
        };
        1
    };

    cb = {|x, y, z|

        var kbX = x.mod(kbcols);
        var pos = kbX + (y * kbcols);

        // only respond to first 8 cols
        if (x < kbcols) {
            if (z == 1) {
                var alpha = 1;
                if (self.kbMode == \toggle) {
                    keys[pos] = 1 - keys[pos];
                    alpha = keys[pos];
                };

                self.onKbPress(x, y, alpha);
                if (alpha.notNil and: {alpha.isNumber} ) {
                    grid.led(x, y, 15 * alpha);
                }
            }{
                if (self.kbMode == \press) {
                    var alpha = self.onKbPress(x, y, 0);
                    if (alpha.notNil and: {alpha.isNumber}) {

                        var hilight = hilights[y][x];
                        if (hilight) {
                            grid.led(x, y, 3);
                        }{
                            grid.led(x, y, 0);
                        }
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
            //self.wake();
        }).play
    };

    setup.()
};

(func: { Environment.make(func) }  )
)