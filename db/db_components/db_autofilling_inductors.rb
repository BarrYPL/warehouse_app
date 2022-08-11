require 'sequel'
require_relative '..\..\app\controllers\private_methods.rb'

DB = Sequel.sqlite 'databaset.db'

$capacitorsDB = DB[:inductors]

$capacitorsDB.each do |k|
  if k[:description][-2] == "?"
    k[:description][-2] = "u"
    $capacitorsDB.where(:id => k[:id]).update(description: k[:description])
  end
  x = k[:description][0..-3].to_f.to_database_num(k[:description][-2])
  $capacitorsDB.where(:id => k[:id]).update(value: x)
end
