SynthDef('Microwave 1.vst3', {
    var sig = VSTPlugin.ar(
        Silent.ar(2), 
        numOut:2,
        params: [
            'AmpEnvAttack', \atk.kr(0),
            'AmpEnvDecay', \dec.kr(0.314),
            'AmpEnvSustain', \suslevel.kr(1),
            'AmpEnvRelease', \rel.kr(0.448),
            'FilterEnvAttack', \fatk.kr(0.29),
            'FilterEnvDecay', \fdec.kr(0.322),
            'FilterEnvSustain', \fsuslevel.kr(0.551),
            'FilterEnvRelease', \frel.kr(0.33),
            'FilterFreq', \cutoff.kr(0.811)
        ],
        info:'Microwave 1.vst3'
    );
    sig = sig * \amp.kr(-20.dbamp);
    Out.ar(\out.kr(0), sig) 
}).add;