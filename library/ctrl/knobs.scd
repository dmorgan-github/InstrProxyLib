(
    var func = {|recAddr="192.168.86.119", recPort=57125|

        var ctrl;
        ctrl = Environment.make({|self|

            self.know = true;
            self.netaddr = NetAddr(recAddr.debug("recAddr"), recPort);
        
            // node needs to be an obj with get/set methods
            // obj should have getSpec
            // assoc =  'prop' -> <num>
            self.osc = {|self, node ...assoc|

                var props, nums, order;
                props = assoc.collect({|a| a.key });
                nums = assoc.collect({|a| a.value });
                order = Order.newFromIndices(props.asArray, nums.asArray);

                (1..8).do({|num|

                    var path = "radial%".format(num).asSymbol;
                    OSCdef(path, {|msg|
                        var val = msg[1];
                        var mapped, ctrl, spec;
                        ctrl = order[num];

                        if (ctrl.isFunction) {
                            ctrl.(val)
                        } {
                            spec = node.getSpec[ctrl];
                            if (spec.isNil) {
                                spec = [0, 1].asSpec;
                            };
                            mapped = spec.map(val);
                            node.set(ctrl, mapped);
                        }
                    }, path: path
                    ).fix;
                });
            };
        });

        ctrl;
    };
    
    (func: func)
)
    