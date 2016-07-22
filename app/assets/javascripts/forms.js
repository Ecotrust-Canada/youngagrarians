
$('#location_province' ).change( function(e)
{
  if( $( this ).val() == 'BC' )
  {
    $('#location_bioregion').removeProp( 'disabled' ).closest( '.form-element' ).show();
    $('input[name="location[zoning]"]').removeProp( 'disabled' ).closest( '.form-element' ).show();
  }
  else
  {
    $('#location_bioregion').prop( 'disabled', true ).closest( '.form-element' ).hide();
    $('input[name="location[zoning]"]').prop( 'disabled', true ).closest( '.form-element' ).hide();
  }
} )
$('#location_bioregion' ).change( function(e)
{
  if( $( this ).val() == 'Lower Mainland - Fraser Valley' )
  {
    $('#location_fv_region').removeProp( 'disabled' ).closest( '.form-element' ).show();
  }
  else
  {
    $('#location_fv_region').prop( 'disabled', true ).closest( '.form-element' ).hide();
  }
} )


$.fn.helpify = function(help_text){
  $(this).each(function(){
    $(this).addClass('tooltip-wrapper')
      .append("<div class='tooltip tooltip-below'>"+help_text+"</div>")
  });
};

$('label:contains("Registered")').helpify("A registered lease on title is a lease that has been registered with the Land Title Office. When a lease is registered, it “runs with the land”, meaning that if ownership of the land changes hands, the lease is also transferred to the new owner. Note that in B.C. (this may differ between provinces) an unregistered lease of three years or less where the tenant is occupying the premises carries the same legal weight as a registered lease in the event of a sale.");

$('label:contains("Lease")').eq(1).helpify("A lease is an interest in land - an agreement between a land owner and tenant (farmer) that gives the tenant exclusive occupation and usage rights to a property or portion of property for a determined period of time in exchange for rent paid to the land owner. ");

$('label:contains("License")').helpify("Unlike a lease, a license is not an interest in land, but gives a person permission to do something on or with someone else's property, usually when a very specific use of the land is desired, such as a grazing licence. A licence is a very limited agreement and should only be considered in specific situations such as the above example.");

$('label:contains("Contract")').helpify("A contract is a legally binding agreement with specific terms between two or more persons or entities in which there is a promise to do something in return for a valuable benefit known as consideration. In order for a contract to be legally valid, it must: be an offer coupled with an acceptance; include an exchange of considerations, where something of value must come from each party (e.g. one person pays rent in exchange for using someone’s property); include subject matter that is not illegal; and involve parties that are competent to contract (e.g. an adult or other legal entity like a cooperative) and who have a mutual intention to be legally bound.");

$('label:contains("MOU")').helpify("A memorandum of understanding (MOU) is an agreement between at least two people that obliges each party to do or not to do specified things. MOUs are typically used as temporary agreements preceding a contract. It is not necessarily a legally binding agreement, though it may be considered legally binding if it meets the criteria above (see CONTRACT). If you would like a legally binding agreement, we recommend working with a lawyer to develop a contract.");

$('label:contains("Zoning")').helpify("BC ALR: The ALR is a provincial land-use zone in British Columbia in which agriculture is recognized as the priority use. Any parcel with the ALR notation may be subject to the ALC Act and the ALR Regulation.");



