(
var func = {|key|

    var view, seqSlider, modSlider, shapeSlider, lenSlider, rotateSlider;
    var updateUi, seqValue = [0], modValue = [1], rotateValue = 0, setSeqValue;
    var size = 16, maxSize = 16, makeUi;
    var amps = [1];
    var ptrn = Pdef("%_ptrn".format(key).asSymbol);

    seqValue = Signal.sineFill(size, amps).linlin(-1, 1, 0, 1);
    modValue = 1.dup(size);
    amps = [1] ++ 0.dup(size-1);

    if (ptrn.get(\seqValue).notNil ) {
        seqValue = ptrn.get(\seqValue);  
    };

    if (ptrn.get(\modValue).notNil ) {
        modValue = ptrn.get(\modValue);  
    };

    if (ptrn.get(\rotateValue).notNil ) {
        rotateValue = ptrn.get(\rotateValue);  
    };

    if (ptrn.get(\amps).notNil) {
        amps = ptrn.get(\amps);
    };

    if (ptrn.get(\size).notNil) {
        size = ptrn.get(\size);
    };
    
    updateUi = {|index|
        {
            if (view.isClosed.not) {
                seqSlider.index = index;
                modSlider.index = index;
            }
        }.defer(Server.default.latency);
    };

    setSeqValue = {
        var sig;
        ptrn.set(\rotateValue, rotateValue, \size, size, \amps, amps);
        sig = Signal.sineFill(size, amps).linlin(-1, 1, 0, 1).rotate(rotateValue);
        seqSlider.valueAction = sig;   
    };

    makeUi = {

        var width = 200, height = 125;

        view = View(bounds:Rect(left:500, top: 500, width:width, height:height))
        .name_("seq")
        .layout_(VLayout().margins_(0).spacing_(0))
        .background_(Color.black);

        seqSlider = MultiSliderView(bounds:Rect(width:width, height:height))
        .elasticMode_(1)
        .indexIsHorizontal_(true)
        .isFilled_(true)
        .showIndex_(true)
        .reference_(0.5 ! size)
        .background_(Color.clear)
        .action_({|ctrl|
            seqValue = ctrl.value;
            modValue = modValue.wrapExtend(size);
            modSlider.value = modValue;
            ptrn.set(\seqValue, seqValue, \modValue, modValue);
        })
        .value_(seqValue);

        modSlider = MultiSliderView(bounds:Rect(width:width, height:height))
        .elasticMode_(1)
        .indexIsHorizontal_(true)
        .fillColor_(Color.white.alpha_(0.6))
        .isFilled_(true)
        .showIndex_(true)
        .background_( Color.clear )
        .action_({|ctrl| 
            modValue = ctrl.value;//.debug("modvalue");
            ptrn.set(\modValue, modValue);
        })
        .value_(modValue);

        shapeSlider = MultiSliderView(bounds:Rect(width:width, height:height))
        .elasticMode_(1)
        .indexIsHorizontal_(true)
        .fillColor_(Color.white.alpha_(0.6))
        .isFilled_(true)
        .showIndex_(false)
        .background_( Color.clear )
        .action_({|ctrl|
            amps = ctrl.value;
            setSeqValue.();
        })
        .value_(amps);

        lenSlider  = MultiSliderView(bounds:Rect(width:width, height:20))
        .maxHeight_(20)
        .elasticMode_(1)
        .indexIsHorizontal_(false)
        .fillColor_(Color.white.alpha_(0.6))
        .isFilled_(true)
        .background_( Color.clear )
        .action_({|ctrl|
            size = ctrl.value[0].linlin(0, 1, 1, maxSize).round.asInteger;
            setSeqValue.();
        })
        .value_( size.linlin(1, maxSize, 0, 1).asArray  );

        rotateSlider = MultiSliderView(bounds:Rect(width:width, height:20))
        .maxHeight_(20)
        .elasticMode_(1)
        .indexIsHorizontal_(false)
        .fillColor_(Color.white.alpha_(0.6))
        .reference_([0.5])
        .isFilled_(true)
        .showIndex_(true)
        .background_( Color.clear )
        .action_({|ctrl|
            rotateValue = ctrl.value.linlin(0, 1, size.neg, size).asInteger.first;
            setSeqValue.();
        })
        .value_( rotateValue.linlin(size.neg, size, 0, 1).asArray );

        view.layout.add(seqSlider);
        view.layout.add(modSlider);
        view.layout.add(lenSlider);
        view.layout.add(rotateSlider);
        view.layout.add(shapeSlider);

        view;
    };

    ptrn.addUniqueMethod('view', { makeUi.() });

    ptrn.addUniqueMethod('setSeq', {|obj, vals|
        size = vals.size;
        seqSlider.resize = size;
        seqSlider.valueAction = vals;

        vals = modSlider.value ?? [1];
        modSlider.resize = size;
        modSlider.valueAction = vals.wrapExtend(size);
        obj;
    });

    ptrn.addUniqueMethod('updateUi', {|obj, index|
        updateUi.(index)    
    });

    ptrn.source = Pbind(
        \phase, Pseries(),
        \seqvals, Pfunc({
            seqValue   
        }),
        \modvals, Pfunc({
            modValue    
        }),
        \seq, Pfunc({|evt|
            var phase = evt['phase'];
            var vals = evt['seqvals'];
            var val = vals.wrapAt(phase);
            val;
        }),
        \mod, Pfunc({|evt|
            var phase = evt['phase'];
            var vals = evt['modvals'];
            var val = vals.wrapAt(phase);
            val;
        }),
        \refresh, Pfunc({|evt|
            var phase = evt['phase'];
            var vals = evt['seqvals'];
            var size = vals.size;
            phase = phase.mod(size);
            updateUi.(phase);
        })
    );

    ptrn
};

(func: func)
)