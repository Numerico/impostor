begin

#links
require 'Clases'
include Clases
require 'Metodos'
include Metodos

require 'rubygems'
require 'alchemist'
require 'uuidtools'
require 'fileutils'

#vars
entrada=ARGV.shift
salida=ARGV.shift

#CONFIGURACIONES TODO cómo decírselas una sola vez (instalación)
work="/tmp/impostor"
$requerimientos=Hash.new
$requerimientos["pdflatex"]="/usr/bin/pdflatex"#TODO podría pasársele el puro comando
$requerimientos["pdfinfo"]="/usr/bin/pdfinfo"

#CHECKS
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
#probamos que exista el directorio de trabajo
if File.exists?(work) then
	#y que sea escribible
	if File.writable?(work) and File.writable_real?(work) then
		#creo mi directorio
		directorio=work+"/"+UUIDTools::UUID.random_create
		Dir.mkdir(directorio)
		Dir.chdir(directorio)
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
				temp=directorio+"/"+File.basename(entrada)#me lo llevo
				FileUtils.cp(entrada, temp)
			else
			puts "el archivo "+entrada+" no es pdf"
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

#PDFINFO se ejecuta una sola vez
pdfinfo = `#{$requerimientos["pdfinfo"]} -box #{temp}`

nPaginasReal=paginasdelpdf(pdfinfo)

size=pagesize(pdfinfo)
wReal=size["ancho"]
hReal=size["alto"]

puts "::::::::::::impostor::::::::::::"#blink blink

#INPUT
w_=input("w:")
h_=input("h:")
wP_=input("W:")
hP_=input("H:")
nX_=input("nX:")
nY_=input("nY:")
nPaginas_=input("nPaginas:")
nPliegos_=input("nPliegos:")
#con unidad
w=w_["numero"].send(w_["unidad"])
h=h_["numero"].send(h_["unidad"])
wP=wP_["numero"].send(wP_["unidad"])
hP=hP_["numero"].send(hP_["unidad"])
#sin unidad
nX=nX_["numero"].to_f.floor
nY=nY_["numero"].to_f.floor
nPaginas=nPaginas_["numero"].to_f.floor
nPliegos=nPliegos_["numero"].to_f.floor

#cuadernitos
cuadernillos = enBooklets()
if cuadernillos then
	#unidades
	if nX%2!=0 then
		nX=exigePar(nX) #TODO sugerencia si + o -
	end	
	#TODO COSTURAS en total
	puts "cXC - cuadernillos por costura (0->todos unos dentro de otros, 1->todos uno al lado de otro o n-> de a n cuadernillos uno dentro de otro)"
	cuadernillosPorCostura=input("cXC:")
	cuadernillosPorCostura=cuadernillosPorCostura["numero"]
	
	nX=nX/2
	puts "como imponemos en cuadernillos, tomamos la mitad de paginas horizontalmente"#TODO mensaje, quizas para una interfaz explicitar mas
	w=w*2

	w_["numero"]=w
	puts "como imponemos en cuadernillos, tomamos una pagina del doble de ancho"
end

#VALIDACION
mensajes=[]
#HORIZONTALMENTE
if w!=0.point then
	if wP!=0.point then
		if nX==0 then
			nX=(wP/w).floor
			wP=wP_["numero"].send(wP_["unidad"])#operación alchemist cambia el operando
			if nX==0 then
				mensajes.push(MensajeDato.new(3, "horizontal", 5))#error
			else
				mensajes.push(MensajeDato.new(1, "horizontal", 1))#info
			end
		end
	elsif nX!=0 then
		if wP==0.point then
			wP_["numero"]=nX*w.to_f#actualiza para no perderlo en operacion de medidas
			wP=wP_["numero"].send(w_["unidad"])
			wP_["unidad"]=w_["unidad"]
			mensajes.push(MensajeDato.new(1, "horizontal", 2))#info
		end
	else
		mensajes.push(MensajeDato.new(3, "horizontal", 1))#error
	end
elsif wP!=0.point then
	if nX!=0 then
		if escalado("horizontalmente") then
			w=(wP.to_f/nX).send(wP_["unidad"])
			w_["numero"]=w
			w_["unidad"]=wP_["unidad"]
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
	else	
		w=wReal
		if cuadernillos then
			w=w*2
			w_["numero"]=w
		end
		w_["unidad"]=size["unidad"]
		mensajes.push(MensajeDato.new(1, "horizontal", 4))#info
		nX=(wP/w).floor
		wP=wP_["numero"].send(wP_["unidad"])
		if nX==0 then
			mensajes.push(MensajeDato.new(3, "horizontal", 5))#error
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
	wP_["numero"]=nX*w.to_f
	wP=wP_["numero"].send(w_["unidad"])
	wP_["unidad"]=w_["unidad"]
	mensajes.push(MensajeDato.new(1, "horizontal", 2))#info
else
	mensajes.push(MensajeDato.new(3, "horizontal", 4))#error
end
#VERTICALMENTE
if h!=0.point then
	if hP!=0.point then
		if nY==0 then
			nY=(hP/h).floor
			hP=hP_["numero"].send(hP_["unidad"])
			if nY==0 then
				mensajes.push(MensajeDato.new(3, "vertical", 5))#error
			else	
				mensajes.push(MensajeDato.new(1, "vertical", 1))#info
			end
		end
	elsif nY!=0 then
		if hP==0.point then
			hP_["numero"]=nY*h.to_f
			hP=hP_["numero"].send(h_["unidad"])
			hP_["unidad"]=h_["unidad"]
			mensajes.push(MensajeDato.new(1, "vertical", 2))#info
		end
	else
		mensajes.push(MensajeDato.new(3, "vertical", 1))#error
	end
elsif hP!=0.point then
	if nY!=0 then
		if escalado("verticalmente") then
			h=(hP.to_f/nY).send(hP_["unidad"])
			h_["numero"]=h
			h_["unidad"]=hP_["unidad"]
			mensajes.push(MensajeDato.new(1, "vertical", 3))#info
		else
			h=hReal
			h_["numero"]=h
			h_["unidad"]=size["unidad"]
			mensajes.push(MensajeDato.new(1, "vertical", 4))#info
		end
	else
		#deducimos del pdf no mas
		h=hReal
		h_["numero"]=h
		h_["unidad"]=size["unidad"]
		mensajes.push(MensajeDato.new(1, "vertical", 4))#info
		nY=(hP/h).floor
		hP=hP_["numero"].send(hP_["unidad"])
		if nY==0 then
			mensajes.push(MensajeDato.new(3, "vertical", 5))#error
		else
			mensajes.push(MensajeDato.new(1, "vertical", 1))#info
		end
	end
elsif nY!=0 then
	h=hReal
	h_["numero"]=h
	h_["unidad"]=size["unidad"]
	mensajes.push(MensajeDato.new(1, "vertical", 4))#info
	hP_["numero"]=nY*h.to_f
	hP=hP_["numero"].send(h_["unidad"])
	hP_["unidad"]=h_["unidad"]
	mensajes.push(MensajeDato.new(1, "vertical", 2))#info
else
	mensajes.push(MensajeDato.new(3, "vertical", 4))#error
end
#MEDIDAS
if redondear(nX*w.to_f) > redondear(wP.to(w_["unidad"]).to_f) then
	mensajes.push(MensajeMedida.new(3, "horizontal", [nX, w_, wP_]))#error
elsif nX>0 and (nX*w.to_f).send(w_["unidad"]) < wP then
	sobra=wP-(nX*w.to_f).send(w_["unidad"])
	wP=wP_["numero"].send(wP_["unidad"])
	mensajes.push(MensajeMedida.new(2, "horizontal", [sobra, wP_["unidad"]]))#warn
end
if redondear(nY*h.to_f) > redondear(hP.to(h_["unidad"]).to_f) then
	mensajes.push(MensajeMedida.new(3, "vertical", [nY, h_, hP_]))#error
elsif nY>0 and (nY*h.to_f).send(h_["unidad"]) < hP then
	sobra=hP-(nY*h.to_f).send(h_["unidad"])
	hP=hP_["numero"].send(hP_["unidad"])
	mensajes.push(MensajeMedida.new(2, "vertical", [sobra, hP_["unidad"]]))#warn
end
#PAGINAS
nXm=nX
if cuadernillos then
	nXm*=2
end
if nPaginas==0 then
	if nPliegos!=0 then
		nCaben=nPliegos*nXm*nY
		if !todasPag(nPliegos, nXm, nY, nCaben, nPaginasReal) then
			nPaginas=nCaben
			if nCaben <= nPaginas then
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
#no se cuantos pliegos
if nX!=0 and nY!=0 then
	nPliegosCalc=(nPaginas.to_f/(nXm*nY)).ceil
	if nPliegos==0 then
		nPliegos=nPliegosCalc
		if cuadernillos and nPliegos%2!=0 then
			nPliegos=(nPliegos.to_f/2).ceil*2
			nPaginas=nPliegos*nXm*nY
		end
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
bookletz=booklets(cuadernillosPorCostura, nPaginas, nPaginasReal)
nPaginas=bookletz.length/2
#nPaginas multiplo de nX*nY
if nX*nY!=0 and nPaginas%(nX*nY)!=0 then
	nPaginasMult=(nPaginas/(nX*nY)+1)*(nX*nY)
	mensajes.push(Mensaje.new(1, "El pdf tiene #{nPaginas} paginas, que impuestas en #{nX}x#{nY} son #{nPaginasMult} paginas"))
else
	nPaginasMult=nPaginas
end

#TODO ¿ROTAR? si se gasta menos espacio por pliego o en total da menos pliegos...

if !validar(mensajes) then
	puts "el programa no se ejecutara"
	exit
else
	if cuadernillos then
		imponerBooklet(directorio, bookletz.join(","), temp, $requerimientos, w_, h_)#pdflatex TODO 1 sola vez?
	end
	#LaTeX TODO dejar en Metodos.rb
	puts "::::::::::::cut&Stack::::::::::::"#blink blink
	puts "nX:"+nXm.to_s
	puts "nY:"+nY.to_s
	puts "nPaginas:"+nPaginasMult.to_s
	puts "nPliegos:"+nPliegos.to_s
	puts "ancho:"+w.to_s+" "+w_["unidad"]
	puts "alto:"+h.to_s+" "+h_["unidad"]
	puts "anchoPliego:"+wP.to_s+" "+wP_["unidad"]
	puts "altoPliego:"+hP.to_s+" "+hP_["unidad"]

	wPC=pdflatexUnit(wP, wP_["unidad"])
	wP=wPC[0]
	wP_["unidad"]=wPC[1]
	hPC=pdflatexUnit(hP, hP_["unidad"])
	hP=hPC[0]
	hP_["unidad"]=hPC[1]
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
		cutStack.puts "papersize={#{wP}#{wP_["unidad"]},#{hP}#{hP_["unidad"]}},"
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
	if salida != nil then
		entrada=salida
	end
	FileUtils.mv(directorio+"/"+"cutStack.pdf", entrada)
end

ensure
#limpio todo, aunque se caiga
`rm -r #{directorio}`
end
#GAME OVER
