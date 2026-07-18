(
var func = {|index|

    t(index) <+ [sig: M.rings.slice_([0, 1]), aeg: M.asr];
    t(index).addUniqueMethod(\instrview, {
        UiModule('rings').(t(index))
    });

};

(func: func)
)