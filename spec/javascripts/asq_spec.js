describe('Asq', function() {

  beforeEach(function() {
    form = affix('form.edit_asq');
  });

  it('disables input tags on the form', function() {
    form.affix('input#1');
    form.affix('input#2');
    $('input').prop('disabled', false)
    disableAllInputTags(form);
    expect($('input').is(':disabled')).toBeTruthy();
  });

  it('enables input tags on the form', function() {
    form.affix('input#1');
    form.affix('input#2');
    $('input').prop('disabled', true)
    enableAllInputTags(form);
    expect($('input').is(':disabled')).toBeFalsy();
  });

  it('disables buttons on the form', function() {
    form.affix('button#1');
    form.affix('button#2');
    $('button').prop('disabled', false)
    disableAllButtons(form);
    expect($('button').is(':disabled')).toBeTruthy();
  });

  it('enables buttons on the form', function() {
    form.affix('button#1');
    form.affix('button#2');
    $('button').prop('disabled', true)
    enableAllButtons(form);
    expect($('button').is(':disabled')).toBeFalsy();
  });

  it('disables select tags on the form', function() {
    form.affix('select#1');
    form.affix('select#2');
    $('select').prop('disabled', false)
    disableAllSelectTags(form);
    expect($('select').is(':disabled')).toBeTruthy();
  });

  it('enables select tags on the form', function() {
    form.affix('select#1');
    form.affix('select#2');
    $('select').prop('disabled', true)
    enableAllSelectTags(form);
    expect($('select').is(':disabled')).toBeFalsy();
  });

  it('enables text input tags on the form', function() {
    form.affix('input[type="text"]');
    $('input').prop('disabled', true)
    enableTextInputTags(form);
    expect($('input[type="text"]').is(':disabled')).toBeFalsy();
  });

  it('sets text input tags on the form to read-only', function() {
    form.affix('input[type="text"]');
    $('input').prop('readonly', false)
    makeTextInputTagsReadOnly(form);
    expect($('input[type="text"]').prop('readonly')).toBeTruthy();
  });

  it('sets text input tags on the form to not-read-only', function() {
    form.affix('input[type="text"]');
    $('input').prop('readonly', true)
    makeTextInputTagsNotReadOnly(form);
    expect($('input[type="text"]').prop('readonly')).toBeFalsy();
  });

  it('sets textareas on the form to read-only', function() {
    form.affix('textarea');
    $('textarea').prop('readonly', false)
    makeTextAreasReadOnly(form);
    expect($('textarea').prop('readonly')).toBeTruthy();
  });

  it('sets textareas on the form to not-read-only', function() {
    form.affix('textarea');
    $('textarea').prop('readonly', true)
    makeTextAreasNotReadOnly(form);
    expect($('textarea').prop('readonly')).toBeFalsy();
  });

  it('enables hidden disabled elements', function() {
    form.affix('input');
    $('input').prop('disabled', true).prop('type', 'hidden');
    enableHiddenElements(form);
    expect($('input').is(':disabled')).toBeFalsy();
  });

  it ('leaves allow-while-disabled elements enabled', function() {
    form.affix('.allow-while-disabled');
    $('.allow-while-disabled').prop('disabled', true);
    fullyEnableAllowedElements(form);
    expect($('.allow-while-dsiabled').is(':disabled')).toBeFalsy();
  });

  it('calls disableAllInputTags when disableAsqEditForm is called', function() {
    spyOn(window, 'disableAllInputTags');
    disableAsqEditForm();
    expect(disableAllInputTags).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('calls disableAllButtons when disableAsqEditForm is called', function() {
    spyOn(window, 'disableAllButtons');
    disableAsqEditForm();
    expect(disableAllButtons).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('calls disableAllSelectTags when disableAsqEditForm is called', function() {
    spyOn(window, 'disableAllSelectTags');
    disableAsqEditForm();
    expect(disableAllSelectTags).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('calls makeTextInputTagsReadOnly when disableAsqEditForm is called', function() {
    spyOn(window, 'makeTextInputTagsReadOnly');
    disableAsqEditForm();
    expect(makeTextInputTagsReadOnly).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('calls makeTextAreasReadOnly when disableAsqEditForm is called', function() {
    spyOn(window, 'makeTextAreasReadOnly');
    disableAsqEditForm();
    expect(makeTextAreasReadOnly).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('calls enableHiddenElements when disableAsqEditForm is called', function() {
    spyOn(window, 'enableHiddenElements');
    disableAsqEditForm();
    expect(enableHiddenElements).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('calls fullyEnableAllowedElements when disableAsqEditForm is called', function() {
    spyOn(window, 'fullyEnableAllowedElements');
    disableAsqEditForm();
    expect(fullyEnableAllowedElements).toHaveBeenCalledWith($('form.edit_asq'));
  });

  it('properly slides down the disabled warning', function() {
    form.affix('#disabled-warning');
    $('#disabled-warning').hide();
    disableAsqEditForm();
    expect($('#disabled-warning').is(':hidden')).toBeFalsy();
  });

   it('calls enableAllInputTags when enableAsqEditForm is called', function() {
    spyOn(window, 'enableAllInputTags');
    enableAsqEditForm();
    expect(enableAllInputTags).toHaveBeenCalledWith($('form.edit_asq'));
   });

   it('calls enableAllButtons when enableAsqEditForm is called', function() {
    spyOn(window, 'enableAllButtons');
    enableAsqEditForm();
    expect(enableAllButtons).toHaveBeenCalledWith($('form.edit_asq'));
   });

   it('calls enableAllSelectTags when enableAsqEditForm is called', function() {
    spyOn(window, 'enableAllSelectTags');
    enableAsqEditForm();
    expect(enableAllSelectTags).toHaveBeenCalledWith($('form.edit_asq'));
   });

   it('calls makeTextInputTagsNotReadOnly when enableAsqEditForm is called', function() {
    spyOn(window, 'makeTextInputTagsNotReadOnly');
    enableAsqEditForm();
    expect(makeTextInputTagsNotReadOnly).toHaveBeenCalledWith($('form.edit_asq'));
   });

   it('calls makeTextAreasNotReadOnly when enableAsqEditForm is called', function() {
    spyOn(window, 'makeTextAreasNotReadOnly');
    enableAsqEditForm();
    expect(makeTextAreasNotReadOnly).toHaveBeenCalledWith($('form.edit_asq'));
   });

   it('slides up the disabled warning', function() {
    jQuery.fx.off = true;
    form.affix('#disabled-warning');
    $('#disabled-warning').show();
    enableAsqEditForm();
    expect($('#disabled-warning').is(':hidden')).toBeTruthy();
   });

   it('hides certain buttons in details view', function() {
    form.affix('button.save');
    form.affix('a.delete');
    form.affix('button.add-button');
    renderAsqDetailsView();
    expect($('button.save, a.delete, button.add-button').is(':hidden')).toBeTruthy();
   });

   it('disables the checkbox that disables the form in details view', function() {
    form.affix('input[type="checkbox"].disabled-control')
    renderAsqDetailsView();
    expect($('.disabled-control').is(':disabled')).toBeTruthy();
   });

   it('shows the disabled warning in details view when the disabled box is checked', function() {
    form.affix('div#disabled-warning');
    $('#disabled-warning').hide();
    form.affix('input[type="checkbox"].disabled-control');
    $('.disabled-control').prop('checked', true);
    renderAsqDetailsView();
    expect($('#disabled-warning').is(':hidden')).toBeFalsy();
   });

   it('hides the disabled warning in details view when the disabled box is checked', function() {
    form.affix('div#disabled-warning');
    $('#disabled-warning').hide();
    form.affix('input[type="checkbox"].disabled-control');
    $('.disabled-control').prop('checked', false);
    renderAsqDetailsView();
    expect($('#disabled-warning').is(':hidden')).toBeTruthy();
   });

   it('detects a valid Query (one without a write command)', function() {
    expect(isQueryInvalid('Select')).toBeFalsy();
   });

   it('detects an invalid Query (one with a write command)', function() {
    expect(isQueryInvalid('Delete')).toBeTruthy();
   });

  it('calls turnQueryErrorOn if an invalid Query is in the Query field', function() {
    form.affix('input.query');
    $('input.query').val('update');
    spyOn(window, 'turnQueryErrorOn');
    validateQueryField();
    expect(turnQueryErrorOn).toHaveBeenCalled();
   });

  it('calls turnQueryErrorOff if a valid Query is in the Query field', function() {
    form.affix('input.query');
    $('input.query').val('select');
    spyOn(window, 'turnQueryErrorOff');
    validateQueryField();
    expect(turnQueryErrorOff).toHaveBeenCalled();
   });

  it('shows the Query error message when turnQueryErrorOn is called', function() {
    form.affix('#query_error');
    $('#query_error').hide();
    turnQueryErrorOn();
    expect($('#query_error').is(':hidden')).toBeFalsy();
   });

  it('hides the Query error message when turnQueryErrorOff is called', function() {
    jQuery.fx.off = true;
    form.affix('#query_error');
    $('#query_error').show();
    turnQueryErrorOff();
    expect($('#query_error').is(':hidden')).toBeTruthy();
   });

  it('adds the has-error class to the Query field panel, so Bootstrap can mark it up', function () {
    var div = form.affix('div')
    div.affix('.query');
    turnQueryErrorOn();
    expect($('.query').parent().hasClass('has-error')).toBeTruthy();
   });

  it('removes the has-error class from the Query field panel, so Bootstrap can put it back to normal', function () {
    var div = form.affix('div')
    div.affix('.query');
    div.addClass('has-error')
    turnQueryErrorOff();
    expect($('.query').parent().hasClass('has-error')).toBeFalsy();
   });

   it('detects a valid URL', function() {
    expect(isUrlValid('http://www.hnnnnnnnnnng.com')).toBeTruthy();
   });

   it('detects an invalid URL', function() {
    expect(isUrlValid('ht:///hnnnnnnnnnng.')).toBeFalsy();
   });

   it('calls turnJsonErrorOn if an invalid URL is in the JSON field', function() {
    form.affix('input.json-url');
    $('input.json-url').val('h:.///rickandmorty100yearsforeverdotcom.');
    spyOn(window, 'turnJsonErrorOn');
    validateJsonUrlField();
    expect(turnJsonErrorOn).toHaveBeenCalled();
   });

   it('calls turnJsonErrorOff if a valid URL is in the JSON field', function() {
    form.affix('input.json-url');
    $('input.json-url').val('http://www.rickandmorty100yearsforeverdotcom.com');
    spyOn(window, 'turnJsonErrorOff');
    validateJsonUrlField();
    expect(turnJsonErrorOff).toHaveBeenCalled();
   });

   it('shows the JSON URL error message when turnJsonErrorOn is called', function() {
    form.affix('#json_url_error');
    $('#json_url_error').hide();
    turnJsonErrorOn();
    expect($('#json_url_error').is(':hidden')).toBeFalsy();
   });

   it('hides the JSON URL error message when turnJsonErrorOff is called', function() {
    jQuery.fx.off = true;
    form.affix('#json_url_error');
    $('#json_url_error').show();
    turnJsonErrorOff();
    expect($('#json_url_error').is(':hidden')).toBeTruthy();
   });

   it('disables the save button when turnJsonErrorOn is called', function () {
    form.affix('button.save');
    $('button.save').removeAttr('disabled');
    turnJsonErrorOn();
    expect($('button.save').is(':disabled')).toBeTruthy();
   });

   it('enables the save button when turnJsonErrorOff is called', function () {
    form.affix('button.save');
    $('button.save').attr('disabled', true);
    turnJsonErrorOff();
    expect($('button.save').is(':disabled')).toBeFalsy();
   });

   it('adds the has-error class to the JSON URL field panel, so Bootstrap can mark it up', function () {
    var div = form.affix('div')
    div.affix('.json-url');
    turnJsonErrorOn();
    expect($('.json-url').parent().hasClass('has-error')).toBeTruthy();
   });

   it('removes the has-error class from the JSON URL field panel, so Bootstrap can put it back to normal', function () {
    var div = form.affix('div')
    div.affix('.json-url');
    div.addClass('has-error')
    turnJsonErrorOff();
    expect($('.json-url').parent().hasClass('has-error')).toBeFalsy();
   });

    describe('Monitor Options', function () {
      it('hides monitor options panels for reports', function () {
          var menu = affix('.query-type-menu');
          var panel = affix('.monitor-options');

          menu.val('monitor');
          menu.val('report').trigger('change');
          expect(panel.is(':visible')).toBe(false);
      });
        it('shows monitor options panels for monitors', function () {
            var menu = affix('.query-type-menu');
            var panel = affix('.monitor-options');

            menu.val('report');
            menu.val('monitor').trigger('change');
            expect(panel.is(':visible')).toBe(true);
        });
    });

});
