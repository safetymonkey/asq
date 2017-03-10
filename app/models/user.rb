class User < ActiveRecord::Base
  # Load Devise modules
  if Rails.configuration.feature_settings['ldap']
    devise :ldap_authenticatable, :rememberable, :trackable
  else
    devise :database_authenticatable, :rememberable, :trackable, :recoverable,
           :registerable
  end
  # Haven't re-added: :recoverable, :registerable, :validatable
  # Look at adding database_authenticatable?

  before_save :sync_ldap_params if Rails.configuration.feature_settings['ldap']
  before_save :make_first_user_admin

  def name
    login
  end

  # Overriding methods from Devise to enable admin approval for new accounts
  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  private

  # Is the user getting saved the ONLY user in the system?
  # Make sure it's an admin.
  def make_first_user_admin
    return unless User.count.zero?

    self.is_admin = true
    self.approved = true
  end

  def sync_ldap_params
    # self.name = ldap_attr('gecos').blank? ? ldap_attr('cn') : ldap_attr('gecos')
    self.email = ldap_attr('mail')
  end

  # Used if you have connected Devise to LDAP
  def ldap_attr(attr_name)
    Devise::LDAP::Adapter.get_ldap_param(login, attr_name).first
  rescue NoMethodError
    # return blank when ldap does not have the desired attribute.
    logger.warn "LDAP attribute '#{attr_name}' not found for '#{login}'"
    ''
  end
end
