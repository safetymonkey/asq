if (typeof gon !== 'undefined' && gon.view === 'settings#index') {

  function validateStatementTimeout() {
    if ($('.query_timeout').val() > gon.max_db_timeout) {
      $('#timeout_error').find('.alert').html('Setting a timeout greater than ' + gon.max_db_timeout + ' may cause never-ending jobs. Consider lowering the timeout.');
      $('#timeout_error').slideDown();
    } else {
      $('#timeout_error').slideUp();
      $('#timeout_error').find('.alert').html('');
    }
  }

  $(document).ready(function initSettings() {
  // email address verification and behavior
  // TODO: make reusable for JSON url
    validateStatementTimeout();
  });

  $('body').on('change keyup', '.query_timeout', function validateTimeout() {
    validateStatementTimeout();
  });
}
