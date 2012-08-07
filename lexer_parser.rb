class Token < Struct.new(:type, :value)
  def inspect
    "[:#{type}, #{value || "nil"}]"
  end
end

$operators = [:times, :div, :plus, :minus, :exp]
$regops = [:times, :div, :plus, :minus]
$muldiv = [:times, :div]
$plusmin = [:plus, :minus]
$other_ops = [:exp]

def lex_input(input)
  tokens = []
  while input.length > 0
    if input =~ /^(\d+)/
      num = $1
      input = input.sub(num, '')
      tokens << Token.new(:number, num.to_i)
    elsif input =~ /^\^/
      input = input[1..-1]
      tokens << Token.new(:exp, nil)
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

def parse_sum(input) # for sum
  num = input[0]
  unless num.type == :number
    raise "Syntax error, expecting number"
  end
  sum = input.shift.value
  return sum if input.empty?
  
  while !input.empty?
    
    op = input[0] # looking at next token
    n = input[1]
    
    if !$operators.include?(op.type)
      #puts $operators
      raise "Syntax error: expecting operator, got #{op.type}"
    elsif !n || n.type != :number
      raise "Syntax error: expecting number, got #{n ? n.type : "nothing"}" 
    elsif op.type == :plus
      input.shift # eat plus/minus op
      sum += parse_product(input)
    elsif op.type == :minus
      input.shift # eat plus/minus op
      sum -= parse_product(input)
    elsif $muldiv.include?(op.type)
      input.unshift(num) # hmm
      sum += parse_product(input)
    end
  end
  sum
end


def parse_product(input)
  n = input[0]
  
  unless n.type == :number
    raise "Syntax error, expecting number, got #{input[0].type}"
  end
  
  product = n.value
  input.shift # so, if it's only one long, now empty -- inp now starts with operator if continues
  return product if input.empty?
  
  while !input.empty? && !$plusmin.include?(input[0].type) 
    n_op = input[0] # check -- peek at next values
    next_num = input[1] # what if this doesn't exist?
    if !$operators.include?(n_op.type)
      raise "Syntax error, expecting operator, got #{n_op.type}"
    elsif next_num.type != :number # what happens if there is none?
      raise "Syntax error, expecting number, got #{next_num.type}"
    elsif n_op.type == :times
      puts "HERE IT IS, #{input}"
      #product *= next_num.value
      input.shift
      product *= parse_exponent(input)
      #input.shift(2)
    elsif n_op.type == :div
      input.shift
      #product /= next_num.value
      product /= parse_exponent(input)
      #input.shift(2)
    end
  end
  product
end


def parse_exponent(input)
end



# code
    
    # infinite loop  
      
    
tokens = lex_input("2+3*2*4^2 -6") 
p tokens
puts parse_sum(tokens)   


### GRAMMAR
## sum: product {('+' | '-') product}*
## product: NUM {('*'|'/') NUM}*
    