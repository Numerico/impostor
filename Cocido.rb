module Cocido

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
def booklets(cuadernillosPorCostura, paginas)
	paginasReal=paginas
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
		#sugerencia
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

end
