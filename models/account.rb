require 'sequel'
require 'json'

# Holds and persists an account's information
class Account < Sequel::Model
  set_allowed_columns :username, :email

  one_to_many :owned_projects, class: :Project, key: :owner_id
  many_to_many :projects,
               join_table: :accounts_projects,
               left_key: :contributor_id, right_key: :project_id

  plugin :timestamps, update_on_create: true
  plugin :association_dependencies, owned_projects: :destroy

  def password=(new_password)
    new_salt = SecureDB.new_salt
    hashed = SecureDB.hash_password(new_salt, new_password)
    self.salt = new_salt
    self.password_hash = hashed
  end

  def password?(try_password)
    try_hashed = SecureDB.hash_password(salt, try_password)
    try_hashed == password_hash
  end

  def to_json(options = {})
    JSON({
           type: 'account',
           id: id,
           username: username,
           email: email
         }, options)
  end
end
