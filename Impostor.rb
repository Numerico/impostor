begin

#links
require 'Clases'
require 'Metodos'
#
require 'rubygems'
require 'alchemist'
require 'uuidtools'
require 'fileutils'

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

#####
#GEMA

impostor=Clases::Imposicion.new

#1° REQUEST (archivo)
Metodos.pdfinfo(impostor, temp)

#2° REQUEST (parametros)
#INPUT
impostor.w_=Metodos.input("w:")
impostor.h_=Metodos.input("h:")
impostor.wP_=Metodos.input("W:")
impostor.hP_=Metodos.input("H:")
nX_=Metodos.input("nX:")
nY_=Metodos.input("nY:")
nPaginas_=Metodos.input("nPaginas:")
nPliegos_=Metodos.input("nPliegos:")
impostor.cuadernillos = Metodos.enBooklets()
#con unidad
impostor.w=impostor.w_["numero"].send(impostor.w_["unidad"])
impostor.h=impostor.h_["numero"].send(impostor.h_["unidad"])
impostor.wP=impostor.wP_["numero"].send(impostor.wP_["unidad"])
impostor.hP=impostor.hP_["numero"].send(impostor.hP_["unidad"])
#sin unidad
impostor.nX=nX_["numero"].to_f.floor
impostor.nY=nY_["numero"].to_f.floor
impostor.nPaginas=nPaginas_["numero"].to_f.floor
impostor.nPliegos=nPliegos_["numero"].to_f.floor

#1° VALIDACION (cuadernillos) - javascripteable
if impostor.cuadernillos then
  
  if impostor.nX%2!=0 then
    impostor.nX=Metodos.exigePar(impostor.nX) #TODO sugerencia si + o -
  end
  
  #Nuevos parametros
  #TODO COSTURAS en total
  puts "cXC - cuadernillos por costura (0->todos unos dentro de otros, 1->todos uno al lado de otro o n-> de a n cuadernillos uno dentro de otro)"
  impostor.cuadernillosPorCostura=Metodos.input("cXC:")
  impostor.cuadernillosPorCostura=impostor.cuadernillosPorCostura["numero"]

  impostor.nX=impostor.nX/2
  puts "como imponemos en cuadernillos, tomamos la mitad de paginas horizontalmente"#TODO mensaje
  impostor.w=impostor.w*2
  impostor.w_["numero"]=impostor.w
  puts "como imponemos en cuadernillos, tomamos una pagina del doble de ancho"#TODO mensaje
end

#2° VALIDACION
retorno=Metodos.validacionRecursiva(impostor, nil, nil)

puts "::::::::::::mensajes:::::::::::::"#blink blink
#TODO si hay error mostrar solo errores
valido=true
mensajes=retorno.shift
mensajes.each do |mensaje|
  puts mensaje.to_s
  if mensaje.level==3 then
    valido=false
  end
end

#EJECUCION
if !valido then
	puts "el programa no se ejecutara"#TODO mensaje
	exit
else
  if impostor.cuadernillos then
    puts "::::::::::::booklets:::::::::::::"#blink blink
    tIni=Time.now
  	  Metodos.imponerBooklet(impostor, temp)#TODO 1 sola vez pdflatex?
  	tFin=Time.now
    t=tFin-tIni
    puts "booklets: "+t.to_s+" segundos"
  end
  puts "::::::::::::cut&Stack::::::::::::"#blink blink
  puts impostor.to_s
  tIni=Time.now
    Metodos.imponerStack(impostor, temp)
	tFin=Time.now
  t=tFin-tIni
  puts "cut&Stack: "+t.to_s+" segundos"
	#lo devuelvo
	if salida != nil then
		entrada=salida
	end
	FileUtils.mv($dir+"/"+"cutStack.pdf", entrada)
	puts "::::::::::::Game Over::::::::::::"#blink blink
end

ensure
  #limpio todo, aunque se caiga
  if $dir!=nil then
    `rm -r #{$dir}`
  end
end
#GAME OVER