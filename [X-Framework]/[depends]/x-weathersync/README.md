# x-weathersync
Synced weather and time for X-Core Framework :sunrise:

## Dependencies
- [x-core](https://github.com/xcore-framework/x-core)

## Features
- Syncs the weather for all players

### Commands
- /blackout - Toggles blackout
- /clock [hour] [minute] - Sets the exact time
- /time [morning/noon/evening/night] - Sets the generic time
- /weather [type] - Changes the weather type 
- /freeze [weather/time] - Freezes the current weather/time

## Installation
### Manual
- Download the script and put it in the `[x]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure x-core
ensure x-weathersync
```

## Configuration
You can adjust available weather and time types in x-weathersync\server\main.lua
