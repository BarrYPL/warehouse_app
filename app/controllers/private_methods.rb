class Integer
  def to_human_redable
    return formati_si(self)
  end
end

def formati_si(size)
  scale = 1000;
  ndx = 1

  conv = [ '', 'K', 'M', 'G']

  if( size < scale**ndx ) then
    return "#{size}"
  end

  size=size.to_f
  [2,3].each do |ndx|
    if( size < (scale**ndx)  ) then
      return "#{'%.3f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
    end
  end
  ndx=4
  return "#{'%.3f' % (size/(scale**(ndx-1)))} #{conv[ndx-1]}"
end

class Float
  def to_human_redable
    return formatf_si(self)
  end
end

def formatf_si(size)
  scale = 1000
  ndx = 1

  conv = [ 'm', 'u', 'n', 'p', 'f']

  size=size.to_f
  [1,2,3,4].each do |ndx|
    if( size >= (scale**-ndx)  ) then
      return "#{'%.3f' % (size*(scale**(ndx-1)))} #{conv[ndx-1]}"
    end
  end
  ndx=5
  return "#{'%.3f' % (size*(scale**(ndx-1)))} #{conv[ndx-1]}"
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
