#########################
#
#
#
#
#
##########################

def checkFile(filename)
  file = File.new(filename, 'r')
  nbrLine = 0
  file.each_line do |line| 
    puts "line #{nbrLine} : #{line}"
    nbrLine += 1
  end
  puts filename
end

Dir.foreach(".") do |file|
  if File.extname(file) == ".c"
    checkFile(file)
  end
end



