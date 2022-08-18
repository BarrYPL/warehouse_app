DB = Sequel.sqlite 'db\database.db'

$usersDB = DB[:users]
$capacitorsDB = DB[:capacitors]
$inductorsDB = DB[:inductors]
$resistorsDB = DB[:resistors]
$laboratoryeqDB = DB[:laboratoryeq]
$mechanicalsDB = DB[:mechanicals]
$othersDB = DB[:others]

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

def formati_si(size)
  scale = 1000;
  ndx = 1

  conv = [ '', 'K', 'M', 'G', 'T']

  size=size.to_f
  [1,2,3,4].each do |ndx|
    if( size < (scale**ndx)) then
      if isNatural(size/(scale**(ndx-1)))
        return "#{(size/(scale**(ndx-1))).to_i} #{conv[ndx-1]}"
      else
        return "#{'%.1f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
      end
    end
  end
  ndx=5
  if isNatural(size/(scale**(ndx-1)))
    return "#{(size/(scale**(ndx-1))).to_i} #{conv[ndx-1]}"
  else
    return "#{'%.1f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
  end
end

def isNatural(floatNum)
  if floatNum.rationalize.denominator == 1
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
      if isNatural(size*(scale**ndx))
        return "#{(size*(scale**ndx)).to_i} #{conv[ndx-1]}"
      else
        return "#{'%.1f' % (size*(scale**ndx))} #{conv[ndx-1]}"
      end
    end
  end
  ndx=5
  if isNatural(size*(scale**ndx))
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
  when 'K'
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
    return "Error, wrong parameter."
  end
end
