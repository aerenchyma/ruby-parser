class Token < Struct.new(:type, :value)
  def inspect
    "[:#{type}, #{value || "nil"}]"
  end
end

def lex_input(input)
  tokens = []
  while input.length > 0
    if input =~ /^(\d+)/
      num = $1
      input = input.sub(num, '')
      tokens << Token.new(:number, num.to_i)
    elsif input =~ /^\*/
      input = input[1..-1]
      tokens << Token.new(:times, nil)
    elsif input =~ /^\//
      input = input[1..-1]
      tokens << Token.new(:div, nil)
    elsif input =~ /^\+/ 
      input = input[1..-1]
      tokens << Token.new(:plus, nil)
    elsif input =~ /^-/
      input = input[1..-1]
      tokens << Token.new(:minus, nil)
    elsif input =~ /^(\s+)/
      input = input.sub($1, '')
    else
      raise "Found invalid input at: #{input}"
    end
  end
  tokens
end

def parse_expression(input)
  muldiv = [:times,:div]
  plusmin = [:plus, :minus]
  num = input.shift
  unless num.type == :number
    raise "Syntax error, expecting number"
  end
  total = num.value
  return total if input.empty?
  
  while !input.empty?

    
    
    
    op = input.shift
    n = input.shift
    next_op = input.shift
    foll_num = input.shift
    newval = nil # placeholder
    # taking off four in a row, basically
    # if the following operator isn't higher precedence than the first, reshift the latter two
    
    if ![:plus, :minus, :times, :div].include?(op.type) || ![:plus, :minus, :times, :div].include?(next_op.type)
      raise "Syntax error: expecting operator, got #{op.type}"
    elsif ( !n || n.type != :number) || ((next_op && !foll_num) || (next_op && foll_num.type != :number))
      raise "Syntax error: expected number, got #{n ? n.type : 'nothing'}" # may need fixing
    elsif op.type == :times
      total *= n.value
    elsif op.type == :div
      total /= n.value
    elsif next_op.type == :times
      newval = n.value * foll_num.value
    elsif next_op.type == :div
      newval = n.value/foll_num.value
    elsif !muldiv.include?(next_op.type)
      input.unshift(foll_num)
      input.unshift(next_op)
    end

    if op.type == :plus
      total += newval
    elsif op.type == :minus
      total -= newval
    end
    
    
  end
  total
end


tokens = lex_input("    1 + 6 / 2 ") 
p tokens

puts parse_expression(tokens)