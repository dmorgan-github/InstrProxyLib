(
/*
mpv --vf=lavfi-monochrome,lavfi-shufflepixels,lavfi-shuffleframes --lavfi-complex='[aid1]asplit[ao][a1];[a1]showwaves=mode=cline:colors=white:rate=25:s=1280x720[sw];[sw] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2 [vo]' --end=01:40 --audio-device='coreaudio/~:AMS2_Aggregate:0' "20240609-3db.wav"
mpv --lavfi-complex='[aid1]asplit[ao][a1];[a1]showwaves=mode=cline:colors=white:rate=25:s=1280x720,format=rgb0 [vo]' --audio-device='coreaudio/~:AMS2_Aggregate:0' '20240609-3db.wav'
*/
var ctrl = Environment.make({|self|
    self.know = true;
    self.open = {|self, stream|
        var pipe;
        var str = "mpv % --audio-device='coreaudio/~:AMS2_Aggregate:0' --profile=pseudo-gui --lavfi-complex='[aid1]asplit[ao][a1];[a1]showwaves=mode=cline:colors=white:rate=25,format=rgb0 [vo]'".format(stream);
        //var str = "mpv % --profile=pseudo-gui --lavfi-complex='[aid1]asplit[ao][a1];[a1]showwaves=mode=cline:colors=white:rate=25,format=rgb0 [vo]'".format(stream);
        str.postln;
        pipe = Pipe.new(str, "r");
        pipe
    }
});

( 
func: { ctrl },
doc: "
https://locusonus.org/soundmap/
https://locus.creacast.com:9443/delhi_bariya.mp3
https://locus.creacast.com:9443/marseille_rue_de_la_bibliotheque.mp3
https://audio.wavefarm.org/pondstation.mp3
https://locus.creacast.com:9443/morecambe_bare_village
https://locus.creacast.com:9443/chania_ffpp_museum_stream.mp3
https://locus.creacast.com:9443/london_listen_to_the_lea.mp3
"
)

)