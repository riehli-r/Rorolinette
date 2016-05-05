#########################
#
#
#
#
#
##########################

##------------COLORS-------------

@blue = "\033[1;34m"
@red = "\033[1;31m"
@default = "\033[0m"

@error = 0

def checkHeader(file)
  nbrLine = 0
  file.each_line do |line| 
    if nbrLine <= 6 && (line.split("")[0] != '/' || line.split("")[0] != '*')
      puts "----line #{@blue}#{nbrLine}#{@default} : Header incorrect"
      @error += 1
    end
    nbrLine += 1
  end
end


def checkFile(filename)
  file = File.new(filename, 'r')
  checkHeader(file)
end

Dir.foreach(".") do |file|
  if File.extname(file) == ".c"
    checkFile(file)
  end
end
puts "#{@red}#{@error}#{@default} erreurs."



