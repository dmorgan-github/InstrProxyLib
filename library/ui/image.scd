(
var func = {|node|

    var width = 300, height = 100, xspeed = 3, yspeed = 2, x = width*0.15, y = height*0.5;
    var size = 8.0;
    var degrees = [-7, 5, 7, 10, 14];
    var points;
    var tops = 5.collect({ rrand(size, 64.0) });
    var yspeeds = 5.collect({ rrand(0.25, 1.0) });
    //w = Window("ball", Rect(width:width, height:height));
    w = View().layout_(VLayout().margins_(0).spacing_(0));
    u = UserView().background_(Color.black);
    u.animate = true;

    127.do({|i| node.off(i) });

    u.drawFunc = {

        var pan;
        var rate;

        //if(x<0 or:{x>width}, { xspeed = 0-xspeed});
        //if(y<0 or:{y>height}, { yspeed = 0-yspeed});
        //x = x+xspeed;
        //y = y+yspeed;

        //pan = x.linlin(0, 300, -1, 1);
        //rate = y.linlin(0, 100, 0.5, 2.0);
        //node.set(\pan, pan, \width, 0, \center, pan, \rate, rate);

        //y = y+yspeed;

        5.do({|i| 
            if (tops[i] < size or: {tops[i] > (height-size)}, {
                if (tops[i] > (height-size)) {
                    node.on(48 + degrees[i]);
                }{
                    node.off(48 + degrees[i])
                };
                yspeeds[i] = 0-yspeeds[i] 
            });
            tops[i] = tops[i] + yspeeds[i];
            Pen.fillColor = Color.white;
            Pen.fillOval(Rect.aboutPoint(Point(x+(i * 48), tops[i]), 8, 8));
        });
    };
    w.layout.add(u);
    w.onResize_({|ctrl|
        width = ctrl.bounds.width;//.postln;
        height = ctrl.bounds.height;
    })
    .minSize_(Size(width, height));
};

(
func: func
)

)

//

