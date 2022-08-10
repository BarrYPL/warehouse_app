require 'sequel'
require 'bcrypt'
require 'rqrcode'
require 'rotp'

DB = Sequel.sqlite "databaset.db"

DB.create_table :users do
  primary_key :id
  String :username
  String :name
  String :password_hash
  int :isAdmin
  int :isMod
  date :isBanned
  int :is2FA
  String :twofaKey
end

DB.create_table :resistors do
  primary_key :id
  String :localid
  float :value
  int :quantity
  float :powerdissipation
  String :description
  String :location
end

DB.create_table :others do
  primary_key :id
  String :localid
  String :name
  int :quantity
  String :description
end

DB.create_table :mechanicals do
  primary_key :id
  String :localid
  String :name
  String :description
  String :parameter
  int :quantity
end

DB.create_table :inductors do
  primary_key :id
  int :localid
  String :name
  String :description
  float :value
  int :quantity
end

DB.create_table :capacitors do
  primary_key :id
  int :localid
  String :name
  String :description
  float :value
  int :quantity
  int :maxvoltage
end

DB.create_table :laboratoryeq do
  primary_key :id
  String :name
  String :serialnumber
  String :description
end

users = DB[:users]
resistors = DB[:resistors]
capacitors = DB[:capacitors]
inductors = DB[:inductors]
mechanicals = DB[:mechanicals]
laboratoryeq = DB[:laboratoryeq]

  def hash_password(password)
    BCrypt::Password.create(password).to_s
  end

  User = Struct.new(:username, :name, :password_hash, :isAdmin, :isMod, :is2FA, :twofaKey)
  USERSS = [
    User.new('bob', 'bob', hash_password('the builder'), 1, 1, 0),
    User.new('test', 'test', hash_password('test'), 0, 0, 0)
  ]

USERSS.each do |user|
	  users.insert username: user.username,
		name: user.name,
		password_hash: user.password_hash,
		isAdmin: user.isAdmin,
		isMod: user.isMod,
		isBanned: Time.now - 1;
end
