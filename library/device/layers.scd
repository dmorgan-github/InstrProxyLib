(
var func = {|node|
    var obj = Environment.make({|self|

        self.know = true;
        self.node = node;
        self.i = Order();
        self.quant = 4.0;
        
        self.set = {|self, index, pattern|
            var proxy = self.i[index];
            if (proxy.isNil) {
                proxy = EventPatternProxy().quant_(self.quant);
                self.i.put(index, proxy);
            };
            if (pattern.isArray) {
                var a;
                pattern.pairsDo {|k,v|
                    a = a.add(k).add(v);
                };
                pattern = Pbind(*a);
            };
            proxy.source = pattern;
            self;
        };
    
        self.play = {|self ... nums|
            nums = nums.asArray.flatten;
            if (nums.isNil or: {nums.size < 1} ) {
                self.node.stop  
            }{
                var ptrns, pattern;
                ptrns = nums.collect({|num| self.i[num] });
                pattern = Ppar(ptrns);
                node.source = pattern;
                if (node.isPlaying.not) {
                    node.play;
                }
            };
        };
    });
    node.addUniqueMethod(\layers, {obj});
    obj
};
(func: func)
)