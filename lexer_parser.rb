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


def multdiv_helper(input, newval) # could take block with diff structure
  # assumes valid input, errors handled outside
  multdiv = [:times, :div]
  while !input.empty? && multdiv.include?(input[0].type)
    new_op = input.shift
    next_num = input.shift
    if new_op.type == :times
      newval *= next_num.value
    elsif new_op.type == :div
      newval /= next_num.value
    end  
  end
  newval
end
      


def parse_expression(input)
  muldiv = [:times,:div]
  plusmin = [:plus, :minus] # not yet used, may delete
  num = input.shift 
  unless num.type == :number
    raise "Syntax error, expecting number"
  end
  total = num.value
  return total if input.empty?
  
  while !input.empty?
    
    op = input.shift
    n = input.shift
    newval = n.value # essentially placeholder

    if ![:plus, :minus, :times, :div].include?(op.type) 
      raise "Syntax error: expecting operator, got #{op.type}"
    elsif !n || n.type != :number
      raise "Syntax error: expected number, got invalid input"
    elsif op.type == :times
        total *= n.value
    elsif op.type == :div
      total /= n.value
    elsif input[1] 
      if input[1].type == :number && muldiv.include?(input[0].type)
        newval = multdiv_helper(input,newval)  
      elsif input[0].type != :number 
        raise "Syntax error: expected number, got invalid input" # TODO-fix code duplication problem
      end
    else
      newval = n.value
    end
      
    if op.type == :plus
      total += newval
    elsif op.type == :minus
      total -= newval
    end
  end
  total
end



# CODE/tests

#input_string = gets.chomp!  # input expression via keyboard
#tokens = lex_input(input_string)

tokens = lex_input("    1 -  6   /2 * 3 * 4 / 2 ")
#p tokens

puts parse_expression(tokens)