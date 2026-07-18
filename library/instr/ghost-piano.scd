
/*
helper function
(
var dir = "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff";
var files = PathName(dir).files;
files
.collect({|pn| 
    var note;
    var name = pn.fileName.split($.)[3];
    name = name.asSymbol;
    note = name.namemidi;
    [note.asInteger, pn.fullPath.asCompileString, note.midicps, note.midicps]
})
.sort({|a, b|
    a[0] < b[0]   
})
.do({|v|
    v.postln
})
)
*/
(
var order = Order();

var load = {
    var map = [


        [24, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 24.midicps, 0],
        [25, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 25.midicps, 0],
        [26, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 26.midicps, 0],
        [27, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 27.midicps, 0],
        [28, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 28.midicps, 0],
        [29, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 29.midicps, 0],
        [30, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p C0.wav", 24.midicps, 30.midicps, 0],

        [31, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 31.midicps, 0],
        [32, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 32.midicps, 0],
        [33, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 33.midicps, 0],
        [34, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 34.midicps, 0],
        [35, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 35.midicps, 0],
        [36, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 36.midicps, 0],
        [37, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G0.wav", 31.midicps, 37.midicps, 0],

        [38, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 38.midicps, 0],
        [39, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 39.midicps, 0],
        [40, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 40.midicps, 0],
        [41, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 41.midicps, 0],
        [42, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 42.midicps, 0],
        [43, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 43.midicps, 0],
        [44, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p D1.wav", 38.midicps, 44.midicps, 0],

        [45, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 45.midicps, 0],
        [46, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 46.midicps, 0],
        [47, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 47.midicps, 0],
        [48, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 48.midicps, 0],
        [49, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 49.midicps, 0],
        [50, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 50.midicps, 0],
        [51, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A1.wav", 45.midicps, 51.midicps, 0],

        [52, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E2.wav", 52.midicps, 52.midicps, 0],
        [53, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E2.wav", 52.midicps, 53.midicps, 0],
        [54, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E2.wav", 52.midicps, 54.midicps, 0],
        [55, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E2.wav", 52.midicps, 55.midicps, 0],
        [56, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E2.wav", 52.midicps, 56.midicps, 0],
        [57, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E2.wav", 52.midicps, 57.midicps, 0],

        [58, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 58.midicps, 0],
        [59, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 59.midicps, 0],
        [60, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 60.midicps, 0],
        [61, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 61.midicps, 0],
        [62, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 62.midicps, 0],
        [63, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 63.midicps, 0],
        [64, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 64.midicps, 0],
        [65, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p B2.wav", 58.midicps, 65.midicps, 0],

        [66, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p F#3.wav", 66.midicps, 66.midicps, 0], 
        [67, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p F#3.wav", 66.midicps, 67.midicps, 0], 
        [68, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p F#3.wav", 66.midicps, 68.midicps, 0], 
        [69, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p F#3.wav", 66.midicps, 69.midicps, 0], 

        [70, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 70.midicps, 0],
        [71, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 71.midicps, 0],
        [72, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 72.midicps, 0],
        [73, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 73.midicps, 0],
        [74, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 74.midicps, 0],
        [75, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 75.midicps, 0],
        [76, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 76.midicps, 0],
        [77, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 77.midicps, 0],
        [78, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#3.wav", 70.midicps, 78.midicps, 0],

        [79, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 79.midicps, 0],
        [80, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 80.midicps, 0],
        [81, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 81.midicps, 0],
        [82, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 82.midicps, 0],
        [83, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 83.midicps, 0],
        [84, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 84.midicps, 0],
        [85, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 85.midicps, 0],
        [86, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 86.midicps, 0],
        [87, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p G4.wav", 79.midicps, 87.midicps, 0],

        [88, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E5.wav", 88.midicps, 88.midicps, 0],
        [89, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E5.wav", 88.midicps, 89.midicps, 0],
        [90, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E5.wav", 88.midicps, 90.midicps, 0],
        [91, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E5.wav", 88.midicps, 91.midicps, 0],
        [92, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E5.wav", 88.midicps, 92.midicps, 0],
        [93, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p E5.wav", 88.midicps, 93.midicps, 0],

        [94, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 94.midicps, 0],
        [95, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 95.midicps, 0],
        [96, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 96.midicps, 0],
        [97, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 97.midicps, 0],
        [98, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 98.midicps, 0],
        [99, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 99.midicps, 0],
        [100, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p A#5.wav", 94.midicps, 100.midicps, 0],

        [101, "/Users/david/Documents/supercollider/media/instruments/Ghost Piano/samples original/Merrill 1900 p F6.wav", 101.midicps, 101.midicps, 0],

    ].do({|v|
        var note = v[0];
        var path = v[1];
        var root = v[2];
        var freq = v[3];
        var start = v[4];
        Buffer.readChannel(Server.default, path:path.debug("path"), channels:[0, 1], action:{|buf|
            order.put(note, [buf.normalize, root, freq, start].debug("buf") )   
        });
    });
};

var mapper = {
    var index = ~midinote.value;//.debug("note");
    var vals = order[index];//.debug("order");
    if (vals.notNil) {
        ~buf = vals[0];//.debug("buf");
        ~rootfreq = vals[1];//.debug("root");
        ~freq = vals[2];//.debug("freq")
        ~startPos = vals[3];
    };
};

var func = {|index|
    load.();
    t(index) <+ [sig: M('synth/smplr').numchannels_(2), aeg: M.asr];
    t(index).notePlayer.filter = mapper;
    t(index) @.finish mapper;
    t(index) @.octave 4;
};

(func: func)

)