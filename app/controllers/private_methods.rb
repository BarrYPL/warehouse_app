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
end

class Symbol
  def to_human_text
    return self.to_s.split('_').each{ |word| word.capitalize! }.join(' ')
  end
end

def all_tables
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
