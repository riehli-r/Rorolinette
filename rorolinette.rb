#########################
#
#
#
#
#
##########################


def checkHeader(file)
  nbrLine = 0
  file.each_line do |line| 
    if nbrLine <= 6 && (line.split("")[0] != '/' || line.split("")[0] != '*')
      puts "line #{nbrLine} : Header incorrect"
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



