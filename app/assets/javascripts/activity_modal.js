function ActivityModal() {}

ActivityModal.run = function run(modal, lastId) {
  var idParam = typeof lastId !== 'undefined' ? '?last_id=' + lastId : '';
  var loader = modal.find('div.loading-activity');
  var asqId = ActivityModal.panelId(modal);
  loader.fadeIn();
  $.ajax( {
    url: '/asqs/' + asqId + '/activity_rows' + idParam,
    type: 'GET',
    dataType: 'text',

    success: function onSuccess(text) {
      loader.fadeOut();
      modal.find('tbody.activity-table').append(text);
      modal.data('refreshing', false);
    },

    error: function onError() {
      loader.fadeOut();
    },
  });
};

// is the current modal scrolled to bottom? (bool)
ActivityModal.scrolledToBottom = function scrolledToBottom(modal) {
  // location of end of visible panel (height plus start)
  var val1 = modal.scrollTop() + modal.height();
  // heigh of panel
  var val2 = modal.find('.activity-table').height();
  // is the end of the panel visible?
  return val1 >= val2;
};

// does the current modal have data-refreshing = true? (bool)
ActivityModal.refreshing = function refreshing(modal) {
  return modal.data('refreshing') === true;
};

// last activity id displayed in modal
ActivityModal.lastId = function lastId(modal) {
  return modal.find('tr').last().data('id');
};

// asq id for a given modal
ActivityModal.panelId = function panelId(modal) {
  return modal.closest('.asq-panel').data('asq_id');
};

// scroll doesn't bubble up with on, we need to init with every dynamic modal add
ActivityModal.initScrollListeners = function initScrollListeners() {
  $('.activity-modal-body').scroll(function getActivity() {
    var modal = $(this);
    var lastId = ActivityModal.lastId(modal);
    if (ActivityModal.refreshing(modal) || !ActivityModal.scrolledToBottom(modal)) { return; }
    $(this).data('refreshing', true);
    ActivityModal.run(modal, lastId);
  });
};

ActivityModal.onReady = function onReady() {
  ActivityModal.initScrollListeners();
  $('body').on('click', 'button.activity-log', function getActivity() {
    var modal = $(this).closest('.asq-panel').find('.activity-modal-body');
    modal.find('tbody.activity-table').html('');
    modal.data('refreshing', false);
    ActivityModal.run(modal);
    modal.animate({ scrollTop: 0 });
  });
};

// init modals and activity button
$(document).ready(ActivityModal.onReady);
