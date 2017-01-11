describe('DirectFtpTest', function() {
  it('some timing tests', function() {
    timerCallback = jasmine.createSpy("timerCallback");
    jasmine.clock().install();

    setTimeout(function() {
      timerCallback();
    }, 100);

    expect(timerCallback).not.toHaveBeenCalled();
    jasmine.clock().tick(101);
    expect(timerCallback).toHaveBeenCalled();

    jasmine.clock().uninstall();
  });
});
