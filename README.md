# GodotOnlineClient
Online 3D worlds powered by Godot (client)

Summary:

Hi guys!

This project is an attempt to create a fully open-source online 3D world system built on top of the Godot game engine. (Note: the current state of the repos as I write this message is a bit messy, most of it has been me experimenting with how to send GLTFDocuments over the network to 'send 3d scenes/objects over the network', I apologize in advance :). ).

My vision is to create a system similar to Second Life/Active Worlds, but with a few twists:

1. Fully open-source: A fully open-source system allows users to dig deeper into why certain things aren't working exactly as they'd like and gives them the opportunity to fix it themselves. For example, if you are creating an online street racing simulator and you want your car to be able to drift realistically, there may actually be a problem inside of the Godot engine itself which prevents the ideal physics experience you are trying to achieve; Because Godot is open-source, creators are able to dig into the game engine itself (or simply put in an issue item) where they can expose their issue to the community to get it fixed. Of course, this same workflow (issue submitting, particularly) can be done with a privatized online 3d simulator game (like Second Life/Active Worlds), however you are at the mercy of their private dev team to fix it which may take longer or be cancelled to prioritize other things. In this system, the creators will have the power to modify the nuts and bolts of the core system itself, from the server/client networking of these repos down to the Godot game engine itself. It is important to note that preservation of this rule requires that no private 3rd party software is used at any level of the system.

2. User-ran Servers: In the current design, there is no single central server that the users connect to. Any user can also be a 'server-owner' by simply downloading the server-side godot project and running it on a publically accessible server. Server-owners will be able to configure their servers in great detail (IP-whitelisting, max-concurrent users, etc.). Server-owners can then invite their friends/followers to the server by giving them the URL and a link to the client-side software download.

3. Interconnecting User-ran servers: This idea is a bit farfetched, but is probably the most important idea of the whole system. Simply put, two separate 'server-owners' should be able to 'connect' their worlds together. What this means is you can log into one server/world (ran be server-owner A) and venture into another world (owned by server-owner B) because A and B have agreed to 'connect' their worlds. I am not sure how well this will work or how to even implement it, but I imagine this being the 'scaling' mechanism for the whole system and giving the ability to generate seemingly endlessly large worlds.


There may be a few points missing above, but that should be the bulk of the design. Anyone is free to contribute, new ideas are welcome as well since this project is still in its infancy. It is important to have a strong design at the start, so I will be sure to create some kind of design documents and put them in the repos as well. Thank you for reading, and also big thanks to the Godot contributors for their implicit part in this! take care!
