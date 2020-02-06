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
- Compile ffmpeg, ffplay and ffprobe and put the executables to the folder path "./bin/ffmpeg/".

### Compiling the Matlab source code (optional)
```
matlab ... .m
```
## Short Manual

### Starting a project
First of all, create a *project folder*, which contains the single audiotracks of the multichannel recording and the video recording (optional). Make sure that there are no other audio or video files in the *project folder*. The *project folder* is later used to automatically save the current state of the project as well as converted versions of the video and audio tracks. It is recommended to use GIAnT with multichannel audio recordings, but GIAnT can also be used with only a single audio or video recording. Please note, the MSAD can only applied with multichannel recordings. If the *project folder* contains at least one audio or video file, the GIAnT tool can be started.

#### Supported file format
- Supported audio format: wav, mp3, wma
- Recommended video format: wmv
- Note: Filenames cannot contain spaces. It is further recommended to name the audio tracks as follows: "name_tracknumber.wav"

#### Load files
Open a project by clicking on the `Load`-button and selecting a *project folder*. All audio files in the *project folder* (up to 8) will be opened in GIAnT, converted to 16kHz and stored in a subfolder. If the *project folder* contains a video file, it will also converted and opened in GIAnT. If there is already an Excel file in the *project folder*, which contains a segmentation and coding, it will also be opened.

#### Save files

The current project can be stored in the *project folder* as an Excel file by means of the `save`button. The project is also stored automatically every 5 minutes.

#### Toolbar and actions

- `F1`(edit): Select and edit a segment per left mouse click. The selected segment is marked in red. Use a defined shortcut or click in the `annotation window` to code/annotate the selected segment. Coded segments are marked in green, while uncoded segments are marked yellow. Write a command for the selected segment in the `command window` if needed. Resize the selected segment per drag and drop or with the keyboard by pressing `STRG` + `<-/->` and `ALT` + `<-/->`. Create a new segment per right mouse click or delete the selected segment by pressing `delete`.
- `F2`(navigate): Scroll left and right by pressing and holding down the left mouse button.
- `F3`/`F4`(zoom in/out): Zoom in/out on the audio tracks. Double mouse click restores standard view. 
- `Video on/off`: Enables/disables the video playblack. For a better performance of GIAnT, it is recommended to use the video only if necessary.
- `Play`: Starts play back of audio and video file starting from the position of the green time cursor. The position of the time cursor can be changed by a mouse click between the audio tracks.
- `SAD`: Start the multichannel speaker activity detection. This requires multichannel audio recordings. 
- `Key`: Choose a coding scheme for coding/annotating the audio material.

### Generate coding schemes (Keys)
GIAnT offers the opportunity to generate customized coding schemes, which can be selected under `Keys`. All Key-files have to be stored in the folder "./Keys/" as ".txt" with the following format:

`shortcut` `Tab` `code` `Tab` `class` `Enter`

Example: 

`a` `Tab` `angry` `Tab` `emotion` `Enter`

*Further notes*: All characters on the keyboard that can be reached with a single key or with `SHIFT` are permitted to define a shortcut. The symbol `^` is an exception, it can be used as placeholder, if no more shortcuts are available on the keyboard. Thus, it is possible to define any number of codes. By using the placeholders, you have to type the code-names in the `annotation window` by hand. Furthermore, it is not allowed to use `spaces` in the second column for a code-name. 

An Key-template can be found in the `Key`-folder. We recommend to use [Notepad++](https://notepad-plus-plus.org/downloads/) to create and edit the Key-files.

### Keyboard shortcuts
- `F1`-`F4`: Choose tool/action (edit, navigate, zoom in, zoom out)
- `F5`/`F8`: Rewind/forward
- `F10`/`F11`: Fast rewind/forward
- `Space`: Play/pause
- `F12`: Play the selected segment
- `Page down`: Go to first uncoded segment
- `Arrows`: Navigate between segments
- `STRG` + `<-/->`: Edit onset of selected segment
- `ALT` + `<-/->`: Edit offset of selected segment

## License
GIAnT is published for research, commercial use is prohibited.

## Citation
If you use GIAnT in your research, please cite
```
@article{meyer2020giant,
  title={GIAnT: A Group Interaction Annotation Tool to simplify psychological interaction analysis},
  author={Meyer, Patrick and Thiele, Lisa and Kauffeld, Simone and Fingscheidt, Tim},
  journal={Gruppe. Interaktion. Organisation. Zeitschrift für Angewandte Organisationspsychologie (GIO)},
  pages={1--7},
  year={2020},
  month={jan},
  publisher={Springer}
}
```
if you use the MSAD for your research, please cite
```
@inproceedings{meyer2018multichannel,
  title={Multichannel Speaker Activity Detection for Meetings},
  author={Meyer, Patrick and Jongebloed, Rolf and Fingscheidt, Tim},
  booktitle={2018 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},
  pages={5539--554},
  year={2018},
  organization={IEEE}
}
```
