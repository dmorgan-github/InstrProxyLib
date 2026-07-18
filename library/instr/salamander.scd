(
var dir = "/Users/david/Documents/supercollider/media/instruments/MoonlightSalamanderGrandPianoV6.0_48khz24bit/48khz24bit";
var order = Order();
var load = {
    var map = [
        (path: "021_A0v01.wav", min:21, max:22, root: 21),
        (path: "024_C1v01.wav", min:23, max: 25, root: 24),
        (path: "027_D#1v01.wav", min:26, max: 28, root: 27),
        (path: "030_F#1v01.wav", min:29, max: 31, root: 30),
        (path: "033_A1v01.wav", min:32, max:34, root: 33),
        (path: "036_C2v01.wav", min:35, max:37, root: 36),
        (path: "039_D#2v01.wav", min:38, max: 40, root: 39),
        (path: "042_F#2v01.wav", min:41, max: 43, root: 42),
        (path: "045_A2v01.wav", min:44, max:46, root: 45),
        (path: "048_C3v01.wav", min:47, max: 49, root: 48),
        (path: "051_D#3v01.wav", min:50, max: 52, root: 51),
        (path: "054_F#3v01.wav", min:53, max:55, root: 54),
        (path: "057_A3v01.wav", min:56, max: 58, root: 57),
        (path: "060_C4v01.wav", min:59, max: 61, root: 60),
        (path: "063_D#4v01.wav", min:62, max: 64, root: 63),
        (path: "066_F#4v01.wav", min:65, max: 67, root: 66),
        (path: "069_A4v01.wav", min:68, max: 70, root: 69),
        (path: "072_C5v01.wav", min:71, max: 73, root: 72),
        (path: "075_D#5v01.wav", min:74, max: 76, root: 75),
        (path: "078_F#5v01.wav", min:77, max: 79, root: 78),
        (path: "081_A5v01.wav", min:80, max: 82, root: 81),
        (path: "084_C6v01.wav", min:83, max: 85, root: 84),
        (path: "087_D#6v01.wav", min:86, max: 88, root: 87),
        (path: "090_F#6v01.wav", min:89, max: 91, root: 90),
        (path: "093_A6v01.wav", min:92,  max: 94, root: 93),
        (path: "096_C7v01.wav", min:95, max: 97, root: 96),
        (path: "099_D#7v01.wav", min:98, max: 100, root: 99),
        (path: "102_F#7v01.wav", min:101, max: 103, root: 102),
        (path: "105_A7v01.wav", min:104, max: 106, root: 105),
        (path: "108_C8v01.wav", min:107, max: 108, root: 108)
    ].do({|v|
        var root = v['root'];
        var min = v['min'];
        var max = v['max'];
        var start = v['start'] ?? 0;
        var path = v['path'];
        path = "%/%".format(dir, path);

        Buffer.readChannel(Server.default, path:path.debug("path"), channels:[0, 1], action:{|buf|
            start = start/buf.numFrames;
            (min..max).do({|note|
                order.put(note, [buf, root.midicps, note.midicps, start].debug("buf") )       
            })
        });        
    });
};

var mapper = {
    var index = ~midinote.value;//.debug("note");
    //var amp = ~amp.value;
    var vals = order[index];//.debug("order");
    if (vals.notNil) {
        ~buf = vals[0].debug("buf");
        ~rootfreq = vals[1].debug("root");
        ~freq = vals[2].debug("freq");
        ~startPos = vals[3];
        //~amp = (amp * vals[4]);//.debug("amp")
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