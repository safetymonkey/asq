// functions for full form disabling based on disabled check
function disableAllInputTags(form) {
  form.find('input').each(function () {
    $(this).prop('disabled', true );
  });
}

function enableAllInputTags(form) {
  form.find('input').each(function () {
    $(this).prop('disabled', false );
  });
}

function disableAllButtons(form) {
  form.find('button').each(function () {
    $(this).prop('disabled', true );
  });
}

function enableAllButtons(form) {
  form.find('button').each(function () {
    $(this).prop('disabled', false );
  });
}

function disableAllSelectTags(form) {
  form.find('select').each(function () {
    $(this).prop('disabled', true );
  });
}

function enableAllSelectTags(form) {
  form.find('select').each(function () {
    $(this).prop('disabled', false );
  });
}

function enableTextInputTags(form) {
  form.find('input[type="text"]').each(function () {
      $(this).prop('disabled', false );
  });
}

function makeTextInputTagsReadOnly(form) {
  form.find('input[type="text"]').each(function () {
      $(this).prop('readonly', true );
  });
}

function makeTextInputTagsNotReadOnly(form) {
  form.find('input[type="text"]').each(function () {
      $(this).prop('readonly', false );
  });
}

function makeTextAreasReadOnly(form) {
  form.find('textarea').each(function () {
      $(this).prop('readonly', true );
  });
}

function makeTextAreasNotReadOnly(form) {
  form.find('textarea').each(function () {
      $(this).prop('readonly', false );
  });
}

function enableHiddenElements(form) {
 form.find('input, textarea, button, select').each(function () {
    if ($(this).attr('type') == 'hidden') {
      $(this).prop('disabled', false );
    }
  });
}

function fullyEnableAllowedElements(form) {
    form.find('.allow-while-disabled').prop('disabled', false).prop('readonly', false)
}

function disableAsqEditForm() {
  var form = $('form.edit_asq')
  disableAllInputTags(form);
  disableAllButtons(form);
  disableAllSelectTags(form);
  enableTextInputTags(form);
  makeTextInputTagsReadOnly(form);
  makeTextAreasReadOnly(form);
  enableHiddenElements(form);
  fullyEnableAllowedElements(form);
  form.find('#disabled-warning').slideDown();
}

function enableAsqEditForm() {
  var form = $('form.edit_asq')
  enableAllInputTags(form);
  enableAllButtons(form);
  enableAllSelectTags(form);
  makeTextInputTagsNotReadOnly(form);
  makeTextAreasNotReadOnly(form);
  form.find('#disabled-warning').slideUp();
}

function renderAsqDetailsView() {
  var form = $('form.edit_asq')
  disableAsqEditForm();
  form.find('button.save, a.delete, button.add-button').hide();
  form.find('.disabled-control').prop('disabled', true);
  if ($('.disabled-control').is(':checked')) {
    form.find('#disabled-warning').show();
  } else {
    form.find('#disabled-warning').hide();
  }
}

// functions for email warning based on address validation

function turnEmailErrorOn() {
  $('.email_to').parent().addClass('has-error');
  $('#email_error').slideDown();
  $('.save').prop("disabled", true);
}

function turnEmailErrorOff() {
  $('.email_to').parent().removeClass('has-error');
  $('#email_error').slideUp();
  $('.save').prop("disabled", false);
}

// check if email options are all blank, expects jquery object
function isPanelEmpty(element) {
  var isEmpty = true;
  var panel = element.closest('.panel');
  panel.find('input:text, textarea').each(function checkTextInputs() {
    if ($(this).val() !== '') {
      isEmpty = false;
      return false;
    }
  });
  panel.find('input:checkbox').each(function checkCheckbox() {
    if ($(this).is(':checked')) {
      isEmpty = false;
      return false;
    }
  });

  return isEmpty;
}

// vaildate one or more email addresses if email is turned on
function validateEmailTo() {
  var emailRegex = /\b\w+@[\w.]+\.[A-z.]{2,4}\b/i;
  var emailErrors = 0;


  $('.email-to').val($('.email-to').val().replace(/\s+/g, '').replace(';', ','));
  $.each($('.email-to').val().split(','), function countErrors(index, value) {
    if (!emailRegex.test(value)) {
      emailErrors++;
    }
  });

  if (emailErrors === 0) {
    // cleared the check
    turnEmailErrorOff();
  } else if (isPanelEmpty($('.email-to'))) {
    // so... it didn't clear the check, but email is off so just remove bad email address and call it good
    turnEmailErrorOff();
  } else {
    // failed the check
    turnEmailErrorOn();
  }
}

// query verification and behavior

function turnQueryErrorOn() {
  $('.query').parent().addClass('has-error');
  $('#query_error').slideDown();
}

function turnQueryErrorOff() {
  $('.query').parent().removeClass('has-error');
  $('#query_error').slideUp();
}

function isQueryInvalid(query) {

  return /update|delete|drop|insert|truncate/i.test(query);
}

function validateQueryField() {
  var queryField = $('.query')
  if (isQueryInvalid(queryField.val())) {
    // failed the test if true
    turnQueryErrorOn();
  } else {
    // passed the test if false
    turnQueryErrorOff();
  }
}

// json url verification and behavior

function turnJsonErrorOn() {
  $('.json-url').parent().addClass('has-error');
  $('#json_url_error').slideDown();
  $('button.save').attr('disabled', true);
}

function turnJsonErrorOff() {
  $('.json-url').parent().removeClass('has-error');
  $('#json_url_error').slideUp();
  $('button.save').removeAttr('disabled');
}

function isUrlValid(url) {
  // This is a pretty gnarly regex, to be sure. According to some person
  // on Stack Overflow (Where Everyone Know What They're Talking About)
  // it's taken from the jQuery URL validator. I'm using a ^$| at the 
  // beginning to consider an empty field to also be valid.  
  return /^$|^(https?):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
}

function validateJsonUrlField() {
  var jsonUrlField = $('.json-url')
  if (isUrlValid(jsonUrlField.val())) {
    // passed the test
    turnJsonErrorOff();
  } else {
    // failed the test
    turnJsonErrorOn();
  }
}

function toggleChevron(e) {
  $(e.target)
  .prev('.panel-heading')
  .find('i.indicator')
  .toggleClass('glyphicon-chevron-right glyphicon-chevron-down');
}


function getNewForm(formIndex) {
  var newForm = '<div id="form_group_' + formIndex + '" class = "schedule-group row">' +
  '<div id="scheduleType_group_' + formIndex + '" class="form-group col-md-2 schedule-type-group">' +
'    <select class="form-control schedule-type" id="schedules_attributes_' + formIndex + '_type" name="asq[schedules_attributes][' + formIndex + '][type]">' +
'    <option selected="selected" value="IntervalSchedule">Every</option>' +
'    <option value="DailySchedule">Daily</option>' +
'    <option value="WeeklySchedule">Weekly</option>' +
'    <option value="MonthlySchedule">Monthly</option>' +
'    </select>' +
'  </div>' +
'' +
'  <div id="param_group_' + formIndex + '" class="form-group col-md-2 schedule-param-group">' +
'  <input class="form-control schedule-param" id="schedules_attributes_' + formIndex + '_param" name="asq[schedules_attributes][' + formIndex + '][param]" type="text" value="0" />' +
'  </div>' +
'' +
'  <div id="time_group_' + formIndex + '" class="form-group col-md-2 schedule-time-group">' +
'  <div class="input-group date schedule-date-picker">' +
'  <input class="form-control schedule-time" id="schedules_attributes_' + formIndex + '_time" name="asq[schedules_attributes][' + formIndex + '][time]" type="text" value="00:00" />' +
'    <span class="input-group-addon">' +
'    <span class="glyphicon glyphicon-time"></span>' +
'  </span>' +
'  </div>' +
'  </div>' +
'' +
'  <div id="time_zone_group' + formIndex + '" class="form-group col-md-2 schedule-time-zone-group" >' +
'  <select class="form-control schedule-time-zone" id="schedules_attributes_' + formIndex + '_time-zone" name="asq[schedules_attributes][' + formIndex + '][time_zone]">' +
'    <option value="Pacific Time (US & Canada)">Pacific</option>' +
'    <option value="Mountain Time (US & Canada)">Mountain</option>' +
'    <option value="Central Time (US & Canada)">Central</option>' +
'    <option value="Eastern Time (US & Canada)">Eastern</option>' +
'    <option value="UTC">UTC</option>' +
'  </select>' +
'  </div>' +
'' +
'  <div id="interval_type_group_' + formIndex + '" class="form-group col-md-2 schedule-interval-type-group" >' +
'  <select class="form-control schedule-interval-type" id="interval_type_' + formIndex + '" name="interval_type_' + formIndex + '">' +
'    <option value="1">Minutes</option>' +
'    <option value="60">Hours</option>' +
'    <option value="1440">Days</option>' +
'  </select>' +
'  </div>' +
'' +
'  <div id="spacer" class="form-group col-md-2 schedule-spacer schedule-spacer-2" >' +
'  </div>' +
'' +
'  <div id="spacer" class="form-group col-md-3 schedule-spacer schedule-spacer-3" >' +
'  </div>' +
'' +
'  <input class="destroy" id="schedules_attributes_' + formIndex + '__destroy" name="asq[schedules_attributes][' + formIndex + '][_destroy]" type="hidden" value="false" />' +
'' +
'  <div class="form-group col-md-1">' +
'  <button type="button" class="btn btn-link destroy-button">' +
'    <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>' +
'  </button>' +
'  </div>' +
'' +
'</div>';
  return newForm;
}

// schedule formatting
function formatSchedule(scheduleGroup, keepValue) {
  var scheduleType = scheduleGroup.find('.schedule-type').val();
  var paramField = scheduleGroup.find('.schedule-param');
  var paramValue = '';
  var timeValue = '00:00';
  var origParamValue;
  var origTimeValue;

  scheduleGroup.children('.form-group').show();
  scheduleGroup.children('.schedule-spacer').hide();

  if (keepValue) {
    origParamValue = scheduleGroup.find('.schedule-param').val();
    origTimeValue = scheduleGroup.find('.schedule-time').val();
  }

  paramField.replaceWith(generateParamsBlock(scheduleGroup));

  switch (scheduleType) {
  case 'IntervalSchedule':
    paramValue = '60';
    scheduleGroup.find('.schedule-time-group').hide();
    scheduleGroup.find('.schedule-time-zone-group').hide();
    scheduleGroup.find('.schedule-spacer-2').show();
    scheduleGroup.find('.schedule-spacer-3').show();
    selectBestInterval(scheduleGroup);
    break;
  case 'DailySchedule':
    scheduleGroup.find('.schedule-interval-type-group').hide();
    scheduleGroup.find('.schedule-param-group').hide();
    scheduleGroup.find('.schedule-spacer-2').show();
    scheduleGroup.find('.schedule-spacer-3').show();
    break;
  case 'WeeklySchedule':
    paramValue = '0';
    scheduleGroup.find('.schedule-interval-type-group').hide();
    scheduleGroup.find('.schedule-spacer-2').hide();
    scheduleGroup.find('.schedule-spacer-3').show();
    break;
  case 'MonthlySchedule':
    paramValue = '1';
    scheduleGroup.find('.schedule-interval-type-group').hide();
    scheduleGroup.find('.schedule-spacer-2').hide();
    scheduleGroup.find('.schedule-spacer-3').show();
    break;
  // no default
  }

  if (keepValue) {
    paramValue = origParamValue;
    timeValue = origTimeValue;
  }


  scheduleGroup.find('.schedule-param').val(paramValue);
  scheduleGroup.find('.schedule-time').val(timeValue);
}

// mark schedule for removal
function newScheduleForm(callback) {
  var formIndex = $('.schedule-group').length;
  var newForm = getNewForm(formIndex);
  $('.add-schedule-group').before(newForm);
  formatSchedule($('.schedule-group').last());
  callback();
}

function removeSchedule(scheduleGroup) {
  scheduleGroup.find('.destroy').val(true);
}

function selectBestInterval(scheduleGroup) {
  var paramField = scheduleGroup.find('.schedule-param');
  var intervalField = scheduleGroup.find('.schedule-interval-type');

  if (paramField.val() > 0) {
    if (paramField.val() % 1440 === 0) {
      intervalField.val(1440);
      paramField.val(paramField.val() / 1440);
      return;
    }
    if (paramField.val() % 60 === 0) {
      intervalField.val(60);
      paramField.val(paramField.val() / 60);
      return;
    }
  }

  intervalField.val(1);
  return;
}

// watch for schedule type change
function watchSched() {
  $('.schedule-type').change(function formatOnSchedChange(event) {
    formatSchedule($(event.target).parent().parent(), false);
  });

  $(function initDatePicker() {
    $('.schedule-date-picker').datetimepicker({
      format: 'HH:mm',
    });

    // watch for schedule removal
    $('.destroy-button').click(function removeScheduleOnDestroy(event) {
      var scheduleGroup = $(event.target).parents('.schedule-group');
      removeSchedule(scheduleGroup);
      scheduleGroup.slideUp();
    });
  });
}

function generateParamsBlock(scheduleGroup) {
  var optionBlock;
  var paramField = scheduleGroup.find('.schedule-param');
  var scheduleType = scheduleGroup.find('.schedule-type').val();

  switch (scheduleType) {
  case 'WeeklySchedule':
    optionBlock = '<select class="form-control schedule-param"" id="' + paramField.attr('id') + '" name="' + paramField.attr('name') + '">' +
'<option value="0">Sunday</option>' +
'<option value="1">Monday</option>' +
'<option value="2">Tuesday</option>' +
'<option value="3">Wednesday</option>' +
'<option value="4">Thursday</option>' +
'<option value="5">Friday</option>' +
'<option value="6">Saturday</option>';
    break;
  case 'MonthlySchedule':
    optionBlock = '<select class="form-control schedule-param"" id="' + paramField.attr('id') + '" name="' + paramField.attr('name') + '">' +
'<option value="1">1st</option>' +
'<option value="2">2nd</option>' +
'<option value="3">3rd</option>' +
'<option value="4">4th</option>' +
'<option value="5">5th</option>' +
'<option value="6">6th</option>' +
'<option value="7">7th</option>' +
'<option value="8">8th</option>' +
'<option value="9">9th</option>' +
'<option value="10">10th</option>' +
'<option value="11">11th</option>' +
'<option value="12">12th</option>' +
'<option value="13">13th</option>' +
'<option value="14">14th</option>' +
'<option value="15">15th</option>' +
'<option value="16">16th</option>' +
'<option value="17">17th</option>' +
'<option value="18">18th</option>' +
'<option value="19">19th</option>' +
'<option value="20">20th</option>' +
'<option value="21">21st</option>' +
'<option value="22">22nd</option>' +
'<option value="23">23rd</option>' +
'<option value="24">24th</option>' +
'<option value="25">25th</option>' +
'<option value="26">26th</option>' +
'<option value="27">27th</option>' +
'<option value="28">28th</option>' +
'<option value="29">29th</option>' +
'<option value="30">30th</option>' +
'<option value="31">31st / Last</option>' +
'</select>';
    break;
  default:
    optionBlock = '<input class="form-control schedule-param" id="' + paramField.attr('id') + '" name="' + paramField.attr('name') + '" type="text" value="0" />';
    break;
  }
  return optionBlock;
}


// used to refresh asq panels with updated information.
function refresh(asqPanelContainer) {
  var requestUrl;
  var overlay = asqPanelContainer.find('.asq-overlay');
  var body = asqPanelContainer.find('.panel-body');
  var intId;

  // get the panel's asq id, which will help us send an HTTP refresh request:
  var asqId = asqPanelContainer.find('.panel').attr('data-asq_id');

  // get the panel's last_run_value for comparison:
  // var lastUpdated = asqPanelContainer.find('.hidden_last_run').html();

  // If the URL is for a specific Asq, then render the complete Asq.
  // Otherwise, render just the partial Asq. 
  var regex = new RegExp("asqs/[0-9]*");
  if (document.URL.match(regex)) {
    requestUrl = '/asqs/' + asqId;
  } else {
    requestUrl = '/asqs/partial/' + asqId;
  };

  overlay.fadeTo(500, 1);
  body.fadeTo(1500, 0.2);

  // hit the asq/ajax endpoint to get its last_run time and compare
  intId = setInterval(function asqRefreshLoop() {
    $.ajax({url: '/asqs/ajax/' + asqId + '/refresh_in_progress', dataType: 'json', success: function processAjaxRepsonse(result) {
      if (result.refresh_in_progress === false) {
        clearInterval(intId);
        // at this point, hit the request_url and grab the updated panel:
        $.ajax({url: requestUrl, success: function replacePanel(refreshedPanel) {
          asqPanelContainer.html($(refreshedPanel).find('.panel-container').html());
          asqPanelContainer.find('.panel-body').css('opacity', '0.2').fadeTo(400, 1);
          asqPanelContainer.find('.asq-overlay').show().fadeOut(700);
          ActivityModal.initScrollListeners();
        }});
      }
    }});
  }, 1000);
}

$('body').on('ajax:success', '.test-class', function runAsqRefresh() {
  var asqPanelContainer = $(this).parents('.panel-container');
  $(this).click(function returnFalse() {return false;});
  $(this).attr('disabled', true);

  refresh(asqPanelContainer);
});


$(document).ready(function initAsq() {
// email address verification and behavior
// TODO: make reusable for JSON url
  $('[data-toggle="tooltip"]').tooltip();

  $('.email-option').on('change keyup', function watchEmailField() {
    validateEmailTo();
  });

  if ($('.query-type-menu').val() === 'report') {
    $('.monitor-options').hide();
  }

  $(document).on('change', '.query-type-menu', function handleQueryType() {
    if ($(this).val() === 'monitor') {
      $('.monitor-options').slideDown();
    } else {
      $('.monitor-options').slideUp();
    }
  });

  $('.disabled-control').on('change', function checkDisabledOnChange() {
    if ($('.disabled-control').is(':checked')) {
      disableAsqEditForm($('form.edit_asq'));
    } else {
      enableAsqEditForm($('form.edit_asq'));
    }
  });

  if ($('.email_option').length > 0) {
    validateEmailTo();
  }

  $('.query').on('keyup', function queryTextValidate() {
    validateQueryField();
  });

  $('.json-url').on('keyup', function jsonTextValidate() {
    validateJsonUrlField();
  });

  $('json-url').on('click', function jsonToggleAndVerify() {
    validateJsonUrlField();
  });

  $('.panel-collapse').on('hide.bs.collapse', toggleChevron);
  $('.panel-collapse').on('show.bs.collapse', toggleChevron);
  $('#accordion').find('.panel-collapse').first().addClass('in');
  $('#accordion').find('.panel-collapse').first().triggerHandler('hide.bs.collapse');

  // iterate through schedule groups for initial formatting
  $('.schedule-group').each( function formatSchedules() {
    formatSchedule($(this), true);
  });

  // watch for schedule add
  $('.add-button').click(function addScheduleOnClick() {
    newScheduleForm(watchSched);
  });

  // convert intervals to minutes on submit
  $('form').submit(function loopThroughGroups() {
    $('.schedule-group').each( function doMinuteMath() {
      var param;
      var intervalType;
      var paramVal;
      var interval;

      if ($(this).find('.schedule-type').val() === 'interval') {
        param = $(this).find('.schedule-param');
        intervalType = $(this).find('.schedule-interval-type');
        paramVal = param.val();
        interval = intervalType.val();
        param.val(paramVal * interval);
        intervalType.val(1);
      }
    });
  });

  watchSched();

  if (gon.details_view == true) {
    renderAsqDetailsView();
  } else if ($('.disabled-control').is(':checked')) {
    disableAsqEditForm();
  }

});
