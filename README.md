# Prompter

A floating teleprompter for screen recordings. You can read it; the recording can't.

It marks its window with macOS's `sharingType = .none`, the same flag password managers use, so screen capture (QuickTime, OBS, Screen Studio, Loom, Cmd-Shift-5) leaves the window out of the saved video even when it's sitting on top of what you're recording. It also keeps out of the Dock and the app switcher.

## Build once

```sh
./build.sh
```

Needs the Xcode Command Line Tools. If `swiftc` isn't found, run `xcode-select --install` first.

## Use

```sh
./prompter scripts/insertion-sort.md
```

A dark, semi-transparent panel appears at the top left and stays above every other window. Drag it anywhere; drag an edge to resize. Click it once so it has focus, then:

| Key | Does |
| --- | --- |
| space | play / pause the auto-scroll |
| ↑ ↓ | nudge the text up or down |
| [ ] | slower / faster |
| - = | smaller / larger text |
| , . | more / less transparent |
| r | back to the top |
| q | quit |

The mouse wheel scrolls it by hand even while another app has focus.

## Check it before the real take

Record five seconds with the prompter on top of what you're recording, then open the video: the prompter should be gone. If it isn't, your recorder is capturing in a mode that ignores the flag (some older or virtual-camera setups do); switch recorders or put the prompter on a second display.

## Scripts

Scripts are Markdown files in `scripts/`. The prompter understands a small subset: `#` headings, `**Say:**` lines (shown bright, the words you speak), `**Type:**` and `**Do:**` lines (shown in monospace, what you do on screen), `- ` bullets, and ``` fenced code. Edit in any text editor; relaunch to reload.

`scripts/insertion-sort.md` is the script for the insertion sort video that goes with [Card in Hand](https://github.com/drbinna/Insertion_sort). `scripts/variables.md` is the script for *Variables, Line by Line*.
