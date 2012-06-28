#Ruby without rails
module 	Impostor

class Posicion
	def initialize(mC,mP,t)
		@mC=mC
		@mP=mP
		@t=t	
	end
	attr_reader :mC, :mP, :t
	def to_s
		"mC=#{@mC} mP=#{@mP} t=#{@t}"
	end
end

class Coordenada
	def initialize(x,y)
		@x=x
		@y=y
	end
	attr_reader :x, :y
	def to_s
		"x=#{@x} y=#{@y}"
	end
end

class Mix
	def initialize(n,x,y,t)
		@n=n
		@x=x
		@y=y
		@t=t
	end
	attr_reader :n, :x, :y, :t
	def to_s
		"n=#{@n}, x=#{@x}, y=#{@y}, t=#{@t}"
	end
end

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

#podria eliminar w y h haciendo la comparacion en base a n y k?
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

end#fin módulo

