
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

if ((window.location+'').replace("://","").indexOf("/map") == -1)
  var backgrounds = [
    'url(/images/splash/apprenticeship2.jpg)',
    'url(/images/splash/apprenticeship.jpg)',
    'url(/images/splash/apprenticeships.jpg)',
    'url(/images/splash/businessbc2.jpg)',
    'url(/images/splash/businessbc.jpg)',
    'url(/images/splash/educationlinnaeafield.jpg)',
    'url(/images/splash/educationubcfarmagain.jpg)',
    'url(/images/splash/educationubcfarm.jpg)',
    'url(/images/splash/educationubcfield.jpg)',
    'url(/images/splash/educationwhitecrowfarmgarden.jpg)',
    'url(/images/splash/eventsalberta.jpg)',
    'url(/images/splash/eventsfarmersontarioyamixer.jpg)',
    'url(/images/splash/events.jpg)',
    'url(/images/splash/eventsubcyamixer.jpg)',
    'url(/images/splash/eventsyaontariomuskoka.jpg)',
    'url(/images/splash/farmalbertaanimals.jpg)',
    'url(/images/splash/farmanimalsalberta2.jpg)',
    'url(/images/splash/farmanimalsokanagangef.jpg)',
    'url(/images/splash/farmgreensimage3.jpg)',
    'url(/images/splash/farmpoultrychickens.jpg)',
    'url(/images/splash/farmseedlajardindelagrelinettequebec2.jpg)',
    'url(/images/splash/field-yellow-blur-grain-min.jpg)',
    'url(/images/splash/food-sunset-love-field-min.jpg)',
    'url(/images/splash/funding.jpg)',
    'url(/images/splash/fundingplumtree.jpg)',
    'url(/images/splash/jobs.jpg)',
    'url(/images/splash/jobsquebec.jpg)',
    'url(/images/splash/landjardindelagrelinettequebec.jpg)',
    'url(/images/splash/landubcfarm.jpg)',
    'url(/images/splash/landwheatfieldchasebcbesidegef.jpg)',
    'url(/images/splash/marketsbcafm20161.jpg)',
    'url(/images/splash/marketsbcafm20162.jpg)',
    'url(/images/splash/marketsbcafm20163.jpg)',
    'url(/images/splash/marketseedfarm.jpg)',
    'url(/images/splash/markets.jpg)',
    'url(/images/splash/organizationegpnorthvan.jpg)',
    'url(/images/splash/organizationplumtreezaklan.jpg)',
    'url(/images/splash/organizationsbees.jpg)',
    'url(/images/splash/organizationsfarmerson57th.jpg)',
    'url(/images/splash/organizations.jpg)',
    'url(/images/splash/organizationsubcfarm.jpg)',
    'url(/images/splash/publicationscosmoflowers.jpg)',
    'url(/images/splash/seedcollection.jpg)',
    'url(/images/splash/seeds2.jpg)',
    'url(/images/splash/seedsbcseedsconference.jpg)',
    'url(/images/splash/seedsfarmslettuce.jpg)',
    'url(/images/splash/seedsfrommexico.jpg)',
    'url(/images/splash/seedsinhand.jpg)',
    'url(/images/splash/seeds.jpg)',
    'url(/images/splash/servicessuppliersfarmhayfield.jpg)',
    'url(/images/splash/servicessuppliersgreenhouseviewgef.jpg)',
    'url(/images/splash/servicessuppliersstrawberriesunderplastic.jpg)',
    'url(/images/splash/servicessuppliersstrawberryplants.jpg)',
    'url(/images/splash/webresources2.jpg)',
    'url(/images/splash/webresources.jpg)'
  ];
  document.body.style.backgroundImage=backgrounds[Math.floor(Math.random() * backgrounds.length)];

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

