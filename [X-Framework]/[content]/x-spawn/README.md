# x-spawn
Spawn Selector for X-Core Framework :eagle:

## Dependencies
- [x-core](https://github.com/xcore-framework/x-core)
- [x-houses](https://github.com/xcore-framework/x-houses) - Lets player select the house
- [x-apartment](https://github.com/xcore-framework/x-apartment) - Lets player select the apartment
- [x-garages](https://github.com/xcore-framework/x-houses) - For house garages

## Screenshots
![Spawn selector](https://imgur.com/UnomCUR.png)

## Features
- Ability to select spawn after selecting the character

## Installation
### Manual
- Download the script and put it in the `[x]` directory.
- Import `x-spawn.sql` in your database
- Add the following code to your server.cfg/resouces.cfg
```
ensure x-core
ensure x-spawn
ensure x-apartmen
ensure x-garages
```

## Configuration
An example to add spawn option
```
X.Spawns = {
    ["spawn1"] = { -- Needs to be unique
        coords = {
            x = 0.0, -- Coords player will be spawned
            y = 0.0, 
            z = 0.0, 
            h = 180.0
        },
        location = "spawn1", -- Needs to be unique
        label = "Spawn 1 Name", -- This is the label which will show up in selection menu.
    },
    ["spawn2"] = { -- Needs to be unique
        coords = {
            x = 1.1, -- Coords player will be spawned
            y = -1.1, 
            z = 1.1, 
            h = 180.0 
        }, 
        location = "spawn2", -- Needs to be unique
        label = "Spawn 2 Name", -- This is the label which will show up in selection menu.
    },
}
```
