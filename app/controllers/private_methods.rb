DB = Sequel.sqlite 'db\database.db'

$usersDB = DB[:uzytkownicy]
$capacitorsDB = DB[:kondensatory]
$inductorsDB = DB[:elementy_indukcyjne]
$resistorsDB = DB[:rezystory]
$laboratoryeqDB = DB[:sprzet_laboratoryjny]
$mechanicalsDB = DB[:elementy_mechaniczne]
$othersDB = DB[:inne]

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

def all_tables_array
  restricted_tables = [:uzytkownicy, :sprzet_laboratoryjny]
  all_tables = DB.tables
  return_table = []
  restricted_tables.each do |item|
    all_tables.delete(item)
  end
  all_tables.each do |table|
    return_table << DB[table]
  end
  return return_table.sort_by!{ |item| item.first_source_alias.to_s }
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
  def id_Exists?
    @countingResults = []
    all_tables_array.each { |tab| @countingResults << tab.where(:localid => self).count }
    if @countingResults.all?(0)
      return false
    else
      return true
    end
  end
end

def check_string(str)
  str !~ /\D/
end

def findQuerys(phrase, restricted=true)
  if restricted == false
    phrase.gsub(/ /, '%')
    phrase = "%" + phrase
  end
  @arr = []
  all_tables_array.each do |table|
    table.where(Sequel.like(:name, "#{phrase}%", case_insensitive: true))
    .or(Sequel.like(:localid, "#{phrase}%", case_insensitive: true)).limit(5).all.each do |k|
      @arr << ({name: k[:name]})
    end
  end
  return @arr
end

def detailedSearch(phrase, filterTab: "", value_min: 0, value_max: 10**12, sort_key: "value", sort_direction: "asc")
  @phrase = phrase.strip
  if sort_direction == "alfa" || sort_direction == "dalfa"
    @column = "name"
  end
  if @phrase.empty? then @phrase = "%" end
  @detailed_arr = []
  @part_att = []
  if sort_direction == ""
    sort_direction = "asc"
  end
  unless filterTab == ""
    @db_tables_array = [DB[:"#{filterTab}"]]
  else
    @db_tables_array = all_tables_array
  end
  @db_tables_array.each do |table|
    #Find by phrase no filters
    @phrase.split.each do |partPhrase|
      @part_att << table.where(Sequel.like(:name, "%#{partPhrase}%", case_insensitive: true)).or(Sequel.like(:localid, "%#{partPhrase}%", case_insensitive: true)).order(:value).all
    end
    #Common part of each subarrays
    if @part_att.length > 1
      @tempArr = @part_att[0] & @part_att.last
      @res_arr = []
      (1..@part_att.length-1).each { |el| @res_arr << @tempArr & @part_att[el] }
      @res_arr.uniq!
      @part_att = @res_arr[0]
    end
    #Value filters here
    if value_max != 10**12
      if value_max.is_a? String then value_max.strip! end
      if value_max.is_a? String
        unit = value_max[-1]
        value_max = value_max.to_i.to_database_num(unit).to_f
      end
    end
    if value_min != 0
      if value_min.is_a? String then value_min.strip! end
      if value_min.is_a? String
        unit = value_min[-1]
        value_min = value_min.to_i.to_database_num(unit).to_f
      end
    end
    if value_min > value_max
      value_min, value_max = value_max, value_min
    end
    @part_att = @part_att.flatten & table.where(value: value_min..value_max).all
    #@part_att = sortTable(@part_att, sort_direction)
    if @part_att.count > 0
      @detailed_arr << @part_att
    end
    @part_att = []
  end
  @detailed_arr = sortTable(@detailed_arr.flatten, sort_direction, @column)
  return @detailed_arr
end

def select_item(itemName)
  resultTab = []
  all_tables_array.each do |table|
    resultTab << table.where(Sequel.like(:localid, "#{itemName}", case_insensitive: true)).all
  end
  return resultTab.flatten[0]
end

def delete_item(itemId)
  all_tables_array.each do |table|
    table.select(:localid).where(:localid => itemId).delete
  end
end

def sortTable(arr, direction, column)
  if column.nil?
    column = "value"
  end
  if direction == "desc" || direction == "dalfa"
    return arr.sort_by{ |w| w[:"#{column}"] }.reverse
  else
    return arr.sort_by{ |w| w[:"#{column}"] }
  end
end

def sortByFirstChar(arr, phrase)
  #arr.sort_by! { |el| el.values[0] }
  regexp = Regexp.new("^" + phrase.strip)
  if arr.all? { |w| !w.values[0].match(regexp) }
    arr.sort_by!(&:values)
  else
    arr.sort_by! { |w| w.values[0].match?(regexp) ? 0 : 1 }
  end
  return arr
end

def changeQuantity(item_id, added_quantity)
  all_tables_array.each do |table|
    unless table.where(:localid => item_id).all.empty?
      @actualQuantity = table.where(:localid => item_id).all[0][:quantity]
      @newQuantity = @actualQuantity + added_quantity.to_i
      table.where(:localid => item_id).update(quantity: @newQuantity)
    end
  end
end

def create_new_item(params={})
  @needTable = false
  p params
  @newItemName = params[:"new-item-name"].strip
  @newTableName = params[:"new-table-name"].strip
  @newItemQuantity = params[:"new-item-quantity"].to_f.to_i
  @newItemValue = params[:"new-item-value"].strip
  @newItemDescription = params[:"new-item-description"].strip
  @newItemDatasheet = params[:"new-item-datasheet"].strip
  @newItemLocation = params[:"new-item-location"].strip
  @newItemUnit = params[:"new-item-unit"].strip
  unless params[:"new-item-checkbox"].nil?
    if @newTableName == ""
      @error = "Nazwa tabeli nie może być pusta!"
      return
    end
    if @newTableName.match(/\A[[:alpha:][:blank:]]+\z/).nil?
      @error = "Nazwa tabeli może składać się tylko z małych znaków a-z i spacji!"
      return
    else
      all_tables_array.each do |tabName|
        if tabName.first_source_alias.to_human_text.to_database_text.downcase == @newTableName.to_database_text.downcase
          @error = "Nazwa tabeli musi być inna niż istniejące tabele!"
          return
        end
      end
      @needTable = true
    end
  end
  if params[:element].nil? && params[:"new-item-checkbox"].nil?
    @error = "Wybierz tablę!"
    return
  end
  unless params[:element].nil?
    @newTableName = params[:element]
  end
  if @newItemName == "" ||
    @newItemName.nil?
    @error = "Nazwa elementu nie może być pusta!"
    return
  end
  if @newItemName.length > 30 ||
    @newTableName.length > 30
    @error = "Nazwa nie może być dłuższa niż 30 znaków."
    return
  end
  if @newItemQuantity == ""
    @error = "Ilość nie może być pusta!"
    return
  end
  if @newItemQuantity.to_s.match?(/[:alpha]/)
    @error = "W polu ilość mogą znajdować się tylko cyfry."
    return
  end
  if @newItemQuantity.to_i < 0
    p @newQuantity
    @error = "Ilość nie może być ujemna!"
    return
  end
  if params[:IdSelect].nil?
    unless params[:"new-item-localid"].nil? ||
      params[:"new-item-localid"] == ""
      @newLocalId = params[:"new-item-localid"]
      if @newLocalId.id_Exists?
        @error = "Istnieje już element o podanym ID!"
        return
      end
    else
      @error = 'Zaznacz "AutoID", jeśli nie chcesz wpisywać!'
      return
    end
  else
    @newLocalId = @newItemName[0..8].gsub(' ','').downcase
    if @newLocalId.id_Exists?
      loop do
        o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
        @newLocalId = @newLocalId + (0...1).map { o[rand(o.length)] }.join
        break if !@newLocalId.id_Exists?
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
  if @needTable
    DB.create_table :"#{@newTableName.to_database_text}" do
      primary_key :id
      String :localid, unique: true
      String :name
      Text :description
      float :value
      int :quantity
      String :location
      String :datasheet
      String :unit
    end
  end
  if @newItemDescription.empty? then @newItemDescription = nil end
  if @newItemDatasheet.empty? then @newItemDatasheet = nil end
  if @newItemLocation.empty? then @newItemLocation = nil end
  case @newTableName
  when "rezystory"
    @newItemUnit = "Ω"
  when "kondensatory"
    @newItemUnit = "F"
  when "elementy_indukcyjne"
    @newItemUnit = "H"
  else
    if @newItemUnit == "" ||
      @newItemUnit.nil?
      @newItemUnit = nil
    end
  end
  DB[:"#{@newTableName}"].insert(localid: @newLocalId,
    name: @newItemName,
    description: @newItemDescription,
    value: @newItemValue,
    quantity: @newItemQuantity,
    datasheet: @newItemDatasheet,
    unit: @newItemUnit,
    location: @newItemLocation)
  return @newLocalId
end
