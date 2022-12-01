# Database

An addon for Ashita v4 to track and display various things needed for gear upgrades, weapon upgrades, current ambu points spent in the month, job points data on one screen, and more!

## Commands:

/database or /db to hide|show the gui

## Notes
- Still TONS of work I need to do and code clean up and such, feel free to try this out and give feedback. This will hold my general notes/updates/to-do's until I organize this addon better
- ~~I am currently using too many nested for loops for gear updates, because of this when you update any gear it will cause client lock up for a moment, it doesnt not DC me but you might lose connection, fyi~~
- I drastically improved the Big O of the search functions and no longer experience a large stutter when updating gear tables
- Added Prime weapons tab, obviously this is on going as the content rolls out
- Need to add Odyssea gear tab, split gear/weapons maybe? hmm
- Off loaded all the search/find functions to modifind include for better organization
- General improvement of variable names including loop iterators, still more to do here
- Need to develope a more global table/system to hold/count items that are used for multiple upgrade paths, such as beetle blood or rocks like beitetsu
- Added KI check/display for the +3 KIs for empy/relic +3 upgrade unlocks
- Added packet check for various currencies to update/display when hiding/showing the gui
- Added text intercepts to update needed alexandrites and rocks for Oboro
- Currently reads/displays which weapon your alex are going towards from the rat but need to make a way to reset to default after completion and then use same function for Oboro
- 
