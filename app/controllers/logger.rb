class DbLogger
  def log_action(action: "", userid:"", itemid:"", old:"", new:"")
    p "#{action}, #{userid}, #{itemid}, #{old}, #{new}"
    #$logsDB.insert()
  end
end
