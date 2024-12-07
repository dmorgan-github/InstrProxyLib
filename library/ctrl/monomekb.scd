(
var cols = 16;
var rows = 8;

var connect = {
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
    result = degrees.collect({|note|
        var list = [note];
        (1..7).do({|i|
            note = note + interval;
            //note = note.nearestInScale(degrees, stepsPerOctave);
            note = nearestInScale.(note, degrees, stepsPerOctave);
            list = list.add(note)
        });
        result.add(list);
        list
    });

    result = result + root;
    result;
};

// hilights for octaves
var getHilights = {|vals, root=24|
    var degreevals, result;
    degreevals = (root + [0, 12, 24, 36, 48, 60, 72, 84, 96, 108]);
    //vals.debug("getHighlights");
    result = vals.collect({|row|
        row.collect({|v|
            degreevals.asInteger.includes(v.asInteger)
        })    
    });
    result.reverse
};

var func = {|self|

    var handler, grid, onKbPress;
    var kbcols = 8;
    var numtracks = 8;
    var keys = Array.fill(kbcols*rows*numtracks, {0});
    var gridvals, hilights;
    var octaveHiLight = 3;
    var ledOn = 15;
    var prevX = -1;
    var launchGrid = Array.fill2D(7, 8, {0});
    var actions = Dictionary();

    self.know = true;
    self.kbMode = \press;
    self.defaultRoot = 24;

    self.initKb = {|self, scale=(Scale.major), mode='press', root=0, interval=7|
        if (scale.isArray) {
            scale = Scale(scale)
        };

        root = self.defaultRoot + root;
        gridvals = getGridVals.(scale, interval, root);
        //gridvals.midiname.debug("monomekb");
        hilights = getHilights.(gridvals, root);
        self.kbMode = mode;
        self.wake;
        self;
    };

    self.onAction = {|self, action, func|
        actions.put(action, func);
        self
    };

    self.wake = {

        var offset, end, temp;
        grid.all(0);  
        // restore toggled keys

        offset = (prevX.max(0) - kbcols) * kbcols * rows;
        end = offset + (kbcols * rows) -1;
        //[offset, offset + (kbcols * rows) -1].debug("offset");
        temp = keys[offset..end];
        rows.do({|y|
            kbcols.do({|x|
                var pos = x + (y * kbcols);
                var val = temp[pos];
                if (val == 1) {
                    grid.led(x, y, ledOn)
                } {
                    if (hilights[y][x]) {
                        grid.led(x, y, octaveHiLight)    
                    }
                }
            })
        });
    };

    self.sleep = {
        \sleep.debug("monomekb");
        grid.all(0);
        grid.key(nil)
    };

    self.config = {|self, kv|
        \config.debug("monomekb");
        if (kv.notNil) {
            actions = kv.as(Dictionary);
        };
        self;
    };
    
    onKbPress = {|x, y, z|
        var row = kbcols-1-y;
        var note = gridvals[row][x];
        if (z == 1) {
            actions[\noteOn].(self, [note, 127]);
        }{
            actions[\noteOff].(self, [note]);
        };
        1
    };

    handler = {|x, y, z|

        // left hand side
        if (x < kbcols) {
            var hilight = hilights[y][x];
            // button press
            if (z == 1) {

                if (self.kbMode == \toggle) {
                    var offset;
                    var kbX = x.mod(kbcols);
                    var pos = kbX + (y * kbcols);

                    offset = (prevX - kbcols) * kbcols * rows;
                    pos = pos + offset;
                    keys[pos] = 1 - keys[pos];
                    z = keys[pos];
                };

                onKbPress.(x, y, z);
                if (hilight and: {z == 0} )  {
                    grid.led(x, y, octaveHiLight);
                }{
                    grid.led(x, y, ledOn * z);
                }
            }{
                if (self.kbMode == \press) {å
                    onKbPress.(x, y, z);
                    if (hilight) {
                        grid.led(x, y, octaveHiLight);
                    }{
                        grid.led(x, y, z);
                    }
                }
            }
        } {
            // right hand side
            if (z == 1) {
                var num = x - kbcols;
                // track selection
                if (y == 0) {
                    if (prevX > 0) {
                        grid.led(prevX, 0, 0);    
                    };
                    prevX = x;
                    actions[\select].(self, num);
                    //self.changed(\select, num);
                    grid.led(x, 0, ledOn); 
                } {
                    // if not playing then play
                    if (launchGrid[y-1][num] == 0) {
                        // find and turn off previous led
                        launchGrid.do({|row, i|
                            if (row[num] == 1) {
                                launchGrid[i][num] = 0;
                                grid.led(x, i+1, 0)
                            };
                        });
                        launchGrid[y-1][num] = 1;
                        actions[\play].(self, [num, y-1]);
                        //self.changed(\play, [num, y-1]);
                        grid.led(x, y, ledOn);  
                    } {
                        // otherwise stop playing
                        launchGrid[y-1][num] = 0;
                        actions[\stop].(self, [num, y-1]);
                        //self.changed(\stop, [num, y-1]);
                        grid.led(x, y, 0);    
                    };
                };
            }
        }
    };

    // default config
    self.config([
        noteOn: {|obj, val| 
            var note = val[0];
            var vel = val[1];
            if (obj.node.notNil) {
                obj.node.on(note, vel);
            }; 
        },
        noteOff: {|obj, val|
            var note = val[0];
            if (obj.node.notNil) {
                obj.node.off(note)
            };
        },
        select: {|obj, val|
            var num = val+1;
            obj.node = T.tracks[num];
            if (obj.node.notNil) {
                var scale = obj.node.get(\scale);
                var root = obj.node.get(\root);
                var mode = obj.node.get(\kbmode) ?? 'press';
                //scale=(Scale.major), mode='press', root=0, interval=7
                obj.initKb(scale, mode, root, 7);
            } {
                "track % not set".format(num).debug("select")
            }
        },
        play: {|obj, val|
            var num = val[0]+1;
            var track = T.tracks[num];
            if (track.notNil) {
                track.play;
            };  
        },
        stop: {|obj, val|
            var num = val[0]+1;
            var track = T.tracks[num];
            if (track.notNil) {
                track.stop;
            }; 
        },
        startUp: {|obj| obj.initKb; }
    ]);

    // start up
    fork({
        var def;
        "connecting...".inform;
        def = connect.();
        def.wait();
        grid = def.value;
        grid.key(handler);
        "connected...".inform;
        actions['startUp'].(self)
    });
};

(
    func: {|kv| Environment.make(func).config(kv) },
    doc: ""
)
)