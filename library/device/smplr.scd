(
var func = {|num, bufs|

    var t = T();
    var instr, bufindex, bufindexchanged, numchannels;
    var spec, currentBuf;
    bufs = bufs.asArray;
    numchannels = bufs[0].numChannels;

    t[num] = {|m| m.sampler(\numchannels, numchannels) * m.asr};
    instr = t[num];

    //instr = T.instr(key, {|m| m.sampler(\numchannels, numchannels) * m.asr});

    bufindex = {
        var index = ~bufindex ?? 0;
        var bufs = ~bufs;
        if (index.isNil) {
            index = 0
        };
        ~buf = bufs.wrapAt(index)
    };

    bufindexchanged = {|obj, what vals|
        if (what == \set) {
            if ( vals.includes(\bufindex) ) {
                var index, val, bufs, buf;
                index = vals.indexOf(\bufindex);
                val = vals[index+1];
                bufs = obj.get(\bufs);
                buf = bufs.wrapAt(val);
                obj.set(\buf, buf);
                currentBuf = buf;
            };
        }
    };

    instr.addDependant(bufindexchanged);
    instr.fx(20, 'dynamics/softkneecompressor');
    instr.fx(22, 'distortion/softclip');
    instr.fx(24, 'eq/eq');
    instr.fx(26, 'reverb/miverb');
    instr.fx(28, 'delay/fb');

    spec = bufs.getSpec ?? ();
    if (spec['index'].isNil ) {
        spec = [0, bufs.size-1, \lin, 1, 0].asSpec;
    }{
        spec = spec['index'];   
    };

    instr.addSpec(\bufindex, spec.units_("smplr"));
    instr @.bufs bufs;
    instr @.amp 1;
    instr @.atk 0;
    instr @.bufindex 0;
    instr @.finish bufindex;
    instr
};

(func: func)
)