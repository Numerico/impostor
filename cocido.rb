#multiplo de 4
def mult4(paginasEnPliego)
	paginas=paginasEnPliego
	if paginasEnPliego%4 != 0 then
		paginas=((paginasEnPliego/4)+1)*4
		puts "se necesitaran #{paginas}p para imponer #{paginasEnPliego}p en #{paginas/4} cuadernillos plegables" #TODO mensaje
	else
		paginas=paginasEnPliego
	end
	return paginas
end

#crea un cuadernillo
def unaDentroDeOtra(paginasReal, paginasEnCuadernillo, inicio, fin)
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

		booklet=unaDentroDeOtra(paginasReal, pagsEnCuadernillo, inicio, fin)
		arreglo.concat(booklet)
	end
	return arreglo
end

#require 'Impostura'
#input("test") TODO
def input(nombre)
	retorno=Hash.new
	STDOUT.puts(nombre)
	input=STDIN.gets
	if input[0]==10 then #no input
		retorno["numero"]=0
		return retorno		
	end
	regex = /(\d+)\s*(\w*)/
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
cuadernillosPorCostura=input("cXC:")
cuadernillosPorCostura=cuadernillosPorCostura["numero"]

pags=24#ya lo debo tener

test=booklets(cuadernillosPorCostura, pags)
puts test.join(",")
puts test.length
