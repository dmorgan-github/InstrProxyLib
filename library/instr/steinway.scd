(
var dir = "/Users/david/Documents/supercollider/media/instruments/Pianobook Kristiansand Concert Steinway/1 Samples/NR";
var order = Order();
var load = {
    var map = [
        (path: "Pianobook Steinway Kristiansand v1 p F6.wav", root: 101, min: 95, max: 110, start: 38909, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p A#5.wav", root: 94, min: 88, max: 94, start: 39841, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p D#5.wav", root: 87, min: 81, max: 87, start: 42225, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p G#4.wav", root: 80, min: 74, max: 80, start: 40502, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p C#4.wav", root: 73, min: 67, max: 73, start: 43263, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p F#3.wav", root: 66, min: 60, max: 66, start: 74563, vol: 0.45),
        (path: "Pianobook Steinway Kristiansand v1 p B2.wav", root: 59, min: 53, max: 59, start: 40872, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p E2.wav", root: 52, min: 46, max: 52, start: 41978, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p A1.wav", root: 45, min: 39, max: 45, start: 42510, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p D1.wav", root: 38, min: 32, max: 38, start: 76586, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p G0.wav", root: 31, min: 25, max: 31, start: 39358, vol: 1),
        (path: "Pianobook Steinway Kristiansand v1 p C0.wav", root: 24, min: 0, max: 24, start: 39896, vol: 1)
    ].do({|v|
        var root = v['root'];
        var min = v['min'];
        var max = v['max'];
        var start = v['start'];
        var path = v['path'];
        var vol = v['vol'];
        path = "%/%".format(dir, path);

        Buffer.readChannel(Server.default, path:path.debug("path"), channels:[0, 1], action:{|buf|
            start = start/buf.numFrames;
            (min..max).do({|note|
                order.put(note, [buf, root.midicps, note.midicps, start, vol].debug("buf") )       
            })
        });        
    });
};

var mapper = {
    var index = ~midinote.value;//.debug("note");
    var amp = ~amp.value;
    var vals = order[index];//.debug("order");
    if (vals.notNil) {
        ~buf = vals[0];//.debug("buf");
        ~rootfreq = vals[1];//.debug("root");
        ~freq = vals[2];//.debug("freq")
        ~startPos = vals[3];
        ~amp = (amp * vals[4]);//.debug("amp")
    };
};

var func = {|index|
    load.();
    t(index) <+ [sig: M('synth/smplr').numchannels_(2), aeg: M.asr];
    t(index).notePlayer.filter = mapper;
    t(index) @.finish mapper;
    //t(index) @.octave 4;
};

(func: func)

)