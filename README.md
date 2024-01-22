# facilevr
This is an attempt to rewrite Fretta as a newer gamemode platform that uses the newer features of GMOD.
Currently abandoned but still can hold some merit to anyone looking for something to try out if you are a developer.
Everything is in working condition as of release.

This fixes many of the issues in the original vrmod, aside from IK player models, complete controller support,
complete locomotion. This does fix the audio from the right hand controller by using a viewing entity that somehow
can transmit it's position locally to the client from the server, it's a great trick and actually solves all the
rendering bugs like area portals. The Lua weapons get their firing positions overridden in Lua scope. This fixes
all the Lua weapons that use this function, it also allows for the weapons to be used on the left hand, although
I have not coded that yet.

This is messy.. I wasn't going to release this properly as there are lots of risks using this in a public server.

# VR
USE WITH RISK. Public servers may use the networked functions and variables to trivially cheat.
Facile allows you to create gamemodes that support VR. You can enable them using the 'C' context menu.
_Sandbox does not work_ I have made this to prevent making changes to the original gamemodes, creating a branch is easy
though if you wish to do so.

# VR Installation
Download and follow installation instructions from the original vrmod creator (here)[https://github.com/catsethecat/vrmod-module]. You do
not have to install the lua as it may interfere with this. They did an awesome job too, I just went off and created my own thing to learn
how to develop a VR project.
