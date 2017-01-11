function testDatabase() {
  $.ajax( { 
    url: "/db_test", 
    data: $( ".testable" ).serialize(), 
    type: "POST", 
    dataType : "text",

    success: function( text ) {
      $( "#test-results" ).html(text)
    },

    error: function( xhr, status, errorThrown ) {
      console.log( "Error: " + errorThrown );
      console.log( "Status: " + status );
      console.dir( xhr );
    },
  });
}

$(".edit_database,.new_database").on('click','button.test-database', function() {
  testDatabase();
});
