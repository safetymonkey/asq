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

describe('DirectSftpTest', function() {
  var sftpTest = new DirectSftpTest();

  beforeEach(function() {
    affix('form.edit_asq #collapseDirectSftp #test-sftp-button');
    affix('form.edit_asq #collapseDirectSftp #test-sftp-results');
    testButton = $('#test-sftp-button');
    testResults = $('#test-sftp-results');
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
      sftpTest.processResults('blah');
      expect(jQuery.parseJSON).toHaveBeenCalled();
    });

    it('calls onSuccess with OK response', function() {
      var okVal = '{"status":"OK"}';
      spyOn(sftpTest,'onSuccess');
      sftpTest.processResults(okVal);
      expect(sftpTest.onSuccess).toHaveBeenCalled();
    });

    it('calls onFail with FAIL response', function() {
      var failVal = '{"status":"FAIL"}';
      spyOn(sftpTest,'onFail');
      sftpTest.processResults(failVal);
      expect(sftpTest.onFail).toHaveBeenCalled();
    });
  });

  describe('.onSuccess', function() {
    it('calls fadeIn on test-sftp-results', function() {
      spyOn($.fn,'fadeIn');
      sftpTest.onSuccess();
      expect(jHelpers.findSelector($.fn.fadeIn.calls.all(),'#test-sftp-results')).toEqual(1);
    });

    it('sets test-sftp-results to success using SftpTestButton.modify', function() {
      spyOn(SftpTestButton,'modify');
      sftpTest.onSuccess();
      expect(SftpTestButton.modify).toHaveBeenCalledWith($('#test-sftp-results'), 'success', 'Success!', 'ok');
    });

    it('sets test-sftp-button to retest using SftpTestButton.modify', function() {
      spyOn(SftpTestButton,'modify');
      sftpTest.onSuccess();
      expect(SftpTestButton.modify).toHaveBeenCalledWith($('#test-sftp-button'), 'default', 'Retest?', 'refresh');
    });
  });

  describe('.onFail', function() {
    it('calls fadeIn on test-sftp-results', function() {
      spyOn($.fn,'fadeIn');
      sftpTest.onFail();
      expect(jHelpers.findSelector($.fn.fadeIn.calls.all(),'#test-sftp-results')).toEqual(1);
    });

    it('sets test-sftp-results to fail using SftpTestButton.modify', function() {
      spyOn(SftpTestButton,'modify');
      sftpTest.onFail();
      expect(SftpTestButton.modify).toHaveBeenCalledWith($('#test-sftp-results'), 'danger', 'Failed', 'exclamation-sign');
    });

    it('sets test-sftp-results to fail with msg using SftpTestButton.modify', function() {
      spyOn(SftpTestButton,'modify');
      sftpTest.onFail('bangarang');
      expect(SftpTestButton.modify).toHaveBeenCalledWith($('#test-sftp-results'), 'danger', 'bangarang', 'exclamation-sign');
    });

    it('sets test-sftp-button to retest using SftpTestButton.modify', function() {
      spyOn(SftpTestButton,'modify');
      sftpTest.onSuccess();
      expect(SftpTestButton.modify).toHaveBeenCalledWith($('#test-sftp-button'), 'default', 'Retest?', 'refresh');
    });
  });

  describe('.reset', function() {
    it('calls fadeIn on test-sftp-results', function() {
      spyOn($.fn,'fadeOut');
      sftpTest.reset();
      expect(jHelpers.findSelector($.fn.fadeOut.calls.all(),'#test-sftp-results')).toEqual(1);
    });

    it('sets test-sftp-button to reset using SftpTestButton.modify', function() {
      spyOn(SftpTestButton,'modify');
      sftpTest.reset();
      expect(SftpTestButton.modify).toHaveBeenCalledWith($('#test-sftp-button'), 'default', 'Test SFTP Connection');
    });
  });

  describe('.run', function() {
    it('executes ajax call', function() {
      spyOn($.fn,'fadeOut').and.callFake(function (callback) {callback();});
      spyOn($,'ajax');
      sftpTest.run();
      expect($.ajax).toHaveBeenCalled();
    });

    it('calls processResults on success', function() {
      var okVal = '{"status":"OK"}';
      spyOn($.fn,'fadeOut').and.callFake(function (callback) {callback();});
      spyOn($,'ajax');
      spyOn(sftpTest,'processResults');
      sftpTest.run();
      $.ajax.calls.mostRecent().args[0].success(okVal);
      expect(sftpTest.processResults).toHaveBeenCalledWith(okVal);
    });

    it('calls processResults on error', function() {
      var okVal = '{"status":"OK"}';
      spyOn($.fn,'fadeOut').and.callFake(function (callback) {callback();});
      spyOn($,'ajax');
      spyOn(sftpTest,'processResults');
      sftpTest.run();
      $.ajax.calls.mostRecent().args[0].error(okVal);
      expect(sftpTest.processResults).toHaveBeenCalledWith('{"status":"FAIL","message":"Problem reaching SFTP test."}');
    });
  });

describe('SftpTestButton', function() {

  var sftpTest = new DirectSftpTest();

  beforeEach(function() {
    affix('form.edit_asq #collapseDirectSftp #test-sftp-button span.icon');
    affix('form.edit_asq #collapseDirectSftp #test-sftp-results');
    testButton = $('#test-sftp-button');
    testResults = $('#test-sftp-results');
    jQuery.fx.off;
  });

  describe('.modify', function() {
    it('removes previous state classes from button', function() {
      testResults.addClass('btn-danger');
      SftpTestButton.modify(testResults, 'state', 'text', 'icon');
      expect(testResults.hasClass('btn-danger')).toBeFalsy();
    });

    it('adds new state classes to button', function() {
      SftpTestButton.modify(testResults, 'state', 'text', 'icon');
      expect(testResults.hasClass('btn-state')).toBeTruthy();
    });

    it('adds icon when present', function() {
      SftpTestButton.modify(testButton, 'state', 'text', 'icon');
      expect(testButton.find('.icon').hasClass('glyphicon-icon')).toBeTruthy();
    });
  });
});
