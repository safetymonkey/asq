function FileName() {}

FileName.prototype = {
  output: function(input) {
    return input;
  },

  validateFileNameOutput: function(fileName){
    //list of protected characters to search for. 
    var regex =/[\\\/\:\*\?\"\<\>\|]/;
    //returns false if we find a match.
    return !fileName.match(regex);
  },

  showErrorMessage: function(fileName){
    if(this.validateFileNameOutput(fileName)){
      $('.filename').parent().removeClass('has-warning');
      $('#filename_error').slideUp();
      return;
    }
      $('.filename').parent().addClass('has-warning');
      $('#filename_error').slideDown();
  }
}


var init = function(){
  var validator = new FileName();
  validator.showErrorMessage($('input.filename').val());
  $('input.filename').keyup(function(){
    validator.showErrorMessage($('input.filename').val());
  });
  $('input.filename').change(function(){
    validator.showErrorMessage($('input.filename').val());
  });
}


$(document).ready(function() {
  if ($("input.filename" ).length) {
    init();
  }
});

