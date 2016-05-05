#########################
# Moulinette de norme
#
# Made by: riehli_r
##########################

##------------COLORS-------------
@blue = "\033[1;34m"
@red = "\033[1;31m"
@default = "\033[0m"
##------------PARAMETERS---------
@HeaderSize = 6
@maxLineInFct = 25
@maxLineSize = 80
@maxParam = 4

##------------GLOBALS------------
@file = 0
@error = 0


def checkSpaceBetweenOperators
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line|
    if /[\+\-\/\%]/.match(line) && !/ [\+\-\/\%] /.match(line)
      puts "----line #{@blue}#{nbrLine}#{@default} : Pas d'espace autour d'un operateur"
      @error += 1
    end
    nbrLine += 1
  end
end

def checkNbrParams
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line|
    if /,/.match(line) && line.split("").count(',') >= @maxParam
      puts "----line #{@blue}#{nbrLine}#{@default} : Trop de parametres"
      @error += 1
    end
    nbrLine += 1
  end
end

##------------Check if there is space between keyword and '('
def checkSpaceBetweenKeyword
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line| 
    if /^\s+[^\(]+[^\( ]+\(/.match(line)
      puts "----line #{@blue}#{nbrLine}#{@default} : Pas d'espace apres un mot cle"
      @error += 1
    end
    nbrLine += 1
  end
end

#------------Check if there isn't space between function and '('
def checkSpaceAfterFct
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line| 
    if /\(/.match(line) && !/if|while|for|return/.match(line) && / \(/.match(line)
      puts "----line #{@blue}#{nbrLine}#{@default} : Espace apres apres un appel fonction"
      @error += 1
    end
    nbrLine += 1
  end
end

##-----------Check if there isn't space at the end of lines
def checkSpaceEndLine
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line| 
    if /\s+\s$/.match(line)
      puts "----line #{@blue}#{nbrLine}#{@default} : Espace ou tabulation en fin de ligne"
      @error += 1
    end
    nbrLine += 1
  end
end

##----------Check if lines are not longer than 80
def checkLineLonger
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line| 
    if line.size - 1 > @maxLineSize
      puts "----line #{@blue}#{nbrLine}#{@default} : Ligne de #{line.size} caracteres"
      @error += 1
    end
    nbrLine += 1
  end
end

##-----------Check if functions are not longer than 25 lines
def checkFctSize
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  lineInFct = 0
  inFct = false
  @file.each_line do |line| 
    if /^{/.match(line) || (/{\s*$/.match(line) && !inFct)
      inFct = true
    elsif /^}/.match(line)
      inFct = false
      lineInFct = 0
    else
      if inFct
        lineInFct += 1
      end
      if lineInFct > @maxLineInFct
        puts "----line #{@blue}#{nbrLine}#{@default} : Fonction de plus de 25 lignes"
        @error += 1
      end
    end
    nbrLine += 1
  end
end

##----------Check if there is a Header
def checkHeader
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line| 
    if nbrLine <= @HeaderSize && (line.split("")[0] != '/' || line.split("")[0] != '*')
      puts "----line #{@blue}#{nbrLine}#{@default} : Header incorrect"
      @error += 1
    end
    nbrLine += 1
  end
end

##----------Comment what you don't need
def checkFile(filename)
  @file = File.new(filename, 'r')
  checkHeader
  checkFctSize
  checkLineLonger
  checkSpaceEndLine
  checkSpaceBetweenKeyword
  checkSpaceAfterFct
  checkNbrParams
  checkSpaceBetweenOperators
end

Dir.foreach(".") do |file|
  if File.extname(file) == ".c" || File.extname(file) == ".h"
    puts "#{file}:"
    checkFile(file)
  end
end
puts "#{@red}#{@error}#{@default} erreurs."
