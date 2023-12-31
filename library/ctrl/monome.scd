(
var active;

var getdata = {|scale='major', interval=7, root=24|
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

var mixin = {|self, obj, scale='major'|
    var data;
    data = getdata.(scale:scale);
    obj.addDependant({|obj, what val| 
        if (what == \preset) {
            var num, preset;
            num = val[0];
            obj << obj.ptrns.wrapAt(num)
        }
    });

    obj.addUniqueMethod(\kbPress, {|self, x, y, z| 
        var row = 7-y;
        var note = data[row][x];

        if (z == 1) {
            self.on(note)
        }{
            self.off(note)
        }
    });
};

var getTracks = {
    (1..8).collect({|num| 
        var key = "t%".format(num).asSymbol; 
        currentEnvironment[key] 
    })
};

var onKbPress = {|self, x, y, z|
    if (active.notNil) {
        active.kbPress(x, y, z)
    };
    1
};

var onChannelSelected = {|self, chan| 
    var tracks = getTracks.();
    active = tracks.wrapAt(chan);
};

var onLaunch = {|self, x, y, z|
    // TODO: figure out a way to not have to collect each time
    var tracks = getTracks.();
    var t = tracks.wrapAt(x);
    if (t.notNil) {
        if (z == 1) {
            var preset;
            t.play;
            // TODO: probably move this into a custom handler
            // so that we aren't making too many assumptions here
            DMPreset.apply(t, y);
        } {
            t.stop
        }
    }
};

var connect = {|cb|
    var grid = MonomeGrid(); // if we don't want to change rotation, we can leave the argument out
    s.waitForBoot({
        var cols = 16, rows = 8;
        MonomeGrid.setAddCallback({arg serial, port, prefix;
            ("grid added: " ++ serial ++ " " ++ port ++ " " ++ prefix).debug("monome grid");
            if( serial == MonomeGrid.getConnectedDevices[0], {
                cols = grid.cols;
                rows = grid.rows;
            });
        });

        grid.connect(0);
        grid.key({|x,y,z|
            var pos = x + (y * cols);
            cb.(x, y, z, grid);
        });
    });
};

var func = {|self|

    var setup;
    self.know = true;
    self.onKbPress = onKbPress;
    self.onChannelSelected = onChannelSelected;
    self.onLaunch = onLaunch;
    self.kbMode = \press;
    self.mixin = mixin;

    setup = {

        var launcher = Array.fill(7*8, {0});
        var keys = Array.fill(8*8, {0});

        var cb = {|x, y, z, grid|
            if (x > 7) {
                if (y == 0) {
                    if (z == 1) {
                        var num = x.mod(8);
                        8.do({|i|
                            if (i == num) {
                                self.onChannelSelected(num);
                                grid.led(x, 0, 15);
                            } {
                                grid.led(i+8, 0, 0);
                            }
                        });
                    } 
                } {
                    if (z == 1) {
                        var launcherX = x.mod(8);
                        var launcherY = y-1;
                        var pos = launcherX + (launcherY * 8);
                        
                        7.do({|i|
                            if (i == launcherY) {
                                launcher[pos] = 1 - launcher[pos];
                                //[launcherX, launcherY].debug("launcher on");
                                grid.led(x, y, launcher[pos] * 15);
                                self.onLaunch(launcherX, launcherY, launcher[pos]);
                            }{
                                var mypos = launcherX + (i * 8);
                                launcher[mypos] = 0;
                                //[x, i+1].debug("launcher off");
                                grid.led(x, i+1, 0);
                                //self.onLaunch(launcherX, i, 0);
                            }
                        });
                    }
                };
                nil
            } {
                var kbX = x.mod(8);
                var pos = kbX + (y * 8);

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
                            grid.led(x, y, 0);
                        }
                    }
                }
            }
        };
        connect.(cb)
    };

    self.setup = setup;
};

(func: { Environment.make(func) }  )
)

