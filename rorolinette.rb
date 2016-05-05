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

def checkLineLonger(file)
  file.seek(0, IO::SEEK_SET)
  nbrLine = 0
  file.each_line do |line| 
    if line.size - 1 > 80
      puts "----line #{@blue}#{nbrLine}#{@default} : Ligne de #{line.size} caracteres"
      @error += 1
    end
    nbrLine += 1
  end
end
def checkFctSize(file)
  file.seek(0, IO::SEEK_SET)
  nbrLine = 0
  lineInFct = 0
  inFct = false
  file.each_line do |line| 
    if /^{/.match(line) || (/{\s*$/.match(line) && !inFct)
      inFct = true
    elsif /^}/.match(line)
      inFct = false
      lineInFct = 0
    else
      if inFct
        lineInFct += 1
      end
      if lineInFct > 25
        puts "----line #{@blue}#{nbrLine}#{@default} : Fonction de plus de 25 lignes"
        @error += 1
      end
    end
    nbrLine += 1
  end
end

def checkHeader(file)
  file.seek(0, IO::SEEK_SET)
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
  checkFctSize(file)
  checkLineLonger(file)
end

Dir.foreach(".") do |file|
  if File.extname(file) == ".c"
    puts "#{file}:"
    checkFile(file)
  end
end
puts "#{@red}#{@error}#{@default} erreurs."
