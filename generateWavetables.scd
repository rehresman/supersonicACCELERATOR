/*

maybe you want to generate your own wavetables instead of using samples.

this is a utility for generating continuous single-cycle wavetables from multi-cycle audio files.

it will interpolate aliasing sections of the waveform (like discontinuities or ripples) using cubic splines.

just set the filename to what you want to convert to a wavetable and run the big code block.
*/

// you can also test it with the code below

w = Synth(\originalWavetable);
w.set(\freq, ~testFreq);
w.free;

x = Synth(\antialiasedWavetable);
x.set(\freq, ~testFreq);
x.free;

~testFreq = 150;

// 1. Load your multi-cycle file
(
GUI.window.closeAll;
~sampleRate = 44100;
~maxFreq = 100;
~aliasThreshold = 0.5; // 0.5 is Nyquist
~filename = "triTube.wav";
~srcPath = PathName.new(thisProcess.nowExecutingPath).parentPath +/+ "samples";
~cycleStart;
~cycleLength;
~testFreq = 50;


~getAliasingSlopeGroups = { |inputWaveTable, sampleRate = 44100, maxFreq = 150, threshold = 0.5|
    var wavetableSize, aliasPoint, maxSlope;
    var aliasingPoints, aliasingGroups, currentGroup;
    var aliasingMask, aliasingMaskBuffer, results;
    var hasWraparound, processedGroups;
    var i, j, firstGroupStartIndex, lastGroupEndIndex;
    var currentGroupToProcess, foundWrapTarget, candidateGroup, mergedGroup;

    // Initialize collections
    aliasingPoints = Array.new;
    aliasingGroups = Array.new;
    currentGroup = nil;

    inputWaveTable.loadToFloatArray(action: { |wavetableData|
        // Get wavetable size
        wavetableSize = wavetableData.size;
        // Calculate Nyquist frequency
        aliasPoint = (sampleRate * threshold);
        // Calculate the maximum allowable slope based on maxFreq
        maxSlope = (pi * (aliasPoint - maxFreq) / wavetableSize);
        // Create aliasing mask (all zeros initially)
        aliasingMask = Array.fill(wavetableSize, 0);

        // Scan through wavetable to find aliasing points
        (wavetableSize-1).do({ |i|
            var slope, nextIndex, nextValue;

            // Calculate slope (change in amplitude per sample)
            nextIndex = ((i + 1) % wavetableSize);  // Wrap around at the end
            nextValue = wavetableData[nextIndex];
            slope = (((nextValue - wavetableData[i]) * maxFreq).abs);

            // Check if slope exceeds the threshold
            if(slope > maxSlope) {
                // Mark this point as causing aliasing
                aliasingPoints = aliasingPoints.add(i);
                // Set mask to 1 at this position
                aliasingMask[i] = 1;

                // Update or create aliasing groups
                if(currentGroup.isNil) {
                    // Start a new group
                    currentGroup = [i];
                } {
                    // Check if this point is contiguous with current group
                    if((i - currentGroup.last) == 1) {
                        // Add to current group
                        currentGroup = currentGroup.add(i);
                    } {
                        // Finish the current group and start a new one
                        aliasingGroups = aliasingGroups.add(currentGroup);
                        currentGroup = [i];
                    };
                };
            };
        });

        // Add the last group if it exists
        if((currentGroup.notNil) && (currentGroup.size > 0)) {
            aliasingGroups = aliasingGroups.add(currentGroup);
        };

        // Check for wrap-around cases - only if we have at least one group
        if(aliasingGroups.size > 0) {
            // Create a new Array to track which groups we've processed
            var processedIndices = Array.fill(aliasingGroups.size, false);
            hasWraparound = false;

            // First check for simple case: last element to first element
            if(aliasingGroups.size > 1) {
                // Get indices of interest
                firstGroupStartIndex = aliasingGroups[0][0];
                lastGroupEndIndex = aliasingGroups[(aliasingGroups.size - 1)].last;

                // Check if we have a group that ends at the last index and another that starts at first index
                if((lastGroupEndIndex == (wavetableSize - 1)) && (firstGroupStartIndex == 0)) {
                    // We have a wrap-around situation
                    var lastGroup, firstGroup;

                    lastGroup = aliasingGroups.pop;  // Remove last group
                    firstGroup = aliasingGroups.removeAt(0);  // Remove first group
                    mergedGroup = (lastGroup ++ firstGroup);  // Merge them
                    aliasingGroups = aliasingGroups.add(mergedGroup);  // Add merged group
                    hasWraparound = true;
                };
            };

            // Now check for more complex wrap-around cases if we didn't already find a simple one
            if((hasWraparound.not) && (aliasingGroups.size > 1)) {
                i = 0;
                processedGroups = Array.new;

                // Create a new array where we'll mark which groups we've processed
                processedIndices = Array.fill(aliasingGroups.size, false);

                while({ i < aliasingGroups.size }) {
                    // Skip if this group has already been processed
                    if(processedIndices[i].not) {
                        currentGroupToProcess = aliasingGroups[i];

                        // Check if this group ends at the wavetable boundary
                        if((currentGroupToProcess.notNil) && (currentGroupToProcess.size > 0) && (currentGroupToProcess.last == (wavetableSize - 1))) {
                            // Look through remaining groups to find one that starts at index 0
                            foundWrapTarget = false;
                            j = 0;

                            while({ (j < aliasingGroups.size) && (foundWrapTarget.not) }) {
                                // Skip the current group and any previously processed groups
                                if((j != i) && (processedIndices[j].not)) {
                                    candidateGroup = aliasingGroups[j];

                                    // Check if this group starts at index 0
                                    if((candidateGroup.notNil) && (candidateGroup.size > 0) && (candidateGroup[0] == 0)) {
                                        // We found a wrap-around pair
                                        mergedGroup = (currentGroupToProcess ++ candidateGroup);
                                        processedGroups = processedGroups.add(mergedGroup);
                                        foundWrapTarget = true;

                                        // Mark both groups as processed
                                        processedIndices[i] = true;
                                        processedIndices[j] = true;
                                    };
                                };

                                j = (j + 1);
                            };

                            // If we didn't find a wrap target, just add the current group
                            if(foundWrapTarget.not) {
                                if(currentGroupToProcess.notNil) {
                                    processedGroups = processedGroups.add(currentGroupToProcess);
                                    processedIndices[i] = true;
                                };
                            };
                        } {
                            // This group doesn't end at the boundary, just add it if not nil
                            if(currentGroupToProcess.notNil) {
                                processedGroups = processedGroups.add(currentGroupToProcess);
                                processedIndices[i] = true;
                            };
                        };
                    };

                    i = (i + 1);
                };

                // No need to add the groups again, as we've already processed them all
                // We just need to replace the original groups with the processed ones
                aliasingGroups = processedGroups;
            };
        };

        // Use defer for GUI operations
        {
            // Plot aliasing mask data
            aliasingMask.plot(
                name: "Aliasing Mask (1 = aliasing region)",
                bounds: Rect(0, 300, 1000, 500)
            );
        }.defer;

        // Print information about aliasing
        ("Number of aliasing points: " ++ aliasingPoints.size).postln;
        ("Number of aliasing groups: " ++ aliasingGroups.size).postln;
        // Print the aliasing groups for detailed inspection
        "Aliasing Groups:".postln;
        aliasingGroups.do({ |group, i|
            ("Group " ++ (i) ++ ": " ++ group).postln;
        });

        // Create a server-side Buffer with the aliasing mask for visualization
        aliasingMaskBuffer = Buffer.loadCollection(Server.default, aliasingMask);
        results = (
            \originalWavetable: inputWaveTable,
            \aliasingMask: aliasingMaskBuffer,
            \aliasingMaskArray: aliasingMask,
            \numAliasingPoints: aliasingPoints.size,
            \numAliasingGroups: aliasingGroups.size,
            \aliasingGroups: aliasingGroups
        );
    });

    results;
};

~getAliasingRippleGroups = {
    arg inputWaveTable, sampleRate = 44100, maxFreq, threshold = 0.5;

    var array;
    var bufferLength;
    var aliasingMask;
    var aliasingGroups;
    var slopes;
    var slopeSignChanges;
    var currentGroup;
    var i, j;

    inputWaveTable.loadToFloatArray(action: {
        arg loadedArray;

        array = loadedArray;
        bufferLength = array.size;
        aliasingMask = Array.fill(bufferLength, 0);
        aliasingGroups = List.new;
        slopes = Array.newClear(bufferLength);
        slopeSignChanges = List.new;

        // Calculate slopes
        (0..(bufferLength-2)).do({
            arg i;
            slopes[i] = array[i+1] - array[i];
        });

        // Handle last element by comparing with the first (circular buffer)
        slopes[bufferLength-1] = array[0] - array[bufferLength-1];

        // Find sign changes in slope
        (0..(bufferLength-1)).do({
            arg i;
            var nextIndex = (i + 1) % bufferLength;

            if (
                ((slopes[i] > 0) && (slopes[nextIndex] <= 0)) ||
                ((slopes[i] <= 0) && (slopes[nextIndex] > 0))
            ) {
                slopeSignChanges.add(nextIndex);
            };
        });

        // Process pairs of sign changes to detect aliasing ripples
        if ((slopeSignChanges.size) > 1) {
            (0..(slopeSignChanges.size - 1)).do({
                arg i;
                var current = slopeSignChanges[i];
                var next;
                var distance;
                var frequency;

                if (i == (slopeSignChanges.size - 1)) {
                    // Compare last change with first (circular buffer)
                    next = slopeSignChanges[0];
                    distance = (bufferLength + next - current) % bufferLength;
                } {
                    next = slopeSignChanges[i+1];
                    distance = (next - current) % bufferLength;
                };

                // Convert distance to frequency
                frequency = (maxFreq * bufferLength) / distance;

                // Check if ripple will alias
                if (frequency > (sampleRate * threshold)) {
                    // Mark aliasing samples in the mask
                    if (next > current) {
                        (current..next).do({ arg j; aliasingMask[j] = 1; });
                    } {
                        // Handle wrap-around case
                        (current..(bufferLength-1)).do({ arg j; aliasingMask[j] = 1; });
                        (0..next).do({ arg j; aliasingMask[j] = 1; });
                    };
                };
            });
        };

        // Group contiguous aliasing regions
        currentGroup = List.new;
        i = 0;

        while { i < bufferLength } {
            if (aliasingMask[i] == 1) {
                currentGroup.add(i);
            } {
                if (currentGroup.size > 0) {
                    aliasingGroups.add(currentGroup.copy);
                    currentGroup = List.new;
                };
            };
            i = i + 1;
        };

        // Check if we need to add the last group
        if (currentGroup.size > 0) {
            aliasingGroups.add(currentGroup.copy);
        };

        // Handle wrap-around case for groups
        if (
            (aliasingGroups.size >= 2) &&
            (aliasingMask[bufferLength-1] == 1) &&
            (aliasingMask[0] == 1)
        ) {
            var firstGroup = aliasingGroups[0];
            var lastGroup = aliasingGroups[aliasingGroups.size-1];

            // Merge first and last groups
            aliasingGroups.removeAt(aliasingGroups.size-1);
            aliasingGroups.removeAt(0);
            aliasingGroups.add(lastGroup.addAll(firstGroup));
        };

        // Plot the aliasing mask
        aliasingMask.plot("Aliasing Ripple Mask", minval: 0, maxval: 1, bounds: Rect(0, 300, 1000, 500));

        ("Found " ++ aliasingGroups.size ++ " aliasing groups").postln;
        aliasingGroups.do({ arg group, i;
            ("Group " ++ i ++ ": " ++ group).postln;
        });

        aliasingGroups = aliasingGroups.asArray;
    });

    // Return aliasing groups
	(aliasingGroups: aliasingGroups);
};

~findCycles = { |buffer|
    buffer.loadToFloatArray(action: { |array|
        var zeroCrossings = [], cycleLengths = [], bestCycleStart = 0, bestCycleLength = 0, medianLength, cycleLength;

        // Find all positive-going zero crossings (where waveform goes from negative to positive)
        (1..(array.size-1)).do({ |i|
			if((array[i-1] < 0 and: {array[i] >= 0}), {
                zeroCrossings = zeroCrossings.add(i);
            });
        });

        // Calculate lengths between consecutive zero crossings
        if(zeroCrossings.size > 1, {
            (1..(zeroCrossings.size-1)).do({ |i|
                cycleLengths = cycleLengths.add(zeroCrossings[i] - zeroCrossings[i-1]);
            });

            // Find the median cycle length
            cycleLengths = cycleLengths.sort;
            medianLength = cycleLengths[cycleLengths.size.div(2)];

            // Find a cycle close to the median length
            (1..(zeroCrossings.size-1)).do({ |i|
                cycleLength = zeroCrossings[i] - zeroCrossings[i-1];
                if(abs(cycleLength - medianLength) < abs(bestCycleLength - medianLength), {
                    bestCycleStart = zeroCrossings[i-1];
                    bestCycleLength = cycleLength;
                });
            });

            // Log what we found
            "Found cycle at sample: ".post; bestCycleStart.postln;
            "Cycle length: ".post; bestCycleLength.postln;
            "Estimated frequency: ".post; (buffer.server.sampleRate / bestCycleLength).postln;

            // Return the findings
			~cycleStart = bestCycleStart;
			~cycleLength = bestCycleLength;
            [bestCycleStart, bestCycleLength];
        }, {
            "Not enough zero crossings found.".postln;
            [0, 1024]; // Default fallback
        });
    });
};


~resample = { |buffer, newSize=2048|
		var server = buffer.server;
		// Create a properly sized buffer
		var formattedBuf = Buffer.alloc(server, newSize, 1);

		// Load the source buffer data
		buffer.loadToFloatArray(action: { |array|
			// Resize to the desired length
			var formattedData = Signal.newFrom(array).resamp1(newSize);

			// Send to the new buffer
			formattedBuf.sendCollection(formattedData);

			"Resampled wavetable to size: ".post; newSize.postln;
		});
		formattedBuf;
	};

~getLeftDerivative = {|buffer, index|
	var ddt;
	buffer.loadToFloatArray(action: {|array|
		if(index > 0){
			ddt = array[index] - array[index -1];
		} {
			ddt = array[index] - array[array.size - 1];
		}
	});
	ddt;
};

~getRightDerivative = {|buffer, index|
	var ddt;
	buffer.loadToFloatArray(action: {|array|
		if(index < (array.size - 1)){
			ddt = array[index] - array[index -1];
		} {
			ddt = array[0] - array[index];
		}
	});
	ddt;
};


~cubicSplineInterpolate = { |buffer, startIndex, endIndex, fpo = 0, fpn = 0|
	var n, h, a0, a1, a, b, c, d, t, newBuf, fullArray;

	n = (endIndex - startIndex) % buffer.numFrames;
	n.postln;

	buffer.loadToFloatArray(action: { |array|
		var interpolated;
		fullArray = Array.newFrom(array);

		a0 = array[startIndex];
		a1 = array[endIndex];
		h = (endIndex - startIndex) % array.size;

		// Coefficients for cubic spline
		a = a0;
		b = fpo;
		c = ((3*(a1 - a0)) - (h*(2*fpo + fpn)))/(h * h);
		d = ((2*(a0 - a1)) + (h*(fpo + fpn)))/(h * h * h);

		// Fill interpolated values
		interpolated = Array.fill((n + 1), { |i|
			t = i % array.size; // unnormalized step (assumes unit spacing)
			a + (b * t) + (c * (t * t)) + (d * (t * t * t));
		});

		// Replace the segment
		interpolated.do { |val, i|
			fullArray[((startIndex + i) % array.size)] = val;
		};

		//interpolated.plot();
		// Allocate new buffer and fill it
		newBuf = Buffer.alloc(s, fullArray.size, 1);
		s.sync;
		newBuf.sendCollection(fullArray);
	});
	newBuf;
};

~getAliasingAccelerationGroups = {
    arg inputWaveTable, sampleRate = 44100, maxFreq, threshold = 0.5;

    var array;
    var bufferLength;
    var aliasingMask;
    var aliasingGroups;
    var firstDerivatives;
    var secondDerivatives;
    var aliasFreq;
    var constraintValue;
    var currentGroup;
    var i;

    inputWaveTable.loadToFloatArray(action: {
        arg loadedArray;
		var sumTerm, nTerms;

        array = loadedArray;
        bufferLength = array.size;
        aliasingMask = Array.fill(bufferLength, 0);
        aliasingGroups = List.new;
        firstDerivatives = Array.newClear(bufferLength);
        secondDerivatives = Array.newClear(bufferLength);

        // Calculate first derivatives (slopes)
        (0..(bufferLength-1)).do({
            arg i;
            var nextIndex = (i + 1) % bufferLength;
            firstDerivatives[i] = array[nextIndex] - array[i];
        });

        // Calculate second derivatives (acceleration)
        (0..(bufferLength-1)).do({
            arg i;
            var prevIndex = (i - 1 + bufferLength) % bufferLength;
            var nextIndex = (i + 1) % bufferLength;

            // Left slope rate of change
            var leftSlopeChange = firstDerivatives[i] - firstDerivatives[prevIndex];

            // Right slope rate of change
            var rightSlopeChange = firstDerivatives[nextIndex] - firstDerivatives[i];

            // Second derivative as rate of change between slopes
            secondDerivatives[i] = (rightSlopeChange - leftSlopeChange) * 0.5;
        });

		~maxx = 0;
		~indexx;
		secondDerivatives.do({|item, i|
			if (item > ~maxx){
				~maxx = item;
				~indexx = i;
			};
		});
		("Maximum second derivative: " ++ ~maxx ++ "at index " ++ ~indexx).postln;
        // Calculate aliasing frequency and constraint value
        aliasFreq = sampleRate * threshold;

        // Calculate the constraint value based on the formula
        // (2*pi*maxFreq)^2 * sum(0, ((aliasFreq/ 2*maxFreq) - 1 /2), (2n+1))
        constraintValue = ((2 * pi * maxFreq / bufferLength) * (2 * pi * maxFreq / bufferLength));

        // Calculate the sum term
        sumTerm = 0;
		nTerms = (((aliasFreq / (2 * maxFreq)) - 0.5)).floor.asInteger;
		("nTerms: " ++ nTerms).postln;
            (0..nTerms).do({
                arg n;
                sumTerm = sumTerm + (2 * n + 1);
            });


		("sumTerm: " ++ sumTerm).postln;
        constraintValue = constraintValue * sumTerm;
		("CONSTRAINT: " ++ constraintValue).postln;

        // Identify aliasing regions based on second derivative
        (0..(bufferLength-1)).do({
            arg i;
            if (secondDerivatives[i].abs > constraintValue) {
                aliasingMask[i] = 1;
            };
        });

        // Group contiguous aliasing regions
        currentGroup = List.new;
        i = 0;

        while { i < bufferLength } {
            if (aliasingMask[i] == 1) {
                currentGroup.add(i);
            } {
                if (currentGroup.size > 0) {
                    aliasingGroups.add(currentGroup.copy);
                    currentGroup = List.new;
                };
            };
            i = i + 1;
        };

        // Check if we need to add the last group
        if (currentGroup.size > 0) {
            aliasingGroups.add(currentGroup.copy);
        };

        // Handle wrap-around case for groups
        if (
            (aliasingGroups.size >= 2) &&
            (aliasingMask[bufferLength-1] == 1) &&
            (aliasingMask[0] == 1)
        ) {
            var firstGroup = aliasingGroups[0];
            var lastGroup = aliasingGroups[aliasingGroups.size-1];

            // Merge first and last groups
            aliasingGroups.removeAt(aliasingGroups.size-1);
            aliasingGroups.removeAt(0);
            aliasingGroups.add(lastGroup.addAll(firstGroup));
        };

        // Plot the aliasing mask
        aliasingMask.plot("Aliasing Mask (Acceleration Method)", minval: 0, maxval: 1);

        ("Found " ++ aliasingGroups.size ++ " aliasing groups (acceleration method)").postln;
        aliasingGroups.do({ arg group, i;
            ("Group " ++ i ++ ": " ++ group).postln;
        });

        aliasingGroups = aliasingGroups.asArray;
    });

    // Return aliasing groups
    (aliasingGroups: aliasingGroups);
};



~saveWavetableToFile = { |buffer, fileName|
    var path = ~srcPath +/+ fileName;
    buffer.write(path, "wav", "float");
    "Saved wavetable to: ".post; path.postln;
};


s.waitForBoot({
	var cycleStart, cycleLength, tableSize;
	s.sync;
	~rawBuf = Buffer.read(s, ~srcPath +/+ ~filename);
	s.sync;
	~findCycles.(~rawBuf);
	s.sync;
	//create wavetable
	cycleStart = ~cycleStart;
	cycleLength = ~cycleLength;

	// Round up to nearest power of two
	tableSize = 2.pow(ceil(log2(cycleLength))).asInteger;
	// Create buffer and copy the data
	~cycleBuf = Buffer.alloc(s, cycleLength, 1);
	s.sync;
	~rawBuf.copyData(~cycleBuf,
		srcStartAt: cycleStart,
		numSamples: cycleLength
	);
	~cycleBuf.plot("pre formatted wavetable", Rect(0,1000,1000,500));

	"Created wavetable with size: ".post; ~cycleBuf.numFrames.postln;

	//respample to an appropriate size
	~formattedBuf = ~resample.(~cycleBuf, tableSize);

	~formattedBuf.normalize(1.0);
	s.sync;



	~formattedBuf.plot("formatted wavetable", Rect(0,1000,1000,500));
	// Try with different values of n (use an even number for best results)
	s.sync;

	~antiAlias = {|buffer findAliasingGroups, sampleRate, maxFreq, threshold|
		var interpolatedBuf, aliasingGroups;
		s.sync;
		aliasingGroups = findAliasingGroups.(
			buffer,
			sampleRate: sampleRate,
			maxFreq: maxFreq,
			threshold: threshold
		).aliasingGroups;
		s.sync;
	interpolatedBuf = buffer;
	while {aliasingGroups.size > 0} {
		//process the first group
		var d1, d2, startPoint, endPoint;
		var aliasingGroup = aliasingGroups[0];
		var numGroups = aliasingGroups.size;
		var startingNumGroups = aliasingGroups.size;
		if (aliasingGroup.size == 1){
			startPoint = (aliasingGroup[0] - 1) % tableSize;
			endPoint = (aliasingGroup[0] + 1) % tableSize;
		} {
			startPoint = aliasingGroup[0];
			endPoint = aliasingGroup[(aliasingGroup.size - 1)];
		};

		//interpolate minimally until the number of groups is reduced
		while {numGroups >= startingNumGroups}{
			s.sync;
			("numGroups: " ++ numGroups).postln;
			("startingNumGroups: " ++ startingNumGroups).postln;
			("startPoint: " ++ startPoint).postln;
			("endPoint: " ++ endPoint).postln;

			//interpolate
			d1 = ~getLeftDerivative.(interpolatedBuf, startPoint);
			d2 = ~getRightDerivative.(interpolatedBuf, endPoint);
			s.sync;
			interpolatedBuf = ~cubicSplineInterpolate.(interpolatedBuf, startPoint, endPoint, d1, d2);

			s.sync;

			//check if group is still aliasing
			aliasingGroups = findAliasingGroups.(
				interpolatedBuf,
				sampleRate: sampleRate,
			maxFreq: maxFreq,
			threshold: threshold
			).aliasingGroups;
			s.sync;
			//grow interpolation range
			startPoint = (startPoint - 1) % tableSize;
			endPoint = (endPoint + 1) % tableSize;
			numGroups = aliasingGroups.size;
			if(numGroups > startingNumGroups) { startingNumGroups = numGroups };
			s.sync;
			interpolatedBuf.plot("interpolated wavetable", Rect(0,1000,1000,500));
		};
		s.sync;
	};
		interpolatedBuf;
	};

	~interpolatedBuf = ~antiAlias.(~formattedBuf, ~getAliasingSlopeGroups, ~sampleRate, ~maxFreq, ~aliasThreshold);
	s.sync;
	~interpolatedBuf = ~antiAlias.(~interpolatedBuf, ~getAliasingRippleGroups, ~sampleRate, ~maxFreq, ~aliasThreshold);
	s.sync;
	/*~interpolatedBuf = ~antiAlias.(~interpolatedBuf, ~getAliasingAccelerationGroups, ~sampleRate, ~maxFreq, ~aliasThreshold);*/
	s.sync;
	~interpolatedBuf.plot("interpolated wavetable", Rect(0,1000,1000,500));



	SynthDef(\antialiasedWavetable, { |out=0, freq=440, amp=0.1, pan=0|
		var sig;
		sig = Osc.ar(~interpolatedBuf, freq, 0, amp);
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig);
	}).add;

	SynthDef(\originalWavetable, { |out=0, freq=440, amp=0.1, pan=0|
		var sig;
		sig = Osc.ar(~formattedBuf, freq, 0, amp);
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig);
	}).add;


// Save your wavetable
	~saveWavetableToFile.(~interpolatedBuf, PathName(~filename).fileNameWithoutExtension ++ "_wt.wav");
});


)

~aliasingSlopeGroups.aliasingGroups