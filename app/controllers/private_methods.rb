DB = Sequel.sqlite 'db/database.db'

$usersDB = DB[:uzytkownicy]
$elementsDB = DB[:elementy]
$locationsDB = DB[:locations]
$logsDB = DB[:logs]
$logger = DbLogger.new()

class Numeric
  def to_human_redable
    if self == 0
      return 0
    end
    if self >= 1
      return formati_si(self)
    else
      return formatf_si(self)
    end
  end
end

class NilClass
  def to_human_redable
    return 0
  end
  def length
    return 0
  end
  def method_missing(m, *args, &block)
    return nil
  end
end

class Symbol
  def to_human_text
    return self.to_s.split('_').each{ |word| word.capitalize! }.join(' ')
  end
end

class String
  def to_database_text
    return self.gsub(' ','_').downcase
  end
end

def formati_si(size)
  scale = 1000;
  ndx = 1

  conv = [ '', 'K', 'M', 'G', 'T']

  size=size.to_f
  [1,2,3,4].each do |ndx|
    if( size < (scale**ndx)) then
      if is_natural(size/(scale**(ndx-1)))
        return "#{(size/(scale**(ndx-1))).to_i} #{conv[ndx-1]}"
      else
        return "#{'%.1f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
      end
    end
  end
  ndx=5
  if is_natural(size/(scale**(ndx-1)))
    return "#{(size/(scale**(ndx-1))).to_i} #{conv[ndx-1]}"
  else
    return "#{'%.1f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
  end
end

def is_natural(float_num)
  if float_num.rationalize.denominator == 1
    return true
  else
    return false
  end
end

def formatf_si(size)
  scale = 1000
  ndx = 1

  conv = [ 'm', 'μ', 'n', 'p', 'f']

  size=size.to_f
  [1,2,3,4].each do |ndx|
    if( size >= (scale**-ndx)) then
      if is_natural(size*(scale**ndx))
        return "#{(size*(scale**ndx)).to_i} #{conv[ndx-1]}"
      else
        return "#{'%.1f' % (size*(scale**ndx))} #{conv[ndx-1]}"
      end
    end
  end
  ndx=5
  if is_natural(size*(scale**ndx))
    return "#{(size*(scale**ndx)).to_i} #{conv[ndx-1]}"
  else
    return "#{'%.1f' % (size*(scale**ndx))} #{conv[ndx-1]}"
  end
end

class Numeric
  def to_database_num(prefix)
    return format_num(self, prefix)
  end
end

def format_num(size, prefix)
  case prefix
  when 'K','k'
    return size*10**3
  when 'M'
    return size*10**6
  when 'G'
    return size*10**9
  when 'T'
    return size*10**12
  when 'm'
    return (size*10**-3)
  when 'u'
    return (size*10**-6)
  when 'n'
    return (size*10**-9)
  when 'p'
    return (size*10**-12)
  else
    return size
  end
end

class String
  def id_exists?
    @countedResults = $elementsDB.where(:localid  => self).count
    if @countedResults == 0
      return false
    else
      return true
    end
  end
end

def select_item(itemName)
  @first_search = $elementsDB.where(Sequel.like(:localid, "#{itemName}", case_insensitive: true)).all
  unless @first_serch.empty?
    @record = $elementsDB.where(Sequel.like(:localid, "#{itemName}", case_insensitive: true)).all[0]
  end
  @second_search = $elementsDB.where(Sequel.like(:id, "#{itemName}", case_insensitive: true)).all
  unless @second_search.empty?
    @record = $elementsDB.where(Sequel.like(:id, "#{itemName}", case_insensitive: true)).all[0]
  end
  return @record
end

def find_querys(phrase, restricted=true)
  @arr = []
  if restricted == false
    phrase.gsub(/ /, '%')
    phrase = "%" + phrase
  end
  $elementsDB.order(:name).where(Sequel.like(:name, "#{phrase}%", case_insensitive: true))
  .or(Sequel.like(:localid, "#{phrase}%", case_insensitive: true)).limit(20).all.each do |k|
    @arr << ({name: k[:name]})
  end
  return @arr
end

def detailed_search(phrase, filterElem: "", valueMin: 0, valueMax: 10**12, sort_key: "value", sortDirection: "asc", filterLocation: "")
  @phrase = phrase.strip
  if sortDirection == "alfa" || sortDirection == "dalfa"
    @column = "name"
  end
  if @phrase.empty? then @phrase = "%" end
  @detailedArr = []
  if sortDirection == ""
    sortDirection = "asc"
  end
  if filterElem == ""
    @dbFilter = nil
  else
    @dbFilter = filterElem
  end
  #Value filters here
  if valueMax != 10**12
    if valueMax.is_a? String then valueMax.strip! end
    if valueMax.is_a? String
      unit = valueMax[-1]
      valueMax = valueMax.to_i.to_database_num(unit).to_f
    end
  end
  if valueMin != 0
    if valueMin.is_a? String then valueMin.strip! end
    if valueMin.is_a? String
      unit = valueMin[-1]
      valueMin = valueMin.to_i.to_database_num(unit).to_f
    end
  end
  if valueMin > valueMax
    valueMin, valueMax = valueMax, valueMin
  end
  @phrase.split.each do |partPhrase|
    if @dbFilter.nil?
      @detailedArr << $elementsDB.where(Sequel.like(:name, "%#{partPhrase}%", case_insensitive: true)).or(Sequel.like(:localid, "%#{partPhrase}%", case_insensitive: true)).where(value: valueMin..valueMax).order(:value).all
    else
      @detailedArr << $elementsDB.where(Sequel.like(:name, "%#{partPhrase}%", case_insensitive: true)).or(Sequel.like(:localid, "%#{partPhrase}%", case_insensitive: true)).where(value: valueMin..valueMax).where(:elementtype => @dbFilter).order(:value).all
    end
  end
  @detailedArr = sort_table(@detailedArr.flatten.uniq, sortDirection, @column)
  unless filterLocation.empty?
    @detailedArr = @detailedArr.reject { |elem| elem[:location] != filterLocation.downcase }
  end
  return @detailedArr
end

def delete_item(itemId)
  $elementsDB.select(:localid).where(:localid => itemId).delete
end

def sort_table(arr, direction, column)
  if column.nil?
    column = "value"
  end
  if direction == "desc" || direction == "dalfa"
    return arr.sort_by{ |w| w[:"#{column}"] }.reverse
  else
    return arr.sort_by{ |w| w[:"#{column}"] }
  end
end

def sort_by_first_char(arr, phrase)
  #arr.sort_by! { |el| el.values[0] }
  regexp = Regexp.new("^" + phrase.strip)
  if arr.all? { |w| !w.values[0].match(regexp) }
    arr.sort_by!(&:values)
  else
    arr.sort_by! { |w| w.values[0].match?(regexp) ? 0 : 1 }
  end
  return arr
end

def change_quantity(item_id, added_quantity)
  unless $elementsDB.where(:localid => item_id).all.empty?
    @actualQuantity = $elementsDB.where(:localid => item_id).all[0][:quantity]
    @newQuantity = @actualQuantity + added_quantity.to_i
    if @newQuantity < 0
      @error = "O kolego, za dużo to i świnia nie przeżre!"
      return {error: @error}
    else
      old = $elementsDB.where(:localid => item_id).all[0][:quantity]
      $logger.log_action(action:"added", userid:session[:user_id], itemid: item_id, old: old, new: @newQuantity)
      $elementsDB.where(:localid => item_id).update(:quantity => @newQuantity)
    end
    return select_item(item_id)
  end
end

def create_new_item_object(params={})
  p params
  @newItemName = params[:"new-item-name"].strip
  @newTypeName = params[:"new-type-name"].strip
  @newItemQuantity = params[:"new-item-quantity"]
  @newItemValue = params[:"new-item-value"].strip
  @newItemDescription = params[:"new-item-description"].strip
  @newItemDatasheet = params[:"new-item-datasheet"].strip
  @newItemLocation = params[:"new-item-location"].strip
  @newItemUnit = params[:"new-item-unit"].strip
  unless params[:"new-item-checkbox"].nil?
    if @newTypeName == "" || @newTypeName.nil?
      @error = "Nazwa typu nie może być pusta!"
      return {error: @error}
    end
    if @newTypeName.match(/\A[[:alpha:][:blank:]]+\z/).nil?
      @error = "Nazwa typu może składać się tylko z małych znaków a-z i spacji!"
      return {error: @error}
    end
  end
  if params[:element].nil? && params[:"new-item-checkbox"].nil?
    @error = "Wybierz rodzaj!"
    return {error: @error}
  end
  unless params[:element].nil?
    @newTypeName = params[:element]
  end
  if @newItemName == "" ||
    @newItemName.nil?
    @error = "Nazwa elementu nie może być pusta!"
    return {error: @error}
  end
  if @newItemName.length > 30 ||
    @newTypeName.length > 30
    @error = "Nazwa nie może być dłuższa niż 30 znaków!"
    return {error: @error}
  end
  if @newItemQuantity.to_s.match?(/[:alpha]/)
    @error = "W tym polu ilość mogą znajdować się tylko cyfry!"
    return {error: @error}
  else
    @newItemQuantity = @newItemQuantity.to_f.to_i
  end
  if @newItemQuantity.to_i < 0
    @error = "Ilość nie może być ujemna!"
    return {error: @error}
  end
  if params[:"new-item-localid"].nil? ||
    params[:"new-item-localid"] == ""
    @newLocalId = @newItemName[0..8].gsub(' ','').downcase
    if @newLocalId.id_exists?
      loop do
        o = [('a'..'z'), ('0'..'9')].map(&:to_a).flatten
        @newLocalId = @newLocalId + (0...1).map { o[rand(o.length)] }.join
        break if !@newLocalId.id_exists?
      end
    end
  else
    @newLocalId = params[:"new-item-localid"]
    if @newLocalId.id_exists?
      @error = "Istnieje już element o podanym ID!"
      return {error: @error}
    end
  end
  @newItemValue.gsub!(',','.')
  unless @newItemValue.match(/\A[[\d][.]]+\z/).nil?
    @newItemValue = @newItemValue.to_f
  else
    unit = @newItemValue[-1]
    @newItemValue = @newItemValue.to_f.to_database_num(unit)
  end
  if @newItemValue < 0
    @error = "Wartość nie może być mniejsza od 0!"
    return {error: @error}
  end
  if @newItemDescription.empty? then @newItemDescription = nil end
  if @newItemDatasheet.empty? then @newItemDatasheet = nil end
  if @newItemLocation.empty? then @newItemLocation = nil end
  unless params[:"new-item-unit"]
    @newItemUnit =  map_unit_name(@newTypeName)
  else
    @newItemUnit = params[:"new-item-unit"]
  end
  if @newItemUnit == "" ||
    @newItemUnit.nil?
    @newItemUnit = nil
  end

  $elementsDB.insert(localid: @newLocalId,
    name: @newItemName,
    description: @newItemDescription,
    value: @newItemValue,
    quantity: @newItemQuantity,
    powerdissipation: nil,
    location: @newItemLocation.downcase,
    datasheet: @newItemDatasheet,
    unit: @newItemUnit,
    maxvoltage: nil,
    elementtype: @newTypeName.gsub(" ","_"))
  return $elementsDB.where(localid: @newLocalId).all[0][:id]
end

def map_unit_name(type)
  units = {
    "resistor" => "Ω",
    "capacitor" => "F",
    "inductor" => "H"
  }
  return units[type]
end

def map_column_name(name)
  names = {
    "name-input" => "name",
    "quantity-input" => "quantity",
    "location-input" => "location",
    "description-input" => "description",
    "datasheet-input" => "datasheet",
    "id" => "localid",
    "type-input" => "elementtype",
    "voltage-input" => "maxvoltage",
    "power-input" => "powerdissipation",
    "unit-input" => "unit",
    "value-input" => "value"
  }
  return names[name]
end

def edit_item(editHash)
  p @item
  @id = @item[:localid]
  editHash.delete("id")
  editHash.keys.each do |key|
    if map_column_name(key) == "quantity" && editHash[key].to_i < 0
      @error = "Ilość nie może być ujemna!"
      return {error: "Ilość nie może być ujemna!"}
    else
      if map_column_name(key) == "value"
        unit = editHash[key][-1]
        editHash[key] = editHash[key].to_f.to_database_num(unit)
      end
      $elementsDB.where(:localid => @id).update(map_column_name(key) => editHash[key])
      return $elementsDB.where(:localid => @id).all[0][:id]
    end
  end
end

def location_serch(location)
  return $elementsDB.where(Sequel.like(:location, "%#{location}%", case_insensitive: true)).all
end

def delete_multiple_items(itemsHash)
  @itemsArr = itemsHash["items_to_delete"].split(',')
  @itemsArr.each do |item|
    delete_item(item)
  end
end

def export_to_csv(itemList)
  @fileName = Time.now.to_i.to_s + "-" + $elementsDB.count.to_s
  saveData($elementsDB.first.keys.to_s, @fileName)
  itemList.split(",").each do |elem|
    saveData($elementsDB.where(:localid => elem).all[0].values.to_s, @fileName)
  end
  return @fileName
end

def saveData(localDataSet, localDocumentName)
  @documentName = localDocumentName
  unless localDataSet.nil?
    @excelLine = localDataSet.tr(':[]\"',"").gsub("nil","")
    File.write("public/temp/" + @documentName + ".csv", @excelLine, mode: 'a')
    File.write("public/temp/" + @documentName + ".csv", "\n", mode: 'a')
  end
end

def genereQR(qrName)
  qrcode = RQRCode::QRCode.new("barry.multi.ovh/find?loc=#{qrName}")
  png = qrcode.as_png(
    bit_depth: 1,
    border_modules: 0,
    color_mode: ChunkyPNG::COLOR_GRAYSCALE,
    color: "black",
    file: nil,
    fill: "white",
    module_px_size: 6,
    resize_exactly_to: false,
    resize_gte_to: false,
    size: 120
  )
  IO.binwrite("./public/QR/#{qrName}.png", png.to_s)
end

def add_location(locationHash)
  if $locationsDB.where(:name =>locationHash[:"location-name"]).all.empty?
    $locationsDB.insert(name: locationHash[:"location-name"],
    parentname: locationHash[:"parent-location"],
    description: locationHash[:"location-description"])
    return $locationsDB.where(:name => locationHash[:"location-name"]).all[0][:id]
  else
    @foundLoc = $locationsDB.select(:parentname).where(:name => locationHash[:"location-name"]).all[0][:parentname]
    return {erorr: "Wybrana nazwa jest już zajęta. Znajduje się w: #{@foundLoc}"}
  end
end

def select_location(name)
  name = name.to_s
  if name.empty?
    @loc = $locationsDB.all
  else
    @loc = $locationsDB.where(Sequel.like(:name, "%#{name}%", case_insensitive: true)).all[0]
  end
  if name.scan(/\D/).empty? &&  !name.to_s.empty?
    @loc = $locationsDB.where(:id => name).all[0]
  end
  if @loc.empty?
    @loc = nil
  end
 return @loc
end

def delete_location(locId)
  $locationsDB.select(:id).where(:id => locId).delete
end

def edit_loc(editHash)
  #p editHash
  #parentname, description, name
  if editHash.include?("id")
    editHash.delete("id")
  end
  editHash.keys.each do |key|
    $locationsDB.where(:id => @loc[:id]).update(key => editHash[key])
  end
  return @loc[:id]
end
