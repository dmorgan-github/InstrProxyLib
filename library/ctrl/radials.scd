(
    var func = {|recAddr="192.168.86.250", recPort=57125|

        var init, ctrl;

        /*
        var colors = [
            "d53e4f",
            "f46d43",
            "fdae61",
            "fee08b",
            "e6f598",
            "abdda4",
            "66c2a5",
            "3288bd"
        ];
        */

        var data = Order();
        var current = 0;

        OSCdef('/radio1').permanent_(false).free;
        (1..16).do({|num| var path = "/radials%".format(num).asSymbol; OSCdef(path).permanent_(false).free });
        (1..8).do({|num| 
            var path; 
            path = "/preset/%".format(num).asSymbol; 
            OSCdef(path).permanent_(false).free;
            path = "/ptrn/%".format(num).asSymbol; 
            OSCdef(path).permanent_(false).free;
            path = "/vol%".format(num).asSymbol; 
            OSCdef(path).permanent_(false).free;
            path = "/pan%".format(num).asSymbol; 
            OSCdef(path).permanent_(false).free;
            path = "/play%".format(num).asSymbol; 
            OSCdef(path).permanent_(false).free;
        });

        ctrl = Environment.make({|self|

            var reset_track;

            self.know = true;
            self.netaddr = NetAddr(recAddr.debug("recAddr"), recPort);

            reset_track = {|val|
                var obj;
                current = val;
                obj = data[val.asInteger];
                if (obj.notNil()) {
                    obj['reset'].()
                } {
                    (1..16).do({|num|
                        self.netaddr.sendMsg("/label%".format(num), "");
                        self.netaddr.sendMsg("/radials%".format(num), 0);
                    });
                    (1..8).do({|num|
                        self.netaddr.sendMsg("/preset/%".format(num), 0);   
                        self.netaddr.sendMsg("/ptrn/%".format(num), 0);  
                    })
                }
            };

            // set up osc for track selector
            OSCdef('/radio1', {|msg|
                var val = msg[1];
                reset_track.(val);
            }, path: '/radio1')
            .fix;

            // set up osc for radials
            (1..16).do({|num|
                var path = "/radials%".format(num).asSymbol;

                OSCdef(path, {|msg|

                    var obj;
                    var mapped, ctrl, spec, filter;
                    obj = data[current];

                    if (obj.notNil) {
                        var props = obj['props'];
                        var node = obj['node'];
                        var val = msg[1];
                        ctrl = props[num-1];

                        if (ctrl.notNil) {
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
                        }
                    }
                }, path:path)
                .fix
            }); 

            // preset selector
            (1..8).do({|num|
                var path;
                path = "/preset/%".format(num).asSymbol;
                OSCdef(path, {|msg|
                    var val = msg[1];
                    if (val > 0) {
                        var obj = data[current];
                        var selected = num-1;
                        if (obj.notNil) {
                            var node = obj['node'];
                            Preset.apply(node, selected);
                            node.set(\preset_num, selected);
                        } {
                            //node.set(\preset_num, nil);    
                        }
                    }
                }, path: path)
                .fix; 
            });

            // ptrn selector
            (1..8).do({|num|
                var path;
                path = "/ptrn/%".format(num).asSymbol;
                OSCdef(path, {|msg|
                    var val = msg[1];
                    if (val > 0) {
                        var obj = data[current];
                        //obj.debug("obj");
                        if (obj.notNil) {
                            var ptrn, selected;
                            var node = obj['node'];
                            selected = num-1;
                            ptrn = node.ptrns[selected];
                            node.set(\ptrn_num, selected);
                            if (ptrn.notNil) {
                                node.source = ptrn;
                            }
                        } {
                            //node.set(\ptrn_num, nil);    
                        }
                    }
                }, path: path)
                .fix; 
            });

            // play, amp, pan buttons
            (0..7).do({|num|
                // obj index is zero-based
                // but everything else is one-based
                var path = "/play%".format(num+1).asSymbol;
                // initialize play buttons as hidden
                self.netaddr.sendMsg("/play%visible".format(num+1), false);

                OSCdef(path, {|msg|
                    var val = msg[1];
                    if (val > 0) {
                        var obj = data[num];
                        if (obj.notNil) {
                            obj.node.play;
                        }
                    } {
                        var obj = data[num];
                        if (obj.notNil) {
                            obj.node.stop;
                        }
                    }
                }, path: path).fix;

                path = "/vol%".format(num+1).asSymbol;                
                OSCdef(path, {|msg|
                    var val = msg[1];
                    var obj = data[num];
                    if (obj.notNil) {
                        var amp = val.linlin(0, 1, 0, 2);
                        obj.node.set(\vol, amp)
                    }
                }, path: path).fix;

                path = "/pan%".format(num+1).asSymbol;
                OSCdef(path, {|msg|
                    var val = msg[1];
                    var obj = data[num];
                    if (obj.notNil) {
                        var pan = val.linlin(0, 1, -1, 1);
                        obj.node.set(\out_pan, pan)
                    }
                }, path: path).fix;
            });

            reset_track.(0);
            self.netaddr.sendMsg("/radio1", 0);
        
            // node needs to be an obj with get/set methods
            // obj should have getSpec
            // assoc =  'prop' -> <ccnum>
            self.osc = {|self, index, node ...assoc|
        
                var props, nums;
                var order, reset, obj;
                var vol, pan;
        
                props = assoc.collect({|a| a.key });
                nums = assoc.collect({|a| a.value });
                order = Order.newFromIndices(props.asArray, nums.asArray);

                vol = node.get(\vol) ?? 1;
                vol = vol.linlin(0, 2, 0, 1);
                self.netaddr.sendMsg("/vol%".format(index), vol);  

                pan = node.get(\pan) ?? 0;
                pan = pan.linlin(-1, 1, 0, 1);
                self.netaddr.sendMsg("/pan%".format(index), pan);

                // enable play button
                self.netaddr.sendMsg("/play%visible".format(index), true);

                reset = {
                
                    // TODO: i don't know if this server bind is necessary
                    //Server.default.bind({

                        (1..8).do({|num|
                            var preset_num = node.get(\preset_num);
                            var ptrn_num = node.get(\ptrn_num);

                            if ( (num-1) ==  preset_num) {
                                self.netaddr.sendMsg("/preset/%".format(num), 1);   
                            }{
                                self.netaddr.sendMsg("/preset/%".format(num), 0); 
                            };

                            if ( (num-1) ==  ptrn_num) {
                                self.netaddr.sendMsg("/ptrn/%".format(num), 1);  
                            }{
                                self.netaddr.sendMsg("/ptrn/%".format(num), 0);  
                            }
                        });

                        (1..16).do({|num|

                            var spec, min, max, current, val;
                            var ctrl = order[num-1];

                            if (ctrl.isNil) {
                                self.netaddr.sendMsg("/label%".format(num), "");  
                                self.netaddr.sendMsg("/radials%".format(num), 0); 
                            }{

                                if (ctrl.isFunction) {
                                }{
                                    var key = "/label%".format(num);
                                    self.netaddr.sendMsg(key, ctrl.asString);

                                    spec = node.getSpec[ctrl];
                                    if (spec.isNil) {
                                        spec = [0, 1].asSpec;
                                    };
                    
                                    min = spec.minval;
                                    max = spec.maxval;
                                    current = node.get(ctrl);
                                    if (current.notNil) {
                                        // don't know how to unmap to a range that is not 0-1
                                        if (spec.warp.isKindOf(ExponentialWarp)) {
                                            val = current.explin(min, max, 0, 1);
                                        }{
                                            val = current.linlin(min, max, 0, 1);
                                        };
                                        //[node.key, \curent, current, \cc, ccval].debug(ctrl);
                                        try {
                                            self.netaddr.sendMsg("/radials%".format(num), val);
                                        } {|err|
                                            "osc out: %".format(err).warn;
                                        }
                                    }
                                };
                            };    
                        });
                    //})
                };

                obj = (
                    reset: reset,
                    node: node,
                    props: order
                );
                reset.();
                index = index -1;
                self.netaddr.sendMsg("/radio1", index);
                current = index;
                data.put(index, obj);
            };
        });

        ctrl;
    };
    
    (func: func)
)
    