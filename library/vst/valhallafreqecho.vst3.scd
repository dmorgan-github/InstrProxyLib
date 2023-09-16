(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'delay', 'valhallafreqecho_delay'.kr(0.00099000986665487),
			'feedback', 'valhallafreqecho_feedback'.kr(0.5),
			'highCut', 'valhallafreqecho_highcut'.kr(0.33110368251801),
			'lowCut', 'valhallafreqecho_lowcut'.kr(0.060402683913708),
			'shift', 'valhallafreqecho_shift'.kr(0.50007498264313),
			'stereo', 'valhallafreqecho_stereo'.kr(1.0),
			'sync', 'valhallafreqecho_sync'.kr(0.0),
			'wetDry', 'valhallafreqecho_wetdry'.kr(0.5),
		],
		info:'ValhallaFreqEcho.vst3'
    )
}
)
