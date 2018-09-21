This is a simple exporter addon for World of Warcraft that works in tandem with EventExporter Discord chat bot ([invite link here](https://discord.gg/anbsKQX)). The addon can currently export the following: 

- **Event roster export** - There's an 'Export' button bellow the event frame in the Calendar. Click it to generate a string that will later parse into a spreadsheet containing 2 columns - Player names (with cells class-colored) and Invite status (Accepted, Declined, etc.) 

- **Online guild members** - You can use slash command ***/eeon*** to generate a string that will later parse into a spreadsheet containing a single column - All online guild members at the time of command invocation. 

- You can opt to record instead, typing ***/eeon start*** to start recording, which will do the same thing as ***/eeon***, but it will save every new guild member that comes online before invoking ***/eeon stop***. If the member goes offline before the 'stop' command is invoked, they are **not** removed from the result. Also later parses into a spreadsheet containing a single column - All online guild members at the time of command invocation and throughout the recording. 

- **All guild members** - You can also use slash commands ***/eeall*** or ***/eeallmembers*** to generate a string that will later parse into a spreadsheet containing 3 columns - Character Name, Member Note (for that character) and Officer Note (for that character). 
 
- **All raid members** - You can use ***/eeraid** to generate a string that will later parse into a spreadsheet containing a single column - Names of players in raid, at the time of command invocation.

## All of these functionalities are now available via window pane that can be accessed by typing ***/ee***. 
 
 
 
FAQ
=== 
 
 
### Why on earth would you need exports like these?
  
Great question. Most of these make managing a guild slightly easier. 

- **Event roster export**, for example, makes tracking responses on an event (a raid, maybe?) easier to put into an spreadsheet, which some people love doing and use them to track attendance of guild members. 

- **Online guild members** can help you see who's online in time and whether or not those that were put as 'reserves' for an event showed up. 

- **All guild members** can be useful depending on how you manage your member/officer notes. My guild, for example, uses it to track alts of members, so that when a member leaves, officers can easily clean up the rest of the alts by that player with a simple spreadsheet search, rather than checking individual notes of 500+ guild characters in-game. 
 
- **All raid members** can be used to easily track groups that actually went into the raid, bypassing raid logs and making a spreadsheet-friendly export.
 
### Can you implement {insert some feature here}?
 
I'm always open to new ideas, so feel free to DM me your ideas over on Discord - [@Trishma#6911](https://discordapp.com/channels/@me/217294231125884929)

