(
var func = {|node|

    var grid;

    grid = MonomeGrid(); // if we don't want to change rotation, we can leave the argument out

    s.waitForBoot({

        var cols = 16, rows = 8;
        var voices = List();
        var draw;

        MonomeGrid.setAddCallback({
            arg serial, port, prefix;
            ("grid was added: " ++ serial ++ " " ++ port ++ " " ++ prefix).postln;
            if( serial == MonomeGrid.getConnectedDevices[0], {
                cols = grid.cols;
                rows = grid.rows;
            });
        });

        grid.connect(0);
        ~press = Array.fill(cols * rows, {0});
        ~step = 0;
        ~lastCol = cols-1;
        ~lastRow = rows-1;
        ~feedback = 0.5;

        grid.key({ arg x,y,z;
            var pos = x + (y * cols);
            var octave = node.get(\octave) ?? 4;
            var scale = node.get(\scale) ?? Scale.major;
            if (z == 1) {
                var note = Event.default
                .put(\degree, x)
                .put(\octave, octave)
                .put(\scale, scale)
                .use({ ~midinote.value });
                var voice = ( x: x, y: y, resetY: y, alpha: 1, note: note, vel: 127);
                //note.debug("noteon");
                node.on(note);
                voices.add( voice );
                draw.value;
            }
        });

        draw = {
            voices.do({|voice, i|
                var x = voice['x'];
                var y = voice['y'].floor;
                var note = voice['note'];
                var alpha = voice['alpha'];
                var rel = node.get(\rel) ?? 1;

                if (y > ~lastRow) {
                    //note.debug("noteoff");
                    var feedback = ~feedback;
                    node.off(note);
                    voices.removeAt(i);

                    if (voice['alpha'] > 0.1) {
                        {
                            voice['alpha'] = voice['alpha'] * feedback;
                            voice['vel'] = voice['vel'] * feedback;
                            y = voice['resetY'];
                            voice['y'] = y;
                            voices.add(voice);
                            //note.debug("noteon");
                            node.on(note, vel: voice['vel']);
                            //\noteon.postln;
                        }.defer(rel)
                    };
                    grid.led(x, ~lastRow, 0);
                } {
                    grid.led(x, y, alpha * 15);
                    if (y > 0) {
                        grid.led(x, y-1, 0);
                    };
                    voice['y'] = voice['y'] + 0.8;
                }
            })
        };

        // environment variables are exposed to the Module
        // and can be accessed ~mod.task, e.g.
        ~task = ~task ?? TaskProxy({
            var interval = 1/8;
            inf.do {|i|
                ~step = i % cols;
                draw.value;
                interval.yield;
            }
        }).play;

        ~grid = grid;

    })
};

(func: func)
)
