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
salida=ARGV.shift
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
				temp=$dir+"/"+File.basename(entrada)#me lo llevo
				FileUtils.cp(entrada, temp)
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
if salida!=nil then
#if File.exists?(salida) then #TODO crearla si es escribible
	salidaDir=File.dirname(salida)
	if !File.writable?(salidaDir) or !File.writable_real?(salidaDir) then
		puts "el directorio de salida "+salida+" no se puede escribir"
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
  impostor=Impostor.funcionar(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,nil)
  if retorno.preguntasOk then
    if retorno.valido then
      puts "::::::::::::mensajes:::::::::::::"#blink blink
      impostor.mensajes.each do |mensaje|
        puts mensaje.mensaje
      end
    else
      retorno.errores().each do |error|
        puts error.mensaje
      end
      puts "el programa no se ejecutara"
      exit
    end
  else
    if !retorno.preguntas["par"].ok then
      puts retorno.preguntas["par"].mensaje
      nX=Metodos.exigePar(nX)
      retorno.preguntas["par"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,retorno.preguntas)
    elsif !retorno.preguntas["cXC"].ok then
      puts retorno.preguntas["cXC"].mensaje
      impostor.cuadernillosPorCostura=Metodos.input("cXC:")#TODO
      retorno.preguntas["cXC"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,retorno.preguntas)
    elsif !preguntas["escaladoH"].ok then
      puts !preguntas["escaladoH"].mensaje
      preguntas["escaladoH"].metodo(Metodos.escalado(preguntas["escaladoH"].tipo))
      preguntas["escaladoH"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,retorno.preguntas)
    elsif !preguntas["escaladoV"].ok then
      puts preguntas["escaladoV"].mensaje
      preguntas["escaladoV"].metodo(Metodos.escalado(preguntas["escaladoV"].tipo)).
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,retorno.preguntas)
    elsif !preguntas["todasPag"].ok then
      puts preguntas["todasPag"].mensaje
      preguntas["todasPag"].metodo(Metodos.todasPag(preguntas["todasPag"].nPliegos, preguntas["todasPag"].nX, preguntas["todasPag"].nY, preguntas["todasPag"].caben, preguntas["todasPag"].tiene))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,retorno.preguntas)
    elsif !preguntas["reducir"].ok then
      puts preguntas["reducir"].mensaje
      preguntas["reducir"].metodo(Metodos.reducirUltimo(preguntas["reducir"].cuadernillosPorCostura, preguntas["reducir"].paginasSobran, preguntas["reducir"].nCuad, preguntas["reducir"].sobranMenos))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,retorno.preguntas)
    end
  end
end
  
puts "::::::::::::Game Over::::::::::::"#blink blink
ensure
  #limpio todo, aunque se caiga
  if $dir!=nil then
    `rm -r #{$dir}`
  end
end
#GAME OVER