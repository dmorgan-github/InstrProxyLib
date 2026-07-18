
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
        [ 60, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.C3.stereo.aif", 261.6255653006, 261.6255653006, 6831 ],
        [ 61, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Db3.stereo.aif", 277.18263097687, 277.18263097687, 12065 ],
        [ 62, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.D3.stereo.aif", 293.66476791741, 293.66476791741, 8036 ],
        [ 63, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Eb3.stereo.aif", 311.12698372208, 311.12698372208, 7534 ],
        [ 64, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.E3.stereo.aif", 329.62755691287, 329.62755691287, 8830 ],
        [ 65, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.F3.stereo.aif", 349.228231433, 349.228231433, 9328 ],
        [ 66, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Gb3.stereo.aif", 369.99442271163, 369.99442271163, 7616 ],
        [ 67, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.G3.stereo.aif", 391.99543598175, 391.99543598175, 9356 ],
        [ 68, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Ab3.stereo.aif", 415.30469757995, 415.30469757995, 8477 ],
        [ 69, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.A3.stereo.aif", 440.0, 440.0, 8638 ],
        [ 70, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Bb3.stereo.aif", 466.16376151809, 466.16376151809, 7691 ],
        [ 71, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.B3.stereo.aif", 493.88330125612, 493.88330125612, 8541 ],
        [ 72, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.C4.stereo.aif", 523.2511306012, 523.2511306012, 739 ],
        [ 73, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Db4.stereo.aif", 554.36526195374, 554.36526195374, 426 ],
        [ 74, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.D4.stereo.aif", 587.32953583482, 587.32953583482, 0 ],
        [ 75, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.D4.stereo.aif", 587.32953583482, 622.25396744416, 2716 ],
        [ 76, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.E4.stereo.aif", 659.25511382574, 659.25511382574, 686 ],
        [ 77, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.F4.stereo.aif", 698.45646286601, 698.45646286601, 1019 ],
        [ 78, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Gb4.stereo.aif", 739.98884542327, 739.98884542327, 1620 ],
        [ 79, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.G4.stereo.aif", 783.9908719635, 783.9908719635, 604 ],
        [ 80, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Ab4.stereo.aif", 830.60939515989, 830.60939515989, 2141 ],
        [ 81, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.A4.stereo.aif", 880.0, 880.0, 867 ],
        [ 82, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Bb4.stereo.aif", 932.32752303618, 932.32752303618, 1029   ],
        [ 83, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.B4.stereo.aif", 987.76660251225, 987.76660251225, 178 ],
        [ 84, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.C5.stereo.aif", 1046.5022612024, 1046.5022612024, 0 ],
        [ 85, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Db5.stereo.aif", 1108.7305239075, 1108.7305239075, 0 ],
        [ 86, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.D5.stereo.aif", 1174.6590716696, 1174.6590716696, 0 ],
        [ 87, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Eb5.stereo.aif", 1244.5079348883, 1244.5079348883, 0 ],
        [ 88, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.E5.stereo.aif", 1318.5102276515, 1318.5102276515, 0 ],
        [ 89, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.F5.stereo.aif", 1396.912925732, 1396.912925732, 0 ],
        [ 90, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Gb5.stereo.aif", 1479.9776908465, 1479.9776908465, 0 ],
        [ 91, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.G5.stereo.aif", 1567.981743927, 1567.981743927, 0 ],
        [ 92, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Ab5.stereo.aif", 1661.2187903198, 1661.2187903198, 0 ],
        [ 93, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.A5.stereo.aif", 1760.0, 1760.0, 0 ],
        [ 94, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Bb5.stereo.aif", 1864.6550460724, 1864.6550460724, 0 ],
        [ 95, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.B5.stereo.aif", 1975.5332050245, 1975.5332050245, 0 ],
        [ 96, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.C6.stereo.aif", 2093.0045224048, 2093.0045224048, 0 ],
        [ 97, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Db6.stereo.aif", 2217.461047815, 2217.461047815, 0 ],
        [ 98, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.D6.stereo.aif", 2349.3181433393, 2349.3181433393, 0 ],
        [ 99, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.Eb6.stereo.aif", 2489.0158697766, 2489.0158697766, 0 ],
        [ 100, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.E6.stereo.aif", 2637.020455303, 2637.020455303, 0 ],
        [ 101, "/Users/david/Documents/supercollider/media/instruments/vibraphone/sustain.ff/Vibraphone.sustain.ff.F6.stereo.aif", 2793.825851464, 2793.825851464, 0 ]
    ].do({|v|
        var note = v[0];
        var path = v[1];
        var root = v[2];
        var freq = v[3];
        var start = v[4];
        Buffer.readChannel(Server.default, path:path.debug("path"), startFrame: start, channels:[0, 1], action:{|buf|
            order.put(note, [buf.normalize, root, freq].debug("buf") )   
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
    };
};

var func = {|index|
    load.();
    t(index) <+ [sig: M('synth/smplr').numchannels_(2), aeg: M.asr];
    t(index).notePlayer.filter = mapper;
    t(index) @.finish mapper;
    t(index) @.octave 6;
};

(func: func)

)