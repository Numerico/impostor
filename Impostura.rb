begin
#VARS/
entrada="/home/roberto/Documentos/imPOSTO/input/podofo.pdf"
salida="/tmp/impostor"

#links
require 'Impostor'
include Impostor
require 'Cocido'
include Cocido

require 'rubygems'
require 'alchemist'
require 'uuidtools'

#CONFIGURACIONES
#TODO cómo decírselas una sola vez (instalación)
$requerimientos=Hash.new
$requerimientos["pdflatex"]="/usr/bin/pdflatex"#TODO podría pasársele el puro comando
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
		directorio=salida+"/"+UUIDTools::UUID.random_create
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
	splitted=pags[0].split(" ")
	unidad=splitted[5]
		#unidades pdfinfo 2 alchemist
		if unidad=="pts" then
			unidad="point"
		#TODO elsif...
		else#default
			unidad="point"
		end
	retorno["unidad"]=unidad
	#con unidad
	retorno["ancho"]=pags[1].to_f.send(unidad)
	retorno["alto"]=pags[2].to_f.send(unidad)
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
#TODO validar que unidad exista en alchemist
def input2alchemist(unidad)
	if unidad=="pt" or unidad=="pts" then
		return "point"
	elsif unidad=="PT" or unidad=="bp" then
		return "printer_point"
	else
		return unidad.downcase
	end
end
def input(nombre)
	retorno=Hash.new
	STDOUT.puts(nombre)
	input=STDIN.gets
	if input[0]==10 then #no input
		retorno["numero"]=0.point
		retorno["unidad"]="point"#default
		return retorno		
	else
		regex = /(\d+\.*\d*)\s*(\w*)/
		split = regex.match(input)
		if split!=nil then
			retorno["numero"]=split[1].to_f
			if split[2]=="" then
				retorno["unidad"]="point"#default
			else
				retorno["unidad"]=input2alchemist(split[2])
			end
			return retorno
		else
			puts "la unidad de #{input} no es correcta"
			input(nombre)
		end
	end
end
	#VARIABLES
	w_=input("w:")
	h_=input("h:")
	W_=input("W:")
	H_=input("H:")
	nX_=input("nX:")
	nY_=input("nY:")
	nPaginas_=input("nPaginas:")
	nPliegos_=input("nPliegos:")
	#con unidad
	w=w_["numero"].send(w_["unidad"])
	h=h_["numero"].send(h_["unidad"])
	W=W_["numero"].send(W_["unidad"])
	H=H_["numero"].send(H_["unidad"])
	#sin unidad
	nX=nX_["numero"].to_f.floor
	nY=nY_["numero"].to_f.floor
	nPaginas=nPaginas_["numero"].to_f.floor
	nPliegos=nPliegos_["numero"].to_f.floor

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
	w_["numero"]=w
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
	STDOUT.puts("el pdf tiene #{caben.to_i} paginas, pero en #{nPliegos.to_i} de #{nX}x#{nY} caben #{caben.to_i} paginas ¿usar las del pdf? (y/n)")
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
if w!=0.point then
	if W!=0.point then
		if nX==0 then
			nX=(W/w).floor
			W=W_["numero"].send(W_["unidad"])#operación alchemist cambia el operando
			if nX==0 then
				mensajes.push(MensajeDato.new(3, "horizontal", 5))#error
			else
				mensajes.push(MensajeDato.new(1, "horizontal", 1))#info
			end
		end
	elsif nX!=0 then
		if W==0.point then
			W_["numero"]=nX*w.to_f#actualiza para no perderlo en operacion de medidas
			W=W_["numero"].send(w_["unidad"])
			W_["unidad"]=w_["unidad"]
			mensajes.push(MensajeDato.new(1, "horizontal", 2))#info
		end
	else
		mensajes.push(MensajeDato.new(3, "horizontal", 1))#error
	end
elsif W!=0.point then
	if nX!=0 then
		if escalado("horizontalmente") then
			w=(W.to_f/nX).send(W_["unidad"])
			w_["unidad"]=W_["unidad"]
			mensajes.push(MensajeDato.new(1, "horizontal", 3))#info
		else
			w=wReal
			if cuadernillos then
				w=w*2
				w_["numero"]=w
			end
			w_["unidad"]=size["unidad"]
			mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
		end
		mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
	else	
		w=wReal
		if cuadernillos then
			w=w*2
			w_["numero"]=w
		end
		w_["unidad"]=size["unidad"]
		mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
		nX=(W/w).floor
		W=W_["numero"].send(W_["unidad"])
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
		w_["numero"]=w
	end
	w_["unidad"]=size["unidad"]
	mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
	W_["numero"]=nX*w.to_f
	W=W_["numero"].send(w_["unidad"])
	W_["unidad"]=w_["unidad"]
	mensajes.push(MensajeDato.new(1, "horizontal", 2))#info
else
	mensajes.push(MensajeDato.new(3, "horizontal", 4))#error
end
#VERTICALMENTE
if h!=0.point then
	if H!=0.point then
		if nY==0 then
			nY=(H/h).floor
			H=H_["numero"].send(H_["unidad"])
			if nY==0 then
				mensajes.push(MensajeDato.new(3, "vertical", 5))#error
			else	
				mensajes.push(MensajeDato.new(1, "vertical", 1))#info
			end
		end
	elsif nY!=0 then
		if H==0.point then
			H_["numero"]=nY*h.to_f
			H=H_["numero"].send(h_["unidad"])
			H_["unidad"]=h_["unidad"]
			mensajes.push(MensajeDato.new(1, "vertical", 2))#info
		end
	else
		mensajes.push(MensajeDato.new(3, "vertical", 1))#error
	end
elsif H!=0.point then
	if h!=0.point then
		if nY==0 then
			nY=(H/h).floor
			H=H_["numero"].send(H_["unidad"])
			if nY==0 then
				mensajes.push(MensajeDato.new(1, "vertical", 5))#error
			else
				mensajes.push(MensajeDato.new(1, "vertical", 1))#info
			end
		end
	elsif nY!=0 then
		if h==0.point then
			if escalado("verticalmente") then
				h=(H.to_f/nY).send(H_["unidad"])
				h_["unidad"]=H_["unidad"]
				mensajes.push(MensajeDato.new(1, "vertical", 3))#info
			else
				h=hReal
				h_["unidad"]=size["unidad"]
				mensajes.push(MensajeDato.new(1, "vertical", 4))#info
			end
		end
	else
		#deducimos del pdf no mas
		h=hReal
		h_["unidad"]=size["unidad"]
		mensajes.push(MensajeDato.new(1, "vertical", 4))#info
		nY=(H/h).floor
		H=H_["numero"].send(H_["unidad"])
		if nY==0 then
			mensajes.push(MensajeDato.new(3, "vertical", 5))#error
		else
			mensajes.push(MensajeDato.new(1, "vertical", 1))#info
		end
	end
elsif nY!=0 then
	if H!=0.point then
		if h==0.point then
			if escalado("verticalmente") then
				h=(H.to_f/nY).send(H_["unidad"])
				h_["unidad"]=H_["unidad"]
				mensajes.push(MensajeDato.new(1, "vertical", 3))#info
			else
				h=hReal
				h_["unidad"]=size["unidad"]
				mensajes.push(MensajeDato.new(1, "vertical", 4))#info
			end
		end
	elsif h!=0.point then
		if H==0.point then
			H_["numero"]=nY*h.to_f
			H=H_["numero"].send(h_["unidad"])
			H_["unidad"]=h_["unidad"]
			mensajes.push(MensajeDato.new(1, "vertical", 2))#info
		end
	else
		h=hReal
		h_["unidad"]=size["unidad"]
		mensajes.push(MensajeDato.new(1, "vertical", 4))#info
		H_["numero"]=nY*h.to_f
		H=H_["numero"].send(h_["unidad"])
		H_["unidad"]=h_["unidad"]
		mensajes.push(MensajeDato.new(1, "vertical", 2))#info
	end
else
	mensajes.push(MensajeDato.new(3, "vertical", 4))#error
end
#MEDIDAS
def redondear(n)#TODO por BUG de alchemist (ruby 1.9 tiene round(3))
	(n*1000).round/1000
end
#if (nX*w.to_f).send(w_["unidad"]) > W then
if redondear(nX*w.to_f) > redondear(W.to(w_["unidad"]).to_f) then
	mensajes.push(MensajeMedida.new(3, "horizontal", [nX, w_, W_]))#error
elsif nX>0 and (nX*w.to_f).send(w_["unidad"]) < W then
	sobra=W-(nX*w.to_f).send(w_["unidad"])
	W=W_["numero"].send(W_["unidad"])
	mensajes.push(MensajeMedida.new(2, "horizontal", [sobra, W_["unidad"]]))#warn
end
#if (nY*h.to_f).send(h_["unidad"]) > H then
if redondear(nY*h.to_f) > redondear(H.to(h_["unidad"]).to_f) then
	mensajes.push(MensajeMedida.new(3, "vertical", [nY, h_, H_]))#error
elsif nY>0 and (nY*h.to_f).send(h_["unidad"]) < H then
	sobra=H-(nY*h.to_f).send(h_["unidad"])
	H=H_["numero"].send(H_["unidad"])
	mensajes.push(MensajeMedida.new(2, "vertical", [sobra, H_["unidad"]]))#warn
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
	imponerBooklet(directorio, bookletz.join(","), temp, $requerimientos, w_, h_)##TODO ya viene doblado? debiera...
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
	puts "ancho:"+w.to_s+" "+w_["unidad"]
	puts "alto:"+h.to_s+" "+h_["unidad"]
	puts "anchoPliego:"+W.to_s+" "+W_["unidad"]
	puts "altoPliego:"+H.to_s+" "+H_["unidad"]

	#conversion unidades alchemy 2 pdflatex
	def pdflatexUnit(x, unidad)
		if unidad=="point" then
			return [x,"pt"]
		elsif unidad=="printer_point" then
			return [x,"bp"]
		elsif unidad=="m" then
			x=x.to.cm
			return [x,"cm"]
		elsif unidad=="inch" then
			return [x, "in"]
		#TODO elsif...
		else
			return [x,unidad]
		end
	end
	WC=pdflatexUnit(W, W_["unidad"])
	W=WC[0]
	W_["unidad"]=WC[1]
	HC=pdflatexUnit(H, H_["unidad"])
	H=HC[0]
	H_["unidad"]=HC[1]
	wC=pdflatexUnit(w, w_["unidad"])
	w=wC[0]
	w_["unidad"]=wC[1]
	hC=pdflatexUnit(h, h_["unidad"])
	h=hC[0]
	h_["unidad"]=hC[1]
	
	#las paginas que no existen se dejan en blanco
	cS=cutStack(nX,nY,nPaginasMult,nPliegos,w.to_f,h.to_f)
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
		cutStack.puts "papersize={#{W}#{W_["unidad"]},#{H}#{H_["unidad"]}},"
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
		cutStack.puts "\\includepdf[pages={#{cS}},nup=#{nX}x#{nY},noautoscale, frame, width=#{w}#{w_["unidad"]}, height=#{h}#{h_["unidad"]}]{#{temp}}"
		cutStack.puts "\\end{document}"
	end
	
	tIni=Time.now
	pdflatex=`#{$requerimientos["pdflatex"]} #{cutted}`
	tFin=Time.now
	t=tFin-tIni
	puts "cut&Stack: "+t.to_s+" segundos"

	#lo devuelvo
	FileUtils.mv(directorio+"/"+"cutStack.pdf", entrada)
end

ensure
#limpio todo, aunque se caiga
`rm -r #{directorio}`
end
#GAME OVER
