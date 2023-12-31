(
    var func = {|recAddr="192.168.86.250", recPort=57125|

        var init, ctrl;
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

        var data = Order();
        var current = 0;

        OSCdef('/radio1').permanent_(false).free;

        ctrl = Environment.make({|self|

            var netaddr;
            var reset_track;

            self.know = true;
            netaddr = NetAddr(recAddr.debug("recAddr"), recPort);

            reset_track = {|val|
                var color = colors.wrapAt(val);
                var obj;
                current = val;
                Server.default.bind({
                    // 16 radials
                    (1..16).do({|num|
                        var path = "radials_color%".format(num);
                        netaddr.sendMsg(path, color);
                        netaddr.sendMsg("radio1color", color ++ "55");
                        netaddr.sendMsg("/label%".format(num), "");
                        netaddr.sendMsg("/radials%".format(num), 0);
                    });
                    // 8 presets
                    (1..8).do({|num|
                        netaddr.sendMsg("presetcolor/%".format(num), color ++ "55");
                    })
                });
        
                obj = data[val.asInteger];
                if (obj.notNil()) {
                    obj['reset'].()
                };
            };

            /*
            (1..16).do({|num|
                var path = "/grid1/%".format(num).asSymbol;
                OSCdef(path, {|msg| 
                    var obj, val;
                    //msg.debug("grid1 val");
                    val = msg[1];
                    obj = data[current];
                    //obj.debug("track");
                    if (obj.notNil) {
                        var node = obj['node'];
                        if (val > 0) {
                            var ptrn = node.ptrns[num-1];
                            if (ptrn.notNil) {
                                node.source = ptrn
                            }
                        }
                    }
                }, path:path)
                .fix    
            });
            */

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
                    var mapped, ctrl, spec, filter;
                    var obj = data[current];
                    if (obj.notNil) {
                        var props = obj['props'];
                        var node = obj['node'];
                        var val = msg[1];
                        ctrl = props[num];
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
                path = "/preset/%".format(num);
                OSCdef(path, {|msg|
                    var val = msg[1];
                    if (val > 0) {
                        var obj = data[current];
                        //obj.debug("obj");
                        if (obj.notNil) {
                            var node = obj['node'];
                            DMPreset.apply(node, num-1)
                        }
                    }
                }, path: path)
                .fix; 
            });

            // pattern launcher
            (1..8).do({|track|

                var selected = nil;

                (1..4).do({|num|
                    var path = "/ptrn%/%".format(track, num);
                    //path.debug("path*****");

                    OSCdef(path, {|msg|
                        var val = msg[1];
                        var node;
                        var obj = data[track-1];
                        //obj.debug("obj*****");

                        if (obj.notNil) {
                            node = obj['node'];
                            //node.debug("node************");
                            if (val > 0) {
                                var ptrn;
                                selected = num-1;
                                ptrn = node.ptrns[selected];
                                if (ptrn.notNil) {
                                    node.source = ptrn;
                                    node.play;
                                }
                            }{
                                if ( (num-1) == selected) {
                                    node.stop;
                                    selected = nil
                                }
                            }
                        }
                    }, path: path)
                    .fix; 
                })
                
            });

            reset_track.(0);
            netaddr.sendMsg("/radio1", 0);

            (1..8).do({|track|
                (1..8).do({|num|
                    var key;
                    //var key = "/preset%/%".format(track, num);
                    //netaddr.sendMsg(key, 0);   
                    key = "/ptrn%/%".format(track, num);
                    netaddr.sendMsg(key, 0);   
                })
            });
        
            // node needs to be an obj with get/set methods
            // obj should have getSpec
            // assoc =  'prop' -> <ccnum>
            self.osc = {|self, index, node ...assoc|
        
                var props, nums;
                var order, reset, obj;
        
                props = assoc.collect({|a| a.key });
                nums = assoc.collect({|a| a.value });
                order = Order.newFromIndices(props.asArray, nums.asArray);

                reset = {
                
                    Server.default.bind({
                        (1..16).do({|num|
                            //var osckey = "t%_osc_%".format(index, num).asSymbol;
                            //OSCdef(osckey).permanent_(false).free;
                            netaddr.sendMsg("/label%".format(num), "");  
                            netaddr.sendMsg("/radials%".format(num), 0);           
                        });

                        // try to initialze device with current values
                        order.indices.do({|num|

                            var spec, min, max, current, val;
                            var ctrl = order[num];
                
                            if (ctrl.isFunction) {
                            }{
                                // update label
                                var key = "label%".format(num);
                                netaddr.sendMsg(key, ctrl.asString);

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
                                        netaddr.sendMsg("/radials%".format(num), val);
                                    } {|err|
                                        "osc out: %".format(err).warn;
                                    }
                                }
                            }
                        });
                    })
                };

                obj = (
                    reset: reset,
                    node: node,
                    props: order
                );
                reset.();
                netaddr.sendMsg("/radio1", index);
                current = index;
                data.put(index, obj);
            };
        });

        ctrl;
    };
    
    (func: func)
)
    