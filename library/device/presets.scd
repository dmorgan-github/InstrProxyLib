(
var func = {|node|

    var obj;

    obj = Environment.make({|self|
        
        self.know = true;
        self.i = Order();

        self.addCurrent = {|self, num|
            var vals = self.getCurrentVals(node);
            var presets = self.getPresets(node);
            num.debug("Preset.addCurrent");
            vals['bufposreplyid'] = nil;
            vals['amp'] = nil;
            self.i.put(num, vals);
        };

        self.getPresets = {|self|
            self.i
        };

        self.getCurrentVals = {|self|

            var vals = if (node.respondsTo(\controlKeys)) {
                node.controlKeys;
            }{
                node.envir.keys;
            };

            vals = vals
            .select({|key|
                var val = node.get(key);
                val.isNumber or: { val.isArray.and({val.size > 0}).and({val[0].isNumber}) }
            })
            .reject({|key|
                (key == \amp) or: {key == \bend} or: {key == \vel}
            })
            .collect({|key| [key, node.get(key)] });

            vals.asArray.flatten.asDict
        };

        self.discard = {|self, num|
            self.i.removeAt(num);
        };

        self.morph = {|self, input|

            var getCurrentVals = {|node|
                var result;
                var specs = node.getSpec.keys;
                result = node.envir.select({|v, k| specs.includes(k) });
                result;
            };
            
            var doMorph = {|node, current, target, blend|
                var specs = node.getSpec;
                var result = current.blend(target, blend);
                var pairs = List();
                result.getPairs.keysValuesDo({|k, v|
                    var val;
                    var spec = specs[k];
                    if (spec.isNil) {
                        spec = [0, 1, \lin, 0, 0].asSpec;
                    };
                    val = v.round(spec.step);
                    pairs.add(k).add(val)
                });
                node.set(*pairs.as(Array));
            };
            
            var morph = {|node, left, right, blend|
                var current = self.i[left];
                var target = self.i[right];
                doMorph.(node, current, target, blend)
            };

            var numnodes = self.i.size;
            var current = input.linlin(0, 127, 0, numnodes-1);
            var blend = current.frac;
            var left = current.floor;
            var right = (left+1).clip(0, numnodes-1);
            morph.(node, left, right, blend);
        };

        self.apply = {|self, to|
            var preset = self.i[to];
            if (preset.notNil) {
                node.set(*preset.getPairs);
            } { 
                "no preset: %".format(to).warn
            };
            node.changed(\preset, [to, preset]);
        };
    });

    node.addUniqueMethod(\presets, {obj});
};
(func: func)
)