# Represents a connetion to a database that Asqs will run their
# queries against.
class Database < ActiveRecord::Base
  has_many :asqs
  validates :name, presence: true, uniqueness: true
  crypt_keeper :password, encryptor: :active_support, key: 'I think super long ' \
    'passwords tend to be the best ones, don\'t you?', salt: 'sodium chloride'

  enum db_type: {
    mysql: 0,
    postgres: 1,
    oracle: 2
  }
end
