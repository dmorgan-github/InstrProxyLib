(
// https://scsynth.org/t/compander-fix/13152/7?u=droptableuser
var compGain;
compGain = { |in, threshold, slope, attack = 0.05, release = 0.3|
    var inArray, amplitude, timeConstantToRT60;
    inArray = if(in.isArray) { in } { [in] };
    timeConstantToRT60 = log(-60.dbamp) * -1;
    amplitude = (Amplitude.ar(inArray, attack * timeConstantToRT60, release * timeConstantToRT60).sum / inArray.size.sqrt).max(-100.dbamp).ampdb;
    ((amplitude - threshold).max(0) * (slope - 1)).lag(attack * timeConstantToRT60).dbamp;
};

{
    var snd;
    snd = SinOsc.ar(440) * Env.perc(0.01, 1.0).ar;
    snd = snd * compGain.(snd, threshold: -10, slope: 1 / 4, attack: 0.1, release: 0.3);
    (snd * -6.dbamp) ! 2;
}.play(fadeTime: 0);
)