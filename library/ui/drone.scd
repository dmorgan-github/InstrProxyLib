(
var func = {|node|

    var width = 300, height = 200, xspeed = 3, yspeed = 2, x = width*0.15, y = height*0.5;
    var size = 8.0;
    //var degrees = [-12, -7, -5, 0, 3, 5, 7, 10, 12, 14];
    //var degrees = [-12, -5, 0, 2, 3, 5, 7, 12, 14];
    var degrees = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var points;
    var tops = 5.collect({ rrand(size, 64.0) });
    var yspeeds = 5.collect({ rrand(0.25, 1.0) });
    var index = 0;
    var mdspeed = 10;
    var count = 0;
    var test = true;
    var debug = false;
    var fb = 0.9;
    var speed = 1;

    var line, connectLine;
    var color = Color.rand;
    var balls = List();

    w = View().layout_(VLayout().margins_(0).spacing_(0));
    u = UserView().background_(Color.black);
    u.animate = true;

    127.do({|i| node.off(i) });
    
    u.drawFunc = {

        balls.do({|b, i|

            if (b.y > height, { 
                var ball = balls.removeAt(i);
                node.off(ball.note);

                if (ball['color'].alpha > 0.05) {
                    var rel = node.get(\rel) ?? 1;
                    {
                        
                        ball['vel'] = ball['vel'] * fb;
                        ball['color'].alpha = ball['color'].alpha * fb;
                        ball[\y] = ball[\resetY];
                        node.on(b.note, vel:ball['vel'], debug: debug);
                        balls.add(ball);
                    }.defer(rel)
                }
            });

            b.y = b.y + b.speed;
            Pen.fillColor = b.color;
            Pen.fillOval(Rect.aboutPoint(Point(b.x, b.y), 8, 8));
        })
    };

    u.mouseDownAction_({|ctrl, x, y|
        var note, mindex, mfb;
        var index = x.linlin(0, width, 0, degrees.size).floor.asInteger;
        note = 48 + degrees.wrapAt(index);
        // --
        //mindex = y.linlin(0, height, 0.1, 5);
        //mindex = y.linlin(0, height, 3, 0);
        //mfb = x.linlin(0, width, 0, 0.8);
        //mfb = x.linlin(0, width, 0.8, 0);
        //node.on(note, debug:debug, extra:[mindex:mindex, mfb: mfb]);
        // --
        node.on(note, debug:debug);
        balls.add( (x:x, y:y, resetY:y, speed: speed, note: note, color:Color.white, vel:127) );
        //index = index + 1;
    });
    u.mouseMoveAction_({|ctrl, x, y|
        if (false) {
        //if (test) {
            var note, mindex, mfb;
            note = 48 + degrees.wrapAt(index);
            mindex = y.linlin(0, height, 0.1, 5);
            mfb = x.linlin(0, width, 0, 0.8);
            node.on(note, debug:debug, extra:[mindex:mindex, mfb: mfb]);
            balls.add( (x:x, y:y, resetY:y, speed: speed, note: note, color:Color.white, vel:127, mindex:mindex, mfb: mfb) );
            index = index + 1;
            test = false;
        };
        //count = count + 1;
    })
    .onResize_({|ctrl|
        height = ctrl.bounds.height;//.debug("resize height");
        width = ctrl.bounds.width;
    });

    w.layout.add(
        LevelSlider('feedback', [0, 1].asSpec, color:Color.rand)
        .action_({|ctrl|
            fb = ctrl.value
        })
        .value_(fb)
        .maxHeight_(20)
    );

    w.layout.add(
        LevelSlider('speed', [0.1, 10].asSpec, color:Color.rand)
        .action_({|ctrl|
            speed = ctrl.value
        })
        .value_(speed)
        .maxHeight_(20)
    );

    w.layout.add(
        LevelSlider('density', [1, 100, \lin, 1, 10].asSpec, color:Color.rand)
        .action_({|ctrl|
            mdspeed = ctrl.value.floor.asInteger
        })
        .value_(mdspeed)
        .maxHeight_(20)
    );

    w.layout.add(u);

    w.onResize_({|ctrl|
        //width = ctrl.bounds.width;//.postln;
        //height = ctrl.bounds.height;
    })
    .minSize_(Size(width, height))
    ;
};

(
func: func
)//['func'].(~sxs).front

)

