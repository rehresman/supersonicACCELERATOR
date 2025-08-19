# supersonicACCELERATOR Paraphonic Semi-Modular Synthesizer and Drum Machine

[![Watch the video](https://img.youtube.com/vi/0orJ6Mp31xY/maxresdefault.jpg)](https://youtu.be/0orJ6Mp31xY)
Watch the [video introduction](https://youtu.be/0orJ6Mp31xY).

This repository contains:
* a SuperCollider-based paraphonic semi-modular synthesizer and drum machine organized as a single file
* a set of audio samples  
* a jpeg labeling all knobs and patch points
* a wavetable generator utility

# Concept

I believe everyone should experience the joy of deep, complex musical improvisation, and I developed the Accelerator to be the fastest route to that goal.  This is not a shortcut machine that does the creative legwork for you, nor is it a retrictor that puts you into a sterile room with guardrails and safety nets.

This is an iteration on the design of my favorite synthesizer of all time, the Korg MS-20.  What if it had different 16 oscillator types to choose from?  What if audio-rate modulation was encouraged?  What if a sequencer and percussive accompaniment were an integral part of the design, and you could record a finished mix at the moment of creation?  

The included *Harmonic Brownian Motion Sequencer* is a controllable chaos environment that completely rejects the idea of tonal music and never does the same thing twice.  You are free to enter the tonal realm by punching in your own notes via the keyboard, which records over the sequence, but a balance of harmonic and rhythmic evolution remains inevitable.  

The Accelerator is meant to be played primarily via the front panel knobs, and a skilled user can ride the sequencer like a neverending wave of hypnotic inspiration, sculpting the perceived melody at will.  By focusing on controlling complex timbres and leaving the source melody up to chance, this device flips the script of what musical expression can and should be.

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

#### Variable shape LFO with ramp and square wave outputs
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

---
![labeling mockup](knob%20labels.jpg) 

## 💻 Desktop Installation (macOS / Windows / Linux)

### 1. **Install SuperCollider**

Download and install from:  
👉 [https://supercollider.github.io/downloads](https://supercollider.github.io/downloads)

SuperCollider is the programming language and environment in which the code runs.

### 2. **Download this Repository**

There are two options: 

either click the "< > Code" button in the upper right of this page and download the .zip file,

or 

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

### 3. **Open and Run**

- Connect your KORG MS-20ic midi controller and turn the power switch OFF
- Open SuperCollider
- Open the `supersonicACCELERATOR.scd` file in the SuperCollider IDE.
- Click anywhere in the code and press `Cmd + Enter` (or `Ctrl + Enter` on PC) to run it
- Turn on the MS-20ic power switch
- Enjoy!

Note: turn off the MS-20ic power switch to end the recording and save it.  Killing the SuperCollider process any other way will destroy the recording.

Note: Press `Cmd + Shift + L` (or `Ctrl + Shift + L` on PC) to kill the SuperCollider process.

---

## 🛠 Bela Mini Installation

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



---

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

### Why are my samples not loading?
Make sure the `samples/` folder exists and that paths are correct. File names and file paths are almost always the issue.

### Does this work without a Korg MS-20ic MIDI controller?
No.  There is no on-screen interface by design.

### Is this Eurorack-compatible?
No.  The Korg MS-20ic controller can use Eurorack cables, but it is not able to send or receive CV signals.

### How can I record the output?
Recording begins automatically when you turn on the MS-20ic controller.  Recording ends and is saved when you turn off the MS-20ic Controller.  Find the recording in the `recording/` directory.  It will be called `supersonicACCELERATOR.wav`.

### My recording is blank.
The order in which you run the code and turn on the MS-20ic controller matters.  The code should be running before and after the MS-20ic controller is turned on and off.  Furthermore, if you turn the controller off and then on again, a new recording will NOT be made.  Currently you need to restart the code to make a new recording, though I may update this as time goes on.

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
- Inspired by the Korg MS-20, Make Noise DPO, Erica Synths Fusion VCO2, Mutable Instruments Marbles, Soundtoys Radiator, Elektron Analog Rytm MkII, Urei 1176, DAFx-17, and Buchla 259
