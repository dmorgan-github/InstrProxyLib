(
var func = {|topic, key, func|
    var id = "%_%".format(key, topic).asSymbol;
    if (func.isNil) {
        Evt.off(topic, id);
        Pdef(id).clear
    } {
        var proxy = Pdef(id);
        Evt.on(topic, id, {|val| 
            proxy.set(id, val) 
        });
        proxy.source = Pbind(topic, Pfunc({|evt| var val = evt[id]; func.(val) }) );
        proxy
    }
};

(
func: func,
doc: "
~sub = DMModule('device/sub')
Pbind() <> ~sub.(\prob, \abc, {|val| if (val.coin) {1}{\} })
"
)
)
