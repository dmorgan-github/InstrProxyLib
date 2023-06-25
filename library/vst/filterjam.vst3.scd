(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Bypass', 'filterjam_bypass'.kr(0.0),
			'Emphasis', 'filterjam_emphasis'.kr(0.5),
			'Frequency', 'filterjam_frequency'.kr(0.5),
			'Gain', 'filterjam_gain'.kr(0.5),
			'Mix', 'filterjam_mix'.kr(1),
			'Operations', 'filterjam_operations'.kr(0),
		],
		info:'Filterjam.vst3'
    )
}
)
