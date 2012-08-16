module Metodos

#INPUT
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

def exigePar(nX) #TODO sugerencia si + o -
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
    todasPag(nPliegos, nX, nY, caben, tiene)
  end
end

def reducirUltimo(cuadernillosPorCostura, paginasSobran, nCuad, sobranMenos)
  puts "al ultimo grupo de #{cuadernillosPorCostura} cuadernillos le sobraran #{paginasSobran}p"#TODO MENSAJE (1 sola vez)
  puts "podemos reducirlo a #{nCuad} cuadernillos, asi sobrarian #{sobranMenos}. ¿0K? (y/n)"
  ok=STDIN.gets.to_s
  if ok[0]==121 then#Y
    return true
  elsif ok[0]==110 then#N
    return false
  else
    reducirUltimo(cuadernillosPorCostura, paginasSobran, nCuad, sobranMenos)
  end
end

#WORK
def funcionar(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,preguntas)
  impostor=Clases::Imposicion.new(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos)
  pdfinfo(impostor, temp)
  retorno=validacion(impostor, preguntas)
  if retorno.preguntasOk then
    retorno.mensajes.push(Clases::Mensaje.new(impostor.to_s))
    if impostor.cuadernillos then
      retorno.mensajes.push(imponerBooklet(impostor, temp))
    end
    retorno.mensajes.push(imponerStack(impostor, temp))
    #lo devuelvo
    if salida != nil then
      entrada=salida
    end
    FileUtils.mv($dir+"/"+"cutStack.pdf", entrada)
  end
  return retorno
end

#########
module_function :input, :enBooklets, :exigePar, :escalado, :todasPag, :reducirUltimo, :funcionar
#########

def self.pdfinfo(impostor, temp)
  Dir.chdir($dir)
  pdfinfo = `#{$requerimientos["pdfinfo"]} -box #{temp}`
  impostor.nPaginasReal=paginasdelpdf(pdfinfo)
  impostor.size=Metodos.pagesize(pdfinfo)
  impostor.wReal=impostor.size["ancho"]
  impostor.hReal=impostor.size["alto"]
  Dir.chdir($codeDir)
end

def self.paginasdelpdf(pdfinfo)
  info = pdfinfo.chomp
  busca = /pages\s*\:\s*(\d+)/moi
  pags = busca.match(info)
  paginas = pags[1]
  return paginas.to_i 
end

#tamaño de página
def self.pagesize(pdfinfo)
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

def self.imponerStack(impostor, temp)
  
  wPC=pdflatexUnit(impostor.wP, impostor.wP_["unidad"])
  impostor.wP=wPC[0]
  impostor.wP_["unidad"]=wPC[1]
  hPC=pdflatexUnit(impostor.hP, impostor.hP_["unidad"])
  impostor.hP=hPC[0]
  impostor.hP_["unidad"]=hPC[1]
  wC=pdflatexUnit(impostor.w, impostor.w_["unidad"])
  impostor.w=wC[0]
  impostor.w_["unidad"]=wC[1]
  hC=pdflatexUnit(impostor.h, impostor.h_["unidad"])
  impostor.h=hC[0]
  impostor.h_["unidad"]=hC[1]
  
  #las paginas que no existen se dejan en blanco
  cS=cutStack(impostor.nX,impostor.nY,impostor.nPaginas,impostor.nPliegos,impostor.w.to_f,impostor.h.to_f)
  for i in 0...cS.size
    if cS[i].to_i > impostor.nPaginasReal then
      cS[i]="{}"
    end
  end
  cS=cS.join(",")

  cutted=$dir+"/"+"cutStack.tex"
  File.open(cutted, 'w') do |cutStack|
    cutStack.puts "\\documentclass{report}"
    cutStack.puts "\\usepackage{pdfpages}"
    cutStack.puts "\\usepackage{geometry}"
    cutStack.puts "\\geometry{"
    cutStack.puts "papersize={#{impostor.wP}#{impostor.wP_["unidad"]},#{impostor.hP}#{impostor.hP_["unidad"]}},"
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
    cutStack.puts "\\includepdf[pages={#{cS}},nup=#{impostor.nX}x#{impostor.nY},noautoscale, frame, width=#{impostor.w}#{impostor.w_["unidad"]}, height=#{impostor.h}#{impostor.h_["unidad"]}]{#{temp}}"
    cutStack.puts "\\end{document}"
  end
  
  #LaTeX
  Dir.chdir($dir)
  tIni=Time.now
  pdflatex=`#{$requerimientos["pdflatex"]} #{cutted}`
  tFin=Time.now
  t=tFin-tIni
  Dir.chdir($codeDir)
  
  #retorno
  return Clases::MensajeTiempo.new(2,t)
end

#TODO 1 sola vez pdflatex?

def self.imponerBooklet(impostor, archivo)
  #unidades latex
  wC=pdflatexUnit(impostor.w_["numero"], impostor.w_["unidad"])
  impostor.w=wC[0]
  impostor.w_["unidad"]=wC[1]
  hC=pdflatexUnit(impostor.h_["numero"], impostor.h_["unidad"])
  impostor.h=hC[0]
  impostor.h_["unidad"]=hC[1]

  wDummy=impostor.w_["numero"].to_f#bug alchemist
  pierpa=$dir+"/"+"booKlet.tex"
  File.open(pierpa, 'w') do |booklet|
    booklet.puts "\\documentclass{report}"
    booklet.puts "\\usepackage{pdfpages}"
    booklet.puts "\\usepackage{geometry}"
    booklet.puts "\\geometry{"
    booklet.puts "papersize={#{impostor.w_["numero"]}#{impostor.h_["unidad"]},#{impostor.h_["numero"]}#{impostor.h_["unidad"]}},"
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
    booklet.puts "\\includepdf[pages={#{impostor.bookletz.join(",")}},nup=2x1,noautoscale,width=#{wDummy/2}#{impostor.w_["unidad"]}, height=#{impostor.h_["numero"]}#{impostor.h_["unidad"]}]{#{archivo}}"
    booklet.puts "\\end{document}"
  end
  #LaTeX
  Dir.chdir($dir)
  tIni=Time.now
  pdflatex=`#{$requerimientos["pdflatex"]} #{pierpa}`
  tFin=Time.now
  t=tFin-tIni
  Dir.chdir($codeDir)
  #lo devuelvo
  FileUtils.mv($dir+"/"+"booKlet.pdf", archivo)
  #retorno
  return Clases::MensajeTiempo.new(1,t)
end

def self.myPlacePDF(nX,nY,nPaginas,nPliegos)
	myCounter=1	#numero de pagina
	myPosition=0	#posicion en las coordenadas
	@Transfer=0	#pliego
	arreglo=[]
	while (myCounter!=nPaginas+1) do
		#USO
		pos=Clases::Posicion.new(myCounter, myPosition, @Transfer)
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
def self.getCoordinates(nX,nY,w,h)

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
		coordenadas.insert(2*i, Clases::Coordenada.new(x0+k*w,y0+n*h))
		coordenadas.insert(2*i+1, Clases::Coordenada.new(xN-k*w,y0+n*h))
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

def self.ordenar(mix)
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

def self.cutStack(nX,nY,nPaginas,nPliegos,w,h)
	coordenadas=getCoordinates(nX,nY,w,h)
	posiciones=myPlacePDF(nX,nY,nPaginas,nPliegos)
	remix=[]
	for i in 0...posiciones.size
		mix=Clases::Mix.new(posiciones[i].mC, coordenadas[posiciones[i].mP].x, coordenadas[posiciones[i].mP].y, posiciones[i].t)
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
def self.pdflatexUnit(x, unidad)
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

#crea un cuadernillo
def self.unaDentroDeOtra(paginasReal, paginasEnCuadernillo, inicio, fin)
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

#TODO validar que unidad exista en alchemist
def self.input2alchemist(unidad)
	if unidad=="pt" or unidad=="pts" then
		return "point"
	elsif unidad=="PT" or unidad=="bp" then
		return "printer_point"
	else
		return unidad.downcase
	end
end

def self.redondear(n)#TODO por BUG de alchemist (ruby 1.9 tiene round(3))
  (n*1000).round/1000
end

#agrupa en cuadernillos
def self.booklets(pagsEnCuadernillo, paginas, paginasReal, q)
  arreglo=[]
  van=0
  for i in 0...(paginas.to_f/pagsEnCuadernillo).ceil
    if i!=0 then
      van+=pagsEnCuadernillo
    end
    inicio=van+1
    fin=van+pagsEnCuadernillo
    if fin>paginas and q!=nil then
          pagsEnCuadernillo=q
          fin=van+q
    end
    booklet=unaDentroDeOtra(paginasReal, pagsEnCuadernillo, inicio, fin)
    arreglo.concat(booklet)
  end
  return arreglo
end

#multiplo de 4
def self.mult4(paginasEnPliego)
  paginas=paginasEnPliego
  if paginasEnPliego%4 != 0 then
    paginas=((paginasEnPliego/4)+1)*4
    puts "se necesitaran #{paginas}p para imponer #{paginasEnPliego}p en #{paginas/4} cuadernillos plegables"#TODO mensaje, no aquí?
  else
    paginas=paginasEnPliego
  end
  return paginas
end

def self.cortarCola(nPaginas, pagsEnCuadernillo, cuadernillosPorCostura)
  max = (nPaginas/pagsEnCuadernillo).ceil
  if max*pagsEnCuadernillo>nPaginas then
    anterior=pagsEnCuadernillo*(max-1)
    q=nPaginas-anterior
    if q%4!=0 then
      q=((q/4)+1)*4
    end
    if anterior+q < max*pagsEnCuadernillo then
      return Clases::PreguntaReducir.new(cuadernillosPorCostura, max*pagsEnCuadernillo-nPaginas, q/4, (anterior+q)-nPaginas, q)
    end
  end
end

def self.validacion(impostor, preguntas)
  mensajes=[]
  if preguntas==nil then
    preguntas=Hash.new
  end
  if impostor.cuadernillos then
    if impostor.nX%2!=0 then
      preguntas["par"]=Clases::PreguntaExigePar.new(impostor.nX)
    end
    if impostor.cuadernillosPorCostura==nil then
        preguntas["cXC"]=Clases::PreguntaCXC.new()
    else
      impostor.cuadernillosPorCostura=impostor.cuadernillosPorCostura["numero"]
    end  
    impostor.nX=impostor.nX/2
    impostor.w=impostor.w*2
    impostor.w_["numero"]=impostor.w
    mensajes.push(Clases::Mensaje.new(1, "como imponemos en cuadernillos, tomamos la mitad de paginas horizontalmente y una pagina del doble de ancho"))
  end
  #HORIZONTALMENTE
  if impostor.w!=0.point then
    if impostor.wP!=0.point then
      if impostor.nX==0 then
        impostor.nX=(wP/w).floor
        impostor.wP=impostor.wP_["numero"].send(impostor.wP_["unidad"])#operación alchemist cambia el operando
        if impostor.nX==0 then
          mensajes.push(Clases::MensajeDato.new(3, "horizontal", 5))#error
        else
          mensajes.push(Clases::MensajeDato.new(1, "horizontal", 1))#info
        end
      end
    elsif impostor.nX!=0 then
      if impostor.wP==0.point then
        impostor.wP_["numero"]=impostor.nX*impostor.w.to_f#actualiza para no perderlo en operacion de medidas
        impostor.wP=impostor.wP_["numero"].send(impostor.w_["unidad"])
        impostor.wP_["unidad"]=impostor.w_["unidad"]
        mensajes.push(Clases::MensajeDato.new(1, "horizontal", 2))#info
      end
    else
      mensajes.push(Clases::MensajeDato.new(3, "horizontal", 1))#error
    end
  elsif impostor.wP!=0.point then
    if impostor.nX!=0 then
      if preguntas["escaladoH"]==nil or !preguntas["escaladoH"].ok then
        preguntas["escaladoH"]=Clases::PreguntaEscalado.new("horizontalmente")
      else
        if preguntas["escaladoH"].yn then
          impostor.w=(impostor.wP.to_f/impostor.nX).send(impostor.wP_["unidad"])
          impostor.w_["numero"]=impostor.w
          impostor.w_["unidad"]=impostor.wP_["unidad"]
          mensajes.push(Clases::MensajeDato.new(1, "horizontal", 3))#info
        else
          impostor.w=impostor.wReal
          if impostor.cuadernillos then
            impostor.w=impostor.w*2
            impostor.w_["numero"]=impostor.w
          end
          impostor.w_["unidad"]=impostor.size["unidad"]
          mensajes.push(Clases::MensajeDato.new(1, "horizontal", 4))#info
        end
      end
    else  
      impostor.w=impostor.wReal
      if impostor.cuadernillos then
        impostor.w=impostor.w*2
        impostor.w_["numero"]=impostor.w
      end
      impostor.w_["unidad"]=impostor.size["unidad"]
      mensajes.push(Clases::MensajeDato.new(1, "horizontal", 4))#info
      impostor.nX=(impostor.wP/impostor.w).floor
      impostor.wP=impostor.wP_["numero"].send(impostor.wP_["unidad"])
      if impostor.nX==0 then
        mensajes.push(Clases::MensajeDato.new(3, "horizontal", 5))#error
      else  
        mensajes.push(Clases::MensajeDato.new(1, "horizontal", 1))#info
      end
    end
  elsif impostor.nX!=0 then
    impostor.w=impostor.wReal
    if impostor.cuadernillos then
      impostor.w=impostor.w*2
      impostor.w_["numero"]=impostor.w
    end
    impostor.w_["unidad"]=impostor.size["unidad"]
    mensajes.push(Clases::MensajeDato.new(1, "horizontal", 4))#info
    impostor.wP_["numero"]=impostor.nX*impostor.w.to_f
    impostor.wP=impostor.wP_["numero"].send(impostor.w_["unidad"])
    impostor.wP_["unidad"]=impostor.w_["unidad"]
    mensajes.push(Clases::MensajeDato.new(1, "horizontal", 2))#info
  else
    mensajes.push(Clases::MensajeDato.new(3, "horizontal", 4))#error
  end
  #VERTICALMENTE
  if impostor.h!=0.point then
    if impostor.hP!=0.point then
      if impostor.nY==0 then
        impostor.nY=(impostor.hP/impostor.h).floor
        impostor.hP=impostor.hP_["numero"].send(impostor.hP_["unidad"])
        if impostor.nY==0 then
          mensajes.push(Clases::MensajeDato.new(3, "vertical", 5))#error
        else  
          mensajes.push(Clases::MensajeDato.new(1, "vertical", 1))#info
        end
      end
    elsif impostor.nY!=0 then
      if impostor.hP==0.point then
        impostor.hP_["numero"]=impostor.nY*impostor.h.to_f
        impostor.hP=impostor.hP_["numero"].send(impostor.h_["unidad"])
        impostor.hP_["unidad"]=impostor.h_["unidad"]
        mensajes.push(Clases::MensajeDato.new(1, "vertical", 2))#info
      end
    else
      mensajes.push(Clases::MensajeDato.new(3, "vertical", 1))#error
    end
  elsif impostor.hP!=0.point then
    if impostor.nY!=0 then
      if preguntas["escaladoV"]==nil or !preguntas["escaladoV"].ok then
        preguntas["escaladoV"]=Clases::PreguntaEscalado.new("verticalmente")
      else
        if preguntas["escaladoV"].yn then
          impostor.h=(impostor.hP.to_f/impostor.nY).send(impostor.hP_["unidad"])
          impostor.h_["numero"]=impostor.h
          impostor.h_["unidad"]=impostor.hP_["unidad"]
          mensajes.push(Clases::MensajeDato.new(1, "vertical", 3))#info
        else
          impostor.h=impostor.hReal
          impostor.h_["numero"]=impostor.h
          impostor.h_["unidad"]=impostor.size["unidad"]
          mensajes.push(Clases::MensajeDato.new(1, "vertical", 4))#info
        end
      end
    else
      #deducimos del pdf no mas
      impostor.h=impostor.hReal
      impostor.h_["numero"]=impostor.h
      impostor.h_["unidad"]=impostor.size["unidad"]
      mensajes.push(Clases::MensajeDato.new(1, "vertical", 4))#info
      impostor.nY=(impostor.hP/impostor.h).floor
      impostor.hP=impostor.hP_["numero"].send(impostor.hP_["unidad"])
      if impostor.nY==0 then
        mensajes.push(Clases::MensajeDato.new(3, "vertical", 5))#error
      else
        mensajes.push(Clases::MensajeDato.new(1, "vertical", 1))#info
      end
    end
  elsif impostor.nY!=0 then
    impostor.h=impostor.hReal
    impostor.h_["numero"]=impostor.h
    impostor.h_["unidad"]=impostor.size["unidad"]
    mensajes.push(Clases::MensajeDato.new(1, "vertical", 4))#info
    impostor.hP_["numero"]=impostor.nY*impostor.h.to_f
    impostor.hP=impostor.hP_["numero"].send(impostor.h_["unidad"])
    impostor.hP_["unidad"]=impostor.h_["unidad"]
    mensajes.push(Clases::MensajeDato.new(1, "vertical", 2))#info
  else
    mensajes.push(Clases::MensajeDato.new(3, "vertical", 4))#error
  end
  #MEDIDAS
  if redondear(impostor.nX*impostor.w.to_f) > redondear(impostor.wP.to(impostor.w_["unidad"]).to_f) then
    mensajes.push(Clases::MensajeMedida.new(3, "horizontal", [impostor.nX, impostor.w_, impostor.wP_]))#error
  elsif impostor.nX>0 and (impostor.nX*impostor.w.to_f).send(impostor.w_["unidad"]) < impostor.wP then
    sobra=impostor.wP-(impostor.nX*impostor.w.to_f).send(impostor.w_["unidad"])
    impostor.wP=impostor.wP_["numero"].send(impostor.wP_["unidad"])
    mensajes.push(Clases::MensajeMedida.new(2, "horizontal", [sobra, impostor.wP_["unidad"]]))#warn
  end
  if redondear(impostor.nY*impostor.h.to_f) > redondear(impostor.hP.to(impostor.h_["unidad"]).to_f) then
    mensajes.push(Clases::MensajeMedida.new(3, "vertical", [impostor.nY, impostor.h_, impostor.hP_]))#error
  elsif impostor.nY>0 and (impostor.nY*impostor.h.to_f).send(impostor.h_["unidad"]) < impostor.hP then
    sobra=impostor.hP-(impostor.nY*impostor.h.to_f).send(impostor.h_["unidad"])
    impostor.hP=impostor.hP_["numero"].send(impostor.hP_["unidad"])
    mensajes.push(Clases::MensajeMedida.new(2, "vertical", [sobra, impostor.hP_["unidad"]]))#warn
  end
  #PAGINAS
  nXm=impostor.nX
  if impostor.cuadernillos then
    nXm*=2
  end
  if impostor.nPaginas==0 then
    if impostor.nPliegos!=0 then
      nCaben=impostor.nPliegos*nXm*impostor.nY
      if preguntas["todasPag"]==nil or !preguntas["todasPag"].ok then
        preguntas["todasPag"]=Clases::PreguntaTodasPag.new(impostor.nPliegos, nXm, impostor.nY, nCaben, impostor.nPaginasReal)
      else
        if !preguntas["todasPag"].yn then
          impostor.nPaginas=nCaben
          if nCaben <= impostor.nPaginas then
            mensajes.push(Clases::MensajeDato.new(1, "paginas", 1))#info
          else
            mensajes.push(Clases::MensajeDato.new(3, "paginas", 1))#error 
          end
        else
          impostor.nPaginas=impostor.nPaginasReal
          mensajes.push(Clases::MensajeDato.new(1, "paginas", 3))#info
        end
      end
    else
      impostor.nPaginas=impostor.nPaginasReal
      mensajes.push(Clases::MensajeDato.new(1, "paginas", 3))#info
    end
  else
    if impostor.nPaginas < impostor.nPaginasReal then
      impostor.nPaginasReal=impostor.nPaginas
    end
  end
  #no se cuantos pliegos
  if impostor.nX!=0 and impostor.nY!=0 then
    nPliegosCalc=(impostor.nPaginas.to_f/(nXm*impostor.nY)).ceil
    if impostor.nPliegos==0 then
      impostor.nPliegos=nPliegosCalc
      if impostor.nPliegos%2!=0 then
        puts "como son cuadernillos lado y lado los pliegos no pueden ser impares, se toman #{impostor.nPliegos}+1"#TODO mensaje
        impostor.nPliegos=(impostor.nPliegos.to_f/2).ceil*2
        impostor.nPaginas=impostor.nPliegos*nXm*impostor.nY
      end
      mensajes.push(Clases::MensajeDato.new(1, "paginas", 2))#info
    else
      if impostor.nPliegos<nPliegosCalc then
        faltan=nPliegosCalc-impostor.nPliegos
        mensajes.push(Clases::MensajeDato.new(3, "pliegos", faltan))#error  
      elsif impostor.nPliegos>nPliegosCalc then
        sobran=impostor.nPliegos-nPliegosCalc
        mensajes.push(Clases::MensajeDato.new(2, "pliegos", sobran))#warn
      end
    end
  end
  if impostor.cuadernillos then
    impostor.nPaginas=mult4(impostor.nPaginas)
    if impostor.cuadernillosPorCostura==0 then
      pagsEnCuadernillo=impostor.nPaginas#todos unos dentro de otros
    else
      pagsEnCuadernillo=impostor.cuadernillosPorCostura*4
    end
    if preguntas["reducir"]==nil or !preguntas["reducir"].ok then
      preguntas["reducir"]=cortarCola(impostor.nPaginas, pagsEnCuadernillo, impostor.cuadernillosPorCostura)
    else
      if preguntas["reducir"].yn then
        q=preguntas["reducir"].q
      else
        q=nil
      end
      impostor.bookletz=booklets(pagsEnCuadernillo, impostor.nPaginas, impostor.nPaginasReal, q)
      impostor.nPaginas=impostor.bookletz.length/2  
    end
  end
  #nPaginas multiplo de nX*nY
  if impostor.nX*impostor.nY!=0 and impostor.nPaginas%(impostor.nX*impostor.nY)!=0 then
    impostor.nPaginas=(impostor.nPaginas/(impostor.nX*impostor.nY)+1)*(impostor.nX*impostor.nY)
    mensajes.push(Clases::Mensaje.new(1, "El pdf tiene #{impostor.nPaginasReal} paginas, que impuestas en #{impostor.nX}x#{impostor.nY} son #{impostor.nPaginas} paginas"))
  end
  #TODO ¿ROTAR? si se gasta menos espacio por pliego o en total da menos pliegos
  return Clases::RespuestaImpostor.new(preguntas,mensajes)
end

end