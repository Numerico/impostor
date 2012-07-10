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

#MODELO
class Mensaje
	attr_reader :level, :mensaje
	def initialize(level, mensaje)
		@level=level #1=info, 2=warn, 3=error
		@mensaje=mensaje
	end
	def to_s
		if @level==1 then
			@retorno="info: "
		elsif @level==2 then
			@retorno="warn: "
		elsif @level==3 then
			@retorno="ERROR: "
		end
		@retorno+=@mensaje
		return @retorno
	end 
end
class MensajeDato < Mensaje
	attr_reader :tipo, :numero
	def initialize(level, tipo, numero)
		@tipo=tipo
		@numero=numero
		@mensaje=deducirMensaje(tipo,level,numero)
		super(level, @mensaje)
	end

	def deducirMensaje(tipo, level, numero)
		if tipo=="horizontal" then
			if level==1 then#info
				if numero==1 then
					return "se calcula la cantidad de paginas por pliego horizontalmente en base al ancho del pliego y el de la pagina"
				elsif numero==2 then
					return "se calcula el ancho del pliego en base al de la pagina y la cantidad de paginas por pliego horizontalmente"
				elsif numero==3 then
					return "se calcula el ancho de la pagina en base al del pliego y la cantidad de paginas por pliego horizontalmente"
				elsif numero==4 then
					return "se toma el ancho real de la pagina"
				end
			elsif level==3 then#error
				if numero==1 then
					return "ha especificado ancho de pagina pero no de pliego ni cuantas paginas por pliego horizontalmente"
				elsif numero==2 then
					return "ha especificado ancho de pliego pero no de pagina ni cuantas paginas por pliego horizontalmente"
				elsif numero==3 then
					return "ha especificado cuantas paginas por pliego horizontalmente pero no ancho de pagina ni de pliego"
				elsif numero==4 then
					return "no ha especificado ni ancho de pagina, ni ancho de pliego, ni cuantos paginas por pliego horizontalmente"
				elsif numero==5 then
					return "no cabe ninguna pagina horizontalmente"
				end
			end
		elsif tipo=="vertical" then
			if level==1 then#info
				if numero==1 then
					return "se calcula la cantidad de paginas por pliego verticalmente en base al alto del pliego y el de la pagina"
				elsif numero==2 then
					return "se calcula el alto del pliego en base al de la pagina y la cantidad de paginas por pliego verticalmente"
				elsif numero==3 then
					return "se calcula el alto de la pagina en base al del pliego y la cantidad de paginas por pliego verticalmente"
				elsif numero==4 then
					return "se toma el alto real de la pagina"
				end
			elsif level==3 then#error
				if numero==1 then
					return "ha especificado alto de pagina pero no de pliego ni cuantas paginas por pliego verticalmente"
				elsif numero==2 then
					return "ha especificado alto de pliego pero no de pagina ni cuantas paginas por pliego verticalmente"
				elsif numero==3 then
					return "ha especificado cuantas paginas por pliego verticalmente pero no alto de pagina ni de pliego"
				elsif numero==4 then
					return "no ha especificado ni alto de pagina, ni alto de pliego, ni cuantos paginas por pliego verticalmente"
				elsif numero==5 then
					return "no cabe ninguna pagina verticalmente"
				end
			end
		elsif tipo=="paginas" then
			if level==1 then
				if numero==1 then
					return "se calcula el numero de paginas a partir del numero de pliegos y de la cantidad de paginas por pliego"
				elsif numero==2 then
					return "se calcula el numero de pliegos a partir del numero de paginas y de la cantidad de paginas por pliego"
				elsif numero==3 then
					return "se usan todas las paginas del pdf"
				end
			elsif level==3 then
				if numero==1 then
					return "esta especificando mas paginas de las que tiene el documento"
				else
					return "no ha especificado numero de paginas ni de pliegos"
				end
			end
		elsif tipo=="pliegos" then
			if level==1 then
				return "se toman los #{numero} pliegos necesarios"
			elsif level==2 then
				return "sobran #{numero} pliegos"
			elsif level==3 then
				return "faltan #{numero} pliegos"	
			end
		end
	
	end
end
class MensajeMedida < Mensaje
	def initialize(level, tipo, args)
		@mensaje=deducirMensaje(level, tipo, args)
		super(level, @mensaje)
	end
	def deducirMensaje(level, tipo, args)
		if tipo=="horizontal" then
			if level==3 then
				return "no caben #{args[0]} paginas de #{args[1]["numero"].to_s+args[1]["unidad"]} de ancho en un pliego de #{args[2]["numero"].to_s+args[2]["unidad"]}"
			elsif level==2 then
				return "sobra #{args[0].to_s+args[1]} de ancho"
			end
		elsif tipo=="vertical" then
			if level==3 then
				return "no caben #{args[0]} paginas de #{args[1]["numero"].to_s+args[1]["unidad"]} de alto en un pliego de #{args[2]["numero"].to_s+args[2]["unidad"]}"
			elsif level==2 then
				return "sobra #{args[0].to_s+args[1]} de alto"
			end
		end
	end
end
end#fin módulo

