describe('FileName', function() {
  var testFileName = new FileName();

    beforeEach(function() {
    jQuery.fx.off = true; //Turn off jQuery animations
      affix('.alert.alert-danger#filename_error[style="display:none"]');
    affix('input.filename');
    init(); //create keystroke listener.
    });

  it('Validates file name input', function() {
    expect(testFileName.output("input")).toBe("input");
  });

  //validates the filename output after date_time has been set.
  it('Check FileName output for protected characters ie."\ / : * ? " < > |"', function() {
    expect(testFileName.validateFileNameOutput("2015_09_03_this_is_a_file<>.csv")).toBeFalsy();
  });

  it('Show invalid characters message when an invalid file name is present.', function() {
    var $invalidFileName = "/time_warner_%Y%m%d.csv";

    //show error message on invalid file name.
    testFileName.showErrorMessage($invalidFileName);
    expect($('#filename_error').is(':visible')).toBeTruthy();
  });

  it('Hide invalid characters message when a valid character name is present.', function() {
    var $validFileName = "time_warner_%Y%m%d.csv";

    testFileName.showErrorMessage($validFileName);
    expect($('#filename_error').is(':visible')).toBeFalsy();
  });

  it('add "has-warning" class to filename form group when invalid file name is present', function() {
    var $invalidFileName = "/time_warner_%Y%m%d.csv";

    testFileName.showErrorMessage($invalidFileName);
    expect($('.filename').parent().hasClass('has-warning')).toBeTruthy();
  });

  it('removes "has-warning" class to filename form group when a valid file name is present', function() {
    var $validFileName = "time_warner_%Y%m%d.csv";

    testFileName.showErrorMessage($validFileName);
    expect($('.filename').parent().hasClass('has-warning')).toBeFalsy();
  });
});
