(
func: {|node, prop|

    var val, tv;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var pdvkey;

    if (prop.isNil) {
        prop = \degree;
    };
    
    if (node.source.isNil) {
        node.source = Pbind()
    };

    prop = prop.asSymbol.postln;
    pdvkey = "%_pdv_vals".format(prop).asSymbol;
    //node.debug("****wtf");
    val = node.get(pdvkey) ?? { "~ ~ ~ ~ | ~ ~ ~ ~ | ~ ~ ~ ~ | ~ ~ ~ ~" };

    tv = TextView()
    .maxHeight_(40)
    .background_(Color.clear)
    .keyDownAction_({|ctrl, char, modifiers, unicode, keycode, key|

        //[char, modifiers, unicode, keycode, key].postln;
        if (modifiers == 262144) {
            switch(keycode,
                40, { // k
                    var code = ctrl.string.stripWhiteSpace;
                    node.set(pdvkey, code);
                    //node.set(prop, pdv(code))
                    node.source = Pbind(prop, pdv(code));
                    {
                        ctrl.background = Color.white.alpha_(0.5);
                        {
                            ctrl.background = Color.clear;
                        }.defer(0.1)
                    }.defer
                }
            )
        }
    }) 
    .hasVerticalScroller_(true)
    .string_(val)
    ;

    tv.syntaxColorize;
    view.layout.add(tv);
    view;
}
)
