(
func: {|node|

    var server = Server.default;
    var updateFreq = 10, dBLow = -80;
    var levelkey = node.key;
    var bus, numchannels;
    var meterWidth = 15;
    var meters, view, synth;
    var alpha = 0.6;
    var color = Color.green.alpha_(alpha);
    var metercolor = if (node.isMonitoring) {color}{Color.grey};

    var monitorwatcher = {|obj, what|
        if (what == \play) {
            meters.do({|m|
                m.meterColor = color;
            })
        }{
            if (what == \stop) {
                meters.do({|m|
                    m.meterColor = Color.grey;
                })
            }
        }
    };

    node = if (node.respondsTo(\node)) {node.node}{node};
    bus = node.bus.index;
    numchannels = node.bus.numChannels;

    meters = Array.fill( numchannels, { arg i;
        var li = LevelIndicator()
        .warning_(-3.dbamp)
        .critical_(-1.dbamp)
        .warningColor_(Color.yellow.alpha_(alpha))
        .criticalColor_(Color.red.alpha_(alpha))
        .drawsPeak_(true)
        .style_(\led)
        .numSteps_(30)
        .meterColor_(metercolor);
        li.minWidth = 175;
        li.fixedHeight = 8
    });

    synth = SynthDef(levelkey ++ "OutputLevels", {
        var in = InFeedback.ar(bus, numchannels).asArray;
        SendPeakRMS.kr(in, updateFreq, 3, "/" ++ levelkey ++ "OutLevels")
    }).play(node.group.nodeID, nil, \addToTail);
    // should this be the node group or monitor group?
    //node.monitor.group.nodeID

    OSCdef(levelkey, {|msg|
        {
            try {

                var channelCount = min(msg.size - 3 / 2, numchannels);
                channelCount.do {|channel|
                    var baseIndex = 3 + (2*channel);
                    var peakLevel = msg.at(baseIndex);
                    var rmsValue = msg.at(baseIndex + 1);
                    var meter = meters.at(channel);
                    if (meter.notNil) {
                        if (meter.isClosed.not) {
                            meter.peakLevel = peakLevel.ampdb.linlin(dBLow, 0, 0, 1, \min);
                            meter.value = rmsValue.ampdb.linlin(dBLow, 0, 0, 1);
                        }
                    }
                }
            } { |error|
                if(error.isKindOf(PrimitiveFailedError).not) { error.throw }
            };
        }.defer;
    }, ("/" ++ levelkey ++ "OutLevels").asSymbol, server.addr);

    node.addDependant(monitorwatcher);

    view = View().layout_(
        VLayout(*meters).margins_(1).spacing_(1) 
    );
    view
    .minWidth_(75)
    .onClose_({
        //"free".debug("meter");
        node.removeDependant(monitorwatcher);
        synth.free;
        OSCdef(levelkey).free;
    });
}
)
