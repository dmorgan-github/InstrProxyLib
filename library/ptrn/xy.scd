(
var func = {
    Pbind(
        \x, Prout({|inval|
            var i = 0;
            inf.do({|j|
                var step = inval['step'] ?? [1, 1];
                var dup = inval['dup'] ?? [1, 1];
                step = step.asArray.wrapAt(0);
                step = step.asArray.wrapAt(j);
                dup = dup.asArray.wrapAt(0);
                dup = dup.asArray.wrapAt(j);
                dup.max(1).do({
                    inval = (i%4).embedInStream(inval);
                });
                i = i + step;
            })
        }),
        \y, Prout({|inval|
            var i = 0;
            inf.do({|j|
                var step = inval['step'] ?? [1, 1];
                var dup = inval['dup'] ?? [1, 1];
                step = step.asArray.wrapAt(1);
                step = step.asArray.wrapAt(j);
                dup = dup.asArray.wrapAt(1);
                dup = dup.asArray.wrapAt(j);
                dup.max(1).do({
                    inval = (i%4 * 4).embedInStream(inval);
                });
                i = i + step;
            })
        }),
        \pos, Pfunc({|evt|
            var x = evt['x'];
            var y = evt['y'];
            var val = x + y;
            15.collect({|i| if (i == val) {"x"}{" "} });
            val
        }),
        \degree, Pfunc({|evt|
            var pos = evt['pos'] ?? 0;
            var vals = evt['vals'] ?? [0];
            vals.asArray.wrapExtend(16).wrapAt(pos);
        })
    )
};

(
    func: func,
    doc: "
~yis << DMModule('ptrn/xy').()
~yis @.step [1, 2] @.dup [2, 3]
~yis @.vals [0, 2, 4, 6, 8]
    "
)
)

