(
var func = {

    var text, p, view;
    var obj = ();
    obj.know = true;
    obj.duration = 1;
    obj.minVal = -1;
    obj.maxVal = 1;
    obj.len = 64;

    view = View().layout_(VLayout().spacing_(1).margins_(1)).minWidth_(400).minHeight_(200);
    p = Plotter(bounds: Rect(600, 30, 800, 250), parent:view);
    p.value = [0];//(0..64).sin;

    p.setProperties(
        \fontColor, Color.white,
        \plotColor, Color.white,
        \backgroundColor, Color(0.75822179317474, 0.58384845256805, 0.37344696521759),
        \gridColorX, Color.white,
        \gridOnX, true,
        \gridOnY, true,
        \showUnits, false,
        );

    p.editMode = false;
    p.showUnits = false;
    p.minval = -1;
    p.maxval = 1;
    p.setGridProperties(\x, \numTicks, 0);
    p.setGridProperties(\y, \numTicks, 2);

    view.layout.add( p.interactionView );
    obj.ugenFunc_ = {|self, val|
        var dur = obj.duration.debug("duration");
        val.getToFloatArray(duration:dur, action: { |x| 
            defer({
                p.value = x;//.resamp1(obj.len);
                //p.minval = -1;
                //p.maxval = 1;
                p.refresh;
                p.editFunc.(p);
                obj.changed;
            })    
        });    
    };
    obj.editFunc_ = {|self, val|
        p.editFunc = val;    
    };

    obj.view = view;
    obj.plotter = p;
    view.front;
    obj;
};

(
func: func,
doc: "
~plot = M('ui/plotter').()
(
~plot.ugenFunc = {
    LFSaw.ar(2) + SinOsc.ar(4)
};
~plot.editFunc = {|plotter, plotIndex, x, y| [plotter, b, x, y].postln }
)
"
)
)