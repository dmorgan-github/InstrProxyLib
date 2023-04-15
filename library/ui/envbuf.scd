(
func: {|node, prefix|

    var valskey = if (prefix.notNil) { "%envbufvals".format(prefix).asSymbol } { \envbufvals };
    var bufkey = if(prefix.notNil) { "%envbuf".format(prefix).asSymbol } { \envbuf };
    var view, buf;
    var ev = EnvelopeView();
    var prevy;
    var curves, levels, times;
    var skipjack;
    var editing = false;
    var vals;

    if (node.get(valskey).isNil) {
        levels = [0, 1, 0];
        times = [0, 0.5, 1];
        curves = [-8, -8];
        node.set(valskey, [levels, times, curves]);
    } {
        vals= node.get(valskey);
        levels = vals[0];
        times = vals[1];
        curves = vals[2];
    };

    buf = if (node.get(bufkey).isNil) {
        var env = Env(levels, times.differentiate[1..], curves);
        var buf = Buffer.sendCollection(Server.default, env.discretize);
        node.set(bufkey, buf);
        buf;
    } {
        node.get(bufkey);
    };

    skipjack = SkipJack({
        var x = ev.x;
        var y = ev.y;
        var env = ev.asEnv(curves);
        
        if (editing) {
            // getting the following error a lot when using loadCollection
            // File '/path/to//SuperCollider/tmp/-589974584' 
            // could not be opened: System error : No such file or directory
            // server is able to find the file so i'm not sure why the message
            // limiting the amount of calling loadcollection seems to help with the annoying message
            buf.loadCollection(env.discretize);
            vals = [levels, times, curves];
            node.set(valskey, vals)
        };
        editing = false; 
    }, dt: 0.2);

    view = View().layout_(HLayout(
        ev
        .background_(Color.clear)
        .drawLines_(true)
        .keepHorizontalOrder_(true)
        .elasticSelection_(true)
        .editable_(true)
        .thumbSize_(10)
        .grid_(Point(0.25, 0.25))
        .gridOn_(true)
        .step_(0.0001)
        .mouseDownAction_({|ctrl, x, y, modifiers|
            if (modifiers == 262144) {
                ctrl.editable = false;
            };
            prevy = y;
        })
        .mouseUpAction_({|ctrl|
            ctrl.editable = true
        })
        .action_({arg ctrl;
            var index = ctrl.index;
            times[index] = ctrl.value[0][index];
            levels[index] = ctrl.value[1][index];
            editing = true;
        })
        .mouseMoveAction_({|ctrl, x, y, modifiers|
            var index = ctrl.index;
            if (modifiers == 262144 and: {index > 0}) {
                if (y < prevy) {
                    var val = clip(curves[index-1] + 0.1, -8, 8);
                    curves[index-1] = val;
                    //curves.changed(index-1);
                    ctrl.curves = curves;
                } {
                    if (y > prevy) {
                        var val = clip(curves[index-1] - 0.1, -8, 8);
                        curves[index-1] = val;
                        //curves.changed(index-1);
                        ctrl.curves = curves;
                    }
                };
                prevy = y;
            };
            nil;
        })
        .value_([times, levels])
        .curves_(curves),
        VLayout(
            Button().states_( [ ["+", nil, Color.clear] ] )
            .action_({|ctrl|
                levels = levels.add(0);
                times = {|v| v.linlin(0, v.maxItem, 0, 1) }.value( times.add(times.maxItem + 0.1) );
                curves = curves.add(0);
                ev.value = [times, levels];
                ev.curves = curves;
            })
            .maxSize_(Size(20, 20)),
            Button().states_( [ ["-", nil, Color.clear] ] )
            .action_({|ctrl|
                levels = levels[0..levels.size-2];
                times = {|v| v.linlin(0, v.maxItem, 0, 1) }.value(times[0..times.size-2]);
                curves = curves[0..curves.size-2];
                ev.value = [times, levels];
                ev.curves = curves;
            })
            .maxSize_(Size(20, 20)),
            nil
        )
    ).margins_(1).spacing_(1));
    skipjack.start;
    view
    .background_(Color.clear)
    //.minSize_(400, 400)
    .onClose_({
        skipjack.stop;
    })
    .front
}
)
