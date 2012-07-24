module Metodos

def myPlacePDF(nX,nY,nPaginas,nPliegos)
	myCounter=1	#numero de pagina
	myPosition=0	#posicion en las coordenadas
	@Transfer=0	#pliego
	arreglo=[]
	while (myCounter!=nPaginas+1) do
		#USO
		pos=Posicion.new(myCounter, myPosition, @Transfer)
		arreglo.push(pos)
		#NEXT
		@Transfer+=1
		if myCounter%2==0 then
			myPosition-=2
		end
		myPosition+=1
		if @Transfer==nPliegos then
			@Transfer=0
			myPosition+=2
		end
		myCounter+=1
	end
	return arreglo
end

#TODO podria eliminar w y h haciendo la comparacion en base a n y k?
def getCoordinates(nX,nY,w,h)

	coordenadas=[]
	#posibilidad de usar márgenes
	x0=0
	y0=0
	xN=x0+w*(nX-1)
	
	i=0
	k=0#posicion en
	n=0#fila
	while(i<nX*nY) do
		#USO
		coordenadas.insert(2*i, Coordenada.new(x0+k*w,y0+n*h))
		coordenadas.insert(2*i+1, Coordenada.new(xN-k*w,y0+n*h))
		#NEXT
		k+=1
		if k==nX then
			k=0
			n+=1
		end
		i+=1
	end
	return coordenadas
end

def ordenar(mix)
	for j in 0...mix.length
		for k in 0...mix.length
			if mix[j].t>mix[k].t and j<k then #si es de un pliego mayor
				temp=mix[j]
				mix[j]=mix[k]
				mix[k]=temp
			elsif mix[j].t==mix[k].t then #si es del mismo pliego
				if mix[j].y>mix[k].y and j<k then#si es de una fila mayor
					temp=mix[j]
					mix[j]=mix[k]
					mix[k]=temp
				elsif mix[j].y==mix[k].y then #si es de la misma
					if mix[j].x>mix[k].x and j<k then #si esta despues
						temp=mix[j]
						mix[j]=mix[k]
						mix[k]=temp
					end
				end
			end
		end
	end
	return mix
end

def cutStack(nX,nY,nPaginas,nPliegos,w,h)
	coordenadas=getCoordinates(nX,nY,w,h)
	posiciones=myPlacePDF(nX,nY,nPaginas,nPliegos)
	remix=[]
	for i in 0...posiciones.size
		mix=Mix.new(posiciones[i].mC, coordenadas[posiciones[i].mP].x, coordenadas[posiciones[i].mP].y, posiciones[i].t)
		remix.insert(i, mix)
	end
	remix=ordenar(remix)
	retorno=[]
	#retorna solo el orden
	for i in 0...remix.length
		retorno << remix[i].n
	end
	return retorno
end

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

#multiplo de 4
def mult4(paginasEnPliego)
	paginas=paginasEnPliego
	if paginasEnPliego%4 != 0 then
		paginas=((paginasEnPliego/4)+1)*4
		#TODO mensaje
		puts "se necesitaran #{paginas}p para imponer #{paginasEnPliego}p en #{paginas/4} cuadernillos plegables"
	else
		paginas=paginasEnPliego
	end
	return paginas
end

#crea un cuadernillo
def unaDentroDeOtra(paginasReal, paginasEnCuadernillo, inicio, fin)
	#llegan como float
	inicio=inicio.to_i
	fin=fin.to_i
	
	arreglo=[]
	for i in 0...paginasEnCuadernillo/2
		if (i+1)%2!=0 then
			arreglo.push(fin-i)
			arreglo.push(i+inicio)
		else
			arreglo.push(i+inicio)
			arreglo.push(fin-i)
		end
	end
	for i in 0...arreglo.length #TODO vale la pena meterlo en el loop anterior o de todos modos el de cut&Stack la hace y lo elimino?
		if arreglo[i]>paginasReal then
			arreglo[i]="{}"
		end
	end
	return arreglo
end

#agrupa en cuadernillos
def booklets(cuadernillosPorCostura, paginas, paginasReal)
	paginas=mult4(paginas)
	if cuadernillosPorCostura==0 then
		pagsEnCuadernillo=paginas#todos unos dentro de otros
	else
		pagsEnCuadernillo=cuadernillosPorCostura*4
	end
	arreglo=[]
	van=0
	for i in 0...(paginas.to_f/pagsEnCuadernillo).ceil
		if i!=0 then
			van+=pagsEnCuadernillo
		end

		inicio=van+1
		fin=van+pagsEnCuadernillo
		#TODO sugerencia
		if fin>paginas then
			q=paginas-van
			if q%4!=0 then
				q=((q/4)+1)*4
			end
			if van+q < fin then
				if reducirUltimo(cuadernillosPorCostura, fin-paginas, q/4, (van+q)-paginasReal)then
					pagsEnCuadernillo=q
					fin=van+q
				end
			end
		end
		#
		booklet=unaDentroDeOtra(paginasReal, pagsEnCuadernillo, inicio, fin)
		arreglo.concat(booklet)
	end
	return arreglo
end

#cortar la cola
def reducirUltimo(cuadernillosPorCostura, x, p, x2)
	puts "al ultimo grupo de #{cuadernillosPorCostura} cuadernillos le sobraran #{x}p"#TODO MENSAJE (1 sola vez)
	puts "podemos reducirlo a #{p} cuadernillos, asi sobrarian #{x2}. ¿0K? (y/n)"
	ok=STDIN.gets.to_s
	if ok[0]==121 then#Y
		return true
	elsif ok[0]==110 then#N
		return false
	else
		reducirUltimo(cuadernillosPorCostura, x, p, x2)
	end
end

def imponerBooklet(directorio, ordenBook, archivo, requerimientos, w_, h_)
	#unidades latex
	wC=pdflatexUnit(w_["numero"], w_["unidad"])
	w=wC[0]
	w_["unidad"]=wC[1]
	hC=pdflatexUnit(h_["numero"], h_["unidad"])
	h=hC[0]
	h_["unidad"]=hC[1]

	wDummy=w_["numero"].to_f#bug alchemist
	pierpa=directorio+"/"+"booKlet.tex"
	File.open(pierpa, 'w') do |booklet|
		booklet.puts "\\documentclass{report}"
		booklet.puts "\\usepackage{pdfpages}"
		booklet.puts "\\usepackage{geometry}"
		booklet.puts "\\geometry{"
		booklet.puts "papersize={#{w_["numero"]}#{h_["unidad"]},#{h_["numero"]}#{h_["unidad"]}},"
		booklet.puts "left=0mm,"#posibilidad de márgenes
		booklet.puts "right=0mm,"
		booklet.puts "top=0mm,"
		booklet.puts "bottom=0mm,"
		booklet.puts "ignoreall,"
		booklet.puts "headsep=0mm,"
		booklet.puts "headheight=0mm,"
		booklet.puts "foot=0mm,"
		booklet.puts "marginpar=0mm"
		booklet.puts "}"
		booklet.puts "\\begin{document}"
		booklet.puts "\\includepdf[pages={#{ordenBook}},nup=2x1,noautoscale,width=#{wDummy/2}#{w_["unidad"]}, height=#{h_["numero"]}#{h_["unidad"]}]{#{archivo}}"
		booklet.puts "\\end{document}"
	end
	tIni=Time.now
	pdflatex=`#{$requerimientos["pdflatex"]} #{pierpa}`
	tFin=Time.now
	t=tFin-tIni
	puts "booklets: "+t.to_s+" segundos"

	#lo devuelvo
	FileUtils.mv(directorio+"/"+"booKlet.pdf", archivo)
end

def paginasdelpdf(pdfinfo)
	info = pdfinfo.chomp
	busca = /pages\s*\:\s*(\d+)/moi
	pags = busca.match(info)
	paginas = pags[1]
	return paginas.to_i 
end

#tamaño de página
def pagesize(pdfinfo)
	info = pdfinfo.chomp
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

def todasPag(nPliegos, nX, nY, caben, tiene)
	STDOUT.puts("el pdf tiene #{tiene.to_i} paginas, pero en #{nPliegos.to_i} de #{nX}x#{nY} caben #{caben.to_i} paginas ¿usar las del pdf? (y/n)")
		escalar=STDIN.gets.to_s
	if escalar[0]==121 then#Y
		return true
	elsif escalar[0]==110 then#N
		return false
	else
		escalado(tipo)
	end
end

def redondear(n)#TODO por BUG de alchemist (ruby 1.9 tiene round(3))
	(n*1000).round/1000
end

#TODO si hay error mostrar solo errores
def validar(mensajes)
	valido=true
	mensajes.each do |mensaje|
		puts mensaje.to_s
		if mensaje.level==3 then
			valido=false
		end
	end
	return valido
end

end
