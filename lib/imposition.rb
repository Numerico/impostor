#GEMAS
require 'rubygems'
require 'uuidtools'
require 'fileutils'
require 'alchemist'
#Clases
require 'imposition/clases'
require 'imposition/metodos'
#
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
  exit
end

