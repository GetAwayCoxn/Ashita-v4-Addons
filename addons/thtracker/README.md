# TH Tracker

Ashita v4 addon for FFXI to track TH levels on mobs.

## Commands:

|**Command**|**Description**|
|------------:|:---|
|/tht|Will show or hide the text box (1.01 saves this on per job basis now)|
|/tht time [number]|Will set the time (in seconds) to delete dead mobs off the list, defaults to 15 if no number entered|
||Example: "/tht time" will set to 15, "/tht time 20" will set to 20 seconds|

## Notes:

-Will check gear at time of attack/ranged chat message to get TH lv's and will show in yellow color

-Will change display of each mob to green if your on THF main and it see's an actual TH+ chat log message

-This reads from the chat log so you still have to have your damage visible in the log for this to work

-Will currently recognize any melee hits or ranged attacks to establish first TH/claim, and of course TH procs after that on THF main, so if you are running around on BLU/THF subductioning stuff in TH gear this will not currently recognize your TH4 on everything

## To Do:

-Standing by for bugs

-Should add more ways for the addon to recognize initial action (mostly magic), kinda not needed at retail though imo

## Current Text Overlay: 

![THtrackerGUI](https://user-images.githubusercontent.com/66495755/184027421-2eb820ff-342d-412a-905e-87b124830fb2.png)
