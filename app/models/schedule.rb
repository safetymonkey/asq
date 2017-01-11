class Schedule < ActiveRecord::Base
  belongs_to :asq
  validates :time, format: { with: /([0-2][0-3]|[0-1][0-9]):[0-5][0-9]/,
                             message: 'Improper time format, use HH:MM' },
            allow_blank: true
  validates :param, numericality: { greater_than_or_equal_to: 0 },
            allow_blank: true

  def get_scheduled_date
    logger.error 'get_scheduled_date is not intended to be called for ' \
      'base class Schedule'
    false
  end
end
