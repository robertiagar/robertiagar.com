$(document).ready(function(){
   var $imgWrapper   = $('.jumbotron');
   var $imgs         = $imgWrapper.find("img");
   
   $imgs.on('ab-color-found', function(e, data){
      var parent = $(this).parents('.jumbotron');

	  
      parent.css({ 
        backgroundColor: data.color
      });
    });
   
   $.adaptiveBackground.run({normalizeTextColor:true});
});