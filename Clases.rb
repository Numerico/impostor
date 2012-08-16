#Ruby without rails
module 	Clases
  
class Imposicion
  attr_accessor :w, :w_, :wP, :wP_, :nX, :wReal, :h, :h_, :hP, :hP_, :nY, :hReal, :size, :cuadernillos, :nPaginas, :nPliegos, :nPaginasReal, :cuadernillosPorCostura, :bookletz
  def initialize(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos)
    @w_=w _
    @h_=h_
    @wP_=wP_
    @hP_=hP_
    @nX=nX
    @nY=nY
    @nPaginas=nPaginas
    @nPliegos=nPliegos
    @cuadernillos=cuadernillos
    #con unidad
    @w=@w_["numero"].send(@w_["unidad"])
    @h=@h_["numero"].send(@h_["unidad"])
    @wP=@wP_["numero"].send(@wP_["unidad"])
    @hP=@hP_["numero"].send(@hP_["unidad"])
    #sin unidad
    @nX=@nX_["numero"].to_f.floor
    @nY=@nY_["numero"].to_f.floor
    @nPaginas=@nPaginas_["numero"].to_f.floor
    @nPliegos=@nPliegos_["numero"].to_f.floor
  end
  def to_s
    nXm=@nX
    if @cuadernillos then
      nXm*=2
    end
    str="nX:"+nXm.to_s+"\n"
    str+="nY:"+@nY.to_s+"\n"
    str+="nPaginas:"+@nPaginas.to_s+"\n"
    str+="nPliegos:"+@nPliegos.to_s+"\n"
    str+="ancho:"+@w.to_s+" "+@w_["unidad"]+"\n"
    str+="alto:"+@h.to_s+" "+@h_["unidad"]+"\n"
    str+="anchoPliego:"+@wP.to_s+" "+@wP_["unidad"]+"\n"
    str+="altoPliego:"+@hP.to_s+" "+@hP_["unidad"]+"\n"
    return str
  end
end

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

class MensajeTiempo < Mensaje
  def initialize(tipo,tiempo)
    @level=1
    if tipo==1 then#booklets
      @mensaje="::::::::::::booklets:::::::::::::\n"#blink blink
      @mensaje+="booklets: "
    elsif tipo==2 then
      @mensaje="::::::::::::cut&Stack::::::::::::"#blink blink
      @mensaje+="cut&Stack: "
    end  
    @mensaje+=@tiempo.to_s+" segundos"
    @tiempo=tiempo
    super(level,mensaje)
  end
end

class Pregunta
  attr_accessor :ok, :yn
  def initialize(mensaje)
    @mensaje=mensaje
  end
  def metodo()
  end
end

class PreguntaExigePar < Pregunta
  attr_accessor :nX
  def initialize(nX)
    @mensaje="para imponer en cuadernillos tienen que caber horizontalmente en numeros pares pero ud especifico nX:#{@nX}."
    @nX=nX
    @ok=false
  end
end

class PreguntaCXC < Pregunta #TODO COSTURAS en total
  #attr_accessor :cXC
  def initialize()
    @mensaje="cXC - cuadernillos por costura (0->todos unos dentro de otros, 1->todos uno al lado de otro o n-> de a n cuadernillos uno dentro de otro)"
  end
end

class PreguntaEscalado < Pregunta
  attr_accessor :tipo
  def initialize(tipo)
    @mensaje="en duro"
    @tipo=tipo
  end
  def metodo(yn)
    @yn=yn
    @ok=true
  end
end

class PreguntaTodasPag < Pregunta
  attr_accessor :nPliegos, :nX, :nY, :caben, :tiene
  def initialize(nPliegos, nX, nY, caben, tiene)
    @nPliegos=nPliegos
    @nX=nX
    @nY=nY
    @caben=caben
    @tiene=tiene
  end
  def metodo(yn)
    @yn=yn
    @ok=true
  end
end

class PreguntaReducir < Pregunta
  attr_reader :q, :cuadernillosPorCostura, :paginasSobran, :nCuad, :sobranMenos
  def initialize(cuadernillosPorCostura, paginasSobran, nCuad, sobranMenos, q)
    @mensaje="en duro"
    @cuadernillosPorCostura=cuadernillosPorCostura
    @paginasSobran=paginasSobran
    @nCuad=nCuad
    @sobranMenos=sobranMenos
    @q=q
    super(@mensaje)
  end
  def metodo(yn)
    @yn=yn
    @ok=true
  end
end

class RespuestaImpostor
  def initialize(preguntas,mensajes)
    @preguntas=preguntas
    @mensajes=mensajes
  end
  def preguntasOk()
    todoOk=true
    @preguntas.each do |k,v|
      if v!=nil and !v.ok then
        todoOk=false
      end
    end
    return todoOk
  end
  def errores()
    errores=[]
    @mensajes.each do |mensaje|
      if mensaje.level==3 then
        errores.push(mensaje)
      end
    end
    return errores
  end
  def valido()
    return errores().size==0
  end
end

end#fin módulo

