(
var func = {|node|

    var view, proxy, buf;
    var bufmodule = UiModule('buf');

    proxy = node.get(\recproxy);
    buf = node.get(\recbuf);

    if (proxy.isNil) {

        if (buf.isNil) {
            var bufkey = "%_recbuf".format(node.key).asSymbol;
            buf = B.allocSec(bufkey, 16, numChannels:2);
            node.set(\recbuf, buf);
        };

        proxy = DMNodeProxy();
        proxy.color = node.color;
        proxy[0] = node.node;
        proxy.set(\buf, buf, \rec, 0, \dorefresh, 1);

        proxy.fx(100, 'delay/bufdelay');
        node.set(\recproxy, proxy);

    };

    view = View().layout_(VLayout(

        bufmodule.view(proxy),

        HLayout(
            nil,
            Button()
            .states_( [ [ "rec", nil, Color.clear ], [ "stop", nil, Color.clear] ] )
            .action_({|ctrl|
                if (ctrl.value == 1) {
                    proxy.set(\rec, 1)
                }{
                    proxy.set(\rec, 0)
                }
            })
            .value_(proxy.get(\rec)),

            LevelSlider('feedback', spec:proxy.getSpec[\fb], color:Color.rand)
            .action_({|ctrl|
                proxy.set(\fb, ctrl.value)
            })
            .value_(proxy.get(\fb))
        )

    )).resize_(1);

    view
};

// export the module
(func: func)

)
