require 'sequel'
require_relative '..\..\app\controllers\private_methods.rb'

DB = Sequel.sqlite 'databaset.db'

$capacitorsDB = DB[:capacitors]

$capacitorsDB.each do |k|
  if k[:name][-2] == "?"
    k[:name][-2] = "u"
    $capacitorsDB.where(:id => k[:id]).update(name: k[:name])
  end
  x = k[:name][0..-3].to_f.to_database_num(k[:name][-2])
end
