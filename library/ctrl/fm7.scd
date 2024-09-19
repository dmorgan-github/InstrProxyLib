(
var func = {|recAddr="192.168.86.249", recPort=57125|

    var obj;
    obj = Environment.use({|self|

        self.know = true;
        self.netaddr = NetAddr(recAddr.debug("recAddr"), recPort);

        self.setNode = {|self, node|

            var ctrl, fb, setVal, setFine, setRatio;
            var ratios = [0.25, 0.5, 0.75] ++ (1..15);
        
            setFine = {|num|
                var key = "op%ratio".format(num).asSymbol;
                var ratio = node.get(key);
                var val = ratio.frac;
                val = val.linlin(0, 0.99, 0, 1);
                self.netaddr.sendMsg("/op%fine".format(num), val); 
            };
        
            setRatio = {|num|
                var index, val;
                var key = "op%ratio".format(num);
                var ratio = node.get(key.asSymbol).floor.asInteger;
                if (ratio == 0) {ratio = 1};
                index = ratios.indexOf(ratio);
                val = index.linlin(0, 17, 0, 1);
                //[num, ratio, index, val].postln;
                self.netaddr.sendMsg(key, val); 
            };
        
            setVal = {|key|
                var spec = node.getSpec[key.asSymbol];
                var val = node.get(key.asSymbol);
                var path = "/%".format(key);
                val = spec.unmap(val);
                //[path, val].postln;
                self.netaddr.sendMsg(path, val);    
            };
        
            self.ctrl = 6.collect({|i|
                var level, atk, dec, sus, rel, ratio, fine, curve, spec, val;
                var num = i+1;
                var prefix = "op%".format(num);
                var key = prefix.asSymbol;
        
                var oscdef = {|key|
                    var spec = node.getSpec[key];
                    if (key.asString.endsWith("ratio")) {
                        OSCdef("fm7/%".format(key).asSymbol, func:{|msg|
                            var val = msg[1];
                            val = val.linlin(0, 1, 0, 17).asInteger;
                            val = ratios[val];
                            //[key, val].postln;
                            node.set(key, val);
                        }, path: "/%".format(key).asSymbol)
                    } {
                        if (key.asString.endsWith("fine")) {
                            OSCdef("fm7/%".format(key).asSymbol, func:{|msg|
                                var result, ratio;
                                var val = msg[1];
                                var ratiokey = "%ratio".format(prefix).asSymbol;
                                ratio = node.get(ratiokey);
                                if (ratio >= 1) {
                                    ratio = ratio.floor;
                                    result = ratio + val.linlin(0, 1, 0, 0.99);
                                    //[ratiokey, ratio, val, result].postln;
                                    node.set(ratiokey, result);
        
                                }{
                                    // TODO: set finetune for values < 0
                                };
                            }, path: "/%".format(key).asSymbol)
                        }{
                            OSCdef("fm7/%".format(key).asSymbol, func:{|msg|
                                var val = msg[1];
                                if (spec.notNil) {
                                    val = spec.map(val);
                                    node.set(key, val);
                                    //[key, val].postln;
                                };
                            }, path: "/%".format(key).asSymbol)
                        }
                    }
                };
        
                level = oscdef.(key);
                atk = oscdef.("%atk".format(prefix).asSymbol);
                dec = oscdef.("%dec".format(prefix).asSymbol);
                sus = oscdef.("%suslevel".format(prefix).asSymbol);
                rel = oscdef.("%rel".format(prefix).asSymbol);
                ratio = oscdef.("%ratio".format(prefix).asSymbol);
                fine = oscdef.("%fine".format(prefix).asSymbol);
                curve = oscdef.("%curve".format(prefix).asSymbol);
        
                setVal.(prefix);
                setFine.(num);
                setRatio.(num);
                setVal.("%curve".format(prefix));
                setVal.("%rel".format(prefix));
                setVal.("%atk".format(prefix));
                setVal.("%dec".format(prefix));
                setVal.("%suslevel".format(prefix));
                setVal.("%rel".format(prefix));
        
                [level, atk, dec, sus, rel, ratio, fine, curve]
            });
        
            setVal.("fb");
            self.fb = OSCdef('fm7/fb', func:{|msg|
                var val = msg[1];
                node.set(\fb, val)
            }, path: '/fb')
        };

        self.cleanUp = {|self|
            self.ctrl.debug("clear");
            self.fb.debug("clear");
        }
    });

    obj
};

(func: func)
)
