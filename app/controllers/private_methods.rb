DB = Sequel.sqlite 'db\database.db'

$usersDB = DB[:uzytkownicy]
$elementsDB = DB[:elementy]

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
  resultTab = []
  unless $elementsDB.where(Sequel.like(:localid, "#{itemName}", case_insensitive: true)).all.empty?
    @record = $elementsDB.where(Sequel.like(:localid, "#{itemName}", case_insensitive: true)).all[0]
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

def detailed_search(phrase, filterElem: "", valueMin: 0, valueMax: 10**12, sort_key: "value", sortDirection: "asc")
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
    else
      $elementsDB.where(:localid => item_id).update(quantity: @newQuantity)
    end
  end
end

def create_new_item(params={})
  @newItemName = params[:"new-item-name"].strip
  @newTypeName = params[:"new-type-name"].strip
  @newItemQuantity = params[:"new-item-quantity"].to_f.to_i
  @newItemValue = params[:"new-item-value"].strip
  @newItemDescription = params[:"new-item-description"].strip
  @newItemDatasheet = params[:"new-item-datasheet"].strip
  @newItemLocation = params[:"new-item-location"].strip
  @newItemUnit = params[:"new-item-unit"].strip
  unless params[:"new-item-checkbox"].nil?
    if @newTypeName == ""
      @error = "Nazwa typu nie może być pusta!"
      return
    end
    if @newTypeName.match(/\A[[:alpha:][:blank:]]+\z/).nil?
      @error = "Nazwa typu może składać się tylko z małych znaków a-z i spacji!"
      return
    end
  end
  if params[:element].nil? && params[:"new-item-checkbox"].nil?
    @error = "Wybierz rodzaj!"
    return
  end
  unless params[:element].nil?
    @newTypeName = params[:element].gsub!(" ","_")
  end
  if @newItemName == "" ||
    @newItemName.nil?
    @error = "Nazwa elementu nie może być pusta!"
    return
  end
  if @newItemName.length > 30 ||
    @newTypeName.length > 30
    @error = "Nazwa nie może być dłuższa niż 30 znaków."
    return
  end
  if @newItemQuantity == ""
    @error = "Ilość nie może być pusta!"
    return
  end
  if @newItemQuantity.to_s.match?(/[:alpha]/)
    @error = "W tym polu ilość mogą znajdować się tylko cyfry."
    return
  end
  if @newItemQuantity.to_i < 0
    @error = "Ilość nie może być ujemna!"
    return
  end
  if params[:IdSelect].nil?
    unless params[:"new-item-localid"].nil? ||
      params[:"new-item-localid"] == ""
      @newLocalId = params[:"new-item-localid"]
      if @newLocalId.id_exists?
        @error = "Istnieje już element o podanym ID!"
        return
      end
    else
      @error = 'Zaznacz "AutoID", jeśli nie chcesz wpisywać!'
      return
    end
  else
    @newLocalId = @newItemName[0..8].gsub(' ','').downcase
    if @newLocalId.id_exists?
      loop do
        o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
        @newLocalId = @newLocalId + (0...1).map { o[rand(o.length)] }.join
        break if !@newLocalId.id_exists?
      end
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
    return
  end
  if @newItemDescription.empty? then @newItemDescription = nil end
  if @newItemDatasheet.empty? then @newItemDatasheet = nil end
  if @newItemLocation.empty? then @newItemLocation = nil end
  @newItemUnit =  map_unit_name(@newTypeName)
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
    location: @newItemLocation,
    datasheet: @newItemDatasheet,
    unit: @newItemUnit,
    maxvoltage: nil,
    elementtype: @newTypeName)
  return @newLocalId
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
    "unit-input" => "unit"
  }
  return names[name]
end

def edit_item(editHash)
  @id = @item[:localid]
  editHash.delete("id")
  editHash.keys.each do |key|
    if map_column_name(key) == "quantity" && editHash[key].to_i < 0
      @error = "Ilość nie może być ujemna!"
    else
      $elementsDB.where(:localid => @id).update(map_column_name(key) => editHash[key])
    end
  end
end
