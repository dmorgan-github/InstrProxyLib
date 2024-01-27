(
// adapted from superdirt
var func = {|in|

    var sig = in;
    var shape = \shape.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, "shape"));
    shape = min(shape, 1.0 - 4e-10); // avoid division by zero
    //amp = 1.0 - (0.15 * shape / (shape + 2.0)) * amp; // optional gain comp
    shape = (2.0 * shape) / (1.0 - shape);

    sig = (1 + shape) * sig / (1 + (shape * abs(sig)));
    sig = in.blend(sig, \shape_mix.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "shape")));
    sig;
};

(func: func)
)