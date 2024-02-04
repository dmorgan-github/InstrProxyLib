(
var func = {|in| 
    var crush = \crush.kr(16, spec:ControlSpec(1, 16, \lin, 0, 16, units: "crush"));
    var fx = in.round(0.5 ** (crush-1)); 
    in.blend(fx, \crush_mix.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"crush" ) )  )
};

(func: func)
)