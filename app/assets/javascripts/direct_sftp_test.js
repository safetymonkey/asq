function DirectSftpTest() {}

DirectSftpTest.prototype = {
  output: function output(input) {
    return input;
  },

  run: function run() {
    // so I can use "this" within the ajax context
    var t = this;
    SftpTestButton.modify($('#test-sftp-button'), 'default', 'Testing...');
    $('#test-sftp-results').fadeOut(function runSftpTest() {
      $.ajax( {
        url: '/sftp_service/test',
        data: $('.testable').serialize(),
        type: 'POST',
        dataType: 'text',

        success: function onSuccess(text) {
          t.processResults(text);
        },

        error: function onError() {
          var text = '{"status":"FAIL","message":"Problem reaching SFTP test."}';
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
    SftpTestButton.modify($('#test-sftp-results'), 'success', 'Success!', 'ok');
    $('#test-sftp-results').fadeIn();
    SftpTestButton.modify($('#test-sftp-button'), 'default', 'Retest?', 'refresh');
  },

  onFail: function onFail(msg) {
    var fMsg = typeof msg !== 'undefined' ? msg : 'Failed';
    SftpTestButton.modify($('#test-sftp-results'), 'danger', fMsg, 'exclamation-sign');
    $('#test-sftp-results').fadeIn();
    SftpTestButton.modify($('#test-sftp-button'), 'default', 'Retest?', 'refresh');
  },

  reset: function reset() {
    SftpTestButton.modify($('#test-sftp-button'), 'default', 'Test SFTP Connection');
    $('#test-sftp-results').fadeOut();
  },

};


function SftpTestButton() {}

SftpTestButton.modify = function modify(button, state, text, icon) {
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
  var sftpTest = new DirectSftpTest();

  $('.edit_asq, .new_asq').on('click', '#test-sftp-button', function showResults() {
    sftpTest.run();
  });

  $('.edit_asq, .new_asq').on('click', '#test-sftp-results', function hideResults() {
    $(this).fadeOut();
  });

  $('#collapseDirectSftp').on('keyup keypress blur change', 'input', function onFormChange() {
    sftpTest.reset();
  });
});
