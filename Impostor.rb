begin

#####
#GEMA
require 'Clases'
require 'Metodos'
#  
require 'rubygems'
require 'uuidtools'
require 'fileutils'
require 'alchemist'

########
#CONSOLA
#vars
entrada=ARGV.shift
$salida=ARGV.shift
#paquetes
$requerimientos=Hash.new
$requerimientos["pdflatex"]="pdflatex"
$requerimientos["pdfinfo"]="pdfinfo"
#checks
$requerimientos.each do |k,v|
  `which #{v}`
  if !$?.success? then
    puts "#{v} no es ejecutable"
    exit
  end  
end
#archivos
work="/tmp/impostor"
#probamos que exista el directorio de trabajo
if File.exists?(work) then
	#y que sea escribible
	if File.writable?(work) and File.writable_real?(work) then
		#creo mi directorio
		$dir=work+"/"+UUIDTools::UUID.random_create
		Dir.mkdir($dir)
		$codeDir = Dir.pwd
	else
	puts "el directorio de trabajo "+work+" no se puede escribir"
	end	
else
puts "el directorio de trabajo "+work+ " no existe"
exit
end
#la entrada
if entrada != nil then
	if File.file?(entrada) then
		if File.owned?(entrada) then
			busca = /.*(.pdf)/
			if busca.match(File.basename(entrada)) then
				$temp=$dir+"/"+File.basename(entrada)#me lo llevo
				FileUtils.cp(entrada, $temp)
			else
			puts "el archivo "+entrada+" no es pdf"#TODO esto es lo único que se testeará en Rails
			exit
			end
		else
		puts "el archivo "+entrada+" no es mío"
		end
	else
	puts entrada+" no es un archivo"
	exit
	end
else
	puts "no ha especificado archivo a imponer"
	exit
end
#y la salida, de haberla
if $salida!=nil then
#if File.exists?(salida) then #TODO crearla si es escribible
	salidaDir=File.dirname($salida)
	if !File.writable?(salidaDir) or !File.writable_real?(salidaDir) then
		puts "el directorio de salida "+$salida+" no se puede escribir"
		exit
	end	
#else
#	puts salida+ " no existe"
#	exit
#end
end

puts "::::::::::::impostor::::::::::::"#blink blink
#INPUT
w_=Metodos.input("w:")
h_=Metodos.input("h:")
wP_=Metodos.input("W:")
hP_=Metodos.input("H:")
nX_=Metodos.input("nX:")
nY_=Metodos.input("nY:")
nPaginas_=Metodos.input("nPaginas:")
nPliegos_=Metodos.input("nPliegos:")
cuadernillos = Metodos.enBooklets()

def recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos, preguntas)
  impostor=Metodos.funcionar(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,preguntas)
  if impostor.preguntasOk then
    if impostor.valido then
      puts "::::::::::::mensajes:::::::::::::"#blink blink
      impostor.mensajes.each do |mensaje|
        puts mensaje.mensaje
      end
    else
      impostor.errores().each do |error|
        puts error.mensaje
      end
      puts "el programa no se ejecutara"
      exit
    end
  else
    if !impostor.preguntas["par"].ok then
      puts impostor.preguntas["par"].mensaje
      nX=Metodos.exigePar(nX)
      impostor.preguntas["par"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["cXC"].ok then
      puts impostor.preguntas["cXC"].mensaje
      impostor.cuadernillosPorCostura=Metodos.input("cXC:")#TODO
      impostor.preguntas["cXC"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["escaladoH"].ok then
      puts !impostor.preguntas["escaladoH"].mensaje
      impostor.preguntas["escaladoH"].metodo(Metodos.escalado(impostor.preguntas["escaladoH"].tipo))
      impostor.preguntas["escaladoH"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["escaladoV"].ok then
      puts impostor.preguntas["escaladoV"].mensaje
      impostor.preguntas["escaladoV"].metodo(Metodos.escalado(impostor.preguntas["escaladoV"].tipo))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["todasPag"].ok then
      puts impostor.preguntas["todasPag"].mensaje
      impostor.preguntas["todasPag"].metodo(Metodos.todasPag(impostor.preguntas["todasPag"].nPliegos, impostor.preguntas["todasPag"].nX, impostor.preguntas["todasPag"].nY, impostor.preguntas["todasPag"].caben, impostor.preguntas["todasPag"].tiene))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["reducir"].ok then
      puts impostor.preguntas["reducir"].mensaje
      impostor.preguntas["reducir"].metodo(Metodos.reducirUltimo(impostor.preguntas["reducir"].cuadernillosPorCostura, impostor.preguntas["reducir"].paginasSobran, impostor.preguntas["reducir"].nCuad, impostor.preguntas["reducir"].sobranMenos))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    end
  end
end
recursivo(w_,h_,wP_,hP_,nX_,nY_,nPaginas_,nPliegos_,cuadernillos, nil)
  
puts "::::::::::::Game Over::::::::::::"#blink blink
ensure
  #limpio todo, aunque se caiga
  if $dir!=nil then
    `rm -r #{$dir}`
  end
end
#GAME OVER