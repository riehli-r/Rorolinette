#!/usr/bin/env ruby
#########################
# Rorolinette de norme
#
# Made by: riehli_r
##########################

##------------COLORS-------------
@blue = "\033[1;34m"
@red = "\033[1;31m"
@default = "\033[0m"
##------------PARAMETERS---------
@HeaderSize = 9
@maxLineInFct = 25
@maxLineSize = 80
@maxParam = 4
@maxFctInFile = 5

##------------GLOBALS------------
@file = 0
@error = 0

def checkMultiple
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line|
    if !/^\s+for/.match(line) && line.split("").count(';') > 1
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Plusieurs ';'" 
      @error += 1
    end
    nbrLine += 1
  end
end

##-----------Check if local include are not after global include
def checkInclude
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  localInclude = false
  @file.each_line do |line|
    if /#include\s+"/.match(line)
      localInclude = true
    end
    if localInclude && /#include\s+</.match(line)
      puts "--ligne #{@blue}#{nbrLine}#{@default} : #include dans le mauvais ordre" 
      @error += 1
    end
    nbrLine += 1
  end
end

def checkDoubleJumpDeLigne
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  tmp = ""
  @file.each_line do |line|
    if nbrLine != 1 && /^\s*$/.match(line) && /^\s*$/.match(tmp)  
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Double saut de ligne" 
      @error += 1
    end
    tmp = line
    nbrLine += 1
  end
end

def checkNbrParams
  @file.seek(0, IO::SEEK_SET)
  nbrLine = 1
  @file.each_line do |line|
    if /,/.match(line) && line.split("").count(',') >= @maxParam && /^[\S]+/.match(line)
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Trop de parametres"
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
    #if /^\s+[^\(]+[^\( ]+\(/.match(line)
    if /\b(if|while|for|return)\(/.match(line)
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Pas d'espace apres un mot cle"
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
    if /\(/.match(line) && !/if|while|for|return/.match(line) && /[^=,\*\+\-]+ \(/.match(line) && !/\)\(/.match(line)
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Espace apres apres un appel fonction"
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
    if /\s+\s$/.match(line) && nbrLine > @HeaderSize
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Espace ou tabulation en fin de ligne"
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
    if line.size - 1 > @maxLineSize && (nbrLine != 2 && line[0] != '*')
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Ligne de #{line.size} caracteres"
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
        puts "--ligne #{@blue}#{nbrLine}#{@default} : Fonction de plus de #{@maxLineInFct} lignes"
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
    if nbrLine <= @HeaderSize && line.split("")[0] != '/' && line.split("")[0] != '*'
      puts "--ligne #{@blue}#{nbrLine}#{@default} : Header incorrect"
      @error += 1
    end
    nbrLine += 1
  end
end

##----------Check nbr function in file
def checkNbrFunction
  @file.seek(0, IO::SEEK_SET)
  nbrFct = 0
  inFct = false
  nbrLine = 1;
  @file.each_line do |line| 
    if /^{/.match(line) || (/\).+{\s*$/.match(line) && !inFct)
      inFct = true
      nbrFct += 1
      if nbrFct > @maxFctInFile
        puts "--ligne #{@blue}#{nbrLine}#{@default} : #{nbrFct} fonctions dans le fichier"
        @error += 1
      end
    elsif /^}/.match(line)
      inFct = false
    end
    nbrLine += 1
  end
end

##----------Comment what you don't need
def checkFile(filename)
  @file = File.new(filename, 'r')
  checkHeader
  checkNbrFunction
  checkFctSize
  checkLineLonger
  checkSpaceEndLine
  checkSpaceBetweenKeyword
  checkSpaceAfterFct
  checkNbrParams
  checkDoubleJumpDeLigne
  checkInclude
  checkMultiple
end

def checkDir(dirname)
  Dir.foreach(dirname) do |file|
    if File.extname(file) == ".c" || File.extname(file) == ".h"
      puts "#{dirname}/#{file}:"
      checkFile("#{dirname}/#{file}")
    elsif File.directory?("#{dirname}/#{file}") && !/^\./.match(File.basename("#{dirname}/#{file}"))
      checkDir("#{dirname}/#{file}")
    end
  end
end

checkDir(".")
puts "#{@red}#{@error}#{@default} erreurs."
