(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Mode', 'valhallaspacemod_mode'.kr(0.090909093618393),
			'depth', 'valhallaspacemod_depth'.kr(0.5),
			'feedback', 'valhallaspacemod_feedback'.kr(0.5),
			'manual', 'valhallaspacemod_manual'.kr(0.5),
			'rate', 'valhallaspacemod_rate'.kr(0.6259999871254),
			'wetDry', 'valhallaspacemod_wetdry'.kr(0.5),
		],
		info:'ValhallaSpaceModulator.vst3'
    )
}
)
