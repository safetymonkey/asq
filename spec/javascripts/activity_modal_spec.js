function jHelpers() {};

describe('ActivityModal', function() {

  beforeEach(function() {
    affix('div.asq-panel#test-panel button.activity-log div.activity-modal-body tbody.activity-table div.loading-activity');
    testPanel = $('div.asq-panel');
    testButton = $('button.activity-log');
    testModal = $('div.activity-modal-body');
    testModal.data('refreshing', false);
    testModal.hide();
    jQuery.fx.off;
  });

  it('has correct initial visibility', function() {
    expect(testModal.is(':visible')).toBeFalsy();
  });

  it('initializes listeners on ready', function() {
    spyOn(ActivityModal, 'initScrollListeners');
    ActivityModal.onReady();
    expect(ActivityModal.initScrollListeners).toHaveBeenCalled();
  });

  describe('on click', function() {
    it('calls ActivityModal.run', function() {
      spyOn(ActivityModal,'run');
      testButton.click();
      expect(ActivityModal.run).toHaveBeenCalled();
    });

    it('clears the modal text', function() {
      spyOn(ActivityModal,'run');
      testModal.find('tbody.activity-table').html('blah');
      testButton.click();
      expect(testModal.find('tbody.activity-table').html()).toEqual('');
    });

    it('sets refreshing to false', function() {
      spyOn(ActivityModal,'run');
      testModal.data('refreshing', true);
      testButton.click();
      expect(testModal.data('refreshing')).toEqual(false);
    });

    it('scrolls to top of modal', function() {
      spyOn(ActivityModal,'run');
      spyOn($.fn,'animate')
      testButton.click();
      expect($.fn.animate).toHaveBeenCalled();
    });
  });

  describe('.panelId', function() {
    it('gets asq id from panel', function() {
      testPanel.data('asq_id', 12);
      expect(ActivityModal.panelId(testModal)).toEqual(12);
    });
  });

  describe('.lastId', function() {
    it('gets last id from table', function() {
      testTable = testModal.find('tbody.activity-table');
      testTable.append('<tr data-id=5></tr>');
      testTable.append('<tr data-id=6></tr>');
      testTable.append('<tr data-id=7></tr>');
      expect(ActivityModal.lastId(testModal)).toEqual(7);
    });
  });

  describe('.refreshing', function() {
    it('returns true when data-refreshing is true', function() {
      testModal.data('refreshing', true);
      expect(ActivityModal.refreshing(testModal)).toBeTruthy();
    });
    it('returns false when data-refreshing is false', function() {
      testModal.data('refreshing', false);
      expect(ActivityModal.refreshing(testModal)).toBeFalsy();
    });
    it('returns false when data-refreshing is not present', function() {
      expect(ActivityModal.refreshing(testModal)).toBeFalsy();
    });
  });

  describe('.scrolledToBottom', function() {
    it('returns false when not scrolled to bottom', function() {
      spyOn($.fn,'height').and.returnValues(100, 500);
      spyOn($.fn,'scrollTop').and.returnValue(50);
      expect(ActivityModal.scrolledToBottom(testModal)).toBeFalsy();
    });

    it('returns true when scrolled to bottom', function() {
      spyOn($.fn,'height').and.returnValues(100, 500);
      spyOn($.fn,'scrollTop').and.returnValue(400);
      expect(ActivityModal.scrolledToBottom(testModal)).toBeTruthy();
    });
  });

  describe('.run', function() {
    beforeEach(function() {
      testModal.data('refreshing', true);
      spyOn($,'ajax');
      spyOn($.fn, 'fadeIn');
      spyOn($.fn, 'fadeOut');
      ActivityModal.run(testModal);
    });

    it('calls ajax', function() {
      expect($.ajax).toHaveBeenCalled();
    });

    it('fades in loader', function() {
      expect($.fn.fadeIn).toHaveBeenCalled();
    });

    describe('on success', function() {
      beforeEach(function() {
        $.ajax.calls.mostRecent().args[0].success('hey now buddy');
      });

      it('fades out loader', function() {
        expect($.fn.fadeOut).toHaveBeenCalled();
      });

      it('resets refeshing to false', function() {
        expect(testModal.data('refreshing')).toBeFalsy();
      });

      it('appends results to table', function() {
        var html = testModal.find('tbody.activity-table').html();
        expect(html).toContain('hey now buddy');
      });
    });

    describe('on failure', function() {
      beforeEach(function() {
        $.ajax.calls.mostRecent().args[0].error();
      });
      it('fades out loader', function() {
        expect($.fn.fadeOut).toHaveBeenCalled();
      });
    });
  });
});
