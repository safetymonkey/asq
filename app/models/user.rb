class User < ActiveRecord::Base
  # Load Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # before_save :get_ldap_params
  before_save :make_first_user_admin

  private

  # Is the user getting saved the ONLY user in the system?
  # Make sure it's an admin.
  def make_first_user_admin
    self.is_admin = true if User.count == 0
  end

  # def get_ldap_params
  #   self.name = Devise::LDAP::Adapter.get_ldap_param(login, 'gecos').blank? ?
  #     Devise::LDAP::Adapter.get_ldap_param(login, 'cn').first :
  #     Devise::LDAP::Adapter.get_ldap_param(login, 'gecos').first
  #   self.firstname = Devise::LDAP::Adapter.get_ldap_param(login, 'givenName').first
  #   self.lastname = Devise::LDAP::Adapter.get_ldap_param(login, 'sn').first
  #   self.email = Devise::LDAP::Adapter.get_ldap_param(login, 'mail').first
  # rescue NoMethodError
  #   logger.warn 'User created, but not found in LDAP'
  # end

  # Used if you have connected Devise to LDAP
  # def ldap_attr(attr_name)
  #   Devise::LDAP::Adapter.get_ldap_param(login, attr_name).first
  # rescue NoMethodError
  #   # return blank when ldap does not have the desired attribute.
  #   logger.warn "LDAP attribute '#{attr_name}' not found for '#{login}'"
  #   ''
  # end
end
