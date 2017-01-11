class EmailTemplate < ActiveRecord::Base
  belongs_to :asq
  before_create :set_defaults

  private

  def set_defaults
    self.subject ||= ''
    self.body ||= ''
  end
end
