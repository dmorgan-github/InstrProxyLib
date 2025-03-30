(
//https://scsynth.org/t/a-collection-of-unit-shapers/11018
var func = {

    var obj = Environment.make({|self|
        
        self.know = true;

        ~init = { |self|
		
            self.helperFunctions = IdentityDictionary.new();
            self.unitShapers = IdentityDictionary.new();
            self.easingFunctions = IdentityDictionary.new();
            self.lerpingFunctions = IdentityDictionary.new();
            self.windowFunctions = IdentityDictionary.new();
            
            self.getHelperFunctions;
            self.getUnitShapers;
            self.getEasingFunctions;
            self.getLerpingFunctions;
            self.getWindowFunctions;
            
        };
        
        ~getHelperFunctions = { |self|
            
            // transfer functions
            
            var triangle = { |phase, skew|
                Select.ar(phase > skew, [
                    phase / skew,
                    1 - ((phase - skew) / (1 - skew))
                ]);
            };
            
            var kink = { |phase, skew|
                Select.ar(phase > skew, [
                    0.5 * (phase / skew),
                    0.5 * (1 + ((phase - skew) / (1 - skew)))
                ]);
            };
            
            // linear interpolation of easing functions
            
            var easingToLinear = { |x, shape, easingFunc|
                var mix = shape * 2;
                easingFunc * (1 - mix) + (x * mix);
            };
            
            var linearToEasing = { |x, shape, easingFunc|
                var mix = (shape - 0.5) * 2;
                x * (1 - mix) + (easingFunc * mix);
            };
            
            var lerpEasing = { |x, shape, easingFuncA, easingFuncB|
                Select.ar(shape > 0.5, [
                    easingToLinear.(x, shape, easingFuncA),
                    linearToEasing.(x, shape, easingFuncB)
                ]);
            };
            
            self.helperFunctions.put(\triangle, triangle);
            self.helperFunctions.put(\kink, kink);
            self.helperFunctions.put(\lerpEasing, lerpEasing);
            
        };
        
        ~getUnitShapers = { |self|
            
            var unitHanning = { |phase|
                1 - cos(phase * pi) * 0.5;
            };
            
            var unitCircular = { |phase|
                sqrt(phase * (2 - phase));
            };
            
            var unitRaisedCos = { |phase, index|
                var cosine = cos(phase * pi);
                exp(index.abs * (cosine.neg - 1));
            };
            
            var unitGaussian = { |phase, index|
                var cosine = cos(phase * 0.5pi) * index;
                exp(cosine * cosine.neg);
            };
            
            var unitTrapezoid = { |phase, width, duty = 1|
                var steepness = 1 / (1 - width);
                var offset = phase - (1 - duty);
                var trapezoid = (offset * steepness + (1 - duty)).clip(0, 1);
                var pulse = offset > 0;
                Select.ar(width |==| 1, [trapezoid, pulse]);
            };
            
            var unitTukey = { |phase, width, duty = 1|
                var trapezoid = unitTrapezoid.(phase, width, duty);
                unitHanning.(trapezoid);
            };
    
            self.unitShapers.put(\hanning, unitHanning);
            self.unitShapers.put(\circular, unitCircular);
            self.unitShapers.put(\raisedCos, unitRaisedCos);
            self.unitShapers.put(\gaussian, unitGaussian);
            self.unitShapers.put(\trapezoid, unitTrapezoid);
            self.unitShapers.put(\tukey, unitTukey);
            
        };
        
        ~getEasingFunctions = { |self|
            
            var easingCores = [
                \cubic,
                \quintic,
                \circular,
                \pseudoExponential
            ];
            
            easingCores.do{ |key|
                
                var easeIn = case
                { key == \cubic } {
                    var cubicIn = { |x|
                        x * x * x;
                    };
                    cubicIn;
                }
                { key == \quintic } {
                    var quinticIn = { |x|
                        x * x * x * x * x;
                    };
                    quinticIn;
                }
                { key == \circular } {
                    var circularIn = { |x|
                        1 - sqrt(1 - (x * x));
                    };
                    circularIn;
                }
                { key == \pseudoExponential } {
                    var pseudoExponentialIn = { |x, coef = 13|
                        (2 ** (coef * x) - 1) / (2 ** coef - 1)
                    };
                    pseudoExponentialIn;
                };
                
                var easeOut = { |x|
                    1 - easeIn.(1 - x);
                };
                
                // sigmoid with variable height
                var easeInOut = { |x, height = 0.5|
                    Select.ar(x > 0.5, [
                        height * easeIn.(x * 2),
                        height + ((1 - height) * (1 - easeIn.(2 * (1 - x))))
                    ]);
                };
                
                // seat with variable height
                var easeOutIn = { |x, height = 0.5|
                    Select.ar(x > 0.5, [
                        height - (height * easeIn.(1 - (x * 2))),
                        height + ((1 - height) * easeIn.((x - 0.5) * 2))
                    ]);
                };
                
                self.easingFunctions.put("%In".format(key).asSymbol, easeIn);
                self.easingFunctions.put("%Out".format(key).asSymbol, easeOut);
                self.easingFunctions.put("%Sigmoid".format(key).asSymbol, easeInOut);
                self.easingFunctions.put("%Seat".format(key).asSymbol, easeOutIn);
                
            };
            
        };
        
        ~getLerpingFunctions = { |self|
            
            // linear interpolation of exponential in and out
            
            var exponentialLerp = { |x, shape|
                var easeOut = self.easingFunctions[\pseudoExponentialOut].(x);
                var easeIn = self.easingFunctions[\pseudoExponentialIn].(x);
                self.helperFunctions[\lerpEasing].(x, shape, easeOut, easeIn);
            };
            
            // linear interpolation of exponential sigmoid to exponential seat
            
            var sigmoidToSeatLerp = { |x, shape|
                var easeOut = self.easingFunctions[\pseudoExponentialSigmoid].(x);
                var easeIn = self.easingFunctions[\pseudoExponentialSeat].(x);
                self.helperFunctions[\lerpEasing].(x, shape, easeOut, easeIn);
            };
            
            // linear interpolation of cubic seat and cubic seat reversed
            
            var cubicSeatLerp = { |x, shape, height = 0.5|
                var easeOut = 1 - self.easingFunctions[\cubicSeat].(1 - x, height);
                var easeIn = self.easingFunctions[\cubicSeat].(x, height);
                self.helperFunctions[\lerpEasing].(x, shape, easeOut, easeIn);
            };
            
            // linear interpolation of quintic seat and quintic seat reversed
            
            var quinticSeatLerp = { |x, shape, height = 0.5|
                var easeOut = 1 - self.easingFunctions[\quinticSeat].(1 - x, height);
                var easeIn = self.easingFunctions[\quinticSeat].(x, height);
                self.helperFunctions[\lerpEasing].(x, shape, easeOut, easeIn);
            };
            
            // linear interpolation of circular seat and circular seat reversed
            
            var circularSeatLerp = { |x, shape, height = 0.5|
                var easeOut = 1 - self.easingFunctions[\circularSeat].(1 - x, height);
                var easeIn = self.easingFunctions[\circularSeat].(x, height);
                self.helperFunctions[\lerpEasing].(x, shape, easeOut, easeIn);
            };
            
            self.lerpingFunctions.put(\exponential, exponentialLerp);
            self.lerpingFunctions.put(\sigmoidToSeat, sigmoidToSeatLerp);
            
            self.lerpingFunctions.put(\cubicSeat, cubicSeatLerp);
            self.lerpingFunctions.put(\quinticSeat, quinticSeatLerp);
            self.lerpingFunctions.put(\circularSeat, circularSeatLerp);
            
        };
        
        ~getWindowFunctions = { |self|
            
            var hanningWindow = { |phase, skew|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                self.unitShapers[\hanning].(warpedPhase);
            };
            
            var circularWindow = { |phase, skew|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                self.unitShapers[\circular].(warpedPhase);
            };
            
            var raisedCosWindow = { |phase, skew, index|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                var raisedCos = self.unitShapers[\raisedCos].(warpedPhase, index);
                var hanning = self.unitShapers[\hanning].(warpedPhase);
                raisedCos * hanning;
            };
            
            var gaussianWindow = { |phase, skew, index|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                var gaussian = self.unitShapers[\gaussian].(warpedPhase, index);
                var hanning = self.unitShapers[\hanning].(warpedPhase);
                gaussian * hanning;
            };
            
            var trapezoidalWindow = { |phase, skew, width, duty = 1|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                self.unitShapers[\trapezoid].(warpedPhase, width, duty);
            };
            
            var tukeyWindow = { |phase, skew, width, duty = 1|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                self.unitShapers[\tukey].(warpedPhase, width, duty);
            };
            
            var exponentialWindow = { |phase, skew, shape|
                var warpedPhase = self.helperFunctions[\triangle].(phase, skew);
                self.lerpingFunctions[\exponential].(warpedPhase, shape);
            };
            
            self.windowFunctions.put(\hanning, hanningWindow);
            self.windowFunctions.put(\circular, circularWindow);
            self.windowFunctions.put(\raisedCos, raisedCosWindow);
            self.windowFunctions.put(\gaussian, gaussianWindow);
            self.windowFunctions.put(\tukey, tukeyWindow);
            self.windowFunctions.put(\trapezoid, trapezoidalWindow);
            self.windowFunctions.put(\exponential, exponentialWindow);
            
        };

    });

    obj.init;
    obj

};
(func: func)
)

/*
~unitShapers = Prot(\unitShaping);

/////////////////////////////////////////////////////////////////////////////////////////////

// window functions:

// warped triangle

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.helperFunctions[\triangle].(phase, \skew.kr(0.5));
}.plot(0.02);
)

// warped hanning window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\hanning].(phase, \skew.kr(0.5));
}.plot(0.02);
)

// warped circular window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\circular].(phase, \skew.kr(0.5));
}.plot(0.02);
)

// warped raised cosine window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\raisedCos].(phase, \skew.kr(0.5), \index.kr(5));
}.plot(0.02);
)

// warped gaussian window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\gaussian].(phase, \skew.kr(0.5), \index.kr(5));
}.plot(0.02);
)

// warped tukey window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\tukey].(phase, \skew.kr(0.5), \width.kr(0.5));
}.plot(0.02);
)

// warped trapezoidal window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\trapezoid].(phase, \skew.kr(0.5), \width.kr(0.5), \duty.kr(0.5));
}.plot(0.02);
)

// warped exponential window

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.windowFunctions[\exponential].(phase, \skew.kr(0.5), \shape.kr(0.99));
}.plot(0.02);
)

// multi LFO

(
var getMultiLFO = { |phase, skew, width, duty, mix|
	var trapezoid = ~unitShapers.windowFunctions[\trapezoid].(phase, skew, width, duty);
	var sine = ~unitShapers.unitShapers[\hanning].(trapezoid);
	trapezoid * (1 - mix) + (sine * mix);
};

{
	var phase = Phasor.ar(0, 100 * SampleDur.ir);
	getMultiLFO.(phase, \skew.kr(0.25), \width.kr(0.75), \duty.kr(0.5), \mix.kr(1));
}.plot(0.02);
)

///////////////////////////////////////////////////////////////////////////////

// easing transfer functions:

// exponential to linear morph

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.morphingFunctions[\expToLin].(phase, \shape.kr(1));
}.plot(0.02);
)

// sigmoid to linear morph

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.morphingFunctions[\sigmoidToLin].(phase, \shape.kr(1));
}.plot(0.02);
)

// sigmoid to exponential morph

(
{
	var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.morphingFunctions[\sigmoidToExp].(phase, \shape.kr(1), \mix.kr(0.5));
}.plot(0.02);
)

// warped cubic seat

(
{
    var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.easingFunctions[\cubicSeatWarped].(phase, \skew.kr(0.25), \height.kr(0.75));
}.plot(0.02);
)

// warped quintic seat

(
{
    var phase = Phasor.ar(0, 50 * SampleDur.ir);
	~unitShapers.easingFunctions[\quinticSeatWarped].(phase, \skew.kr(0.25), \height.kr(0.75));
}.plot(0.02);
)

// cubic seat to linear morph

(
{
	var phase = Phasor.ar(DC.ar(0), 50 * SampleDur.ir);

	var sigA = ~unitShapers.morphingFunctions[\cubicSeatToLin].(phase, \shapeA.kr(0), \height.kr(0.875));
	var sigB = ~unitShapers.morphingFunctions[\cubicSeatToLin].(phase, \shapeB.kr(0.5), \height.kr(0.875));
	var sigC = ~unitShapers.morphingFunctions[\cubicSeatToLin].(phase, \shapeC.kr(1), \height.kr(0.875));

	[sigA, sigB, sigC];
}.plot(0.02).superpose_(true).plotColor_([Color.red, Color.blue, Color.magenta]);
)

// elliptic seat to linear morph

(
{
	var phase = Phasor.ar(DC.ar(0), 50 * SampleDur.ir);

	var sigA = ~unitShapers.morphingFunctions[\ellipticSeatToLin].(phase, \shapeA.kr(0), \height.kr(0.875));
	var sigB = ~unitShapers.morphingFunctions[\ellipticSeatToLin].(phase, \shapeB.kr(0.5), \height.kr(0.875));
	var sigC = ~unitShapers.morphingFunctions[\ellipticSeatToLin].(phase, \shapeC.kr(1), \height.kr(0.875));

	[sigA, sigB, sigC];
}.plot(0.02).superpose_(true).plotColor_([Color.red, Color.blue, Color.magenta]);
)

*/