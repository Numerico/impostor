#GEMAS
require 'rubygems' if RUBY_VERSION < '1.9'
require 'uuidtools'
require 'fileutils'
require 'alchemist'
require 'i18n'
#Clases
require 'imposition/clases'
require 'imposition/metodos'
#i18n
I18n.load_path = Dir.glob(File.dirname(__FILE__)+"/locales/*.{rb,yml}")
#
$requerimientos=Hash.new
$requerimientos["pdflatex"]="pdflatex"
$requerimientos["pdfinfo"]="pdfinfo"
#
$work="/tmp"
#
check=Metodos.checksCompile()
if check.instance_of? Clases::Mensaje then
  puts check.mensaje
  #exit
end