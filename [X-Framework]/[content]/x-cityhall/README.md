# x-cityhall
City Services for X-Core Framework :us:

## Dependencies
- [x-core](https://github.com/xcore-framework/x-core)
- [x-phone](https://github.com/xcore-framework/x-phone) - For E-Mail
- [x-logs](https://github.com/xcore-framework/x-logs) - Log System

## Screenshots
![City Services](https://imgur.com/czVg0Ze.png)
![Request Birth Certificate](https://imgur.com/l6KSzPf.png)
![Request Driver License](https://imgur.com/pP24GEw.png)
![Apply For a Job](https://imgur.com/dXKKsn0.png)

## Features
- Ability to request birth certificate when lost
- Ability to request driver license when lost
- Ability to apply to government jobs

## Installation
### Manual
- Download the script and put it in the `[x]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure x-core
ensure x-phone
ensure x-logs
ensure x-cityhall
```

## Configuration
```
Config = Config or {}

Config.Cityhall = { -- Location for City Sevices
    coords = {x = -552.0, y = -191.68, z = 38.22},
}

Config.DriverTest = { -- Not on use
    coords = {x = -549.86, y = -191.75, z = 38.22},
}

Config.DrivingSchool = { -- Not on use
    coords = {x = 232.5, y = 368.7, z = 105.94},
}

Config.CompanyPrice = 25000 -- Not on use
```
