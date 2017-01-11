function DirectFtpTest() {}

DirectFtpTest.prototype = {
  output: function output(input) {
    return input;
  },

  run: function run() {
    // so I can use "this" within the ajax context
    var t = this;
    FtpTestButton.modify($('#test-ftp-button'), 'default', 'Testing...');
    $('#test-ftp-results').fadeOut(function runFtpTest() {
      $.ajax( {
        url: '/ftp_service/test',
        data: $('.testable').serialize(),
        type: 'POST',
        dataType: 'text',

        success: function onSuccess(text) {
          t.processResults(text);
        },

        error: function onError() {
          var text = '{"status":"FAIL","message":"Problem reaching FTP test."}';
          t.processResults(text);
        },
      });
    });
  },

  processResults: function processResults(resultJson) {
    var results;
    results = jQuery.parseJSON(resultJson);
    if (results.status === 'OK') {
      this.onSuccess();
    } else {
      this.onFail(results.message);
    }
  },

  onSuccess: function onSuccess() {
    FtpTestButton.modify($('#test-ftp-results'), 'success', 'Success!', 'ok');
    $('#test-ftp-results').fadeIn();
    FtpTestButton.modify($('#test-ftp-button'), 'default', 'Retest?', 'refresh');
  },

  onFail: function onFail(msg) {
    var fMsg = typeof msg !== 'undefined' ? msg : 'Failed';
    FtpTestButton.modify($('#test-ftp-results'), 'danger', fMsg, 'exclamation-sign');
    $('#test-ftp-results').fadeIn();
    FtpTestButton.modify($('#test-ftp-button'), 'default', 'Retest?', 'refresh');
  },

  reset: function reset() {
    FtpTestButton.modify($('#test-ftp-button'), 'default', 'Test FTP Connection');
    $('#test-ftp-results').fadeOut();
  },

};


function FtpTestButton() {}

FtpTestButton.modify = function modify(button, state, text, icon) {
  var fIcon = typeof icon !== 'undefined' ? icon : false;
  button.removeClass('btn-default btn-primary btn-success btn-info');
  button.removeClass('btn-warning btn-danger btn-link');
  button.addClass('btn-' + state);
  button.find('.text').html(text);
  if (icon) {
    button.find('.icon').removeClass().addClass('icon glyphicon glyphicon-' + fIcon);
  } else {
    button.find('.icon').removeClass().addClass('icon');
  }
};

$( document ).ready(function ready() {
  var ftpTest = new DirectFtpTest();

  $('.edit_asq, .new_asq').on('click', '#test-ftp-button', function showResults() {
    ftpTest.run();
  });

  $('.edit_asq, .new_asq').on('click', '#test-ftp-results', function hideResults() {
    $(this).fadeOut();
  });

  $('#collapseDirectFtp').on('keyup keypress blur change', 'input', function onFormChange() {
    ftpTest.reset();
  });
});
