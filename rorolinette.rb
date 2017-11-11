#!/usr/bin/env ruby
#########################
# Rorolinette de norme
#
##########################

##------------COLORS-------------
@blue = "\033[1;34m"
@red = "\033[1;31m"
@default = "\033[0m"
##------------PARAMETERS---------
@header_size = 9
@max_line_in_fct = 25
@max_line_size = 80
@max_params = 4
@max_fct_in_file = 5

##------------GLOBALS------------
@file = 0
@error = 0

def check_multiple
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line|
    if !/^\s+for/.match(line) && line.split('').count(';') > 1
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Plusieurs ';'"
      @error += 1
    end
    nbr_line += 1
  end
end

##-----------Check if local include are not after global include
def check_include
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  local_include = false
  @file.each_line do |line|
    if line =~ /#include\s+"/
      local_include = true
    end
    if local_include && /#include\s+</.match(line)
      puts "--ligne #{@blue}#{nbr_line}#{@default} : #include dans le mauvais ordre"
      @error += 1
    end
    nbr_line += 1
  end
end

def check_multiple_line_break
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  tmp = ''
  @file.each_line do |line|
    if nbr_line != 1 && /^\s*$/.match(line) && /^\s*$/.match(tmp)
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Double saut de ligne" 
      @error += 1
    end
    tmp = line
    nbr_line += 1
  end
end

def check_params_nbr
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line|
    if /,/.match(line) && line.split("").count(',') >= @max_params && /^[\S]+/.match(line)
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Trop de parametres"
      @error += 1
    end
    nbr_line += 1
  end
end

##------------Check if there is space between keyword and '('
def check_space_between_kw
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line|
    if line =~ /\b(if|while|for|return)\(/
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Pas d'espace apres un mot cle"
      @error += 1
    end
    nbr_line += 1
  end
end

#------------Check if there isn't space between function and '('
def check_fct_space_after_paren
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line| 
    if /\(/.match(line) && !/if|while|for|return/.match(line) && /[^=,\*\+\-]+ \(/.match(line) && !/\)\(/.match(line)
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Espace apres apres un appel fonction"
      @error += 1
    end
    nbr_line += 1
  end
end

##-----------Check if there isn't space at the end of lines
def check_trailing_whitespaces
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line| 
    if /\s+\s$/.match(line) && nbr_line > @header_size
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Espace ou tabulation en fin de ligne"
      @error += 1
    end
    nbr_line += 1
  end
end

##----------Check if lines are not longer than 80
def check_line_longer
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line| 
    if line.size - 1 > @max_line_size && (nbr_line != 2 && line[0] != '*')
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Ligne de #{line.size} caracteres"
      @error += 1
    end
    nbr_line += 1
  end
end

##-----------Check if functions are not longer than 25 lines
def check_fct_size
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  line_in_fct = 0
  in_fct = false
  @file.each_line do |line| 
    if /^{/.match(line) || (/{\s*$/.match(line) && !in_fct)
      in_fct = true
    elsif line =~ /^}/
      in_fct = false
      line_in_fct = 0
    else
      if in_fct
        line_in_fct += 1
      end
      if line_in_fct > @max_line_in_fct
        puts "--ligne #{@blue}#{nbr_line}#{@default} : Fonction de plus de #{@max_line_in_fct} lignes"
        @error += 1
      end
    end
    nbr_line += 1
  end
end

##----------Check if there is a Header
def check_header
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line| 
    if nbr_line <= @header_size && line.split("")[0] != '/' && line.split("")[0] != '*'
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Header incorrect"
      @error += 1
    end
    nbr_line += 1
  end
end

##----------Check nbr function in file
def check_fct_nbr
  @file.seek(0, IO::SEEK_SET)
  fct_nbr = 0
  in_fct = false
  nbr_line = 1
  @file.each_line do |line| 
    if /^{/.match(line) || (/\).+{\s*$/.match(line) && !in_fct)
      in_fct = true
      fct_nbr += 1
      if fct_nbr > @max_fct_in_file
        puts "--ligne #{@blue}#{nbr_line}#{@default} : #{fct_nbr} fonctions dans le fichier"
        @error += 1
      end
    elsif line =~ /^}/
      in_fct = false
    end
    nbr_line += 1
  end
end

##----------Check space after comma
def check_space_after_comma
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line|
    if line =~ /,[\S]+/
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Pas d'espace après la virgule"
    end
    nbr_line += 1
  end
end

##----------Check space after comma
def check_space_after_plus_operator
  @file.seek(0, IO::SEEK_SET)
  nbr_line = 1
  @file.each_line do |line|
    if /[\+][^=\+; ]+/.match(line) || /[^\+ ]+[\+][^+]{1}/.match(line)
      puts "--ligne #{@blue}#{nbr_line}#{@default} : Pas assez d'espace autour de l'operateur +"
    end
    nbr_line += 1
  end
end

##----------Comment what you don't need
def check_file(filename)
  @file = File.new(filename, 'r')
  check_header
  check_fct_nbr
  check_fct_size
  check_line_longer
  check_trailing_whitespaces
  check_space_between_kw
  check_fct_space_after_paren
  check_params_nbr
  check_multiple_line_break
  check_include
  check_multiple
  check_space_after_comma
  check_space_after_plus_operator
end

def check_dir(dirname)
  Dir.foreach(dirname) do |file|
    if File.extname(file) == '.c' || File.extname(file) == '.h'
      puts "#{dirname}/#{file}:"
      check_file("#{dirname}/#{file}")
    elsif File.directory?("#{dirname}/#{file}") && !/^\./.match(File.basename("#{dirname}/#{file}"))
      check_dir("#{dirname}/#{file}")
    end
  end
end

check_dir('.')
puts "#{@red}#{@error}#{@default} erreurs."
