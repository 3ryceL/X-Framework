# x-apartments
Apartments System for X-Core Framework :office:

## Dependencies
- [x-core](https://github.com/xcore-framework/x-core)
- [x-clothing](https://github.com/xcore-framework/x-clothing) - To save outfits
- [x-houses](https://github.com/xcore-framework/x-houses) - House logic
- [x-interior](https://github.com/xcore-framework/x-interior) - Interior logic
- [x-weathersync](https://github.com/xcore-framework/x-weathersync) - To desync weather while inside
- [x-spawn](https://github.com/xcore-framework/x-spawn) - To spawn the player at apartment if last location was in apartment

## Screenshots
![Inside Apartment](https://imgur.com/uTu8yUL.png)
![Enter Apartment](https://imgur.com/1giGyt1.png)
![Stash](https://imgur.com/t6crf4c.png)
![Saved Outfits](https://imgur.com/I0YLuQA.png)
![Log Out](https://imgur.com/q1Yx3nS.png)

## Features
- Door Bell
- Stash
- Log Out Marker
- Saved Outfits

## Installation
### Manual
- Download the script and put it in the `[x]` directory.
- Import `x-apartments.sql` in your database
- Add the following code to your server.cfg/resouces.cfg
```
ensure x-core
ensure x-interior
ensure x-weathersync
ensure x-clothing
ensure x-houses
ensure x-spawn
ensure x-apartments
```

## Configuration
```
Apartments = {} -- Don't touch

Apartments.SpawnOffset = 30 -- Don't touch

Apartments.Locations = {
    ["apartment1"] = { -- Needs to be unique
        name = "apartment1", -- Apartment id
        label = "South Rockford Drive", -- Apartment Label (for Blip and other stuff)
        coords = {
            enter = {x = -667.372, y = -1106.034, z = 14.629, h = 65.033}, -- Enter Apartment Marker Location
            doorbell = {x = -667.601, y = -1107.354, z = 15.133, h = 65.033}, -- Exit Apartment Marker Location
        }
    },
    ["apartment2"] = {
        name = "apartment2",
        label = "Morningwood Blvd",
        coords = {
            enter = {x = -1288.046, y = -430.126, z = 35.077, h = 305.348},
            doorbell = {x = -667.682, y = -1105.876, z = 14.629, h = 65.033},
        }
    },
    ["apartment3"] = {
        name = "apartment3",
        label = "Integrity Way",
        coords = {
            enter = {x = 269.075, y = -640.672, z = 42.02, h = 70.01},
            doorbell = {x = -667.682, y = -1105.876, z = 14.629, h = 65.033},
        }
    },
    ["apartment4"] = {
        name = "apartment4",
        label = "Tinsel Towers",
        coords = {
            enter = {x = -621.016, y = 46.677, z = 43.591, h = 179.36},
            doorbell = {x = -667.682, y = -1105.876, z = 14.629, h = 65.033},
        }
    },
    ["apartment5"] = {
        name = "apartment5",
        label = "Fantastic Plaza",
        coords = {
            enter = {x = 291.517, y = -1078.674, z = 29.405, h = 270.75},
            doorbell = {x = -667.682, y = -1105.876, z = 14.629, h = 65.033},
        }
    },
}
```
