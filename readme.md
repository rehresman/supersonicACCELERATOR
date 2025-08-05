# supersonicACCELERATOR Paraphonic Semi-Modular Synthesizer and Drum Machine

[![Watch the video](https://img.youtube.com/vi/0orJ6Mp31xY/maxresdefault.jpg)](https://youtu.be/0orJ6Mp31xY)

This repository contains:
* a SuperCollider-based paraphonic semi-modular synthesizer and drum machine organized as a single file
* a set of audio samples 
* a wavetable generator utility

---

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
set Run project on boot to supersonicACCELERATOR
set Block size (audio frames) to 512
Shut down Bela and close the bela.local window in your browser.


### 4. **Start the Patch**

Now when you plug in Bela Mini, the code will automatically run.
Bela Mini takes approximately 60 seconds to start.  This can feel like a lifetime, but your patience will be rewarded.  Do not turn on the MS-20ic controller until then, or you may get strange behavior, like the recording not working.



---

## ❓ FAQ

### Why are my samples not loading?
Make sure the `samples/` folder exists and that paths are correct. File names and file paths are almost always the issue.

### Does this work without a Korg MS-20ic MIDI controller?
No.  There is no on-screen interface by design.

### How can I record the output?
Recording begins automatically when you turn on the MS-20ic controller.  Recording ends and is saved when you turn off the MS-20ic Controller.

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
- Inspired by the Korg MS-20, Make Noise DPO, Erica Synths Fusion, Mutable Instruments Marbles, Soundtoys Radiator, Elektron Analog Rytm MkII, Urei 1176, DAFx-17, and Buchla 259
