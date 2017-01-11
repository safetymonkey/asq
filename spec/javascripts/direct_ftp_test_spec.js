function jHelpers() {};

jHelpers.findSelector = function findSelector(array, selector) {
  var count = 0;
  $.each(array, function(index, value) {
    if (value['object']['selector'] === selector) {
      count++;
    }
  })
  return count;
};

describe('DirectFtpTest', function() {
  var ftpTest = new DirectFtpTest();

  beforeEach(function() {
    affix('form.edit_asq #collapseDirectFtp #test-ftp-button');
    affix('form.edit_asq #collapseDirectFtp #test-ftp-results');
    testButton = $('#test-ftp-button');
    testResults = $('#test-ftp-results');
    jQuery.fx.off;
  });

  it('has correct initial visibility', function() {
    testResults.hide();
    expect(testButton.is(':visible')).toBeTruthy();
    expect(testResults.is(':visible')).toBeFalsy();
  });

  describe('.processResults', function() {
    it('calls jQuery.parseJSON', function() {
      var okVal = '{"status":"OK"}';
      spyOn(jQuery,'parseJSON').and.returnValue(okVal);
      ftpTest.processResults('blah');
      expect(jQuery.parseJSON).toHaveBeenCalled();
    });

    it('calls onSuccess with OK response', function() {
      var okVal = '{"status":"OK"}';
      spyOn(ftpTest,'onSuccess');
      ftpTest.processResults(okVal);
      expect(ftpTest.onSuccess).toHaveBeenCalled();
    });

    it('calls onFail with FAIL response', function() {
      var failVal = '{"status":"FAIL"}';
      spyOn(ftpTest,'onFail');
      ftpTest.processResults(failVal);
      expect(ftpTest.onFail).toHaveBeenCalled();
    });
  });

  describe('.onSuccess', function() {
    it('calls fadeIn on test-ftp-results', function() {
      spyOn($.fn,'fadeIn');
      ftpTest.onSuccess();
      expect(jHelpers.findSelector($.fn.fadeIn.calls.all(),'#test-ftp-results')).toEqual(1);
    });

    it('sets test-ftp-results to success using FtpTestButton.modify', function() {
      spyOn(FtpTestButton,'modify');
      ftpTest.onSuccess();
      expect(FtpTestButton.modify).toHaveBeenCalledWith($('#test-ftp-results'), 'success', 'Success!', 'ok');
    });

    it('sets test-ftp-button to retest using FtpTestButton.modify', function() {
      spyOn(FtpTestButton,'modify');
      ftpTest.onSuccess();
      expect(FtpTestButton.modify).toHaveBeenCalledWith($('#test-ftp-button'), 'default', 'Retest?', 'refresh');
    });
  });

  describe('.onFail', function() {
    it('calls fadeIn on test-ftp-results', function() {
      spyOn($.fn,'fadeIn');
      ftpTest.onFail();
      expect(jHelpers.findSelector($.fn.fadeIn.calls.all(),'#test-ftp-results')).toEqual(1);
    });

    it('sets test-ftp-results to fail using FtpTestButton.modify', function() {
      spyOn(FtpTestButton,'modify');
      ftpTest.onFail();
      expect(FtpTestButton.modify).toHaveBeenCalledWith($('#test-ftp-results'), 'danger', 'Failed', 'exclamation-sign');
    });

    it('sets test-ftp-results to fail with msg using FtpTestButton.modify', function() {
      spyOn(FtpTestButton,'modify');
      ftpTest.onFail('bangarang');
      expect(FtpTestButton.modify).toHaveBeenCalledWith($('#test-ftp-results'), 'danger', 'bangarang', 'exclamation-sign');
    });

    it('sets test-ftp-button to retest using FtpTestButton.modify', function() {
      spyOn(FtpTestButton,'modify');
      ftpTest.onSuccess();
      expect(FtpTestButton.modify).toHaveBeenCalledWith($('#test-ftp-button'), 'default', 'Retest?', 'refresh');
    });
  });

  describe('.reset', function() {
    it('calls fadeIn on test-ftp-results', function() {
      spyOn($.fn,'fadeOut');
      ftpTest.reset();
      expect(jHelpers.findSelector($.fn.fadeOut.calls.all(),'#test-ftp-results')).toEqual(1);
    });

    it('sets test-ftp-button to reset using FtpTestButton.modify', function() {
      spyOn(FtpTestButton,'modify');
      ftpTest.reset();
      expect(FtpTestButton.modify).toHaveBeenCalledWith($('#test-ftp-button'), 'default', 'Test FTP Connection');
    });
  });

  describe('.run', function() {
    it('executes ajax call', function() {
      spyOn($.fn,'fadeOut').and.callFake(function (callback) {callback();});
      spyOn($,'ajax');
      ftpTest.run();
      expect($.ajax).toHaveBeenCalled();
    });

    it('calls processResults on success', function() {
      var okVal = '{"status":"OK"}';
      spyOn($.fn,'fadeOut').and.callFake(function (callback) {callback();});
      spyOn($,'ajax');
      spyOn(ftpTest,'processResults');
      ftpTest.run();
      $.ajax.calls.mostRecent().args[0].success(okVal);
      expect(ftpTest.processResults).toHaveBeenCalledWith(okVal);
    });

    it('calls processResults on error', function() {
      var okVal = '{"status":"OK"}';
      spyOn($.fn,'fadeOut').and.callFake(function (callback) {callback();});
      spyOn($,'ajax');
      spyOn(ftpTest,'processResults');
      ftpTest.run();
      $.ajax.calls.mostRecent().args[0].error(okVal);
      expect(ftpTest.processResults).toHaveBeenCalledWith('{"status":"FAIL","message":"Problem reaching FTP test."}');
    });
  });
});

describe('FtpTestButton', function() {

  var ftpTest = new DirectFtpTest();

  beforeEach(function() {
    affix('form.edit_asq #collapseDirectFtp #test-ftp-button span.icon');
    affix('form.edit_asq #collapseDirectFtp #test-ftp-results');
    testButton = $('#test-ftp-button');
    testResults = $('#test-ftp-results');
    jQuery.fx.off;
  });

  describe('.modify', function() {
    it('removes previous state classes from button', function() {
      testResults.addClass('btn-danger');
      FtpTestButton.modify(testResults, 'state', 'text', 'icon');
      expect(testResults.hasClass('btn-danger')).toBeFalsy();
    });

    it('adds new state classes to button', function() {
      FtpTestButton.modify(testResults, 'state', 'text', 'icon');
      expect(testResults.hasClass('btn-state')).toBeTruthy();
    });

    it('adds icon when present', function() {
      FtpTestButton.modify(testButton, 'state', 'text', 'icon');
      expect(testButton.find('.icon').hasClass('glyphicon-icon')).toBeTruthy();
    });
  });
});
