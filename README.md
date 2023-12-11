# Keyboard remapper

This program implements the spacebar tap-hold functionality from qmk natively on mac, with special consideration given to edge cases in order to prevent false taps. Modify the standard keymap by changing the `getLayerKey` function in `main.m`, then compile using XCode. Tip: use the shell script action in automator to run the program without the open terminal.
