#GEMAS
#TODO por qué tengo que requerir todo esto?
require 'rubygems'
require 'uuidtools'
require 'fileutils'
require 'alchemist'
#Clases
require 'imposition/clases'
require 'imposition/metodos'
#
$requerimientos=Hash.new
$requerimientos["pdflatex"]="pdflatex"
$requerimientos["pdfinfo"]="pdfinfo"
#
work="/tmp/impostor"
#
check=Metodos.checksCompile($requerimientos,work)
if check.instance_of? Clases::Mensaje then
  puts check.mensaje
  exit#TODO raise
end

