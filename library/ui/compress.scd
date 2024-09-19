
(
var func = {|node, index|

    // adapted from  https://sccode.org/1-5cW
    var view, id;
    var props;
    var maxReduc = -6; // Maximum gain reduction indicated
	var nIntervals = 10; // Number of ticks (except the zero)
	var width = 20; // Width of the indicator in px
	//var height = 300; // Height of the indicator in px
    var indicator, layout, oscFn;
    id = UniqueID.next;

    view = View().layout_(HLayout().margins_(2).spacing_(2)).minWidth_(200);
    //.backgroundImage_(Image(SCDoc.helpSourceDir +/+ "images/Swamp.png"));

    indicator = LevelIndicator().fixedWidth_(width);//.fixedHeight_(height);
	indicator.numTicks = nIntervals + 1;
	indicator.numMajorTicks = 3;
	indicator.warning = 0.dbamp;
	indicator.critical = 0.dbamp;
	indicator.background = node.color;//Color.new255(246, 184, 0);
	indicator.meterColor = Color.black;
	// Layout of the window
	layout = HLayout();
	layout.add(nil);
	layout.add(VLayout(indicator));
	//layout.add(VLayout(StaticText().string_("0.0dB"), nil, StaticText().string_((maxReduc/2.0).asString ++ "dB"), nil, StaticText().string_((1.0*maxReduc).asString ++ "dB")));
	layout.add(nil);

    node.set(\levelreplyid, id);
    // TODO: update to be stereo
    oscFn = OSCFunc({arg msg;
		{
            var replyid = msg[2];
            if (replyid == id) {
			    indicator.value = (1-msg[3]).ampdb.linlin(maxReduc, 0, 0, 1);
            }
		}.defer;
	}, '/compresslevel');

    props = UiModule('props').(node.node, index);
    view.layout.add(props);
    view.layout.add(layout);
    view.onClose = {
        oscFn.free;
        node.set(\levelreplyid, -1);
    };
    view;
};
(func: func)
)