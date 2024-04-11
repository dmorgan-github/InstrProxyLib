(
/*
~tracker = M('device/tracker')
~t1 = ~tracker.()

t(4) << ~t1.ptrn

(
~t1.track(
    0,    (degree: 0, vel: 1.5, legato: 0.3),  
    5.5,  (degree: 1, vel: 0.8), 
    6,    (degree: -1, vel: 0.7),
    6.5,  (degree: -2, vel: 0.3, legato: 0.05),
    6.75, (degree: 0, vel: 0.7, octave: 5, legato: 0.1, clip: 0.5),
    7,    (octave: 3, legato: 0.1))
)
*/
var func = {

    var obj = ();
    obj.data = Order();
    obj.numbeats = 8;

    // TODO: support doing this with just dur values
    obj.track = {|self ...args|
        var diffs;
        var data = obj.data;
        var times = args.select({|v, i| i.even });
        diffs = data.indices.asFloat.difference(times.asFloat);
        diffs.do({|i| data.removeAt(i) });
        args.keysValuesDo({|k, v|
            data.put(k, v)  
        });
    };
    /*
    obj.track = {|self, str, props|

        var fromHexString = {|string|
            var digits, red, green, blue;
            if(string[0] == $#, {string = string.copyToEnd(1)});
            digits = string.collectAs({|chr|
                var val = chr.digit;
                if(val>15, { "hex value 0x% out of bounds - clipping to 0xF".format(chr).warn });
                val.min(15);
            }, Array);
            if(digits.size == 3, { digits = digits.dupEach(2) });
            digits = digits[0] * 16 + digits[1];
            digits
        };
        
        var data = obj.data;
        var order = Order();
        var result = List();
        var rows, diffs;
    
        rows = str
        .stripWhiteSpace
        .split($\n);
        
        rows.do({|row|
            var row_vals = List();
            var vals = row.split(Char.space);
            vals.do({|v|
                if (v.size > 0) {
                    row_vals.add(v)    
                };   
            });
            result.add(row_vals)
        });
        result.do({|v|
            var degree = nil;
            var octave = nil;
            var legato = nil;
            var vel = nil;
            var index = v[0].asFloat;
            if (v.size >= 2) {
                var props = v[1];
                var temp = props[0..1];
                var match = temp.findAllRegexp("[0-9]");
                if (match.size == 2) {
                    degree = temp.asInteger;
                };
                if (props.size >= 4) {
                    temp = props[2..3];
                    match = temp.findAllRegexp("[0-9]");
                    if (match.size == 2) {
                        octave = temp.asInteger
                    }
                };
                if (props.size >= 6) {
                    temp = props[4..5];
                    match = temp.findAllRegexp("[a-zA-Z0-9]");
                    if (match.size == 2) {
                        vel = fromHexString.(temp);
                        vel = vel.linlin(0, 255, 0, 2)
                    };
                };
                if (props.size >= 8) {
                    temp = props[6..7];
                    match = temp.findAllRegexp("[a-zA-Z0-9]");
                    if (match.size == 2) {
                        legato = fromHexString.(temp);
                        legato = legato.linlin(0, 255, 0, 1)
                    };
                }
            };
            order.put(index, (degree: degree, octave: octave, vel: vel, legato: legato) )
        });
        diffs = data.indices.asFloat.difference(order.indices.asFloat);
        
        diffs.do({|i|
            data.removeAt(i)
        });
        
        order.do({|v, i|
            data.put(i, v)    
        });
    };
    */
    obj.ptrn = Plazy({
        Pspawner({|sp|
            inf.do({
                var numbeats = obj.numbeats;
                var order = obj.data;
                var durs = (order.indices ++ [numbeats]).reverse.differentiate.abs.reverse[0..order.size-1];
                var vals = order.array;
                durs.do({|v, i|
                    var val = vals[i];
                    var dur = v;
                    var evt = Pbind( \dur, Pn(dur, 1) ) <> val;
                    sp.seq(evt)
                })
            })
        })
    });
    obj;
};

(func: func)

)