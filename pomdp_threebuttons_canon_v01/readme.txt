
Open and start “pomdp_threebuttons_canon_main.m”

Requires the psychtoolbox 3

You have to change the following lines:
- line 13, keep 0 for macs, 1 for windows. 0 should work for linux too.
- line 17 or 19: put the directory of the folder.
- line 23: inside the function “pomdp_threebuttons_canon_screen” you might have to change the screen number (line 11 or 21). If you have 2 monitors, set it to 1 or 2 for your primary and secondary monitors. If you have only 1, set it to 0.
- line 25: you might have to change key names in side the function if it complains about the function KbName. You’ll know the key name in your OS by typing “KbName” in matlab’s console, then pressing the key.
- line 31: it is likely you’ll have to change your OS soundcard index. It’ll say “error using psychportaudio”. You’ll have to use PsychPortAudio(‘GetDevices’) to find your sound card index, see inside the function for details.

The rest should be fine regardless of your OS.

When you start the experiment, there will be a blinking exclamation mark, just ignore it.

When prompted for subject name, type “train” to have the mode where you can change parameters and see the telegraph process. During the experiment, use:
- up/down to vary the repletion rate Tau (how quickly the equilibrium lambda grows)
- right/left to vary the depletion rate Delta (the fraction of lambda that is subtracted at depletion)
- w/s to change the telegraph process time constant (how quickly it changes state independent of the equilibrium)
- a/d to change the variance of the pink noise texture

