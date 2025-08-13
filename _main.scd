(
s.freeAll;
s = Server.default;
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 2;
s.options.sampleRate = 44100;
s.options.blockSize = 512;
s.options.recSampleFormat = "int16";
s.options.recHeaderFormat = "wav";
Server.killAll;


/*

============================================================
code organization
============================================================

this is a large file. highlight the name of the section you want to navigate to,
then use Cmd + F (or Ctrl + F) and Enter to jump there.

------------------------------------------------------------
safeguards & init
------------------------------------------------------------

create buses
functions and environment variables
├ voice functions and environment variables
├ oscillator functions and environment variables
└ sequencer functions and environment variables
prepare recording
loadBuffers

------------------------------------------------------------
create nodes
------------------------------------------------------------

├ safeguards
├ create Groups
├ define patchNode
├ create virtual patch matrix
├ create Synths
├ create voice
├ create midi handlers
├ create clock
├ create sequencer
└ create recording

------------------------------------------------------------
boot instructions
------------------------------------------------------------

├ initialize midi
├ initialize buses
├ create SynthDefs
├ create ServerTree
└ run ServerTree

*/






//////////////////////////////////////////////////////////////////////
// safeguards & init
//////////////////////////////////////////////////////////////////////

s.options.numInputBusChannels = 0;
CmdPeriod.add({
	if (~synthGen.notNil) {
		~synthGen.stop;
		~synthGen = nil;
	};
	if (~drumsGen.notNil) {
		~drumsGen.stop;
		~drumsGen = nil;
	};
	if (~tempoUpdater.notNil) {
		~tempoUpdater.stop;
		~tempoUpdater = nil;
	};

});

ServerTree.removeAll;





//////////////////////////////////////////////////////////////////////
// create buses
//////////////////////////////////////////////////////////////////////
//
//  all buses are named after their original MS-20 controls, not the
//  ACCELERATOR controls.  this was once helpful for me. maybe it will
//  be helpful for you too if you end up redefining some of them.
//


s.newBusAllocators;

// vco1
~osc1Shape = Bus.control(s, 1);
~osc1PW = Bus.control(s, 1);
~osc1Scale = Bus.control(s, 1);
~osc1ModIn = Bus.audio(s, 1);
~portamento = Bus.control(s, 1);
~osc1Out = Bus.audio(s, 1);

// vco2
~osc2Shape = Bus.control(s, 1);
~osc2Pitch = Bus.control(s, 1);
~osc2Scale = Bus.control(s, 1);
~osc2ModIn = Bus.audio(s, 1);
~osc2CVIn = Bus.audio(s, 1);
~osc2Out = Bus.audio(s, 1);

// vco master
~fmIn = Bus.audio(s, 1);
~masterTune = Bus.control(s, 1);
~freqModMG = Bus.control(s, 1);
~freqModEG1 = Bus.control(s, 1);

// mixer
~osc1In = Bus.audio(s, 1);
~osc1Level = Bus.control(s, 1);
~osc2Level = Bus.control(s, 1);
~osc2In = Bus.audio(s, 1);
~mixerOut = Bus.audio(s, 1);

// hpf
~hpfCutoff = Bus.control(s, 1);
~hpfResonance = Bus.control(s, 1);
~hpfCutoffIn = Bus.audio(s, 1);
~hpfModMG = Bus.control(s,1);
~hpfModEG2 = Bus.control(s, 1);
~hpfIn = Bus.audio(s, 1);
~hpfOut = Bus.audio(s, 1);

// lpf
~lpfCutoff = Bus.control(s, 1);
~lpfResonance = Bus.control(s, 1);
~lpfCutoffIn = Bus.audio(s, 1);
~lpfModMG = Bus.control(s, 1);
~lpfModEG2 = Bus.control(s, 1);
~lpfOut = Bus.audio(s,1);

// mg
~mgShape = Bus.control(s, 1);
~mgFrequency = Bus.control(s, 1);
~mgRampOut = Bus.audio(s, 1);
~mgPulseOut = Bus.audio(s, 1);

// eg1
~eg1TrigIn = Bus.audio(s, 1);
~eg1Delay = Bus.control(s, 1);
~eg1Attack = Bus.control(s, 1);
~eg1Release = Bus.control(s, 1);
~eg1Out = Bus.audio(s, 1);
~eg1RevOut = Bus.audio(s, 1);

// eg2
~egAllTimeIn = Bus.audio(s, 1);
~eg2Hold = Bus.control(s, 1);
~eg2Attack = Bus.control(s, 1);
~eg2Decay = Bus.control(s, 1);
~eg2Sustain = Bus.control(s, 1);
~eg2Release = Bus.control(s, 1);
~eg2Out = Bus.audio(s, 1);
~eg2RevOut = Bus.audio(s, 1);

// s&h (sample and hold)
~shIn = Bus.audio(s, 1);
~shClockIn = Bus.audio(s, 1);
~shOut = Bus.audio(s, 1);

// VCAs
~ampKr = Bus.control(s, 1);
~amIn = Bus.audio(s, 1);
~vcaIn = Bus.audio(s, 1);
~vcaCtrlIn = Bus.audio(s, 1);
~vcaOut = Bus.audio(s, 1);
~dcOut = Bus.audio(s, 1);
~dcNegOut = Bus.audio(s, 1);

// sequencer
~espSignalLevel = Bus.control(s, 1);
~espLowCut = Bus.control(s, 1);
~espHighCut = Bus.control(s, 1);
~espCVAdjust = Bus.control(s, 1);
~espThreshold = Bus.control(s, 1);
~seqRateIn = Bus.audio(s, 1);
~seqRateOut = Bus.control(s, 1);
~clockDivideIn = Bus.control(s, 1);

~seqCVIn = Bus.control(s, 1);
~seqCVInvIn = Bus.control(s, 1);
~seqGateIn = Bus.control(s, 1);
~seqGateDiv4In = Bus.control(s, 1);

~seqCVOut = Bus.audio(s, 1);
~seqCVInvOut = Bus.audio(s, 1);
~seqGateOut = Bus.audio(s, 1);
~seqGateDiv4Out = Bus.audio(s, 1);

// others
~driftLFOOut = Bus.audio(s, 1);
~totalModIn = Bus.audio(s, 1);
~modWheelIn = Bus.control(s, 1);
~modWheelOut = Bus.audio(s, 1);
~buttonOut = Bus.audio(s, 1);
~buttonIn = Bus.control(s, 1);
~outputVolume = Bus.control(s, 1);
~driftLFOAmt = Bus.control(s, 1);
~grindOscOut = Bus.audio(s, 1);
~clockTempoOut = Bus.control(s, 1);
~masterVolume = Bus.audio(s, 2);

~delayAmt = Bus.control(s, 1);
~drumOut = Bus.audio(s, 1);
~extIn = Bus.audio(s, 1);
~noiseOut = Bus.audio(s, 1);
~normalVCAOut = Bus.audio(s, 1);
~compressorSidechainIn = Bus.audio(s, 1);
~compressorOut = Bus.audio(s, 2);
~rumbleIn = Bus.audio(s, 2);
~rumbleOut = Bus.audio(s, 2);
~delayOut = Bus.audio(s, 2);
~postFX = Bus.audio(s, 2);

~drumCVIn = Bus.audio(s, 1);
~drumCVOut = Bus.audio(s, 1);
~kickOut = Bus.audio(s, 1);
~extLPFCutoff = Bus.control(s, 1);
~extHPFCutoff = Bus.control(s, 1);

~freqIn = Bus.control(s, 1);
~freqOut = Bus.audio(s, 1);

~gateKr = Bus.control(s, 1);
~gateOut = Bus.audio(s, 1);

~drumClockDiv = Bus.control(s, 1);
~delayClockDiv = Bus.control(s, 1);
~tapeDivOut = Bus.control(s, 1);
~delayFeedback = Bus.control(s, 1);

~wavefolderIn = Bus.audio(s, 1);
~wavefolderOut = Bus.audio(s, 1);
~drumFXIn = Bus.audio(s, 1);
~drumFXOut = Bus.audio(s, 1);
~fxTimeIn = Bus.audio(s, 1);
~normalLevel = Bus.control(s, 1);




//////////////////////////////////////////////////////////////////////
// functions and environment variables
//////////////////////////////////////////////////////////////////////

~liveNotes = [];
~sequencerRunning = false;
// trigger release stage of note
~noteOff = {|note|
	~gateKr.set(0);
};

//center frequency is 130 (C3).  maps up and down 2.5 octaves, so
// cv of -1 gives freq of 23.12,
// cv of +1 gives freq of 739.99
// this is slow if you use it directly.  use the wavetable / LUT instead.
~cvToFreq = {|cv|
	130.8127826503 * (2 ** (cv * 2.5));
};

// inverse map of ~cvToFreq.  frequencies outside of [23.12, 739.99] will be
//mapped to values outside of [-1, 1].
~freqToCV = {|freq|
	log2(freq / 130.8127826503) / 2.5;
};

~cvToFreqTableSize = 4096;
~cvToFreqWavetable = Signal.fill((~cvToFreqTableSize / 2) + 1, {|i|
	var x = i.linlin(0, ~cvToFreqTableSize / 2, -1.0, 1.0);
	var y = 130.8127826503 * (2 ** (x * 2.5));
	y;
});

// this is for audio-rate conversions
~cvToFreqLUT = {|cv|
	Shaper.ar(~cvToFreqBuf, cv);
};



// this imitates analog asymmetric clipping
// waveshaper LUT
//////////////////////////////////////////////////////////////////////

~minHeatInput = -1.0;
~maxHeatInput = 1.0;
~heatLUTSize = 1024;
~heatScale = 8;
~heatWavetable = Signal.fill((~heatLUTSize / 2) + 1, {|i|
	var x = i.linlin(0.0,
		~heatLUTSize / 2,
		~minHeatInput * ~heatScale,
		~maxHeatInput * ~heatScale);
	var y;
	y = (x - 0.6).tanh + 0.535;
	y;
} );

/*

this function is the proper way to add analog modeling distortion.
but if you actually use it, your SynthDefs will be slow.
so instead, just copy/paste the *inside* of it wherever you need it, and
make the amount whatever you want (usually 1 is good).
*/
~heat = {|sig, amount = 1|
	sig = Shaper.ar(~heatBuf, (amount * sig) / ~heatScale);
	sig = (sig / amount);
};


// wavefolder LUT
//////////////////////////////////////////////////////////////////////

~wavefolderScale = 8;
~minWavefolderInput = -8.0;
~maxWavefolderInput = 8.0;
~wavefolderLUTSize = 16384;

//wavefolder based on DAFx-17
~wavefolderFunc = { |x, smoothness = 0.1|
	var s = x.sign;
	var fastSmoothActivation = { |input, threshold|
		var absx = input.abs;
		var delta = absx - threshold;
		((delta > 0).asInteger * (delta < smoothness).asInteger* (delta / smoothness))
		+ ((delta >= smoothness).asInteger);
	};
	var fold1 = fastSmoothActivation.(x, 0.6) * (0.8333 * x - (0.5000 * s));
	var fold2 = fastSmoothActivation.(x, 2.9940) * (0.3768 * x - (1.1281 * s));
	var fold3 = fastSmoothActivation.(x, 5.4600) * (0.2829 * x - (1.5446 * s));
	var fold4 = fastSmoothActivation.(x, 1.8000) * (0.5743 * x - (1.0338 * s));
	var fold5 = fastSmoothActivation.(x, 4.0800) * (0.2673 * x - (1.0907 * s));
	var direct = x;
	var output = (
		((-12.000) * fold1) + ((-27.777) * fold2) + ((-21.428) * fold3) +
		(17.647 * fold4) + (36.363 * fold5) + (5.000 * direct)
	) / 40;
	output;
};

~wavefolderTable = Signal.fill((~wavefolderLUTSize / 2) + 1, {
	|i|
	var x = i.linlin(0.0,
		~wavefolderLUTSize / 2,
		~minWavefolderInput,
		~maxWavefolderInput);
	var y = ~wavefolderFunc.(x);
	y;
});

~bumpWavetableSize = 2048;

~bumpWavetable = Signal.fill((~bumpWavetableSize / 2) + 1, {
	|i|
	var phase = (i / ((~bumpWavetableSize /2))) * 2pi - pi;
	var sine = sin(phase);
	var y = sine.lincurve(-1, 1, -1, 1, -15);
	y;
});

// voice functions and environment variables
//////////////////////////////////////////////////////////////////////
~voiceNew = { |note, freq, amp|
	var voice = (
		note: note,
		freq: freq,
		amp: amp
	);

	// Method to retrigger
	voice.retrigger = { |freq, amp|
		voice.freq = freq;
		// Update all synth params
		if(~osc1.notNil){
			~osc1.set(\freq, freq);
		};
		if (~osc2.notNil){
			~osc2.set(\freq, freq);
		};
	};

	voice;
};



// oscillator functions and environment Variables
//////////////////////////////////////////////////////////////////////
//do not use.  use ~setOsc1 instead.
~selectOsc1Wave = { |shape|
	var freq = ~voice.freq;
	switch(~osc1Group,
		3, {
			switch(shape,
				3, {Synth(\granularSampler, [
					freq: freq,
					buf: ~buffers.violence,
					stretch: 2,
					amp: 0.125,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				2, {Synth(\granularSampler, [
					buf: ~buffers.enoise,
					freq: freq,
					stretch: 1,
					amp: 0.125,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				1, {Synth(\granularSampler, [
					freq: freq,
					buf: ~buffers.allGranular,
					stretch: 1,
					amp: 0.25,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				{Synth(\water, [
					buf: ~buffers.water,
					freq: freq,
					amp: 2,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
			)
		},

		2, {
			switch(shape,
				3, {Synth(\reese, [
					freq: freq,
					buf: ~buffers.reese,
					startPos: 20000,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				2, {Synth(\osc1Strings, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				1, {Synth(\saw, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				{Synth(\nesTriangle, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)}
			)
		},
		1, {
			switch(shape,
				3, {Synth(\melodicSampler, [
					freq: freq,
					buf: ~buffers.hydrachord,
					amp: 1,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},

				2, {Synth(\melodicSampler, [
					freq: freq,
					buf: ~buffers.chord,
					amp: 1,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				1, {Synth(\melodicGranularSampler, [
					buf: ~buffers.flute,
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				{Synth(\resonator, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)}
			)
		},
		{

			switch(shape,
				3, {Synth(\bump, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},

				2, {Synth(\sineRando, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				1, {Synth(\decoupledSine, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)},
				{Synth(\sine, [
					freq: freq,
					freqModKnob1: ~freqModMG.asMap,
					freqModKnob2: ~freqModEG1.asMap,
					pitch: ~osc1PW.asMap,
					driftModKnob: ~portamento.asMap
				], ~modGrp)}
			)
		}
	);
};

// do not use. Use ~setOsc2 instead.
~selectOsc2 = { |shape, freq|
	switch(shape,
		3, {Synth(\osc2SqrAM, [
			pitch: ~osc2Pitch.asMap,
			freqModKnob1: ~freqModMG.asMap,
			freqModKnob2: ~freqModEG1.asMap,
			osc1ModKnob: ~masterTune.asMap
		], ~modGrp)},
		2, {Synth(\osc2ExpFM, [
			pitch: ~osc2Pitch.asMap,
			freqModKnob1: ~freqModMG.asMap,
			freqModKnob2: ~freqModEG1.asMap,
			osc1ModKnob: ~masterTune.asMap
		], ~modGrp)},
		1, {Synth(\osc2LinFM, [
			pitch: ~osc2Pitch.asMap,
			freqModKnob1: ~freqModMG.asMap,
			freqModKnob2: ~freqModEG1.asMap,
			osc1ModKnob: ~masterTune.asMap
		], ~modGrp)},
		{Synth(\osc2SinAM, [
			pitch: ~osc2Pitch.asMap,
			freqModKnob1: ~freqModMG.asMap,
			freqModKnob2: ~freqModEG1.asMap,
			osc1ModKnob: ~masterTune.asMap
		], ~modGrp)},

	);
};



~setOsc1Group = { |oscillatorGroup|
	~osc1Group = oscillatorGroup;
	~setOsc1Wave.(~osc1Wave);
};

~setOsc1Wave = { |shape|
	if(~osc1.notNil){
		~osc1.free;
	};
	~osc1Wave = shape;
	~osc1 = ~selectOsc1Wave.(shape);
};


~setOsc2 = { |shape|
	if(~osc2.notNil){
		~osc2.free;
	};
	~osc2 = ~selectOsc2.(shape, ~voice.freq);
};

~initOscillators = {
	~setOsc1Group.(~osc1Shape.getSynchronous.asInteger);
	~osc2 = ~setOsc2Shape.(~osc2Shape.getSynchronous.asInteger);
};


~noteOn = {|note, cv, amp|
	var freq = ~cvToFreq.(cv);
	~freqIn.set(cv);
	~gateKr.set(1);
	~ampKr.set(amp);
	~voice[\retrigger].(freq, amp);
};

~drumOn = {|step|
	var knob = ~espThreshold.getSynchronous.asInteger;

	case
	{ knob == 0 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1]) }
		};
	}
	{ knob == 1 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1])
			};
			~tomDrum.set(\gate, step[2], \amp, step[2]);
		};
	}
	{ knob == 2 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1])
			};
			~tomDrum.set(\gate, step[2], \amp, step[2]);
			~snareDrum.set(\gate, step[1], \amp, step[1], \fx, 1);
		};
	}
	{ knob == 3 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1])
			};
			~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
		};
	}

	{ knob == 4 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1])
			};
			~tomDrum.set(\gate, step[2], \amp, step[2]);
			case
			{ step[0] >= 0.8 }{
				~openHatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			}
			{ step[0] < 0.8 }{
				~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			};
		};
	}
	{ knob == 5 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1])
			};
			~snareDrum.set(\gate, step[1], \amp, step[1], \fx, 1);
			case
			{ step[0] >= 0.8 }{
				~openHatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			}
			{ step[0] < 0.8 }{
				~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			};
		};
	}
	{ knob == 6 } {
		s.bind {
			if (step[3][0] > 0){
				~kickDrum.set(\gate, step[3][0], \amp, step[3][0], \duration, step[3][1])
			};
			~tomDrum.set(\gate, step[2], \amp, step[2]);
			~snareDrum.set(\gate, step[1], \amp, step[1], \fx, 1);
			case
			{ step[0] >= 0.8 }{
				~openHatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			}
			{ step[0] < 0.8 }{
				~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			};
		};
	}
	{ knob == 7 } {
		s.bind { ~tomDrum.set(\gate, step[2], \amp, step[2]);
			case
			{ step[0] >= 0.8 }{
				~openHatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			}
			{ step[0] < 0.8 }{
				~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			};
		};
	}
	{ knob == 8 } {
		s.bind { ~snareDrum.set(\gate, step[1], \amp, step[1], \fx, 1);
			case
			{ step[0] >= 0.8 }{
				~openHatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			}
			{ step[0] < 0.8 }{
				~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			};
		};
	}
	{ true } {
		s.bind {
			case
			{ step[0] >= 0.8 }{
				~openHatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			}
			{ step[0] < 0.8 }{
				~hatDrum.set(\gate, step[0], \amp, step[0], \duration, step[0]);
			};
		};
	}
};
~drumOff = {
	s.bind {~kickDrum.set(\gate, 0);
		~hatDrum.set(\gate, 0);
		~openHatDrum.set(\gate, 0);
	};
};


// sequencer functions and environment variables
//////////////////////////////////////////////////////////////////////

~initSequencerPatterns = {
	var tempo = ~eg2Hold.getSynchronous;
	[0, 1, 2].do({|i| ~updateVelocityMatrix.(i)});
	~updateSnare.(tempo);
	~updateToms.(tempo);
	~updateKick.(tempo);
	~updateHats.(tempo) ;

	~genPitchRoutine = ~genPitchFn.asStream;
	~genRhythmRoutine = ~genRhythmFn.asStream;
	~drumsRoutine = ~genDrumsFn.asStream;
};

~createSequencer = {
	s.bind({
		~tempoUpdater = ~tempoUpdater.play;
		if(~synthGen.isNil) {~synthGen = Routine(~synthFn).play(clock: ~clock, quant: [1, 0 , 0.02])};
		if(~drumsGen.isNil) {~drumsGen = Routine(~drumsFn).play(clock: ~clock, quant: 4)};
	});
};

~tempoUpdater = Routine({
	loop {
		var knobVal = ~eg2Hold.getSynchronous;
		var rateCV = ~seqRateOut.getSynchronous;
		var rateMult;
		var newTempo;

		case
		{ rateCV < (-9) } {
			~sequencerRunning = false;
			rateMult = 1;
		}
		{ rateCV < (-0.9) } {
			rateMult = 0.25;
			~sequencerRunning = true;
		}
		{ rateCV < (-0.625) } {
			rateMult = 0.3333;
			~sequencerRunning = true;
		}
		{ rateCV < (-0.375) } {
			rateMult = 0.5;
			~sequencerRunning = true;
		}
		{ rateCV < (-0.125) } {
			rateMult = 0.75;
			~sequencerRunning = true;
		}
		{ rateCV < 0.125 } {
			rateMult = 1;
			~sequencerRunning = true;
		}
		{ rateCV < 0.375 } {
			rateMult = 1.5;
			~sequencerRunning = true;
		}
		{ rateCV < 0.625 } {
			rateMult = 2;
			~sequencerRunning = true;
		}
		{ rateCV < 0.9 } {
			rateMult = 3;
			~sequencerRunning = true;
		}
		{ true } {
			rateMult = 4;
			~sequencerRunning = true;
		};

		~clock.tempo = rateMult * knobVal / 60;


		s.bind{ ~clockTempoOut.set(~clock.beatDur)};
		0.2.wait;
	};
});

//pitchMatrix is of the following form:
/*
[[ p0a, p0b, p0c],
[ p1a, p1b, p1c],
[ p2a, p2b, p2c],
...
[ p7a, p7b, p7c]]

this makes it so we step through the sequence normally with Pseq and then down the line choose which song section we want to use.

*/
~halfStep = 0.03333;
~octaveStep = 0.4;

~pitchMatrix = Array.fill(8, {Array.fill(3, {rrand(((-1) * ~halfStep / 2), (~halfStep / 2))})});
~genPitchFn = Pseq(~pitchMatrix, inf);

~velocityMatrix = Array.fill(16, {Array.fill(3, {[1,1]})});

//0 means rest. 1 means play the note
~genRhythmFn = Pseq(~velocityMatrix, inf);

~generateSpecialRhythm = {
	// these are for rhythm-centric ideas
	var variations = [
		[ 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1 ],
		[ 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
		[ 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1 ],
		[ 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1 ],
		[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1 ],
		[ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1 ],
		[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
		[ 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1 ],
		[ 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1 ],
		[ 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1 ],
		[ 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0 ],
		[ 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1 ],
		[ 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
		[ 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
		[ 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1 ],
		[ 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0 ],
		[ 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1 ],
		[ 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1 ],
		[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1 ],
		[ 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
		[ 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1 ],
		[ 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1 ],
		[ 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0 ],
		[ 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1 ],
		[ 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1 ],
		[ 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0 ]
	];
	var rando = rrand(0, (variations.size - 1));
	variations[rando];
};

~generateDenseRhythm = {
	(0..15).collect({ |item, index|
		//de-emphasize downbeats
		case
		//downbeat
		{(index % 4) == 0 } {
			0.90.coin.if { 1 } { 0 }
		}
		// e
		{(index % 4) == 1}
		{
			0.99.coin.if { 1 } { 0 }
		}
		// &
		{(index % 4) == 2}
		{
			1
		}
		// a
		{(index % 4) == 3}
		{
			0.99.coin.if { 1 } { 0 }
		}
	});
};

~updateVelocityMatrix = {|songSection|
	var newRhythmicRhythm, newMelodicRhythm;
	//this generates two rhythms at a time
	// [melodic rhythm, rhythmicRhythm]
	var newMatrix = Array.fill(16, [1,1]);

	newRhythmicRhythm = ~generateSpecialRhythm.value;
	newMelodicRhythm = ~generateDenseRhythm.value;
	newMatrix.do({|step, i|
		newMatrix[i] = [newMelodicRhythm[i], newRhythmicRhythm[i]];
	});
	~velocityMatrix.do({|step, i|
		step[songSection] = [newMelodicRhythm[i], newRhythmicRhythm[i]]});
	~velocityMatrix;
};


~gateMod4 = 0;
~rhythmCentric = false;
~contracting = false;
~rangeCenter = 0;
~outerThreshold = 0.9;
~innerThreshold = 0.01;

// used by pitch and drum sequencers to evolve
~probablilityMap = { |x|
	var b = 16.118;
	var a = 1 / (exp(b) - 1);
	a * (exp(b * x) - 1)
};


// main sequencer function
~synthFn = {
	var stepIndex = 0;
	var triggerDenseRhythm = false;
	var sequenceNote = {|cv, playNote, stepIndex, songSection|
		//process cv for sequencer knobs
		var rangeThreshold = ~espLowCut.getSynchronous;
		var nearestSemitone = (cv / ~halfStep).round * ~halfStep;
		var deviation = cv - nearestSemitone;
		var octave = ((nearestSemitone / (~halfStep * 12)).round) * (~halfStep * 12);
		case { rangeThreshold >= 0.5 }{
			//rescale
			rangeThreshold = 2 * rangeThreshold - 1;
			cv = cv.wrap((-1 * rangeThreshold), rangeThreshold);
		}
		{rangeThreshold == 0} {
			cv = 0;
		}
		{rangeThreshold < 0.5} {
			cv = octave + deviation;
		};

		//trigger note
		case
		{ ~liveNotes != [] } {
			// get keyboard input if there is any
			cv = ~freqToCV.((~liveNotes[0]).midicps / 4) + rrand(~halfStep / (-4), ~halfStep / 4);
			// cheap order mode arpeggiator
			~liveNotes.removeAt(0);
		};

		s.bind {
			~pitchMatrix[stepIndex][songSection] = cv;
			~seqCVIn.set(cv);
			~seqCVInvIn.set((-1) * cv);
			~seqGateIn.set(1);
			if(~gateMod4 == 0){
				~seqGateDiv4In.set(1);
			};
			if(playNote == 1){
				~noteOn.(note: 1, cv: cv, amp: exprand(0.5, 1));
			};
		};
		0.2.wait;

		s.bind {
			~seqGateIn.set(0);
			if(~gateMod4 == 0){
				~seqGateDiv4In.set(0);
			};
			~noteOff.(note: 1);
		};
		0.05.wait;

		~gateMod4 = (~gateMod4 + 1) % 4;
	};

	var sequenceNonMajorNote = {|cv, playNote, stepIndex, songSection|
		//detect the major third
		case
		{ cv > 0.1166 and: { cv < 0.1499 }} {
			cv = cv - ~halfStep;
		}
		{ cv > 0.5166 and: { cv < 0.5499 }} {
			cv = cv - ~halfStep;
		}
		{ cv > 0.9166 and: { cv < 0.9499 }} {
			cv = cv - ~halfStep;
		}
		{ cv > -0.2833 and: { cv < -0.2499 }} {
			cv = cv - ~halfStep;
		}
		{ cv > -0.6833 and: { cv < -0.6499 }} {
			cv = cv - ~halfStep;
		};
		sequenceNote.(cv, playNote, stepIndex, songSection);
	};

	var scaleOdds = {|p, scale|
		(p * scale)/(1 - p + (p * scale));
	};

	loop {
		if (~sequencerRunning) {
			var calculatedFreq;
			var genFreqBus;
			var genFreq, genVelocity;
			var numSteps = ~espSignalLevel.getSynchronous.asInteger;
			var evolveFactor = ~probablilityMap.(~espHighCut.getSynchronous);
			var randEvolve = rrand(0, 10000);
			var randStep = (rrand(0,1) == 1).if {~halfStep} {~halfStep * 2};
			var randJump = ~octaveStep;
			var randomMove, randomDirection;
			var upperOuterBound;
			var lowerOuterBound;
			var upperInnerBound;
			var lowerInnerBound;
			var nextFreq, currentRhythm;
			var songSection = ~espCVAdjust.getSynchronous.asInteger;
			var rhythmicMode = (~espLowCut.getSynchronous < 0.5).if { 1 } { 0 };

			case
			{~contracting} {
				~contracting = (scaleOdds.(evolveFactor, 30).coin).if { ~contracting.not } { ~contracting };
			}
			{~contracting.not && ~rhythmCentric.not}{
				~contracting = (evolveFactor.coin).if { ~contracting.not } { ~contracting };
			}
			{~rhythmCentric} {
				~rhythmCentric = (scaleOdds.(evolveFactor, 80).coin).if { triggerDenseRhythm = true; ~rhythmCentric.not } { ~rhythmCentric }
			};

			~outerThreshold = (~contracting).if { 0.1 } { 0.9 };
			~rangeCenter = (evolveFactor.coin).if { rrand(-0.125, 0.125)} {~rangeCenter};
			upperOuterBound = ~rangeCenter + ~outerThreshold;
			lowerOuterBound = ~rangeCenter - ~outerThreshold;
			upperInnerBound = ~rangeCenter + ~innerThreshold;
			lowerInnerBound = ~rangeCenter - ~innerThreshold;

			/*
			("rhythmCentric: " ++ ~rhythmCentric).postln;
			("contracting: " ++ ~contracting).postln;
			("rangeCenter: " ++ ~rangeCenter).postln;
			("outerThreshold: " ++ ~outerThreshold).postln;
			("innerThreshold: " ++ ~innerThreshold).postln;
			("randEvolve: " ++ randEvolve).postln;
			*/

			if (scaleOdds.(evolveFactor, 29).coin){
				~updateVelocityMatrix.(songSection);
			};


			while {stepIndex > (numSteps - 1)} {
				genFreqBus = ~genPitchRoutine.next;
				stepIndex = (stepIndex + 1) % 8;
			};
			genFreq = ~genPitchRoutine.next[songSection];

			case
			{ rhythmicMode == false } {
				genVelocity = ~genRhythmRoutine.next[songSection][rhythmicMode];
			}
			{ true } {
				genVelocity = ~genRhythmRoutine.next[songSection][rhythmicMode];
			};




			//calculate pitch
			case
			//rhythm centric mode
			{~rhythmCentric or: {rhythmicMode == 1}}{
				case
				//too low, go higher
				{genFreq <= lowerOuterBound} {
					nextFreq = genFreq + randJump;
				}
				//too high, go lower
				{genFreq > upperOuterBound} {
					nextFreq = genFreq - randJump;
				}
				//evolve normally
				{ scaleOdds.(evolveFactor, 50).coin }{
					randomDirection = 0.75.coin.if {-1} {1};
					randJump = randJump * randomDirection;
					nextFreq = genFreq + randJump;
				}
				//stay the same
				{ true }{
					nextFreq = genFreq;
				};
				sequenceNonMajorNote.(nextFreq, genVelocity, stepIndex, songSection);
			}

			//normal zones
			{genFreq > lowerOuterBound and: 	{genFreq < lowerInnerBound} or:
				{genFreq > upperInnerBound and: 	{genFreq < upperOuterBound}}}{
				//evolve occasionally
				if(scaleOdds.(evolveFactor, 50).coin){
					//choose step or octave
					randomDirection = [-1,1].choose;
					//up or down
					randStep = randStep * randomDirection;
					randJump = randJump * randomDirection;
					((randEvolve % 10) > 1).if {randomMove = randStep} {randomMove = randJump};
					nextFreq = genFreq + randomMove;
				} { nextFreq = genFreq };

				//trigger note
				sequenceNonMajorNote.(nextFreq, genVelocity, stepIndex, songSection);
			}

			//too central, expand
			{genFreq > lowerInnerBound and: {genFreq < upperInnerBound}}{
				//evolve often
				if(scaleOdds.(evolveFactor, 500).coin){
					//choose step or octave
					randomDirection = [-1,1].choose;
					//up or down
					randStep = randStep * randomDirection;
					randJump = randJump * randomDirection;
					((randEvolve % 10) > 0).if {randomMove = randStep} {randomMove = randJump};
					nextFreq = genFreq + randomMove;
				}  { nextFreq = genFreq };

				//trigger note
				sequenceNonMajorNote.(nextFreq, genVelocity, stepIndex, songSection);
			}

			//too low, go higher
			{genFreq <= lowerOuterBound} {
				//evolve often
				if(scaleOdds.(evolveFactor, 500).coin){
					((randEvolve % 10) > 0).if {randomMove = randStep} {randomMove = randJump};
					(((randEvolve % 100) / 10) > 0).if {randomDirection = 1} { randomDirection = -1};
					randomMove = randomMove * randomDirection;
					nextFreq = genFreq + randomMove;
					//trigger note
					sequenceNonMajorNote.(nextFreq, genVelocity, stepIndex, songSection);
				}
			}

			//too high, go lower
			{genFreq >= upperOuterBound} {
				//walk downward
				//evolve often
				if(scaleOdds.(evolveFactor, 500).coin){
					((randEvolve % 10) > 0).if {randomMove = randStep} {randomMove = randJump};
					(((randEvolve % 100) / 10) > 0).if {randomDirection = -1} { randomDirection = 1};
					randomMove = randomMove * randomDirection;
					nextFreq = genFreq + randomMove;
					//trigger note
					sequenceNonMajorNote.(nextFreq, genVelocity, stepIndex, songSection);
				}
			};
			stepIndex = (stepIndex + 1) % 8;
		} {
			//wait if sequencer isn't running
			0.25.wait;
		};
	}
};

// drum sequencer


~updateSnare = {|tempo|
	var seqLength = ~drumMatrix.size;
	var rando = (tempo < 120).if { rrand(18, ~buffers.snares.size) } { rrand(0,17) };
	0.1.coin.if { ~snareDrum.set(\buf, ~buffers.snares[rando])};
	(tempo < 120).if { ~snareDrum.set(\buf, ~buffers.snares[rando]) };
	~drumMatrix.do({|step, index|
		case
		{ tempo < 120 } {
			case
			{ (index % 8) == 3 }{
				step[1] = 0.2.coin.if { 1 } { 0 };
			}
			{ (index % 8) == 4 }{
				step[1] = 1;
			}
			{ (index % 2) == 0 }{
				step[1] = 0.2.coin.if {rrand(0.25, 0.5)} { 0 }
			}
			{ true }{
				step[1] = 0
			};
		}
		{ tempo < 160 } {
			case
			{ (index % 8) == 4 }
			{
				step[1] = 0.3.coin.if {rrand(0.5, 1)} { 0 }
			}
			{ (index % 2) == 0 }
			{ step[1] = 0.2.coin.if {rrand(0.25, 0.5)} { 0 }}
			{ true }
			{step[1] = 0};
		}
		{ true } {
			case
			{ (index % 8) == 4 }
			{
				step[1] = 1;
			}
			{ (index % 2) == 0 }
			{ step[1] = 0.2.coin.if {rrand(0.25, 0.5)} { 0 }}
			{ true }
			{step[1] = 0};
		}

	});
	// add dotted accents
	~drumMatrix.do({|step, index|
		case
		{step[1] != 0}
		{~drumMatrix[(index + 3) % seqLength][1] = 0.35.coin.if {rrand(0.5, 1)} { 0 }};
	});

};

~updateToms = {|tempo|
	var seqLength = ~drumMatrix.size;
	var rando = rrand(0,~buffers.toms.size);
	(tempo < 120).if { ~tomDrum.set(\buf, ~buffers.toms[rando]) } { ~tomDrum.set(\buf, ~buffers.toms[0]) };
	~drumMatrix.do({|step, index|
		case
		{ (index % 4) == 0 }{
			step[2] = 0;
		}
		{ (index % 2) == 0 }{
			step[2] = 0.1.coin.if {rrand(0.25, 0.5)} { 0 };
		}
		{ true }{
			step[2] = 0.1.coin.if {rrand(0.5, 1)} { 0 };
		};
	});
};

~updateKick = { |tempo|
	var seqLength = ~drumMatrix.size;
	var pattern = rrand(0,1);
	//todo:  make setting the kick click-free
	var randoDowntempo = rrand(6,~buffers.kicks.size);
	var randoUptempo = rrand(0, 5);
	case
	{ tempo < 120 }{
		0.1.coin.if {~kickDrum.set(\buf, ~buffers.kicks[randoDowntempo])};
	}
	{ tempo >= 120}{
		0.1.coin.if {~kickDrum.set(\buf, ~buffers.kicks[0])  };
	};
	~drumMatrix.do({|step, index|
		case
		{ tempo < 120 } {
			var preset = 0.75.coin;
			case
			{ preset == false }{
				case
				{ (index % 8) == 0 }{
					step[3][0] = 0.8.coin.if { rrand(0.5, 1.0) } { 0 };
				}
				{ (index % 8) == 4 }{
					step[3][0] = 0;
				}
				{ (index % 4) == 1 } {
					step[3][0] = 0.2.coin.if {rrand(0.25, 0.75)} { 0 };
				}
				{ (index % 4) == 2 } {
					step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
				}
				{ true }{
					step[3][0] = 0.2.coin.if {rrand(0.25, 0.75)} { 0 };
				};
			}
			{ true } {
				case
				{ pattern == 0 }{
					case
					{ index == 0 }{
						step[3][0] = 1;
					}
					{ index == 7 }{
						step[3][0] = 0.75.coin.if { 1 } { 0 };
					}
					{ index == 10 }{
						step[3][0] = 1;
					}
					{ true }{
						step[3][0] = 0;
					}
				}
				{ pattern == 1 }{
					case
					{ (index % 8) == 0 }{
						step[3][0] = 1;
					}
					{ (index % 8) == 3 }{
						step[3][0] = rrand(0.5, 1);
					}
					{ true }{
						step[3][0] = 0;
					}
				}

			}
		}
		{ tempo < 160 } {
			//4 on the floor
			case
			{ (index % 8) == 0 }{
				step[3][0] = 1;
			}
			{ (index % 8) == 4 }{
				//4 on the floor
				step[3][0] = 1;
			}

			{ (index % 4) == 1 } {
				step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
			}
			{ (index % 4) == 2 } {
				step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
			}
			{ true }{
				step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
			};
		}
		{ true } {
			case
			{ (index % 8) == 0 }{
				step[3][0] = 0;
			}
			{ (index % 8) == 4 }{
				step[3][0] = 0;
			}

			{ (index % 4) == 1 } {
				step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
			}
			{ (index % 4) == 2 } {
				step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
			}
			{ true }{
				step[3][0] = 0.1.coin.if {rrand(0.25, 0.75)} { 0 };
			};
		}

	});

	//second pass.  allow anticipated beats and
	//set kick durations
	~drumMatrix.do({|step, index|
		var nextSteps, checkIndices;
		if (step[3][0] > 0){
			//find the maximum length
			checkIndices = [(index + 1) % seqLength, (index + 2) % seqLength, (index + 3) % seqLength];
			nextSteps = ~drumMatrix[checkIndices].collect({|item| item[3][0]});

			//allow anticipated beats
			case { (index % 4) == 3} {
				if (nextSteps[0] == 1){
					step[3][0] = 1;
					~drumMatrix[(index + 1) % seqLength][3][0] = 0.75.coin.if { 1 } { 0 };
				};
			};

			//set durations
			case
			{ nextSteps[0] > 0 } {
				step[3][1] = 1;
			}
			{ nextSteps[1] > 0 } {
				step[3][1] = 0.6.coin.if { 2 } { 1 };
			}
			{ nextSteps[2] > 0 } {
				step[3][1] = 0.6.coin.if { 3 } { 1 };
			}
			{ true } {
				step[3][1] = 0.5.coin.if { 4 } { rrand(1, 3) };
			};
		};
	});
};

~updateHats = {|tempo|
	//if the velocity is greater than 0.8, the sequencer will trigger the open hat
	//instead of closed
	var seqLength = ~drumMatrix.size;
	var dotted = 0.05.coin;
	var sparse = 0.15.coin;
	var rando = rrand(0,~buffers.hats.size);
	0.1.coin.if { ~hatDrum.set(\buf, ~buffers.hats[rando]);
		~openHatDrum.set(\buf, ~buffers.hats[rando]);
	};
	~hatDrum.set(\curve, rrand((-4), 2));
	~openHatDrum.set(\curve, rrand((-4), 2));
	~drumMatrix.do({|step, index|
		case
		{ tempo < 120 } {
			case
			{ (index % 2) == 0 }{
				step[0] = rrand(0.5, 0.8);
			}
			{ (index % 4) == 2 }{
				case
				{ sparse == true } {
					step[0] = rrand(0.5, 0.79);
				}
				{ true }{
					step[0] = rrand(0.8, 1);
				}
			}
			{ sparse == false }{
				step[0] = rrand(0.3, 0.5);
			}
			{ true }{
				step[0] = rrand(0.01, 0.1);
			};
		}
		{ true } {
			case
			//upbeat hats
			{ dotted == false } {
				case
				{ (index % 4) == 2 }{
					case
					{ sparse == true } {
						step[0] = rrand(0.5, 0.79);
					}
					{ true }{
						step[0] = rrand(0.8, 1);
					}
				}
				{ sparse == false }{
					step[0] = rrand(0.3, 0.5);
				}
				{ true }{
					step[0] = rrand(0.01, 0.1);
				};
			}
			{ dotted == true } {
				case
				{ ((index % 8) % 3) == 0 }{
					step[0] = rrand(0.8, 1);
				}
				{ true }{
					step[0] = rrand(0.3, 0.5);
				};
			}
		}
	});
};

//drum matrix is of the following form:
/*
[[hi hat velocity1, snare vel1, tom vel1, kick vel1],
[hi hat velocity2, snare vel2, tom vel2, kick vel2],
...
[hi hat velocity16, snare vel16, tom vel16, kick vel16]]

*/
~drumMatrix = Array.fill(16, {[rrand(0.5, 1), 0, 0, [1,1]]});

~genDrumsFn = Pseq(~drumMatrix, inf);

~drumsFn = {
	var intervalOn = 0.20;
	var intervalOff = 0.05;
	var playTime;
	var restTime;
	var update;
	loop{
		var tempoMult = ~drumClockDiv.getSynchronous;
		var step = ~drumsRoutine.next;
		var tempo = ~eg2Hold.getSynchronous;
		playTime = intervalOn / tempoMult;
		update = ~probablilityMap.(1 -~espHighCut.getSynchronous).coin;
		if (update == true) {
			~updateSnare.(tempo);
			~updateToms.(tempo);
			~updateHats.(tempo);
			~updateKick.(tempo);
		};

		~drumOn.(step);

		playTime.wait;
		restTime = intervalOff / tempoMult;
		~drumOff.value;
		restTime.wait;
	}
};

//////////////////////////////////////////////////////////////////////
// prepare recording
//////////////////////////////////////////////////////////////////////
~recording = Recorder(s);
~recordingPath = PathName.new(thisProcess.nowExecutingPath).parentPath +/+ "recording"
+/+ "supersonicACCELERATOR.wav";




~loadBuffers = {
	//////////////////////////////////////////////////////////////////////
	// Load Buffers, Create Buffers
	//////////////////////////////////////////////////////////////////////
	//
	//
	//  user-generated samples are encouraged.
	//  it's easy to add your own.  just drag and drop them into the samples
	//  subfolder, which should be in the same folder as
	//  supersonicACCELERATOR.scd.  the samples must be mono, 48kHz.
	//
	//  then update the path below to reflect your actual filename.
	//  you could also just name your samples the same thing I named mine and
	//  avoid touching the code completely.
	//
	//  drum samples suffixed with _downtempo are only used at slower bpms
	//
	//
	//  protip: compress your drum samples in a DAW before using them with this
	//  device.  there's no drum compressor in here.  if you don't know how to do
	//  that, just knock off 3-5db using an attack time of 0.3ms to 1ms, and a fast
	//  release (50ms)
	//
	//
	//  protip: normalize your drum samples so they are all at 0db.  that will lead to
	//  a pretty neutral mix. once you get the feel of that, modify sample volume
	//  to taste.  some samples won't like being so loud


	~srcPath = PathName.new(thisProcess.nowExecutingPath).parentPath +/+ "samples";

	~buffers = (
		kicks: [Buffer.readChannel(s, ~srcPath +/+ "kick0.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick1.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick2.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick3.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick4.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick5.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick_downtempo.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick_downtempo4.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "kick_downtempo3.wav", channels: [0])
		],
		toms: [Buffer.readChannel(s, ~srcPath +/+ "tom1.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "tom_downtempo1.wav", channels: [0])],
		snares: [Buffer.readChannel(s, ~srcPath +/+ "snare11.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare12.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare13.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare14.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare15.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare16.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare17.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare18.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "clap1.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "clap2.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "clap3.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "clap4.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "clap5.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "rim1.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "rim2.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "rim3.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "rim4.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "rim5.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare_downtempo1.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare_downtempo2.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare_downtempo3.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare_downtempo4.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "snare_downtempo5.wav", channels: [0]),
		],
		hats: [
			Buffer.readChannel(s, ~srcPath +/+ "hat0.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat1.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat2.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat3.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat4.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat5.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat6.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat7.wav", channels: [0]),
			Buffer.readChannel(s, ~srcPath +/+ "hat8.wav", channels: [0]),
		],
		violence: Buffer.readChannel(s, ~srcPath +/+ "granular_violence.wav", channels: [0]),
		water: Buffer.readChannel(s, ~srcPath +/+ "water.wav", channels: [0]),
		enoise: Buffer.readChannel(s, ~srcPath +/+ "granular_electrical_noise.wav", channels: [0]),
		allGranular: Buffer.readChannel(s, ~srcPath +/+ "granular_drums.wav", channels: [0]),
		flute: Buffer.readChannel(s, ~srcPath +/+ "flute_chord.wav", channels: [0]),
		triangle: Buffer.readChannel(s, ~srcPath +/+ "nes_tri.wav", channels: [0]),
		reese: Buffer.readChannel(s, ~srcPath +/+ "reese1.wav", channels: [0]),
		chord: Buffer.readChannel(s, ~srcPath +/+ "mFreakChord.wav", channels: [0]),
		hydrachord: Buffer.readChannel(s, ~srcPath +/+ "hydra_chord.wav", channels: [0]),
	);
	~wavefolderBuf = Buffer.alloc(s, ~wavefolderLUTSize);
	~heatBuf = Buffer.alloc(s, ~heatLUTSize);
	~cvToFreqBuf = Buffer.alloc(s, ~cvToFreqTableSize);
	~bumpBuf = Buffer.alloc(s, ~bumpWavetableSize);
	s.sync;
	~wavefolderBuf.loadCollection(~wavefolderTable.asWavetableNoWrap);
	~heatBuf.loadCollection(~heatWavetable.asWavetableNoWrap);
	~cvToFreqBuf.loadCollection(~cvToFreqWavetable.asWavetableNoWrap);
	~bumpBuf.loadCollection(~bumpWavetable.asWavetableNoWrap

	);
};






//////////////////////////////////////////////////////////////////////
// create nodes
//////////////////////////////////////////////////////////////////////

~createNodes = {
	//safeguard for midi
	MIDIdef.freeAll;





	//////////////////////////////////////////////////////////////////////
	// create Groups
	//////////////////////////////////////////////////////////////////////

	~modGrp = Group();
	s.sync;
	~routingGrp = Group(~modGrp, \addAfter);
	s.sync;
	~dryGrp = Group(~routingGrp, \addAfter);
	s.sync;
	~fxGrp = Group(~dryGrp, \addAfter);
	s.sync;





	//////////////////////////////////////////////////////////////////////
	// define PatchNode
	//////////////////////////////////////////////////////////////////////

	s.bind({
		// factory function to create a new patch node
		// this was once a class. now it is done using events instead of classes/objects
		// to simplify installation on other devices like Bela.
		//
		// change it at your own risk.  there are lots of gotchas using environments
		// this way.
		//
		~patchNodeNew = { |name, index, incoming, toBus, normaledFrom, nodeGroup, before|
			var patchNode = (
				name: name,
				index: index,
				incoming: incoming,
				toBus: toBus,
				normaledFrom: normaledFrom,
				fromBus: normaledFrom,
				patch: nil,
				nodeGroup: nodeGroup
			);

			// Initialize the patch if this is an incoming node
			if(patchNode.incoming) {
				patchNode.patch = Synth(\audioPatch, [
					\from, patchNode.fromBus,
					\to, patchNode.toBus,
				], patchNode.nodeGroup);
			};

			patchNode.setFromBus = { |newBus|
				if(patchNode.patch.notNil) {
					patchNode.patch.set(\from, newBus);
				} {
					// Create a new patch if this is an incoming node but patch doesn't exist yet
					patchNode.patch = Synth(\audioPatch, [
						\from, newBus,
						\to, patchNode.toBus
					], patchNode.nodeGroup);

				};
				patchNode.fromBus = newBus;
			};

			patchNode.disconnect = {
				if(patchNode.patch.notNil) {
					//patchNode.patch.free;
					patchNode.patch.set(\from, nil);
				};
				//patchNode.patch = nil;

			};

			patchNode.denormal = {
				if(patchNode.fromBus == patchNode.normaledFrom){
					patchNode.disconnect;
				};
			};

			patchNode.debuggingInfo = {
				"PatchNode(" ++
				patchNode.name ++ ", incoming: " ++ patchNode.incoming
				++ ", index: " ++ patchNode.index
				++ ", fromBus: " ++ patchNode.fromBus
				++ ", toBus: " ++ patchNode.toBus
				++ ", normaledFrom: " ++ patchNode.normaledFrom
				++ ", nodeGroup: " ++ patchNode.nodeGroup
				++ ")";
			};

			patchNode;
		};

	});





	////////////////////////////////////////////////////////////////
	// create virtual patch matrix
	////////////////////////////////////////////////////////////////

	s.bind({

		~patchOutputs = [
			~patchNodeNew.("MG Ramp Out", 1, false, ~mgRampOut.index, nil, ~routingGrp),
			~patchNodeNew.("Seq CV Out", 3, false, ~seqCVOut.index, nil, ~routingGrp),
			~patchNodeNew.("MG Pulse Out", 6, false, ~mgPulseOut.index, nil, ~routingGrp),
			~patchNodeNew.("S&H Out", 7, false, ~shOut.index, nil, ~routingGrp),
			~patchNodeNew.("Seq CV Inv Out", 8, false, ~seqCVInvOut.index, nil, ~routingGrp),
			~patchNodeNew.("EG1 Out", 10, false, ~eg1Out.index, nil, ~routingGrp),
			~patchNodeNew.("EG1 Rev Out", 11, false, ~eg1RevOut.index, nil, ~routingGrp),
			~patchNodeNew.("Seq Gate Out", 15, false, ~seqGateOut.index, nil, ~routingGrp),
			~patchNodeNew.("VCA Out", 16, false, ~vcaOut.index, nil, ~routingGrp),
			~patchNodeNew.("Seq Gate /4 Out", 20, false, ~seqGateDiv4Out.index, nil, ~routingGrp),
			~patchNodeNew.("EG2 Rev Out", 22, false, ~eg2RevOut.index, nil, ~routingGrp),
			~patchNodeNew.("Drift Out", 23, false, ~driftLFOOut.index, nil, ~routingGrp),
			~patchNodeNew.("Drum Out", 28, false, ~drumOut.index, nil, ~routingGrp),
			~patchNodeNew.("Mod Wheel Out", 27, false, ~modWheelOut.index, nil, ~routingGrp),
			~patchNodeNew.("Osc1 Out", 29, false, ~osc1Out.index, nil, ~routingGrp),
			~patchNodeNew.("Osc2 Out", 30, false, ~osc2Out.index, nil, ~routingGrp),
			~patchNodeNew.("Button Out", 33, false, ~buttonOut.index, nil, ~routingGrp),
		];

		~patchInputs = [
			~patchNodeNew.("Total In", 0, true, ~totalModIn.index, ~mgRampOut.index, ~routingGrp),
			~patchNodeNew.("S&H In", 2, true, ~shIn.index, ~noiseOut.index, ~routingGrp),
			~patchNodeNew.("S&H Clock In", 4, true, ~shClockIn.index, ~seqGateOut.index, ~routingGrp),
			~patchNodeNew.("FM In", 5, true, ~fmIn.index, ~eg1Out.index, ~routingGrp),
			~patchNodeNew.("VCA In", 12, true, ~vcaIn.index, ~dcOut.index, ~routingGrp),
			~patchNodeNew.("Ext Signal In", 25, true, ~extIn.index, nil, ~routingGrp),
			~patchNodeNew.("VCA Ctrl In", 14, true, ~vcaCtrlIn.index, ~dcOut.index, ~routingGrp),
			~patchNodeNew.("HPF Cutoff In", 13, true, ~hpfCutoffIn.index, ~eg2Out.index, ~routingGrp),
			~patchNodeNew.("Osc2 Mod In", 32, true, ~osc2ModIn.index, ~osc1Out, ~routingGrp),
			~patchNodeNew.("LPF Cutoff In", 17, true, ~lpfCutoffIn.index, ~eg2Out.index, ~routingGrp),
			~patchNodeNew.("EG1 Trig In", 18, true, ~eg1TrigIn.index, ~gateOut.index, ~routingGrp),
			~patchNodeNew.("Osc2 CV In", 24, true, ~osc2CVIn.index, ~freqOut.index, ~routingGrp),
			~patchNodeNew.("AM In", 21, true, ~amIn.index, ~eg2Out.index, ~routingGrp),
			~patchNodeNew.("EG All Time In", 19, true, ~egAllTimeIn.index, nil, ~routingGrp),
			~patchNodeNew.("Osc1 In", 9, true, ~osc1In.index, ~osc1Out.index, ~routingGrp),
			~patchNodeNew.("FX Time In", 26, true, ~fxTimeIn.index, ~dcOut.index, ~routingGrp),
			~patchNodeNew.("Osc1 Mod In", 31, true, ~osc1ModIn.index, ~driftLFOOut.index, ~routingGrp),
			~patchNodeNew.("Seq Rate In", 34, true, ~seqRateIn.index, ~dcNegOut.index, ~routingGrp),
		];
	});





	////////////////////////////////////////////////////////////////
	// create Synths
	////////////////////////////////////////////////////////////////

	s.bind({

		~kickDrum = Synth(\kickSampler, [buf: ~buffers.kicks[rrand(0, 5)], duration: 4], ~modGrp);
		~tomDrum = Synth(\drumSampler, [buf: ~buffers.toms[0]], ~modGrp);
		~snareDrum = Synth(\snareSampler, [buf: ~buffers.snares[rrand(0, 17)]], ~modGrp);
		~hatDrum = Synth(\hatSampler, [buf: ~buffers.hats[0]], ~modGrp);
		~openHatDrum = Synth(\openHatSampler, [buf: ~buffers.hats[0]], ~modGrp);


		~modWheel = Synth(\modWheel, [], ~modGrp);
		~button = Synth(\k2a, [in: ~buttonIn, out: ~buttonOut], ~modGrp);
		~sequencerRouter = Synth(\k2a, [in: ~seqCVIn, out: ~seqCVOut], ~modGrp);
		~sequencerInvRouter = Synth(\k2a, [in: ~seqCVInvIn, out: ~seqCVInvOut], ~modGrp);
		~sequencerGateRouter = Synth(\k2a, [in: ~seqGateIn, out: ~seqGateOut], ~modGrp);
		~sequencerGateDiv4Router = Synth(\k2a, [in: ~seqGateDiv4In, out: ~seqGateDiv4Out], ~modGrp);
		~sequencerRateConverter = Synth(\a2k, [in: ~seqRateIn, out: ~seqRateOut], ~modGrp);
		~dc  = Synth(\dc, [\out, ~dcOut], ~modGrp);
		~dcNeg = Synth(\dc, [\offset, -10, \out, ~dcNegOut], ~modGrp);
		~panelVCA = Synth(\panelVCA, [], ~modGrp);
		~noise = Synth(\noise, [], ~modGrp);
		~sampleAndHold = Synth(\sampleAndHold, [], ~modGrp);

		~driftLFO = Synth(\driftLFO, [\freq, 2], ~modGrp);

		~mg = Synth(\mg, [
			\rampOut, ~mgRampOut,
			\pulseOut, ~mgPulseOut,
			\freq, ~mgFrequency.asMap,
			\waveform, ~mgShape.asMap
		], ~modGrp);

		~grindOsc = Synth(\freerunningLFO, [
			\rampOut, ~grindOscOut,
			\freq, ~osc2Scale.asMap,
			\freqMult, 87.25
		], ~modGrp);


		~freq = Synth(\k2a, [in: ~freqIn, out: ~freqOut], ~modGrp, \addToHead);
		~gate = Synth(\k2a, [in: ~gateKr, out: ~gateOut], ~modGrp, \addToHead);

		~eg1 = Synth(\eg1, [
			delay: ~eg1Delay.asMap,
			attack: ~eg1Attack.asMap,
			release: ~eg1Release.asMap
		], ~modGrp);


		~eg2 = Synth(\eg2, [
			attack: ~eg2Attack.asMap,
			decay: ~eg2Decay.asMap,
			sustain: ~eg2Sustain.asMap,
			release: ~eg2Release.asMap
		], ~modGrp);

		~tapeDelay = Synth(\TapeDelay, [
			\out, 0,
			\mix, 1,
			\feedback, ~delayFeedback.asMap,
			\wowRate, 0.33,
			\wowDepth, 0.005,
			\clockDiv, ~delayClockDiv.asMap
		], ~fxGrp);

		// Create mixer and other components
		~mixer = Synth(\magicMixer, [
			input1Level: ~osc1Level.asMap,
			input2Level: ~osc2Level.asMap
		], ~dryGrp);

		~mixerRoute = Synth(\audioPatch, [from: ~mixerOut, to: ~hpfIn], ~dryGrp, \addToTail);

		~hpf = Synth(\hpf, [
			cutoff: ~hpfCutoff.asMap,
			resonance: ~hpfResonance.asMap,
			knob1: ~hpfModMG.asMap,
			knob2: ~hpfModEG2.asMap
		], ~dryGrp, \addToTail);

		~lpf = Synth(\lpf, [
			cutoff: ~lpfCutoff.asMap,
			resonance: ~lpfResonance.asMap,
			knob1: ~lpfModMG.asMap,
			knob2: ~lpfModEG2.asMap
		], ~dryGrp, \addToTail);

		~vca = Synth(\characterVCA, [], ~dryGrp, \addToTail);

		~sidechainCompressor = Synth(\compressor, [], ~fxGrp, \addToHead);

		~outputMixer = Synth(\outputMixer, [], ~fxGrp, \addToTail);

		~rumble = Synth(\rumble, [], ~modGrp);





		////////////////////////////////////////////////////////////////
		// create voice (oscillators)
		////////////////////////////////////////////////////////////////

		~voice = ~voiceNew.(60, 261.6, 0.5, nil);
		s.sync;
		~initOscillators.value;
	});


	s.bind({
		//////////////////////////////////////////////////////////////////////
		// create MIDI handlers
		//////////////////////////////////////////////////////////////////////

		MIDIdef.noteOn(\noteOn, {|vel, note, chan, src|
			var scale = 1;
			var freq = note.midicps / 4;
			var cv = ~freqToCV.(freq);
			var amp = 1;

			/*
			("note: " ++ note).postln;
			("freq: " ++ freq).postln;
			("cv: " ++ cv).postln;
			*/


			case
			{~sequencerRunning == false} {
				~noteOn.(note, cv, amp);
			}
			{ true } {
				// if the sequencer is running we add the note to the sequence instead of playing it
			};

			//keep track of all held down notes
			~liveNotes = ~liveNotes.add(note);
		});

		MIDIdef.noteOff(\noteOff, {|vel, note, chan, src|
			var freq;
			var newNote;
			var amp = 1;
			var cv;

			//remove note from tracking
			~liveNotes = ~liveNotes.reject({|item| item == note});

			//monophonic last note priority
			case
			{~liveNotes.size == 0} {
				~noteOff.(note);
				~liveNotes = [];
			}
			{ true }{
				newNote = ~liveNotes.last;
				freq = newNote.midicps / 4;
				cv = ~freqToCV.(freq);
				if (~sequencerRunning == false){
					~noteOn.(newNote, cv, amp);
				};
			};
		});

		// cc99 cc98 and cc6 get special treatment because they make up the patch bay
		~ccValues = Dictionary.newFrom([
			99, 0,
			98, 0,
			6, 0
		]);

		~updatedCCs = Dictionary.newFrom([
			99, false,
			98, false,
			6, false
		]);

		MIDIdef.cc(\controlChange, { |val, num, chan, src|

			var knob;

			///////////////////
			// patch matrix / patch bay MIDI handler
			///////////////////
			var processCombinedCCs = { |cc99val, cc98val, cc6val|
				//TODO:
				// convert all these if statements into case statements for clarity

				/*
				["cc99:", cc99val].postln;
				["cc98:", cc98val].postln;
				["cc6:", cc6val].postln;
				"--------------------".postln;
				*/

				//special cases
				/*
				case
				{cc99val == 4 && cc98val == 34 && cc6val == 34} {
				~sequencerRunning = false;
				}
				{cc6val == 34 && cc98val != 34 } {
				~sequencerRunning = true;
				}
				{cc99val == 5 && cc98val == 34 && cc6val == 34} {
				~sequencerRunning = true;
				}; */

				case
				{ cc99val == 4 && cc98val == 28 && cc6val == 25 } {
					if (~snareFX.isNil) {
						~snareFX = Synth(\audioPatchStereo, [
							\from, ~drumFXOut,
							\to, ~drumFXIn
						], ~routingGrp);
					};
				}

				{ cc99val == 5 && cc98val == 28 && cc6val == 25 } {
					if (~snareFX.notNil) {
						~snareFX.free;
						~snareFX = nil;
					};
				};

				//add rumble when kick is in
				if(cc99val == 4 && cc98val == 28 && cc6val == 25){
					if(~rumblePatch.isNil){
						~rumblePatch = Synth(\audioPatchStereo, [
							\from, ~rumbleOut,
							\to, ~rumbleIn
					], ~routingGrp)};
					//add sidechain
					if(~sidechainPatch.isNil){
						~sidechainPatch = Synth(\audioPatch, [
							\from, ~kickOut,
							\to, ~compressorSidechainIn
					], ~routingGrp);}
				};

				//remove rumble with kick
				if(cc99val == 5 && cc98val == 28 && cc6val == 25){
					if(~rumblePatch.notNil){
						~rumblePatch.free;
						~rumblePatch = nil;
					};
					//add sidechain
					if(~sidechainPatch.notNil){
						~sidechainPatch.free;
						~sidechainPatch = nil;
					};
				};

				//special case, LFO ramp to VCA.  Use unipolar mode
				if(cc99val == 4 && cc98val == 1 && cc6val == 14){
					if (~panelVCA.notNil){
						~panelVCA.free;
					};
					~panelVCA = Synth(\panelVCAUnipolar, [], ~modGrp, \addToTail);
				};

				// back to bipolar VCA mode
				if(cc99val == 5 && cc98val == 1 && cc6val == 14){
					if (~panelVCA.notNil){
						~panelVCA.free;
					};
					~panelVCA = Synth(\panelVCA, [], ~modGrp, \addToTail);
				};


				//handle normaled connections
				if( cc98val == cc6val){
					var arrayIndex;
					//find input node
					~patchInputs.do({|inputNode, i|
						if(inputNode.index == cc6val){
							arrayIndex = i;
						};
					});
					if(arrayIndex.notNil){
						if(cc99val == 4){
							// disconnect normal
							~patchInputs[arrayIndex].denormal.value;
						};
						if(cc99val == 5){
							// connect normal
							~patchInputs[arrayIndex][\setFromBus].(~patchInputs[arrayIndex].normaledFrom);
						};
					};

					//special case: Turn OFF
					if(cc99val == 6){
						~recording.stopRecording;
						// add this back in later
						//~recording.prepareForRecord(~recordingPath);
					};
				} {
					var inputArrayIndex;
					//on switch
					if(cc99val == 6){
						//initialize driftLFO
						~driftLFO.set(\freq, 0.04);
						////////////////////////////////////////////////////////////////
						// create recording
						////////////////////////////////////////////////////////////////

						s.bind({
							~recording.prepareForRecord(~recordingPath);
						});
						s.makeBundle(2.0, {~recording.record(numChannels: 2);
							"starting recording!".postln;});
					};

					//handle user connections
					//get input node

					//get the correct input node
					~patchInputs.do({|inputNode, i|
						if(inputNode.index == cc6val){
							inputArrayIndex = i;
						};
					});
					//if cc6 contains an input node
					if (inputArrayIndex.notNil){
						if(cc99val == 5){
							//disconnect user connection
							~patchInputs[inputArrayIndex].disconnect.value;
						};
						if(cc99val == 4){
							//connect user connection
							var outputArrayIndex;
							//get output node
							~patchOutputs.do({|outputNode, i|
								if(outputNode.index == cc98val){
									outputArrayIndex = i;
								}
							});
							if(outputArrayIndex.notNil){
								~patchInputs[inputArrayIndex][\setFromBus].(~patchOutputs[outputArrayIndex].toBus);
							}
						}
					} {
						inputArrayIndex = nil;
						//check if cc98 is an input node
						~patchInputs.do({|inputNode, i|
							if(inputNode.index == cc98val){
								inputArrayIndex = i;
							};
						});
						//if cc98 contains an input node
						if (inputArrayIndex.notNil){
							if(cc99val == 5){
								//disconnect user connection
								~patchInputs[inputArrayIndex].disconnect.value;
							};
							if(cc99val == 4){
								//connect user connection
								var outputArrayIndex;
								//get output node
								~patchOutputs.do({|outputNode, i|
									if(outputNode.index == cc6val){
										outputArrayIndex = i;
									};
								});
								if(outputArrayIndex.notNil){
									~patchInputs[inputArrayIndex][\setFromBus].(~patchOutputs[outputArrayIndex].toBus);
								}
							}
						}
					}
				}
			};

			if([99, 98, 6].includes(num)) {
				~ccValues[num] = val;
				~updatedCCs[num] = true;

				// check if we have all three CC values updated
				if(~updatedCCs[99] && ~updatedCCs[98] && ~updatedCCs[6]) {
					// Reset the updated flags
					~updatedCCs[99] = false;
					~updatedCCs[98] = false;
					~updatedCCs[6] = false;

					processCombinedCCs.(~ccValues[99], ~ccValues[98], ~ccValues[6]);
				}

				// return early so we don't process these CCs individually
				^nil;
			};





			/////////////////////////////////////////////
			// regular CC processing for knobs
			/////////////////////////////////////////////


			num.switch(
				74, {
					knob = val.linexp(0, 127, 20, 20000);
					~lpfCutoff.set(knob);
				},
				71, {
					//0.03 for clean mode
					knob = val.linlin(0, 127, 0, 4);
					~lpfResonance.set(knob);
				},
				77, {
					case
					{val == 0} { knob = 0 }
					{val == 43} { knob = 1 }
					{val == 85} { knob = 2 }
					{true} { knob = 3 };
					~osc1Shape.set(knob);
					~setOsc1Group.(knob);
				},
				1, {
					knob = val.linlin(0, 127, -1, 1);
					case
					{~buttonIn.getSynchronous.asInteger < 1}{
						//no button press
						~modWheelIn.set(knob);
					}
					{ true }{
						//button held
						case
						{ knob > 0 } {
							~normalLevel.set(1 - knob);
							~delayAmt.set(0);
						}
						{ true }{
							~delayAmt.set(knob);
						}

					};
				},
				// VCO1
				14, {
					knob = (val < 64).if { val.linexp(0, 63, 0.25, 1) } { val.linexp(64, 127, 1, 8) };
					~osc1PW.set(knob);
				},
				15, {
					case
					{val == 0} { knob = 0 }
					{val == 43} { knob = 1 }
					{val == 85} { knob = 2 }
					{true} { knob = 3 };
					~osc1Scale.set(knob);
					~setOsc1Wave.(knob);
				},
				// VCO2
				82, {
					case
					{val == 0} { knob = 0 }
					{val == 43} { knob = 1 }
					{val == 85} { knob = 2 }
					{true} { knob = 3 };
					~osc2Shape.set(knob);
					~setOsc2.(knob);
				},
				19, {
					knob = (val < 64).if { val.linexp(0, 63, 0.25, 1) } { val.linexp(64, 127, 1, 8) };
					~osc2Pitch.set(knob);
				},
				22, {
					case
					{val == 0} {
						knob = 0;
						if(~fuzz.notNil){
							~fuzz.free;
						};
						~fuzz = Synth(\clean, [], ~fxGrp, \addToTail);
						if (~wavefolder.notNil){
							~mixerRoute = Synth(\audioPatch, [from: ~mixerOut, to: ~hpfIn], ~wavefolder, \addReplace);
							~wavefolder.free;
							~wavefolder = nil;
						};
					}
					{val == 43} {
						knob = 3;
						if(~fuzz.notNil){
							~fuzz.free;
						};
						~fuzz = Synth(\tape, [], ~fxGrp, \addToTail);
						if (~wavefolder.notNil){
							~mixerRoute = Synth(\audioPatch, [from: ~mixerOut, to: ~hpfIn], ~wavefolder, \addReplace);
							~wavefolder.free;
							~wavefolder = nil;
						};
					}

					{val == 85} {
						knob = 2;
						if(~fuzz.notNil){
							~fuzz.free;
						};
						~fuzz = Synth(\clean, [], ~fxGrp, \addToTail);
						~wavefolder = Synth(\wavefolder, [], ~mixerRoute, \addReplace);
						if(~mixerRoute.notNil)
						{
							~mixerRoute.free;
							~mixerRoute = nil;
						};
					}
					{true} {
						knob = 1;
						if(~fuzz.notNil){
							~fuzz.free;
						};
						~fuzz = Synth(\fuzz, [
							amp: 1,
							fmOsc: ~grindOscOut.asMap
						], ~fxGrp, \addToTail);
						if (~wavefolder.notNil){
							~mixerRoute = Synth(\audioPatch, [from: ~mixerOut, to: ~hpfIn], ~wavefolder, \addReplace);
							~wavefolder.free;
							~wavefolder = nil;
						};
					};

					~osc2Scale.set(knob);
				},
				// VCO Master
				5, {
					knob = val.linlin(0, 127, 0, 1.0);
					~portamento.set(knob);
				},
				18, {
					knob = val.linlin(0, 127, 0, 1);
					~masterTune.set(knob);
				},
				76, {
					knob = val.linlin(0, 127, 0, 1.0);
					~mgShape.set(knob);
				},
				12, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~freqModMG.set(knob);
				},
				93, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~freqModEG1.set(knob);
				},
				// VCO Mixer
				20, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~osc1Level.set(knob);
				},
				21, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~osc2Level.set(knob);
				},
				// HPF
				28, {
					knob = val.linexp(0, 127, 20, 12000);
					~hpfCutoff.set(knob);
				},
				29, {
					knob = val.linlin(0, 127, 0, 4);
					~hpfResonance.set(knob);
				},
				30, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~hpfModMG.set(knob);
				},
				31, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~hpfModEG2.set(knob);
				},
				85, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~lpfModMG.set(knob);
				},
				79, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~lpfModEG2.set(knob);
				},
				// MG
				27, {
					knob = val.linlin(0, 127, 0.05, 20);
					~mgFrequency.set(knob);
				},
				// EG1
				24, {
					knob = val.curvelin(0, 127, 0.001, 7, -3);
					~eg1Delay.set(knob);
				},
				23, {
					knob = val.curvelin(0, 127, 0.005, 30, -16);
					~eg1Attack.set(knob);
				},
				26, {
					knob = val.curvelin(0, 127, 0.01, 30, -16);
					~eg1Release.set(knob);
				},
				// EG2
				25, {


					case
					{ ~buttonIn.getSynchronous.asInteger < 1}{
						//no button press
						knob = val.linlin(0, 127, 2, 258);

						case
						{knob < 8 } {
							~drumClockDiv.set(4)
						}
						{knob < 70} {
							~drumClockDiv.set(2)
						}
						{knob > 170} {
							~drumClockDiv.set(0.5)
						}
						{true} {
							~drumClockDiv.set(1)
						};

						case
						{val < 1} { ~delayClockDiv.set(96) }
						{val < 3} { ~delayClockDiv.set(32) }
						{val < 17} { ~delayClockDiv.set(16) }
						{val < 50} { ~delayClockDiv.set(2) }
						{val > 95} { ~delayClockDiv.set(0.5) }
						{true} { ~delayClockDiv.set(1) };

						//set notched tempo values
						case
						{ knob < 90}{
							~eg2Hold.set(knob);
						}
						{ knob < 100}{
							~eg2Hold.set(94);
						}
						{ knob < 116}{
							~eg2Hold.set(112);
						}
						{ knob < 125}{
							~eg2Hold.set(120);
						}
						{ knob < 130}{
							~eg2Hold.set(128);
						}
						{ knob < 135}{
							~eg2Hold.set(132);
						}
						{ knob < 140}{
							~eg2Hold.set(138);
						}
						{ knob < 150}{
							~eg2Hold.set(144);
						}
						{ knob < 160}{
							~eg2Hold.set(155);
						}
						{ knob < 170}{
							~eg2Hold.set(160);
						}
						{ true}{
							~eg2Hold.set(knob);
						};
					}
					{ true }{
						// button hold
						knob = val.linexp(0, 127, 0.125, 4);
						~tapeDivOut.set(knob)
					}
				},

				73, {
					knob = val.curvelin(0, 127, 0.001, 30, -16);
					~eg2Attack.set(knob);
				},
				75, {
					knob = val.curvelin(0, 127, 0.1, 30, -16);
					~eg2Decay.set(knob);
				},
				70, {
					knob = val.linlin(0, 127, 0.0, 1.0);
					~eg2Sustain.set(knob);
				},
				72, {
					knob = val.curvelin(0, 127, 0.001, 30, -16);
					~eg2Release.set(knob);
				},
				// ESP
				11, {
					case
					{val < 32}{
						~espSignalLevel.set(3);
					}
					{val < 64}{
						~espSignalLevel.set(4);
					}
					{val < 96}{
						~espSignalLevel.set(5);
					}
					{true}{
						~espSignalLevel.set(8);
					};

				},
				88, {
					case
					{ val < 64} {
						knob = val.linlin(0, 63, 0.0, 0.5)
					}
					{ true } {
						knob = val.linexp(64, 127, 0.5, 1)
					};
					~espLowCut.set(knob);
				},
				89, {
					case {val == 0}{
						~espHighCut.set(val);
					}
					{ true }{
						knob = val.linlin(0, 127, 0.0, 1);
						~espHighCut.set(knob);
					};
				},
				90, {
					case
					{val < 42}{
						~espCVAdjust.set(0);
					}
					{val < 84}{
						~espCVAdjust.set(1);
					}
					{true}{
						~espCVAdjust.set(2);
					}

				},
				91, {
					knob = val.linlin(0, 127, 0, 9).round;
					case
					{~buttonIn.getSynchronous.asInteger < 1}{
						// no button press
						~espThreshold.set(knob);
					}
					{ true }{
						// button hold
						var lpfCutoff, hpfCutoff;
						case
						{val < 60 }{
							lpfCutoff = val.linexp(0, 60, 80, 20000);
							hpfCutoff = 0;

						}
						{ val < 68 }{
							lpfCutoff = 20000;
							hpfCutoff = 0;
						}
						{ true }{
							hpfCutoff = val.linlin(68, 127, 0, -15);
							lpfCutoff = 20000;
						};
						~extLPFCutoff.set(lpfCutoff);
						~extHPFCutoff.set(hpfCutoff);
					}
				},
				// Others
				7, {
					knob = val.linlin(0, 127, 0.0, 1);
					case
					{~buttonIn.getSynchronous.asInteger < 1}{
						// no button press
						~outputVolume.set(knob);
					}
					{ true }{
						// button hold
						~delayFeedback.set(knob);
					}

				}
			);
		});





		/////////////////////////////////////////////
		// the button
		/////////////////////////////////////////////

		MIDIdef.touch(\buttonHandler, { |val|
			case
			{ val > 0 }{
				~buttonIn.set(1)
			}
			{ true } {
				~buttonIn.set(0)
			}

		});
	};);





	////////////////////////////////////////////////////////////////
	// create clock
	////////////////////////////////////////////////////////////////

	~clock = TempoClock.new(155/60).permanent_(true);
	~clockTempoOut.set(~clock.beatDur);
	s.sync;


	////////////////////////////////////////////////////////////////
	// create sequencer
	////////////////////////////////////////////////////////////////

	~initSequencerPatterns.value;
	s.sync;
	~createSequencer.value;
	s.sync;
};

s.freeAll;
Buffer.freeAll;

////////////////////////////////////////////////////////////////
// boot instructions
////////////////////////////////////////////////////////////////

s.waitForBoot({
	s.sync;
	////////////////////////////////////////////////////////////////
	// initialize MIDI
	////////////////////////////////////////////////////////////////
	MIDIClient.init;
	MIDIIn.connectAll;

	~loadBuffers.value;
	s.sync;

	////////////////////////////////////////////////////////////////
	// initialize buses
	////////////////////////////////////////////////////////////////


	// VCO1
	~osc1Shape.set(0);
	~osc1PW.set(1);
	~osc1Scale.set(0);
	~portamento.set(0.03);

	// VCO2
	~osc2Shape.set(0);
	~osc2Pitch.set(1);
	~osc2Scale.set(0);

	// VCO Master
	~masterTune.set(0);
	// knobs
	~freqModMG.set(0);
	~freqModEG1.set(0);

	// VCO Mixer
	~osc1Level.set(1);
	~osc2Level.set(0);

	// HPF
	~hpfCutoff.set(20);
	~hpfResonance.set(1);
	//knobs
	~hpfModMG.set(0);
	~hpfModEG2.set(0);

	// LPF
	~lpfCutoff.set(20000);
	~lpfResonance.set(1);
	//knobs
	~lpfModMG.set(0);
	~lpfModEG2.set(0);

	// MG
	~mgShape.set(0.5);
	~mgFrequency.set(1);

	// EG1
	~eg1Delay.set(0.001);
	~eg1Attack.set(0.01);
	~eg1Release.set(0.5);


	// EG2
	~eg2Hold.set(140);
	~eg2Attack.set(0.01);
	~eg2Decay.set(0.3);
	~eg2Sustain.set(0.7);
	~eg2Release.set(0.1);

	// sequencer
	~espSignalLevel.set(8);
	~espLowCut.set(0.5);
	~espHighCut.set(0.5);
	~espCVAdjust.set(0);
	~espThreshold.set(0.5);
	~seqCVIn.set(0);
	~seqCVInvIn.set(0);
	~seqGateIn.set(0);
	~seqGateDiv4In.set(0);
	~clockDivideIn.set(1);
	~delayClockDiv.set(1);
	~delayFeedback.set(0.8);

	// others
	~modWheelIn.set(0);
	~buttonIn.set(0);
	~outputVolume.set(0);
	~driftLFOAmt.set(0);
	~delayAmt.set(-1);
	~modWheelIn.set(0.75);
	~tapeDivOut.set(1);
	~drumClockDiv.set(1);
	~extLPFCutoff.set(20000);
	~extHPFCutoff.set(0);
	~normalLevel.set(1);


	~freqIn.set(0);
	~gateKr.set(0);
	~ampKr.set(0);

	s.sync;

	////////////////////////////////////////////////////////////////
	// create SynthDefs
	////////////////////////////////////////////////////////////////


	SynthDef(\freerunningLFO, {
		arg rampOut, freq=0.5, waveform=0.5, amp=1, freqMult = 0.25;
		var  ramp;

		freq = freq * freqMult;
		ramp = VarSaw.ar(freq, waveform);
		ramp = ramp * amp;

		Out.ar(rampOut, ramp);
	}).add;


	SynthDef(\driftLFO, {
		|freq = 0.04|
		var randVal = Latch.kr(WhiteNoise.kr(), Impulse.kr(freq));
		var sig;

		sig = VarLag.kr(randVal, (1/freq), 0);
		sig = K2A.ar(sig);
		Out.ar(~driftLFOOut, sig);
	}).add;


	SynthDef(\mg, {
		arg rampOut, freq=0.5, waveform=0.5, amp=1, pulseOut;
		var  ramp, pulse;

		waveform = waveform.clip(0.01, 0.99);
		ramp = VarSaw.ar(freq, 0, waveform);
		pulse = LFPulse.ar(freq, 0, waveform);

		ramp = ramp * amp;
		pulse = pulse * amp;

		Out.ar(rampOut, ramp);
		Out.ar(pulseOut, pulse);
	}).add;


	SynthDef(\eg1, { |doneAction = 0|
		var trig = InFeedback.ar(~eg1TrigIn);
		var timeMod = Latch.kr(InFeedback.ar(~egAllTimeIn), Impulse.kr(10));
		var eg1;

		timeMod = (timeMod + 1.05) * 2;
		eg1 = EnvGen.ar(Env.new(levels: [0, 0, 1, 0],
			times: [\delay.kr(0), \attack.kr(0.1), \release.kr(0.1)],
			curve: [0, -12, -12],
			releaseNode: 2
		), trig, timeScale: timeMod, doneAction: doneAction);

		Out.ar(~eg1Out, eg1);
		Out.ar(~eg1RevOut, 1 - eg1);
	}).add;

	SynthDef(\eg2, {|doneAction = 0|
		var gate = InFeedback.ar(~gateOut);
		var timeMod = Latch.kr(InFeedback.ar(~egAllTimeIn), Impulse.kr(10));
		var eg2, sustain;

		timeMod = (timeMod + 1.05) * 2;
		eg2 = EnvGen.ar(Env.adsr(\attack.kr(0.5),
			\decay.kr(0.5),
			\sustain.kr(1),
			\release.kr(0.1),1, -4),
		gate: gate,
		timeScale: timeMod,
		doneAction: doneAction);

		Out.ar(~eg2Out, eg2);
		Out.ar(~eg2RevOut, 1 - eg2);
	}).add;

	SynthDef(\sine, {|freq = 440|
		var sig, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = SinOsc.ar(freq);

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\sineRando, {|freq = 440|
		var sig, rand1, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var overtones;

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		rand1 = exprand(2, 5);
		sig = SinOsc.ar(freq);
		sig = sig + (SinOsc.ar(freq * rand1));
		sig = sig * 0.5;

		Out.ar(~osc1Out, sig);
	}).add;


	SynthDef(\decoupledSine, {|freq = 440|
		var sig, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var overtones;

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = SinOsc.ar(freq);

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\bump, {|freq = 440|
		var sig, rand1, rand2, rand3, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = Osc.ar(~bumpBuf, freq);

		sig = sig * 0.75;

		Out.ar(~osc1Out, sig);
	}).add;


	SynthDef(\saw, {|freq = 440|
		var sig, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = Saw.ar(freq);

		Out.ar(~osc1Out, sig);
	}).add;


	SynthDef(\nesTriangle, {|freq = 440|
		var sig, rand1, rand2, rand3, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = OscN.ar(~buffers.triangle, freq);
		sig = sig * 1.25;

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\reese, {
		|freq, buf|
		var sig, rate, rand1, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var sampleBaseFreq = 261.63; // C4 frequency in Hz
		var gate = InFeedback.ar(~gateOut, 1);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		rate = freq / sampleBaseFreq;
		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf) * rate,
			trigger: gate,
			startPos: \startPos.kr(0),
			loop: \loop.kr(1)
		);
		sig = sig + SinOsc.ar(freq * 1.06, 0, 0.333) + SinOsc.ar(freq * 0.94, 0, 0.333);
		sig = sig * \amp.kr(1) * 0.5;

		Out.ar(~osc1Out, sig);
	}).add;


	SynthDef(\resonator, {|freq = 440|
		var sig, rand1, rand2, rand3, freqMod1, freqMod2, freqMod3, modulatedBase;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var gate = InFeedback.ar(~gateOut, 1);
		var clockDiv = In.kr(~delayClockDiv, 1);
		var trig = Trig1.kr(gate, 0.001);
		var stepCount = Stepper.kr(trig, 0, 0, 5, 1);

		var steps = [
			Select.kr(stepCount, [1, 0, 0, 0, 0]),
			Select.kr(stepCount, [0, 1, 0, 0, 0]),
			Select.kr(stepCount, [0, 0, 1, 0, 0]),
			Select.kr(stepCount, [0, 0, 0, 1, 0]),
			Select.kr(stepCount, [0, 0, 0, 0, 1])
		];

		var latchTrigs = (0..4).collect { |i| Trig1.kr(steps[i], 0.001) };
		var latchedFreqs = latchTrigs.collect { |t| Latch.kr(freq, t) };
		var env = Env.perc(0.001, 2 * clockDiv, 1, -12);
		var freqs, pitch;

		pitch = \pitch.kr(0.5, 0.18);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		modulatedBase = pitch * freqMod1 * freqMod2 * freqMod3;

		freqs = latchedFreqs.collect {|f| Clip.ar(modulatedBase * f, 20, 20000)};

		sig = SinOsc.ar(freqs * 4) * EnvGen.kr(env, trig);
		sig= Mix(sig) * 0.33;

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\polyBump, {|freq = 440|
		var sig, rand1, rand2, rand3, freqMod1, freqMod2, freqMod3, modulatedBase;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var gate = InFeedback.ar(~gateOut, 1);
		var clockDiv = In.kr(~delayClockDiv, 1);
		var trig = Trig1.kr(gate, 0.001);
		var stepCount = Stepper.kr(trig, 0, 0, 5, 1);
		var steps = [
			Select.kr(stepCount, [1, 0, 0, 0, 0]),
			Select.kr(stepCount, [0, 1, 0, 0, 0]),
			Select.kr(stepCount, [0, 0, 1, 0, 0]),
			Select.kr(stepCount, [0, 0, 0, 1, 0]),
			Select.kr(stepCount, [0, 0, 0, 0, 1])
		];
		var latchTrigs = (0..4).collect { |i| Trig1.kr(steps[i], 0.001) };
		var latchedFreqs = latchTrigs.collect { |t| Latch.kr(freq, t) };
		var env = Env.perc(0.001, 2 * clockDiv, 1, -12);
		var freqs, pitch;

		pitch = \pitch.kr(0.5, 0.18);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		modulatedBase = pitch * freqMod1 * freqMod2 * freqMod3;

		freqs = latchedFreqs.collect {|f| Clip.ar(modulatedBase * f, 20, 20000)};
		sig = SinOsc.ar(freqs * 2).lincurve(-1, 1, -1, 1, -15);
		sig = sig * EnvGen.kr(env, trig);
		sig= Mix(sig) * 0.5;

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\polyFlute, {|freq = 440, buf|
		var sig, rand1, rand2, rand3, freqMod1, freqMod2, freqMod3, modulatedBase;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var gate = InFeedback.ar(~gateOut, 1);
		var clockDiv = In.kr(~delayClockDiv, 1);
		var trig = Trig1.kr(gate, 0.001);
		var stepCount = Stepper.kr(trig, 0, 0, 5, 1);
		var sampleBaseFreq = 261.63;
		var steps = [
			Select.kr(stepCount, [1, 0, 0, 0, 0]),
			Select.kr(stepCount, [0, 1, 0, 0, 0]),
			Select.kr(stepCount, [0, 0, 1, 0, 0]),
			Select.kr(stepCount, [0, 0, 0, 1, 0]),
			Select.kr(stepCount, [0, 0, 0, 0, 1])
		];
		var latchTrigs = (0..4).collect { |i| Trig1.kr(steps[i], 0.001) };
		var latchedFreqs = latchTrigs.collect { |t| Latch.kr(freq, t) };
		var env = Env.asr(0.01, 1, 0.05);
		var rates, pitch;


		pitch = \pitch.kr(0.5, 0.18);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		modulatedBase = pitch * freqMod1 * freqMod2 * freqMod3 * 4;

		rates = latchedFreqs.collect {|f| modulatedBase * f / sampleBaseFreq};

		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf) * rates,
			trigger: gate,
			startPos: \startPos.kr(0),
			loop: \loop.kr(0)
		);
		sig = sig * EnvGen.kr(env, gate);
		sig= Mix(sig) * 0.5;

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\osc1Strings, {|freq = 440|
		var sig, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = CombN.ar(WhiteNoise.kr(), 0.5, 1 / [freq], 5) * 5;
		sig = Clip.ar(sig, -5, 5);

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\water, {
		|freq, buf|
		var sig, rate, rand1, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var gate = InFeedback.ar(~gateOut, 1);
		var shelfFreq;

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;
		rate = log2(freq / 32);
		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf) * rate,
			startPos: \startPos.kr(0),
			loop: \loop.kr(1)
		);
		sig = sig * \amp.kr(1);
		shelfFreq = 5 * (5 - rate);
		sig = BLowShelf.ar(sig, 100, 1, shelfFreq);

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\melodicSampler, {
		|freq, buf|
		var sig, rate, rand1, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var sampleBaseFreq = 130.8;
		var gate = InFeedback.ar(~gateOut, 1);
		var length = BufFrames.ir(buf);
		var start = freq.explin(20,20000, 0.0, 1.0) * length;
		var env = EnvGen.kr(Env.new([0, 1, 0], [0.01, start], 'lin', 2, 1), gate);


		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		rate = freq / sampleBaseFreq;


		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.ir(buf) * rate,
			trigger: env,
			startPos: start,
			loop: \loop.kr(1)
		);
		sig = sig * \amp.kr(1);

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\melodicGranularSampler, {
		|freq, buf|
		var sig, rate, rand1, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var sampleBaseFreq = 130.8;
		var gate = InFeedback.ar(~gateOut, 1);
		var length = BufFrames.ir(buf);
		var start;
		var env;


		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		rate = freq / sampleBaseFreq;
		length = BufFrames.ir(buf);
		start = rate * 220000;
		env = EnvGen.ar(Env.new(levels: [start, start, start + (length / 8), start, start + (length / 16)], times: [0.01, BufRateScale.ir(buf), BufRateScale.ir(buf), BufRateScale.ir(buf)], releaseNode: 3, loopNode: 0), gate);

		sig = BufRd.ar(
			numChannels: 1,
			bufnum: buf,
			phase: env,
			loop: 1
		);
		sig = sig * \amp.kr(1) * 2;

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\granularSampler, {
		|freq, buf, stretch|
		var sig, phs, normalizedFreq, env, freqMod1, freqMod2, freqMod3;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var driftMod = InFeedback.ar(~osc1ModIn, 1);
		var gate = InFeedback.ar(~gateOut, 1);
		var sampleRate = BufSampleRate.ir(buf);
		var bufFrames = BufFrames.ir(buf);
		var phaseDelta = (sampleRate * 0.25) / bufFrames;

		// modulation
		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(driftMod * \driftModKnob.kr(1, 0.18));
		freq = freq * freqMod1 * freqMod2 * freqMod3;

		// pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;
		normalizedFreq = ~freqToCV.(freq);
		normalizedFreq = (normalizedFreq + 1.8) / 4;
		env = Env.new(
			levels: [normalizedFreq, normalizedFreq, (normalizedFreq + phaseDelta)],
			times: [0.001, (0.25 * normalizedFreq * stretch)]
		);
		phs = EnvGen.ar(env, gate, bufFrames);
		sig = BufRd.ar(
			numChannels: 1,
			bufnum: buf,
			phase: phs,
			loop: 0
		);
		sig = sig * \amp.kr(2) * 4;
		sig = sig.tanh;
		sig = sig * 1.5;

		Out.ar(~osc1Out, sig);
	}).add;

	SynthDef(\osc2LinFM, {
		var sig, freqMod1, freqMod2, freqMod3, freq, freqUnmodulated;
		var totalModIn = InFeedback.ar(~totalModIn, 1);
		var fmIn = InFeedback.ar(~fmIn, 1);
		var osc1Mod = InFeedback.ar(~osc2ModIn, 1);
		var cv = InFeedback.ar(~osc2CVIn, 1);

		// this may look odd, but it improves performance
		freq = Shaper.ar(~cvToFreqBuf, cv);

		freqUnmodulated = freq;

		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = osc1Mod * \osc1ModKnob.kr(0,0.18) * 5000;
		freq = freq * freqMod1* freqMod2 + freqMod3;

		freq = \pitch.kr(0.5, 0.18) * freq;

		sig = SinOsc.ar(freq) + (LFTri.ar(freqUnmodulated) * \osc1ModKnob.kr(0,0.18) * 0.5);

		//analog noise to get the high end right
		sig = sig * exp(PinkNoise.ar(0.025));

		Out.ar(~osc2Out, sig)
	}
	).add;

	SynthDef(\osc2ExpFM, {
		var sig, freqMod1, freqMod2, freqMod3, syncTrig, phase, freq;
		var totalModIn = InFeedback.ar(~totalModIn.index, 1);
		var fmIn = InFeedback.ar(~fmIn.index, 1);
		var osc1Mod = InFeedback.ar(~osc2ModIn.index, 1);
		var cv = InFeedback.ar(~osc2CVIn.index, 1);

		freq = Shaper.ar(~cvToFreqBuf, cv);

		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		freqMod3 = exp(osc1Mod * \osc1ModKnob.kr(0,0.18) * 4);
		freq = freq * freqMod1* freqMod2 * freqMod3;

		//pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;

		//sync trigger
		syncTrig = Schmidt.ar(osc1Mod, -0.01, 0.01);
		syncTrig = Trig1.ar(syncTrig, 0.001);
		phase = Phasor.ar(syncTrig, freq * 2pi / SampleRate.ir, 0, 2pi);

		sig = SinOsc.ar(0, phase);
		sig = sig * exp(PinkNoise.ar(0.025));

		Out.ar(~osc2Out, sig)
	}
	).add;


	SynthDef(\osc2SinAM, {
		var sig, freqMod1, freqMod2, ampMod, freq;
		var totalModIn = InFeedback.ar(~totalModIn.index, 1);
		var fmIn = InFeedback.ar(~fmIn.index, 1);
		var osc1Mod = InFeedback.ar(~osc2ModIn.index, 1);
		var cv = InFeedback.ar(~osc2CVIn.index, 1);

		freq = Shaper.ar(~cvToFreqBuf, cv);

		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		ampMod = exp(osc1Mod * \osc1ModKnob.kr(0,0.18) * 2);
		freq = freq * freqMod1* freqMod2;

		//pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;
		sig = SinOsc.ar(freq) * ampMod;
		sig = (sig * 0.3).tanh;
		sig = sig * 3;

		Out.ar(~osc2Out, sig)
	}
	).add;

	SynthDef(\osc2SqrAM, {
		var sig, freqMod1, freqMod2, ampMod, freq;
		var totalModIn = InFeedback.ar(~totalModIn.index, 1);
		var fmIn = InFeedback.ar(~fmIn.index, 1);
		var osc1Mod = InFeedback.ar(~osc2ModIn.index, 1);
		var cv = InFeedback.ar(~osc2CVIn.index, 1);


		freq = Shaper.ar(~cvToFreqBuf, cv);

		freqMod1 = exp(totalModIn * \freqModKnob1.kr(0, 0.18));
		freqMod2 = exp(fmIn * \freqModKnob2.kr(0, 0.18));
		ampMod = exp(osc1Mod * \osc1ModKnob.kr(0,0.18) * 2);
		freq = freq * freqMod1* freqMod2;

		//pitch knob
		freq = \pitch.kr(0.5, 0.18) * freq;
		sig = Pulse.ar(freq) * ampMod;
		sig = LPF.ar(Clip.ar(sig, -1, 1), 12000);

		Out.ar(~osc2Out, sig)
	}	).add;

	SynthDef(\audioPatch, { |from, to|
		var sig = In.ar(from, 1);
		Out.ar(to, sig);
	}).add;

	SynthDef(\audioPatchStereo, { |from, to|
		var sig = In.ar(from, 2);
		Out.ar(to, sig);
	}).add;

	SynthDef(\magicMixer, {
		var input1, input2, sig;
		input1 = In.ar(~osc1In, 1);
		input2 = In.ar(~osc2Out, 1);

		input1 = LeakDC.ar(input1);

		sig = (input1 * \input1Level.kr(1, 0.18)) + (input2 * \input2Level.kr(0, 0.18));
		Out.ar(~mixerOut, sig);
	}).add;

	SynthDef(\hpf, {
		var hpfMod1, hpfMod2, hpfCutoffFinal;
		var sig = In.ar(~hpfIn, 1);
		var totalModIn = In.ar(~totalModIn.index, 1);
		var cutoffIn = In.ar(~hpfCutoffIn, 1);
		var resonance = In.kr(~hpfResonance, 1);
		var character = 42 ** (resonance / 4) * 0.117;
		var bpfRes = (-0.225 * resonance) + 1;
		var filtered;
		var pole, low, peak;

		hpfMod1 = exp(totalModIn * \knob1.kr(0, 0.18) * 8);
		hpfMod2 = exp(cutoffIn * \knob2.kr(0, 0.18) * 8);
		hpfCutoffFinal = (\cutoff.kr(20, 0.18) * hpfMod2 * hpfMod1).clip(20,20000);


		sig = sig / 2;
		pole = exp((-2pi) * hpfCutoffFinal / SampleRate.ir);
		low = OnePole.ar(sig, pole);
		sig = sig - low;

		peak = Shaper.ar(~heatBuf,
			(character * BPF.ar(sig, hpfCutoffFinal, bpfRes)) / ~heatScale);
		peak = (peak / character) * resonance;

		sig = sig + peak;

		sig = sig * 2;

		Out.ar(~hpfOut, sig);
	}).add;


	SynthDef(\lpf, {
		var lpfMod1, lpfMod2, lpfCutoffFinal;

		var sig = In.ar(~hpfOut, 1);
		var totalModIn = In.ar(~totalModIn.index, 1);
		var cutoffIn = In.ar(~lpfCutoffIn, 1);
		var resonance = \resonance.kr(0);
		var bpfRes = (-0.225 * resonance) + 1;
		var character = 42 ** (resonance / 4) * 0.117;
		var peak, alpha;

		lpfMod1 = exp(totalModIn * \knob1.kr(0, 0.18) * 8);
		lpfMod2 = exp(cutoffIn * \knob2.kr(0, 0.18) * 8);
		lpfCutoffFinal = (\cutoff.kr(20000, 0.18) * lpfMod2 * lpfMod1).clip(20,20000);

		alpha = (2pi * lpfCutoffFinal / SampleRate.ir).clip(0.0001, 1);

		peak = LeakDC.ar(Shaper.ar(~heatBuf, (character * BPF.ar(sig, lpfCutoffFinal, bpfRes)) / ~heatScale));
		peak = (peak / character) * resonance;

		sig = OnePole.ar(sig, 1 - alpha);
		sig = OnePole.ar(sig, 1 - alpha);
		sig = sig + peak;

		Out.ar(~lpfOut, sig);
	}).add;

	SynthDef(\characterVCA, {
		var sig;
		var input = In.ar(~lpfOut, 1);
		var control = In.ar(~amIn, 1);
		var amp = In.kr(~ampKr, 1);

		amp = amp * 0.8;
		control = control.clip(0,1);
		sig = input * amp * control;
		sig = LeakDC.ar(sig);

		Out.ar(~normalVCAOut, sig);
	}).add;

	SynthDef(\panelVCA, {
		var sig;
		var input = InFeedback.ar(~vcaIn, 1);
		var control = InFeedback.ar(~vcaCtrlIn, 1);

		control = control.clip(-1,1);
		sig = input * control;

		Out.ar(~vcaOut, sig);
	}).add;

	SynthDef(\panelVCAUnipolar, {
		var sig;
		var input = InFeedback.ar(~vcaIn, 1);
		var control = InFeedback.ar(~vcaCtrlIn, 1);

		control = (control / 2) + DC.ar(0.5);
		sig = input * control;

		Out.ar(~vcaOut, sig);
	}).add;

	SynthDef(\TapeDelay, {
		arg out=0, mix=1, feedback=0.4, wowRate=0.5, wowDepth=0.02, clockDiv = 1;
		var input, input2, wet, delayedSignal, wowLFO, wowLFOR, delayTime, amp;
		var randomRate, randomRateR, customDiv, modulation;

		input = In.ar(~normalVCAOut, 1);
		input2 = In.ar(~drumFXIn, 1);
		delayTime = In.kr(~clockTempoOut, 1);
		amp = In.kr(~delayAmt, 1);
		customDiv = In.kr(~tapeDivOut, 1);
		modulation = LinExp.ar(InFeedback.ar(~fxTimeIn, 1), -1, 1, 0.5, 2);
		amp = (amp + 1) / 2;
		delayTime = 0.75 * delayTime * modulation * customDiv / clockDiv;
		delayTime = Lag.ar(delayTime, 0.5);

		randomRate = Latch.kr(LFNoise1.kr(0.1).range(0.9, 1.1), Impulse.kr(1));
		randomRateR = Latch.kr(LFNoise1.kr(0.1).range(0.9, 1.1), Impulse.kr(1));
		wowLFO = SinOsc.kr(wowRate * randomRate) * wowDepth;
		wowLFOR = SinOsc.kr(wowRate * randomRateR) * wowDepth;

		delayedSignal = DelayL.ar(
			input + input2 + (LocalIn.ar(2) * feedback),
			1.0,
			[delayTime * (1 + wowLFO),delayTime * (1 + wowLFOR)]
		);

		delayedSignal = LPF.ar(delayedSignal, 3500);
		delayedSignal = HPF.ar(delayedSignal, 120);
		delayedSignal = LeakDC.ar(delayedSignal);
		LocalOut.ar(delayedSignal);

		wet = (input * (1 - mix)) + (delayedSignal * mix);

		Out.ar(~delayOut, wet * amp);
	}).add;

	SynthDef(\drumSampler, {|buf, amp = 1, duration = 1|
		var sig, env;
		var tempo = In.kr(~clockTempoOut, 1);
		var tempoMult = In.kr(~drumClockDiv, 1);
		var durationCalc = tempo / tempoMult *duration * 0.20;
		var trig = Trig1.kr(\gate.kr(0).roundUp(1), durationCalc);

		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf),
			trigger: trig,
			startPos: 0,
			loop: 0
		);
		env = EnvGen.kr(envelope: Env.asr(0.001, 1, 0.05), gate: trig);
		sig = sig * 5.5 * env * amp;

		Out.ar(~drumOut, sig);
	}).add;

	SynthDef(\kickSampler, {|buf, amp = 1, duration = 1|
		var sig, env;
		var tempo = In.kr(~clockTempoOut, 1);
		var tempoMult = In.kr(~drumClockDiv, 1);
		var durationCalc = tempo / tempoMult *duration * 0.19;
		var trig = Trig1.kr(\gate.kr(0).roundUp(1), durationCalc);


		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf),
			trigger: trig,
			startPos: 0,
			loop: 0
		);
		env = EnvGen.kr(envelope: Env.asr(0.001, 1, 0.03), gate: trig);
		sig = sig * 5.5 * env * amp;

		Out.ar(~drumOut, sig);
		Out.ar(~kickOut, sig);
	}).add;

	SynthDef(\snareSampler, {|buf, amp = 1, duration = 1, fx = 0|
		var sig, env;
		var tempo = In.kr(~clockTempoOut, 1);
		var tempoMult = In.kr(~drumClockDiv, 1);
		var durationCalc = tempo / tempoMult *duration * 0.20;
		var trig = Trig1.kr(\gate.kr(0).roundUp(1), durationCalc);

		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf),
			trigger: trig,
			startPos: 0,
			loop: 0
		);
		env = EnvGen.kr(envelope: Env.asr(0.001, 1, 0.05), gate: trig);
		sig = sig * 2.25 * env * amp;

		Out.ar(~drumOut, sig);
		Out.ar(~drumFXOut, sig * fx * 0.25);
	}).add;

	SynthDef(\hatSampler, {|buf, amp = 1, duration = 1, curve = -4|
		var sig, env;
		var tempo = In.kr(~clockTempoOut, 1);
		var tempoMult = In.kr(~drumClockDiv, 1);
		var durationCalc = tempo / tempoMult *duration * 0.20;
		var trig = Trig1.kr(\gate.kr(0).roundUp(1), durationCalc);

		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf),
			trigger: trig,
			startPos: rrand(0, 100),
			loop: 0
		);
		env = EnvGen.kr(envelope: Env.perc(0.001, durationCalc, 1, curve), gate: trig);
		sig = sig * 3.5 * env * amp;

		Out.ar(~drumOut, sig);
	}).add;

	SynthDef(\openHatSampler, {|buf, amp = 1, duration = 1, curve = -4|
		var sig, env;
		var tempo = In.kr(~clockTempoOut, 1);
		var tempoMult = In.kr(~drumClockDiv, 1);
		var durationCalc = tempo / tempoMult *duration * 0.20;
		var trig = Trig1.kr(\gate.kr(0).roundUp(1), durationCalc);

		sig = PlayBuf.ar(numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf),
			trigger: trig,
			startPos: rrand(0, 100),
			loop: 0
		);
		env = EnvGen.kr(envelope: Env.perc(0.001, 5, 1, curve), gate: trig);
		sig = sig * 3.5 * env * amp;

		Out.ar(~drumOut, sig);
	}).add;

	SynthDef(\rumble, {
		var sig = LPF.ar([BrownNoise.ar(), BrownNoise.ar()], 50) * 0.33;
		sig = 0;
		Out.ar(~rumbleOut, sig);
	}).add;

	SynthDef(\compressor, {
		var input = In.ar(~normalVCAOut, 1);
		var rumble = In.ar(~rumbleIn, 2);
		var sidechain = In.ar(~compressorSidechainIn, 1);
		var sig;

		input = input ! 2;
		sig = input + rumble;
		sig = Compander.ar(
			in: sig,
			control: sidechain * 0.68,
			thresh: 0.3,
			slopeBelow: 1,
			slopeAbove: 0.1,
			clampTime: 0.03,
			relaxTime: 0.05,
			mul: 1
		);

		Out.ar(~compressorOut,sig);
	}).add;

	SynthDef(\outputMixer, {
		var normalIn = In.ar(~compressorOut, 2);
		var extIn = In.ar(~extIn, 1);
		var fxIn = In.ar(~delayOut, 2);
		var extLPFCutoff = LagIn.kr(~extLPFCutoff, 1, 0.18);
		var extHPFCutoff = LagIn.kr(~extHPFCutoff, 1, 0.18);
		var normalLevel = LagIn.kr(~normalLevel, 1);
		var sig;
		var rate = 0.5;
		var depth = 0.006;
		var baseDelay = 0.006;
		var chorusIn;
		var lfo1L, lfo2L, lfo1R, lfo2R;
		var del1L, del2L, del1R, del2R;
		var wetL, wetR;
		var mixWet;
		var filteredExtIn = RLPF.ar(BLowShelf.ar(extIn, 100, 1, extHPFCutoff), extLPFCutoff, 0.4) * 4;

		normalIn = normalIn * normalLevel;
		chorusIn = normalIn + ((filteredExtIn ! 2) / 8);

		lfo1L = LFTri.kr(rate, 0, depth, baseDelay);
		lfo2L = LFTri.kr((rate * 1.05), 0, depth, baseDelay);
		lfo1R = LFTri.kr(rate, 2, depth, baseDelay);
		lfo2R = LFTri.kr((rate * 1.05), 2, depth, baseDelay);

		del1L = DelayC.ar(chorusIn[0], (baseDelay + depth), lfo1L);
		del2L = DelayC.ar(chorusIn[0], (baseDelay + depth), lfo2L);
		del1R = DelayC.ar(chorusIn[1], (baseDelay + depth), lfo1R);
		del2R = DelayC.ar(chorusIn[1], (baseDelay + depth), lfo2R);

		wetL = (del1L + del2L) * 0.5;
		wetR = (del1R + del2R) * 0.5;
		mixWet = [wetL, wetR];

		sig = XFade2.ar(chorusIn, mixWet, -0.9) + fxIn;
		sig = sig * 0.3;

		Out.ar(~postFX, sig);
	}).add;

	// PostFX

	SynthDef(\clean, {|amp = 1|
		var sig = In.ar(~postFX, 2);
		var masterVolume = In.kr(~outputVolume, 1);

		sig = sig * amp * masterVolume;

		Out.ar(0, sig);
	}).add;

	SynthDef(\tape, {|amp = 1|
		// unfinished, needs total overhaul
		var sig = In.ar(~postFX, 2);
		var masterVolume = In.kr(~outputVolume, 1);
		var rates = PinkNoise.kr(0.05) + DC.kr(0.166);
		var lfo = LFTri.kr(rates, mul: 2) + LFTri.kr(10, mul: 2) + DC.kr(1);

		sig = sig * amp;
		sig = FreqShift.ar(sig, lfo);
		sig = HPF.ar(sig, 80);
		sig = LPF.ar(sig, 12000);
		sig = sig = Shaper.ar(~heatBuf,  sig / ~heatScale);
		//sig = (sig * 1).tanh;
		/*
		sig = Compander.ar(
		in: sig,
		control: sig,
		thresh: 0.05,
		slopeBelow: 1,
		slopeAbove: 0.25,
		clampTime: 0.0008,
		relaxTime: 0.05,
		mul: 1.5);
		*/
		sig = sig * masterVolume;

		Out.ar(0, sig);

	}).add;

	SynthDef(\fuzz, {|amp = 1|
		var sig, fuzzed, input1, input2;
		var outLevel = 0.5;
		var biasSetting = 0.15;
		var in = In.ar(~postFX, 2);
		var fuzzAmt = 0.3;
		var masterVolume = In.kr(~outputVolume, 1);
		var gain = 0.9;

		// simulate capacitor at input
		sig = in * gain;
		sig = HPF.ar(sig, 80);
		sig = sig * exp(\fmOsc.ar() * 0.3);

		// first stage
		fuzzed = (sig * (15 * fuzzAmt + 1)) + (biasSetting * fuzzAmt);
		fuzzed = fuzzed.tanh;

		fuzzed = LPF.ar(fuzzed, 7000 - (fuzzAmt * 2000));

		// second stage
		fuzzed = (fuzzed * (5 * fuzzAmt + 1)) + (biasSetting * fuzzAmt * 0.5);
		fuzzed = fuzzed.clip2(0.9);

		// output capacitor simulation
		fuzzed = LeakDC.ar(fuzzed);
		fuzzed = fuzzed * outLevel;
		sig = fuzzed * gain * masterVolume;

		Out.ar(0, sig);
	}).add;

	SynthDef(\wavefolder, {
		arg amp=3, smoothness=0.1;
		var sig, index, folded;

		sig = In.ar(~mixerOut) * amp;
		folded = Shaper.ar(~wavefolderBuf, sig / ~wavefolderScale);

		Out.ar(~hpfIn, folded * 12);
	}).add;

	SynthDef(\modWheel, {
		var sig;
		var input = In.kr(~modWheelIn);

		sig = K2A.ar(input);
		sig = Lag.ar(sig, 0.18);

		Out.ar(~modWheelOut, sig);
	}).add;

	SynthDef(\k2a, {|in, out|
		var sig;
		var input = In.kr(in);

		sig = K2A.ar(input);

		Out.ar(out, sig);
	}).add;

	SynthDef(\a2k, {|in, out|
		var sig;
		var input = InFeedback.ar(in);

		sig = A2K.kr(input);

		Out.kr(out, sig);
	}).add;

	SynthDef(\dc, {|offset = 1, out|
		var sig = DC.ar(offset);

		Out.ar(out, sig);
	}).add;

	SynthDef(\noise, {
		var sig = PinkNoise.ar() * 3;

		sig.clip(-1,1);

		Out.ar(~noiseOut, sig);
	}).add;

	SynthDef(\sampleAndHold, {
		var input = InFeedback.ar(~shIn);
		var clock = InFeedback.ar(~shClockIn);
		var sig, slew = 0.005;

		sig = Latch.ar(input, clock);
		sig = Lag.ar(sig, slew);

		Out.ar(~shOut, sig);
	}).add;

	s.sync;

	ServerTree.add(~createNodes);
	ServerTree.run;
});

)