X = {}
X.Phone = {}
X.Screen = {}
X.Phone.Functions = {}
X.Phone.Animations = {}
X.Phone.Notifications = {}
X.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

X.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

X.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && X.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

X.Phone.Functions.SetupApplications = function(data) {
    X.Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= X.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, X.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === X.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/politie.png" class="police-icon">';
            }
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

X.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

X.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (X.Phone.Data.currentApplication == null) {
                X.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                X.Phone.Functions.ToggleApp(PressedApplication, "block");
                
                if (X.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    X.Phone.Functions.HeaderTextColor("black", 300);
                }
    
                X.Phone.Data.currentApplication = PressedApplication;
    
                if (PressedApplication == "settings") {
                    $("#myPhoneNumber").text(X.Phone.Data.PlayerData.charinfo.phone);
                    $("#mySerialNumber").text("X-" + X.Phone.Data.PlayerData.metadata["phonedata"].SerialNumber);
                } else if (PressedApplication == "twitter") {
                    $.post('https://x-phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                        X.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                    })
                    $.post('https://x-phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                        X.Phone.Notifications.LoadHashtags(Hashtags)
                    })
                    if (X.Phone.Data.IsOpen) {
                        $.post('https://x-phone/GetTweets', JSON.stringify({}), function(Tweets){
                            X.Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                } else if (PressedApplication == "bank") {
                    X.Phone.Functions.DoBankOpen();
                    $.post('https://x-phone/GetBankContacts', JSON.stringify({}), function(contacts){
                        X.Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('https://x-phone/GetInvoices', JSON.stringify({}), function(invoices){
                        X.Phone.Functions.LoadBankInvoices(invoices);
                    });
                } else if (PressedApplication == "whatsapp") {
                    $.post('https://x-phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                        X.Phone.Functions.LoadWhatsappChats(chats);
                    });
                } else if (PressedApplication == "phone") {
                    $.post('https://x-phone/GetMissedCalls', JSON.stringify({}), function(recent){
                        X.Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('https://x-phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
                        X.Phone.Functions.SetupSuggestedContacts(suggested);
                    });
                    $.post('https://x-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                } else if (PressedApplication == "mail") {
                    $.post('https://x-phone/GetMails', JSON.stringify({}), function(mails){
                        X.Phone.Functions.SetupMails(mails);
                    });
                    $.post('https://x-phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                } else if (PressedApplication == "advert") {
                    $.post('https://x-phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                        X.Phone.Functions.RefreshAdverts(Adverts);
                    })
                } else if (PressedApplication == "garage") {
                    $.post('https://x-phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                } else if (PressedApplication == "crypto") {
                    $.post('https://x-phone/GetCryptoData', JSON.stringify({
                        crypto: "qbit",
                    }), function(CryptoData){
                        SetupCryptoData(CryptoData);
                    })

                    $.post('https://x-phone/GetCryptoTransactions', JSON.stringify({}), function(data){
                        RefreshCryptoTransactions(data);
                    })
                } else if (PressedApplication == "racing") {
                    $.post('https://x-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else if (PressedApplication == "houses") {
                    $.post('https://x-phone/GetPlayerHouses', JSON.stringify({}), function(Houses){
                        SetupPlayerHouses(Houses);
                    });
                    $.post('https://x-phone/GetPlayerKeys', JSON.stringify({}), function(Keys){
                        $(".house-app-mykeys-container").html("");
                        if (Keys.length > 0) {
                            $.each(Keys, function(i, key){
                                var elem = '<div class="mykeys-key" id="keyid-'+i+'"> <span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Click to set GPS</span> </div>';

                                $(".house-app-mykeys-container").append(elem);
                                $("#keyid-"+i).data('KeyData', key);
                            });
                        }
                    });
                } else if (PressedApplication == "meos") {
                    SetupMeosHome();
                } else if (PressedApplication == "lawyers") {
                    $.post('https://x-phone/GetCurrentLawyers', JSON.stringify({}), function(data){
                        SetupLawyers(data);
                    });
                } else if (PressedApplication == "store") {
                    $.post('https://x-phone/SetupStoreApps', JSON.stringify({}), function(data){
                        SetupAppstore(data); 
                    });
                } else if (PressedApplication == "trucker") {
                    $.post('https://x-phone/GetTruckerData', JSON.stringify({}), function(data){
                        SetupTruckerInfo(data);
                    });
                }
            }
        }
    } else {
        X.Phone.Notifications.Add("fas fa-exclamation-circle", "System", X.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('https://x-phone/SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (X.Phone.Data.currentApplication === null) {
        X.Phone.Functions.Close();
    } else {
        X.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        X.Phone.Animations.TopSlideUp('.'+X.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            X.Phone.Functions.ToggleApp(X.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        X.Phone.Functions.HeaderTextColor("white", 300);

        if (X.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (X.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (X.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"}); 
            }, 400)
        }

        X.Phone.Data.currentApplication = null;
    }
});

X.Phone.Functions.Open = function(data) {
    X.Phone.Animations.BottomSlideUp('.container', 300, 0);
    X.Phone.Notifications.LoadTweets(data.Tweets);
    X.Phone.Data.IsOpen = true;
}

X.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

X.Phone.Functions.Close = function() {

    if (X.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            X.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            X.Phone.Animations.TopSlideUp('.'+X.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            X.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            X.Phone.Data.currentApplication = null;
        }, 500)
    } else if (X.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"}); 
    }

    X.Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('https://x-phone/Close');
    X.Phone.Data.IsOpen = false;
}

X.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

X.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

X.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

X.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

X.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

X.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('https://x-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (X.Phone.Notifications.Timeout == undefined || X.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!X.Phone.Data.IsOpen) {
                    X.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                X.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (X.Phone.Notifications.Timeout !== undefined || X.Phone.Notifications.Timeout !== null) {
                    clearTimeout(X.Phone.Notifications.Timeout);
                }
                X.Phone.Notifications.Timeout = setTimeout(function(){
                    X.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!X.Phone.Data.IsOpen) {
                        X.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    X.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                if (!X.Phone.Data.IsOpen) {
                    X.Phone.Animations.BottomSlideUp('.container', 300, -52);
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (X.Phone.Notifications.Timeout !== undefined || X.Phone.Notifications.Timeout !== null) {
                    clearTimeout(X.Phone.Notifications.Timeout);
                }
                X.Phone.Notifications.Timeout = setTimeout(function(){
                    X.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    if (!X.Phone.Data.IsOpen) {
                        X.Phone.Animations.BottomSlideUp('.container', 300, -100);
                    }
                    X.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

X.Phone.Functions.LoadPhoneData = function(data) {
    X.Phone.Data.PlayerData = data.PlayerData;
    X.Phone.Data.PlayerJob = data.PlayerJob;
    X.Phone.Data.MetaData = data.PhoneData.MetaData;
    X.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    X.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    X.Phone.Functions.SetupApplications(data);
    console.log("Phone succesfully loaded!");
}

X.Phone.Functions.UpdateTime = function(data) {    
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html(MessageTime + " <span style='font-size: 1.1vh;'>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

var NotificationTimeout = null;

X.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('https://x-phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);
        
            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }
        
            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

// X.Screen.Notification("Nieuwe Tweet", "Dit is een test tweet like #YOLO", "fab fa-twitter", 4000);

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                X.Phone.Functions.Open(event.data);
                X.Phone.Functions.SetupAppWarnings(event.data.AppData);
                X.Phone.Functions.SetupCurrentCall(event.data.CallData);
                X.Phone.Data.IsOpen = true;
                X.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            // case "LoadPhoneApplications":
            //     X.Phone.Functions.SetupApplications(event.data);
            //     break;
            case "LoadPhoneData":
                X.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                X.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                X.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                X.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
                break;
            case "RefreshAppAlerts":
                X.Phone.Functions.SetupAppWarnings(event.data.AppData);                
                break;
            case "UpdateMentionedTweets":
                X.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);                
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (X.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        console.log('Chat reloaded')
                        X.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        console.log('Chats reloaded')
                        X.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                X.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshWhatsappAlerts":
                X.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('https://x-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('https://x-phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                X.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                X.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);

                if (!X.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }

                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                X.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    X.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                X.Phone.Functions.HeaderTextColor("white", 300);
    
                X.Phone.Data.CallActive = false;
                X.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                X.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                X.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (X.Phone.Data.currentApplication == "advert") {
                    X.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                X.Phone.Data.PlayerJob = event.data.JobData;
                X.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('https://x-phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                X.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            X.Phone.Functions.Close();
            break;
    }
});

// X.Phone.Functions.Open();
