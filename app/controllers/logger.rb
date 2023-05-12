class DbLogger
  def log_action(action: "", userid:"", itemid:"", old:"", new:"", columnName:"")
    #p "#{action}, #{userid}, #{itemid}, #{old}, #{new}"
    $logsDB.insert(action: action,
      userid: userid,
      itemid: itemid,
      old: old,
      new: new,
      datetime: Time.now(),
      columnName: columnName
    )
  end
end
