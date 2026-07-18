////////////////////////////////////////////
// region UI

(
var func = {|node|
    var increment = 0.1;
    var prevY = 0;
    var curveVal = -4;
    var stepsVal = 16;
    var envview, stepsview;
    var model = Ref(1);
    var sc = SimpleController(model);
    var view = View(bounds:Rect(width:400, height:400))
    .layout_(VLayout().margins_(2).spacing_(2))
    .background_(Color.black)
    ;

    stepsview = NumberBox()
    .clipLo_(1)
    .clipHi_(64)
    .decimals_(0)
    .value_(stepsVal)
    .action_({|ctrl|
        model.changed('steps', ctrl.value);
    });

    envview = EnvelopeView()
    .keepHorizontalOrder_(true)
    .elasticSelection_(true)
    .editable_(true)
    .gridOn_(false)
    .gridColor_(Color.clear)
    .background_(Color.clear)
    .style_(1)
    .thumbSize_(8)
    .grid_(Point(0.25, 0.25))
    //.gridOn_(true)
    .step_(0.0001)
    .value_( [ [0, 1], [0, 1] ] )
    .curves_( curveVal )
    .editable_(false)
    .mouseDownAction_({|ctrl, x, y|
        prevY = y;   
    })
    .mouseMoveAction_({|ctrl, x, y, modifiers|
        var dir = 0;
        if (y > prevY) {
            dir = 1;
        };
        if (y < prevY) {
            dir = -1;
        };
        curveVal = curveVal + (increment * dir);
        curveVal = curveVal.clip(-20, 20);
        ctrl.curves = curveVal;
        model.changed('curve', curveVal);
        prevY = y;
    });

    sc.put(\curve, {|self, what, val|
        node.set(\curve, val.debug("curve"));
    })
    .put(\steps, {|self, what, val|
        node.set(\steps, val.debug("steps"))
    });

    view.layout.add(stepsview);
    view.layout.add(envview);
    view.front
};
~func = func
)

~func.( t(1) )