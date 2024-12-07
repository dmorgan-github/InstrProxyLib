(
var func = {|node|
    
    var obj = Environment.make({|self|
        self.know = true;
        self.i = Dictionary();

        /*
        self.rampup = {|self|};
        self.rampdown = {|self|};
        self.random = {|self|};
        self.perlin = {|self|}
        */
        
        self.sine = {|self, prop, val, depth, rate|
            var proxies;
            var settings = [val, depth, rate].flop;
            proxies = settings.collect({|val, i|
                var v = val[0];
                var d = val[1];
                var r = val[2];
                var key = "%_%".format(prop, i).asSymbol;
                Ndef(key, {
                    var sig;
                    var valctlr = NamedControl(\val, v, 0.1 );
                    var depthctrl = NamedControl(\depth, d, 0.1 );
                    var ratectrl = NamedControl(\rate, r, 0.1 );
                    sig = valctlr * ( depthctrl.linlin(0, 1, 1, 2) ** SinOsc.kr(ratectrl));
                    sig//.poll
                })
            });
            self.i.put(prop, proxies.debug("lfo"));
            node.set(prop, proxies);
        };
    });
    node.addUniqueMethod(\lfos, {obj});
    node.addDependant({|obj, what, val|
        if (what == \clear) {
            "clear".debug("lfos")
        }
    });
    obj
};
(func: func)
)