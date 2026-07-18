
(
var func = {|in|

    var sig = in;

    var loshelf_freq = \loshelf_freq.kr(20, spec:ControlSpec(20, 4000, \exp, 0, 20, units:"lohishelf") );
    var loshelf_db = \loshelf_db.kr(0, spec:ControlSpec(-60, 0, \lin, 0, 0, units:"lohishelf") );

    var hishelf_freq = \hishelf_freq.kr(16000, spec:ControlSpec(4000, 16000, \exp, 0, 16000, units:"lohishelf") );
    var hishelf_db = \hishelf_db.kr(0, spec:ControlSpec(-60, 0, \lin, 0, 0, units:"lohishelf") );

    sig = BLowShelf.ar(sig, freq:loshelf_freq, db:loshelf_db);
    sig = BHiShelf.ar(sig, hishelf_freq, db:hishelf_db);

    //sig = in.blend(sig, \lohishelf_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"lohishelf"))  );
    sig
};

(func: func)

)