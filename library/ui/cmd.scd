

(
var scrollView;
var window, input;
var outputView;

var palette = QPalette()
.window_(Color.clear)
.windowText_(Color.grey(0.5))
//.button_(Color.red)
//.buttonText_(Color.red)
.baseText_(Color.grey(0.5))
.highlight_(Color.clear)
//.highlightText_(Color.red)
;

palette.base = Color.black;
palette.setColor(Color.black, \shadow);

input = {

    var tf = TextField(bounds: Rect(0, 0));
    {
        tf.focus(true)
    }.defer;

    HLayout(
        StaticText(bounds:Rect(width:5)).string_("(sc) >")
        .stringColor_(Color.green),

        tf
        .palette_(palette)
        .action_({|ctrl|
            ctrl.enabled = false;
            if (ctrl.value == "freq") {
                var mod = M('ui/freq').( t(6) );
                {
                    var w;
                    outputView.bounds.height.debug("outputview height");
                    window.bounds.height.debug("window height");
                    scrollView.bounds.height.debug("scroll height");
                    mod.bounds.height.debug("mod heigth");
                    w = mod.bounds.width;
                    mod.resizeTo(w, 100)
                }.defer(4);
                outputView.layout.add( mod, 1 ); 
                //outputView.layout.add( nil, 1 ); 
            } {
                var list = V.ls;
                var str = "";
                var tv;
                list.do({|v| 
                    str = str ++ v ++ "\n";
                });
                tv = TextView()
                .resize_(1)
                .palette_(palette)
                .string_(str);

                outputView.layout.add( tv, 1 ); 
                //outputView.layout.add( nil, 1 ); 
            };
            
            outputView.layout.add( input.(), 1 ); 
            //outputView.layout.add( nil, 1 ); 

        })
    ).margins_(0).spacing_(0);
};

window = View(bounds: Rect(0, 0, 500, 200))
//window = View()
.layout_(VLayout().margins_(0).spacing_(0))
.background_(Color.black);

outputView = View(bounds:window.bounds)
.layout_(VLayout().margins_(0).spacing_(0));

outputView.layout.add( input.() );
outputView.layout.add( nil );

scrollView = ScrollView(bounds:window.bounds)
.hasBorder_(false)
.autohidesScrollers_(false)
.hasVerticalScroller_(true)
.hasHorizontalScroller_(false);

window.layout.add(outputView);

scrollView.canvas = window;
scrollView.front
)