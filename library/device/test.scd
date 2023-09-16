(
var func = {|node|

    var task;

    ~bobo.debug("here");
    ~monome = 5;

    ~task = ~task ?? TaskProxy({|envir|
        inf.do({|i|
            //envir['bobo'].debug("here2");
            envir['bobo2'] = i;
            1.wait;
        })
    })
    .envir_(currentEnvironment)
    .play;

    // expose a function
    //~testfunc = {
    //    \here.postln;
    //    Tdef(\abc).class
    //};

};

(func: func)

)
