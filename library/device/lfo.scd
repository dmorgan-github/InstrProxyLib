(
var func = {

    var obj = ();

    obj['sine'] = {|self, dur=1, min=0, max=1|
        { SinOsc.ar(\dur.kr(dur).reciprocal, 1).range(\min.kr(min), \max.kr(max)) }
        //{ SinOsc.ar(\dur.kr(dur).reciprocal, 1).range(0, 1) }
    };

    obj['tri'] = {|self, dur=1, min=0, max=1|
        { LFTri.ar(\dur.kr(dur).reciprocal).range(\min.kr(min), \max.kr(max)) };
    };

    obj['rampup'] = {|self, dur=1, min=0, max=1|
        { LFSaw.ar(\dur.kr(dur).reciprocal).range(\min.kr(min), \max.kr(max)) };
    };

    obj['rampdown'] = {|self, dur=1, min=0, max=1|
        { LFSaw.ar(\dur.kr(dur).reciprocal.neg).range(\min.kr(min), \max.kr(max)) };        
    };

    /*
    curves {|levels, times, curve, min=0, max=1|
        this[0] = {
            var dur = times.sum;
            var env = Env(levels, times, curve);
            var index = LFSaw.ar(dur.reciprocal, iphase:1).range(0, dur);
            // DemandEnvGen??
            IEnvGen.ar(env, index).linlin(-1, 1, min, max)
        };
        this.set(\min, min, \max, max)
    }
    */

    obj
};

(func: func)
)
