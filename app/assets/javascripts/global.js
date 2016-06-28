
var toggleHam = function(e) {
  var menu = document.getElementById('menu')
  if (menu.className === "away") {
    e.target.className = 'expanded';
    menu.className="here";
  } else {
    e.target.className = 'compressed';
    menu.className="away";
  }
};

if ((window.location+'').indexOf("/map") == -1)
  document.body.style.background=[
    'url(/images/splash/sky-clouds-field-blue-min.jpg)',
    'url(/images/splash/field-yellow-blur-grain-min.jpg)',
    'url(/images/splash/food-sunset-love-field-min.jpg)'
  ][Math.floor(Math.random() * 3)];

/*
window.fbAsyncInit = function() {
  // init the FB JS SDK
  FB.init({
    appId      : '236752999835803',                        // App ID from the app dashboard
    status     : false,                                 // Check Facebook Login status
    xfbml      : false                                  // Look for social plugins on the page
  });

  // Additional initialization code such as adding Event Listeners goes here
};

// Load the SDK asynchronously
(function(){
   // If we've already installed the SDK, we're done
   if (document.getElementById('facebook-jssdk')) {return;}

   // Get the first script element, which we'll use to find the parent node
   var firstScriptElement = document.getElementsByTagName('script')[0];

   // Create a new script element and set its id
   var facebookJS = document.createElement('script'); 
   facebookJS.id = 'facebook-jssdk';

   // Set the new script's source to the source of the Facebook JS SDK
   facebookJS.src = '//connect.facebook.net/en_US/all.js';

   // Insert the Facebook JS SDK into the DOM
   firstScriptElement.parentNode.insertBefore(facebookJS, firstScriptElement);
 }());
 */
