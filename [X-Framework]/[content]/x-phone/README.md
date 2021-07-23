# x-phone
Advanced Phone for X-Core Framework :iphone:

## Dependencies
- [x-core](https://github.com/xcore-framework/x-core)
- [x-policejob](https://github.com/xcore-framework/x-policejob) - MEOS, handcuff check etc. 
- [x-crypto](https://github.com/xcore-framework/x-crypto) - Crypto currency trading 
- [x-lapraces](https://github.com/xcore-framework/x-lapraces) - Creating routes and racing 
- [x-houses](https://github.com/xcore-framework/x-houses) - House and key management 
- [x-garages](https://github.com/xcore-framework/x-garages) - 
- [x-banking](https://github.com/xcore-framework/x-banking) - For banking


## Screenshots
![Home](https://imgur.com/ceEIvEk.png)
![Bank](https://imgur.com/tArcik2.png)
![Whatsapp](https://imgur.com/C9aIinK.png)
![Phone](https://imgur.com/ic2zySK.png)
![Settings](https://imgur.com/jqC5Y8C.png)
![MEOS](https://imgur.com/VP7gXf.png)
![Vehicles](https://imgur.com/NUTcfwr.png)
![Email](https://imgur.com/zTD33N1.png)
![Advertisements](https://imgur.com/QtQxJLz.png)
![Houses](https://imgur.com/n6ocF7b.png)
![App Store](https://imgur.com/mpBOgfN.png)
![Lawyers](https://imgur.com/SzIRpsI.png)
![Racing](https://imgur.com/cqj1JBP.png)
![Crypto](https://imgur.com/Mvv6IZ4.png)

## Features
- Garages app to see your vehicle details
- Mails to inform the player
- Banking app to see balance and transfer money
- Racing app to create races
- App Store to download apps
- MEOS app for polices to search
- Houses app for house details and management

## Installation
### Manual
- Download the script and put it in the `[x]` directory.
- Import `x-phone.sql` in your database
- Add the following code to your server.cfg/resouces.cfg
```
ensure x-core
ensure x-phone
ensure x-policejob
ensure x-crypto
ensure x-lapraces
ensure x-houses
ensure x-garages
ensure x-banking
```

## Configuration
```

Config = Config or {}

Config.RepeatTimeout = 2000 -- Timeout for unanswered call notification
Config.CallRepeats = 10 -- Repeats for unanswered call notification
Config.OpenPhone = 244 -- Key to open phone display
Config.PhoneApplications = {
    ["phone"] = { -- Needs to be unique
        app = "phone", -- App route
        color = "#04b543", -- App icon color
        icon = "fa fa-phone-alt", -- App icon
        tooltipText = "Phone", -- App name
        tooltipPos = "top",
        job = false, -- Job requirement
        blockedjobs = {}, -- Jobs cannot use this app
        slot = 1, -- App position
        Alerts = 0, -- Alert count
    },
}
```
