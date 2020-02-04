# GIAnT - A Group Interaction Annotation Tool

## Introduction
This repository contains the implementation of the GIAnT tool, which enables an accurate and fast annotation/coding of group interactions supported by an automatic multichannel speaker activity detection (MSAD). In the case that all participants of the group interaction have used a headset or lapel microphone during the audio recordings, the GUI displays up to 8 audio tracks in parallel and segments the speaker turns. Every speaker turn can be adapted and annotated/coded by hand with a user-specific coding scheme.

## Prerequisites
### Using GIAnT (compiled)
- [Matlab runtime 2015b](https://de.mathworks.com/products/compiler/matlab-runtime.html)
- [FFMPEG](https://www.ffmpeg.org/download.html) (ffmpeg, ffplay and ffprobe). You may want to download the executable files if you are not familiar with compiling source code. 

### For editing and compiling the source code (optional)
- [Matlab 2015b](https://de.mathworks.com/) or higher
- [FFMPEG](https://www.ffmpeg.org/download.html)

## Getting Started
### Installation

- Install Matlab (runtime)
- Compile ffmpeg, ffplay and ffprobe and put the executables to the folder path ./bin/ffmpeg/.

### Compiling the Matlab source code (optional)
```
matlab ... .m
```
## Short Manual

### Starting a project
#### Supported file format
#### Load files
#### Save files
#### toolbar and actions

### Generate coding schemes


### Keyboard shortcuts
- `F1`-`F4`: Choose tool/action (edit, navigate, zoom in, zoom out)
- `F5`/`F8`: Rewind/forward
- `F10`/`F11`: Fast rewind/forward
- `Space`: Play/pause
- `F12`: Play back selected item
- `Page down`: Go to first uncoded item
- `Arrows`: Navigate between items
- `STRG` + `<-/->`: Edit onset of selected item
- `ALT` + `<-/->`: Edit offset of selected item

## License

## Citation
If you use GIAnT in your research, please cite
```
@article{meyer2019,
  author =  {P. Meyer and L. Thiele and S. Kauffeld and T. Fingscheidt},
  title =   {{GIAnT: A Group Interaction Annotation Tool to Simplify Psychological Interaction Analysis}},
  journal = {Gruppe. Interaktion. Organisation. Zeitschrift für Angewandte Organisationspsychologie},
  year =    {2020},
  month =   jan
}
```
