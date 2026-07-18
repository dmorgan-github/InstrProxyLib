(
var func = {|index|
    
    t(index) <+ [sig: { SoundIn.ar( [0, 1] ) }, aeg: M.asr];
    t(index) @.amp -3.dbamp;

    t(index).addUniqueMethod('instrview', {
        t(index).gui("[kb freq]");    
    });
};

(func: func)
)