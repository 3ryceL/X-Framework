X.Phone.Settings = {};
X.Phone.Settings.Background = "default-x";
X.Phone.Settings.OpenedTab = null;
X.Phone.Settings.Backgrounds = {
    'default-x': {
        label: "Standard x"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        X.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        X.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "profilepicture") {
        X.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        X.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        X.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", X.Phone.Data.AnonymousCall);

        if (!X.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = X.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        X.Phone.Notifications.Add("fas fa-paint-brush", "Settings", X.Phone.Settings.Backgrounds[X.Phone.Settings.Background].label+" is ingesteld!")
        X.Phone.Animations.TopSlideUp(".settings-"+X.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+X.Phone.Settings.Background+".png')"})
    } else {
        X.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        X.Phone.Animations.TopSlideUp(".settings-"+X.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+X.Phone.Settings.Background+"')"});
    }

    $.post('https://x-phone/SetBackground', JSON.stringify({
        background: X.Phone.Settings.Background,
    }))
});

X.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        X.Phone.Settings.Background = MetaData.background;
    } else {
        X.Phone.Settings.Background = "default-x";
    }

    var hasCustomBackground = X.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+X.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+X.Phone.Settings.Background+"')"});
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    X.Phone.Animations.TopSlideUp(".settings-"+X.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

X.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(X.Phone.Settings.Backgrounds, function(i, background){
        if (X.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            X.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            X.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    X.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    X.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    X.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = X.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        X.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard avatar set!")
        X.Phone.Animations.TopSlideUp(".settings-"+X.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        X.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal avatar set!")
        X.Phone.Animations.TopSlideUp(".settings-"+X.Phone.Settings.OpenedTab+"-tab", 200, -100);
        console.log(ProfilePicture)
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('https://x-phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    X.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    X.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            X.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            X.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    X.Phone.Animations.TopSlideUp(".settings-"+X.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    X.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});