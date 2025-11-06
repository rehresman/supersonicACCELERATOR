# supersonicACCELERATOR Paraphonic Semi-Modular Synthesizer and Drum Machine

[![Watch the video](https://img.youtube.com/vi/xkHhoSj9MnE/maxresdefault.jpg)](https://youtu.be/xkHhoSj9MnE)
Watch the [video introduction](https://youtu.be/xkHhoSj9MnE).

This repository contains:
* a SuperCollider-based paraphonic semi-modular synthesizer and drum machine organized as a single file
* a set of audio samples  
* a pdf quickstart guide
* a jpeg labeling all knobs and patch points
* a wavetable generator utility

# Concept

I believe everyone should experience the joy of deep, complex musical improvisation, and I developed the Accelerator to be the fastest route to that goal.  This is not a shortcut machine that does the creative legwork for you, nor is it a restrictor that puts you into a sterile room with guardrails and safety nets.

This is a digital extension of the greatest synthesizer of all time, the Korg MS-20.  What if it had 16 customizable oscillators to choose from?  What if audio-rate modulation was encouraged?  What if a sequencer, effects, and percussive accompaniment were integrated from the start, and you could record a studio-quality mix at the moment of creation?

Of course with the breadth of digital tools also comes new limitations.  Rather than making a dedicated effort to copy my favorite designs, instead I have tried to follow the more abstract philosophies of Fumio Mieda and Hiroaki Nishijima.  This led to core values of the project like valuing sound aesthetic over clean processing, and adopting a high-speed, hard-driven development cycle.

The included *Harmonic Brownian Motion Sequencer* is a controllable chaos environment that *almost* completely rejects the idea of tonal music and never does the same thing twice.  You are free to enter the tonal realm by punching in your own notes via the keyboard, which records over the sequence, but a balance of harmonic and rhythmic evolution is inevitable.  It occupies the panel space designated for the external signal processor in the original MS-20 design.

The Accelerator is meant to be played primarily via the front panel knobs, and a skilled user can ride the sequencer like a never-ending wave of hypnotic inspiration, sculpting the perceived melody at will.  By focusing on controlling complex timbres and leaving the source melody up to chance, this device flips the script of what musical expression can and should be.


# Specs

#### 4 Operating Modes:
- Clean
- Tape Simulation
- Wavefolder
- Fuzz

#### Oscillator 1:
- Wavetable
- Physical Modeling
- Melodic Sampler
- Granular Sampler
- Drag & Drop User Samples

#### Oscillator 2:
- Sine AM
- Linear FM
- Exponential FM with Sync
- Square Ring Mod

#### Resonant 12db/Oct. Low Pass Filter & Saturator
#### Resonant 6db/Oct. High Pass Filter & Saturator

#### Triangle LFO with FM Input
#### Loopable DSR Envelope
#### ADSR Envelope
#### Drift LFO
#### 2x VCAs
#### Sample & Hold
#### Variable Clock with Time Division

#### Harmonic Brownian Motion Sequencer:
- Atonal Generative Sequencer
- 3, 4, 5, or 8/16-Steps
- Controllable Melodic and Rhythmic Content
- Variable Melody Evolution Probability
- Variable Drum Evolution Probability
- Variable Drum Sample Swap Probability
- 3 Sequencer Memory Slots
- Arpeggiator-Style Keyboard Sequence Recording
- Variable Swing

- Compressor with Sidechain Input
- Stereo Chorus
- Stereo Tape Delay with Modulatable Delay Time

- 5-Channel Generative Drum Machine
- Velocity Sensitivity
- 10 User-Selectable Drum Mix Combinations
- Resonant DJ-Style Low Pass Filter & Low-Shelf EQ
- Drag & Drop User Drum Samples

- 35 Semi-Modular MIDI Patch Points

44.1k Stereo Recorder
44.1k Stem Recorder

# 🎵

# Details
This is currently an open-source DIY project accessible to a **total beginner** who has no experience building synthesizers of any kind.

**You'll need:**

- A KORG MS-20ic midi controller ([check prices](https://reverb.com/price-guide/korg-ms20ic))

and either
- A computer (installation is only 3 steps)

or

- A Bela Mini (for use on-the-go).

## 💻 Desktop Installation (macOS / Windows / Linux)

### 1. **Install SuperCollider**

Download and install for free from:  
👉 [https://supercollider.github.io/downloads](https://supercollider.github.io/downloads)

SuperCollider is the programming language and environment in which the code runs.

### 2. **Download this Repository**

There are two options: 

Either click the "< > Code" button in the upper right of this page and download the .zip file,

or 

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

### 3. **Open and Run**

- Connect your KORG MS-20ic via USB and turn the master volume/power switch OFF
- Open SuperCollider on your computer
- Open the `supersonicACCELERATOR.scd` file in the SuperCollider IDE.
- Click anywhere in the code and press `Cmd + Enter` (or `Ctrl + Enter` on PC) to run it
- Turn on the MS-20ic power switch
- Enjoy!

Note: turn off the MS-20ic power switch to end the recording and save it.  Killing the SuperCollider process any other way will destroy the recording.

Note: Press `Cmd + Shift + L` (or `Ctrl + Shift + L` on PC) to kill the SuperCollider process.

# ✨

---

## 🛠 (Optional) Bela Mini Installation

### 1. **Prerequisites**

- Bela Mini with a working Bela image installed.
- access to the board.
- `supercollider` installed via Bela's package manager (it comes already installed).

### 2. **Download this Repository**

There are two options: 

either click the "< > Code" button in the upper right of this page and download the .zip file,

or 

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

### 3. **Deploy to Bela**

Plug in Bela Mini to your computer via USB
From your internet browser, navigate to `bela.local`
Navigate to the Project Explorer (Folder Icon)
Create a new SuperCollider project named supersonicACCELERATOR
Drag & drop all files into "Project contents."  Allow _main.scd to overwrite.
We can't drag and drop the folders, so create them yourself on Bela.  One named "samples", and one named "recording"
Drag & drop the contents of the samples folder on your computer into the "samples" folder in Bela

Navigate to Project Settings (Gear Icon)

Set "Run project on boot" to supersonicACCELERATOR

Set "Block size (audio frames)" to 512

Shut down Bela and close the bela.local window in your browser.


### 4. **Start the Patch**

Now when you plug in Bela Mini, the code will automatically run.
Bela Mini takes approximately 60 seconds to start.  This can feel like a lifetime, but your patience will be rewarded.  Do not turn on the MS-20ic controller until then, or you may get strange behavior, like the recording not working.

# ✨

---
![labeling mockup](knob%20labels%20v2.jpg) 
This is how I would recommend labeling the MS-20ic controller.  I sanded the black paint off mine and put some clear coat on it to protect the amazing natural color.  I also spray-painted the white keys silver.  You can also just use blank stickers for labels:
![sticker labels](sticker%20labels.jpg)
The one I sanded down is still unlabeled for now.  I just printed out the diagram from the [quickstart guide](https://github.com/rehresman/supersonicACCELERATOR/blob/main/supersonicACCELERATOR%20Quickstart%20Guide.pdf) and keep it under the synth.

## ❓ FAQ

### How do I use the tape delay?
Press and hold the momentary button (next to the mod wheel).  Use the mod wheel to dial in your desired amount of fx.
Momentary button + Clock changes delay time
Momentary button + Master Volume changes delay feedback

The tape delay time is always synced to the clock, with varying clock divisions at different tempos.

### The knobs and patch points aren't working as expected.
Many knobs and patch points have been redefined or modified from the original MS-20 design.  There is a jpeg file `knob labels.jpg` included in the repository containing a map of the new controls.  I would recommend sticking some labels on your MS-20ic controller for ease-of-use.

### How do I start the sequencer?
Patch a dummy cable to Rate In.  Leave the other end of the cable unplugged, unless you want to control the rate with something variable.

### What are the oscillator mod amount knobs normalled to?
Drift is normalled to Oscillator 1 Mod, and Osc 1 Out is normalled to Oscillator 2 Mod.

### What are the other normalled connections?
* LFO -> Mod 1 for All Osc Freq Mod and the filters
* Envelope Generator 1 -> Mod 2 for All Osc Freq Mod
* Envelope Generator 2 -> Mod 2 for the filters
* Envelope Generator 2 -> VCA Amount
* Noise -> Sample & Hold In
* Sequencer Gate Out -> Sample & Hold Clock In
* Osc 1 Out -> Osc 1 In

### How do I make Envelope Generator 1 self-trigger/loop?
Patch EG1 Rev Out to EG1 Trig In.  This is weird, becuase it's the opposite of how you would self-trigger EG1 on the original MS-20.  But...

EG1 is triggered whenever EG1 Trig In gets a signal > 0. 
It releases when EG1 Trig In gets a signal <= 0.  

It doesn't care about rising edges or anything like that.  

All values on the patch bay range in between -1 and 1.  Most are bipolar, but some are unipolar like the LFO Square Wave Out, or Sequencer Gate, and only range from 0 to 1.  EG2 Rev Out is also 0 to 1, not 0 to -1.  

### How do I filter Drums In?
Press and hold the momentary button (next to the mod wheel), and turn the drums knob to access a DJ-style low pass filter to the left, and Low-Shelf EQ to the right, designed for lo-fi, levels and drops.  There is a virtual notch in the center, allowing the signal to pass through unprocessed for carefree twiddling.

### Can I add fx to the drums?
The Drums In input is not routed to any fx.  However the snare drum gets independently sent to the fx by default.  In general if you want fx on your drums, you have to patch it into the Mixer Osc 1 In input.

### How do I add swing to the sequencer?
Open up the `_main.scd` file in a text editor.  About 25 lines down you'll see 
```
~swingDrums = 0;
~swingSynth = 0;
```
`0` means no swing. `100` means full swing.  Choose any value in between and save the file.

### How do I turn on stem recording mode?
Open up the `_main.scd` file in a text editor.  About 18 lines down you'll see 
```
~recordStems = false;
```
change `false` to `true` and save the file to record stems.

### Why are my samples not loading?
Make sure the `samples/` folder exists and that paths are correct. File names and file paths are almost always the issue.

### Does this work without a Korg MS-20ic MIDI controller?
No.  There is no on-screen interface by design.

### Is this Eurorack-compatible?
No.  The Korg MS-20ic controller can use Eurorack cables, but it is not able to send or receive CV signals.

### How can I record the output?
Recording begins automatically when you turn on the MS-20ic controller.  Recording ends and is saved when you turn off the MS-20ic Controller.  Find the recording in the `recording/` directory.  It will be called `supersonicACCELERATOR.wav`, or if you have stem recording enabled, it will be three stems, `supersonicACCELERATOR_drums.wav` `supersonicACCELERATOR_synth.wav` and `supersonicACCELERATOR_fx.wav`.

### My recording is blank.
The order in which you run the code and turn on the MS-20ic controller matters.  The code should be running before and after the MS-20ic controller is turned on and off.

### My stem recording sounds different than when I performed it
Stem recordings are the same source material, but without the mixing elements of the device.  So the synth won't be sidechained to the drums, there will be no stereo imaging, and Fuzz and Tape mode will not affect the recorded output.  This is because if you want stems, I assume you will mix them on your own using whatever outside processing you like.

### Can I contribute or fork this?
Absolutely. Keep all updates as a single file to maintain Bela Mini compatibility.

---


## 📁 Code Organization

This is a large file. Use `Cmd + F` (or `Ctrl + F`) to search for section names and navigate quickly:

```
safeguards & init
 ├ create buses
 ├ functions and environment variables
 │  ├ voice functions and environment variables
 │  ├ oscillator functions and environment variables
 │  └ sequencer functions and environment variables
 ├ prepare recording
 └ loadBuffers

create nodes
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

boot instructions
 ├ initialize midi
 ├ initialize buses
 ├ create SynthDefs
 ├ create ServerTree
 └ run ServerTree
```

---

## 📜 License

MIT License – feel free to use, modify, and distribute.

---

## 🙏 Acknowledgments

- Thanks to the SuperCollider community
- Thanks to Sam Crivelli
- Inspired by the Korg MS-20, Make Noise DPO, Erica Synths Fusion VCO2, Mutable Instruments Marbles, Soundtoys Radiator, Elektron Analog Rytm MkII, Urei 1176, DAFx-17, and Buchla 259
