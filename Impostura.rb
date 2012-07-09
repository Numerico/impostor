#VARS/
entrada="/home/roberto/Documentos/imPOSTO/input/podofo.pdf"
salida="/tmp/impostor"

#links
require 'Impostor'
include Impostor
require 'Cocido'
include Cocido

#CONFIGURACIONES
#TODO cómo decirselas una sola vez (instalacion)
$requerimientos=Hash.new
$requerimientos["pdflatex"]="/usr/bin/pdflatex"#podría pasársele el puro comando
$requerimientos["pdfinfo"]="/usr/bin/pdfinfo"
#check
$requerimientos.each do |k,v|
if File.file?(v) then
	if !File.executable?(v) or !File.executable_real?(v) :
	puts k+" no es ejecutable"
	exit
	end
else
puts "no hay "+k
exit
end
end

#ARCHIVOS
require 'fileutils'
#probamos que exista la salida
if File.exists?(salida) then
	#y que sea escribible
	if File.writable?(salida) and File.writable_real?(salida) then
		#creo mi directorio
		directorio=salida+"/"+"test"#TODO GUID
		Dir.mkdir(directorio)
		Dir.chdir(directorio)
	else
	puts salida+" no se puede escribir"
	end	
else
puts salida+ " no existe"
exit
end
#y la entrada (triunfal)
if File.file?(entrada) then
	if File.owned?(entrada) then
		busca = /.*(.pdf)/
		if busca.match(File.basename(entrada)) then
			temp=directorio+"/"+File.basename(entrada)#me lo llevo
			FileUtils.mv(entrada, temp)
		else
		puts entrada+" no es pdf"
		exit
		end
	else
	puts entrada+" no es mío"
	end
else
puts entrada+" no es un archivo"
exit
end

#PDFINFO
$pdfinfo = `#{$requerimientos["pdfinfo"]} -box #{temp}`
#se ejecuta una sola vez
def paginasdelpdf()
	#pdfinfo = `#{$requerimientos["pdfinfo"]} -box #{archivo}`
	info = $pdfinfo.chomp
	busca = /pages\s*\:\s*(\d+)/moi
	pags = busca.match(info)
	paginas = pags[1]
	return paginas.to_i 
end
nPaginasReal=paginasdelpdf()
#tamaño de página
def pagesize()
	info = $pdfinfo.chomp
	busca = /Page size\s*\:\s*([\d\.]+)\s*x\s*([\d\.]+).*/
	pags = busca.match(info)
	retorno=Hash.new
	retorno["ancho"]=pags[1].to_f
	retorno["alto"]=pags[2].to_f
	splitted=pags[0].split(" ")
	unidad=splitted[5]
		#TODO conversion unidades pdfinfo & pdflatex
		if unidad=="pts" then
			unidad="pt"
		end
	retorno["unidad"]=unidad
	if splitted[6]!=nil then
		retorno["nombre"]=splitted[6].delete("(").delete(")")
	end
	return retorno
end
size=pagesize()
wReal=size["ancho"]
hReal=size["alto"]

puts "::::::::::::impostor::::::::::::"#blink blink
#INPUT
def input(nombre)
	retorno=Hash.new
	STDOUT.puts(nombre)
	input=STDIN.gets
	if input[0]==10 then #no input
		retorno["numero"]=0
		return retorno		
	end
	regex = /(\d+)\s*(\w*)/ #TODO punto flotante
	split = regex.match(input)
	if split!=nil then
		retorno["numero"]=split[1].to_i
		retorno["unidad"]=split[2]
		return retorno
	else
		puts "la unidad de #{input} no es correcta"
		input(nombre)
	end
end
	#VARIABLES
	w=input("w:")
	h=input("h:")
	W=input("W:")
	H=input("H:")
	nX=input("nX:")
	nY=input("nY:")
	nPaginas=input("nPaginas:")
	nPliegos=input("nPliegos:")
	
	#TODO TRATAMIENTO DE UNIDADES ahora que las tengo
	w=w["numero"]
	h=h["numero"]
	W=W["numero"]
	H=H["numero"]
	nX=nX["numero"]
	nY=nY["numero"]
	nPaginas=nPaginas["numero"]
	nPliegos=nPliegos["numero"]

#cuadernitos
def enBooklets()
	STDOUT.puts("¿imponer en cuadernillos? (y/n)")
		bookies=STDIN.gets.to_s
	if bookies[0]==121 then#Y
		return true
	elsif bookies[0]==110 then#N
		return false
	else
		enBooklets()
	end
end
def exigePar(nX)
	puts "para imponer en cuadernillos tienen que caber horizontalmente en numeros pares pero ud especifico nX:#{nX}."
	nX=input("nX:")
	nX=nX["numero"]
	if nX%2!=0 then
		exigePar(nX)
	end
	return nX 		
end

cuadernillos = enBooklets()
if cuadernillos then
	#unidades
	if nX%2!=0 then
		nX=exigePar(nX) #TODO sugerencia si + o -
	end
	
	#TODO COSTURAS en total
	puts "Cuadernillos por Costura -cXC- (0->todos unos dentro de otros, 1->todos uno al lado de otro o n-> de a n cuadernillos uno dentro de otro)"
	cuadernillosPorCostura=input("cXC:")
	cuadernillosPorCostura=cuadernillosPorCostura["numero"]

	nX=nX/2
	puts "como imponemos en cuadernillos, tomamos la mitad de paginas horizontalmente"#TODO mensaje, quizas para una interfaz explicitar mas
	w=w*2
	puts "como imponemos en cuadernillos, tomamos una pagina del doble de ancho"

end

###########
#VALIDACION
mensajes=[]
#DATOS
def escalado(tipo)
	if tipo=="horizontalmente" then
		puts "no especifico ancho de pagina pero si ancho de pliego y numero de paginas por pliego "+tipo 
	else
		puts "no especifico alto de pagina pero si alto de pliego y numero de paginas por pliego "+tipo
	end
	STDOUT.puts("¿escalar "+tipo+"? (y/n)")
		escalar=STDIN.gets.to_s
	if escalar[0]==121 then#Y
		return true
	elsif escalar[0]==110 then#N
		return false
	else
		escalado(tipo)
	end
end
def todasPag(nPliegos, nX, nY, caben)
	STDOUT.puts("el pdf tiene #{caben.to_i} paginas, pero en #{nPliegos.to_i} de #{nX.to_i}x#{nY.to_i} caben #{caben.to_i} paginas ¿usar las del pdf? (y/n)")
		escalar=STDIN.gets.to_s
	if escalar[0]==121 then#Y
		return true
	elsif escalar[0]==110 then#N
		return false
	else
		escalado(tipo)
	end
end
#HORIZONTALMENTE
if w!=0 then
	if W!=0 then
		if nX==0 then
			nX=(W/w).floor
			if nX==0 then
				mensajes.push(MensajeDato.new(3, "horizontal", 5))#error
			else
				mensajes.push(MensajeDato.new(1, "horizontal", 1))#info
			end
		end
	elsif nX!=0 then
		if W==0 then
			W=nX*w
			mensajes.push(MensajeDato.new(1, "horizontal", 2))#info
		end
	else
		mensajes.push(MensajeDato.new(3, "horizontal", 1))#error
	end
elsif W!=0 then
	if nX!=0 then
		if escalado("horizontalmente") then
			w=W/nX
			mensajes.push(MensajeDato.new(1, "horizontal", 3))#info
		else
			w=wReal
			if cuadernillos then
				w=w*2
			end
			mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
		end
	else	
		w=wReal
		if cuadernillos then
			w=w*2
		end
		mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
		nX=(W/w).floor
		if nX==0 then
			mensajes.push(MensajeDato.new(1, "horizontal", 5))#error
		else	
			mensajes.push(MensajeDato.new(1, "horizontal", 1))#info
		end
	end
elsif nX!=0 then
	w=wReal
	if cuadernillos then
		w=w*2
	end
	mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
	W=nX*w
	mensajes.push(MensajeDato.new(1, "horizontal", 2))#info
else
	mensajes.push(MensajeDato.new(3, "horizontal", 4))#error
end
#VERTICALMENTE
if h!=0 then
	if H!=0 then
		if nY==0 then
			nY=(H/h).floor
			if nY==0 then
				mensajes.push(MensajeDato.new(3, "vertical", 5))#error
			else	
				mensajes.push(MensajeDato.new(1, "vertical", 1))#info
			end
		end
	elsif nY!=0 then
		if H==0 then
			H=nY*h
			mensajes.push(MensajeDato.new(1, "vertical", 2))#info
		end
	else
		mensajes.push(MensajeDato.new(3, "vertical", 1))#error
	end
elsif H!=0 then
	if h!=0 then
		if nY==0 then
			nY=(H/h).floor
			if nY==0 then
				mensajes.push(MensajeDato.new(1, "vertical", 5))#error
			else
				mensajes.push(MensajeDato.new(1, "vertical", 1))#info
			end
		end
	elsif nY!=0 then
		if h==0 then
			if escalado("verticalmente") then
				h=H/nY
				mensajes.push(MensajeDato.new(1, "vertical", 3))#info
			else
				h=hReal
				mensajes.push(MensajeDato.new(1, "vertical", 4))#info
			end
		end
	else
		#deducimos del pdf no mas
		h=hReal
		mensajes.push(MensajeDato.new(1, "vertical", 4))#info
		nY=(H/h).floor
		if nY==0 then
			mensajes.push(MensajeDato.new(3, "vertical", 5))#error
		else
			mensajes.push(MensajeDato.new(1, "vertical", 1))#info
		end
	end
elsif nY!=0 then
	if H!=0 then
		if h==0 then
			if escalado("verticalmente") then
				h=H/nY
				mensajes.push(MensajeDato.new(1, "vertical", 3))#info
			else
				h=hReal
				mensajes.push(MensajeDato.new(1, "vertical", 4))#info
			end
		end
	elsif h!=0 then
		if H==0 then
			H=nY*h
			mensajes.push(MensajeDato.new(1, "vertical", 2))#info
		end
	else
		h=hReal
		mensajes.push(MensajeDato.new(1, "vertical", 4))#info
		H=nY*h
		mensajes.push(MensajeDato.new(1, "vertical", 2))#info
			#mensajes.push(MensajeDato.new(3, "vertical", 3))#error
	end
else
	mensajes.push(MensajeDato.new(3, "vertical", 4))#error
end
#MEDIDAS
if nX*w>W then
	mensajes.push(MensajeMedida.new(3, "horizontal", [nX, w, W]))#error
elsif nX>0 and nX*w<W then
	sobra=W-(nX*w)
	mensajes.push(MensajeMedida.new(2, "horizontal", [sobra]))#warn
end
if nY*h>H then
	mensajes.push(MensajeMedida.new(3, "vertical", [nY, h, H]))#error
elsif nY>0 and nY*h<H then
	sobra=H-(nY*h)
	mensajes.push(MensajeMedida.new(2, "vertical", [sobra]))#warn
end
#PAGINAS
if nPaginas==0 then
	if nPliegos!=0 then
		nCaben=nPliegos*nX*nY
		if !todasPag(nPliegos, nX, nY, nCaben) then
			if nCaben <= nPaginas then
				nPaginas=nCaben
				mensajes.push(MensajeDato.new(1, "paginas", 1))#info
			else
				mensajes.push(MensajeDato.new(3, "paginas", 1))#error	
			end
		else
			nPaginas=nPaginasReal
			mensajes.push(MensajeDato.new(1, "paginas", 3))#info
		end
	else
		nPaginas=nPaginasReal
		mensajes.push(MensajeDato.new(1, "paginas", 3))#info
	end
end
#unidad y orden (parece lema patrio)
if cuadernillos then
	bookletz=booklets(cuadernillosPorCostura, nPaginas)
	nPaginas=bookletz.length/2
	puts "si cada pagina es un cuadernillo serian #{nPaginas}p"#TODO mensaje
	#pdflatex
	imponerBooklet(directorio, bookletz.join(","), temp, $requerimientos, w, h, size)
end
#nPaginas multiplo de nX*nY
if nX*nY!=0 and nPaginas%(nX*nY)!=0 then
	nPaginasMult=(nPaginas/(nX*nY)+1)*(nX*nY)
	mensajes.push(Mensaje.new(1, "El pdf tiene #{nPaginas} paginas, que impuestas en #{nX}x#{nY} son #{nPaginasMult} paginas"))
else
	nPaginasMult=nPaginas
end
#no se cuantos pliegos
if nX!=0 and nY!=0 then
	nPliegosCalc=(nPaginasMult.to_f/(nX*nY)).ceil
	if nPliegos==0 then
		nPliegos=nPliegosCalc
		mensajes.push(MensajeDato.new(1, "paginas", 2))#info
	else
		if nPliegos<nPliegosCalc then
			faltan=nPliegosCalc-nPliegos#error
			mensajes.push(MensajeDato.new(3, "pliegos", faltan))#error	
		elsif nPliegos>nPliegosCalc then
			sobran=nPliegos-nPliegosCalc
			mensajes.push(MensajeDato.new(2, "pliegos", sobran))#warn
		end
	end
end

#TODO ¿ROTAR?
#si se gasta menos espacio por pliego o en total da menos pliegos...

#######
#OUTPUT#
#######
ejecutara=true
tratarRotar=false
mensajes.each do |mensaje|
	puts mensaje.to_s
	if mensaje.level==3 then
		ejecutara=false
	end
end
if !ejecutara then
	puts "el programa no se ejecutara"
	exit
else
	#LaTeX
	puts "::::::::::::cut&Stack::::::::::::"#blink blink
	puts "nX:"+nX.to_s
	puts "nY:"+nY.to_s
	puts "nPaginas:"+nPaginasMult.to_s
	puts "nPliegos:"+nPliegos.to_s
	puts "ancho:"+w.to_s
	puts "alto:"+h.to_s
	puts "anchoPliego:"+W.to_s
	puts "altoPliego:"+H.to_s

	#tIni=Time.now

	#las paginas que no existen se dejan en blanco
	cS=cutStack(nX,nY,nPaginasMult,nPliegos,w,h)
	for i in 0...cS.size
		if cS[i].to_i > nPaginas then
			cS[i]="{}"
		end
	end
	cS=cS.join(",")

	cutted=directorio+"/"+"cutStack.tex"
	File.open(cutted, 'w') do |cutStack|
		cutStack.puts "\\documentclass{report}"
		cutStack.puts "\\usepackage{pdfpages}"
		cutStack.puts "\\usepackage{geometry}"
		cutStack.puts "\\geometry{"
		cutStack.puts "papersize={#{W}#{size["unidad"]},#{H}#{size["unidad"]}},"#TODO MANEJO UNIDADES
		cutStack.puts "left=0mm,"#posibilidad de márgenes
		cutStack.puts "right=0mm,"
		cutStack.puts "top=0mm,"
		cutStack.puts "bottom=0mm,"
		cutStack.puts "ignoreall,"
		cutStack.puts "headsep=0mm,"
		cutStack.puts "headheight=0mm,"
		cutStack.puts "foot=0mm,"
		cutStack.puts "marginpar=0mm"
		cutStack.puts "}"
		cutStack.puts "\\begin{document}"
		cutStack.puts "\\includepdf[pages={#{cS}},nup=#{nX}x#{nY},noautoscale, frame, width=#{w}pt, height=#{h}pt]{#{temp}}"#TODO MANEJO UNIDADES
		cutStack.puts "\\end{document}"
	end
	
	tIni=Time.now
	pdflatex=`#{$requerimientos["pdflatex"]} #{cutted}`
	tFin=Time.now
	t=tFin-tIni
	puts "cut&Stack: "+t.to_s+" segundos"

	#lo devuelvo
	FileUtils.mv(directorio+"/"+"cutStack.pdf", entrada)
	#limpio todo, TODO aunque se caiga
	Dir.delete(directorio)
	#GAME OVER
end


