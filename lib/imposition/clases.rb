#!/bin/env ruby
# encoding: utf-8

module 	Clases
  
class Imposicion
  attr_accessor :w, :w_, :wP, :wP_, :nX, :wReal, :h, :h_, :hP, :hP_, :nY, :hReal, :size, :cuadernillos, :nPaginas, :nPliegos, :nPaginasReal, :cuadernillosPorCostura, :bookletz
  def initialize(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos)
    @w_=w_
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
    @nX=@nX["numero"].to_f.floor
    @nY=@nY["numero"].to_f.floor
    @nPaginas=@nPaginas["numero"].to_f.floor
    @nPliegos=@nPliegos["numero"].to_f.floor
  end
  def to_s
    nXm=@nX
    if @cuadernillos then
      nXm*=2
    end
    str=I18n.t(:params)+"\n"
    str+="nX:"+nXm.to_s+"\n"
    str+="nY:"+@nY.to_s+"\n"
    str+=I18n.t(:nPages)+":"+@nPaginas.to_s+"\n"
    str+=I18n.t(:nSheets)+":"+@nPliegos.to_s+"\n"
    str+=I18n.t(:pwidth)+":"+@w.to_s+" "+@w_["unidad"]+"\n"
    str+=I18n.t(:pheight)+":"+@h.to_s+" "+@h_["unidad"]+"\n"
    str+=I18n.t(:swidth)+":"+@wP.to_s+" "+@wP_["unidad"]+"\n"
    str+=I18n.t(:sheight)+":"+@hP.to_s+" "+@hP_["unidad"]+"\n"
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
#
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
#
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
	attr_reader :id, :level, :mensaje
	def initialize(*args)
	  if args.size==1 then
	   @id=args[0]
	  elsif args.size==2 then
	    @level=args[0] #level 1=info, 2=warn, 3=error
      @mensaje=args[1]
	  end
	end
	def to_s
		if @level==1 then
			@retorno=I18n.t(:info)+": "
		elsif @level==2 then
			@retorno=I18n.t(:warn)+": "
		elsif @level==3 then
			@retorno=I18n(:error)+": "
		end
		@retorno+=@mensaje.to_s
		return @retorno
	end
	def ==(msg)
	  if msg!=nil then
	   return @id==msg.id
	  else
	   return false
	  end
	end 
end
#
class MensajeDato < Mensaje
	attr_reader :tipo, :numero
	def initialize(level,tipo,numero)
      @level=level
      @tipo=tipo
      @numero=numero
      dd=deducirMensaje(tipo,level,numero)
      @id=dd[0]
      @mensaje=dd[1]
      super(level, @mensaje)
  end
	def deducirMensaje(tipo, level, numero)
		if tipo=="horizontal" then
			if level==1 then#info
				if numero==1 then
					return [15,I18n.t(:nXCalc)]
				elsif numero==2 then
					return [2,I18n.t(:wPCalc)]
				elsif numero==3 then
					return [12,I18n.t(:wCalc)]
				elsif numero==4 then
					return [1,I18n.t(:wRoyal)]
				end
			elsif level==3 then#error
				if numero==1 then
					return [13,I18n.t(:wOnly)]
				elsif numero==2 then
					return [16,I18n.t(:wPOnly)]
				elsif numero==3 then
					return [17,I18n.t(:nXOnly)]
				elsif numero==4 then
					return [18,I18n.t(:nothingH)]
				elsif numero==5 then
					return [19,I18n.t(:noPageH)]
				end
			end
		elsif tipo=="vertical" then
			if level==1 then#info
				if numero==1 then
					return [20,I18n.t(:nYCalc)]
				elsif numero==2 then
					return [4,I18n.t(:hPCalc)]
				elsif numero==3 then
					return [11,I18n.t(:hCalc)]
				elsif numero==4 then
					return [3,I18n.t(:hRoyal)]
				end
			elsif level==3 then#error
				if numero==1 then
					return [14,I18n.t(:hOnly)]
				elsif numero==2 then
					return [21,I18n.t(:hPOnly)]
				elsif numero==3 then
					return [22,I18n.t(:nYOnly)]
				elsif numero==4 then
					return [23,I18n.t(:nothingV)]
				elsif numero==5 then
					return [24,I18n.t(:noPageV)]
				end
			end
		elsif tipo=="paginas" then
			if level==1 then
				if numero==1 then
					return [25,I18n.t(:nPageCalc)]
				elsif numero==2 then
					return [6,I18n.t(:nSheetCalc)]
				elsif numero==3 then
					return [5,I18n.t(:nPagePdf)]
				end
			elsif level==3 then
				if numero==1 then
					return [26,I18n.t(:nPageXL)]
				else
					return [27,I18n.t(:noPages)]
				end
			end
		elsif tipo=="pliegos" then
			if level==1 then
				return [28,I18n.t(:allSheet, :n=>numero)]
			elsif level==2 then
				return [29,I18n.t(:sheetXL, :n=>numero)]
			elsif level==3 then
				return [30,I18n.t(:sheetXS, :n=>numero)]	
			end
		end
	
	end
end
#
class MensajeMedida < Mensaje
	def initialize(level, tipo, args)
		@mensaje=deducirMensaje(level, tipo, args)
		super(level, @mensaje)
	end
	def deducirMensaje(level, tipo, args)
		if tipo=="horizontal" then
			if level==3 then
			  
				return I18n.t(:nXwwPno, :nX=>args[0], :w=>args[1]["numero"].to_s+args[1]["unidad"], :wP=>args[2]["numero"].to_s+args[2]["unidad"])
			elsif level==2 then
				return I18n.t(:wPXL, :n=>args[0].to_s+args[1])
			end
		elsif tipo=="vertical" then
			if level==3 then
				return I18n.t(:nYhhPno, :nY=>args[0], :h=>args[1]["numero"].to_s+args[1]["unidad"], :hP=>args[2]["numero"].to_s+args[2]["unidad"])
			elsif level==2 then
			  @id=15
				return I18n.t(:hPXL, :n=>args[0].to_s+args[1])
			end
		end
	end
end
#
class MensajeTiempo < Mensaje
  attr_reader :tipo
  def initialize(tipo,tiempo)
    @tiempo=tiempo
    @level=1
    if tipo==1 then#booklets
      @id=14#fijo
      @mensaje=I18n.t(:bookltsblink)#blink blink
      @mensaje+=I18n.t(:bookltsxplain)
    elsif tipo==2 then
      @id=9#fijo
      @mensaje=I18n.t(:nUpblink)#blink blink
      @mensaje+=I18n.t(:nUpxplain)
    end  
    @mensaje+=@tiempo.to_s+" "+I18n.t(:s)
    super(level,mensaje)
  end
end
#
class MensajeLadoLado < Mensaje
  attr_reader :nP
  def initialize(nP)
    @id=7#fijo
    @nP=nP
    @mensaje=I18n.t(:sheetPair, :n=>@nP)
    super(1,@mensaje)
  end
end
#
class MensajeVars < Mensaje
  def initialize(*args)
    if args.size==0 then
     super(8)#clasico
    elsif args.size==2 then
      @id=8
      super(args[0],args[1])
    end
  end
end
#
class MensajeMultiplo < Mensaje
  def initialize(level, mensaje)
    @id=10
    super(level,mensaje)
  end
end
#TODO DRY!
class MensajeBooklets < Mensaje
  def initialize(level,mensaje)
    @id=13
    super(level,mensaje)
  end
end

class Pregunta
  attr_accessor :ok, :yn, :mensaje
  attr_reader :ide
  def initialize(arg)
    if arg.instance_of? String then
      @mensaje=arg
    else
      @ide=arg
    end
  end
  def metodo()
  end
  def ==(question)
    if question==nil then
      return false
    end
    return @ide==question.ide
  end
end
#
#TODO sugerencia si + o -
class PreguntaExigePar < Pregunta
  attr_accessor :nX
  def initialize(nX)
    @nX=nX
    @mensaje=I18n.t(:nXPair, :nX=>@nX)
    @ok=false
  end
  def metodo(nX)
    @nX=nX.to_i
    @ok=true
  end
end
#
#TODO COSTURAS en total
class PreguntaCXC < Pregunta 
  attr_reader :cXC
  def initialize()
    @ide=4
    @mensaje=I18n.t(:cXC)
  end
  def metodo(cXC)
    @cXC=cXC["numero"].to_i
    @ok=true
  end
end
#
class PreguntaEscalado < Pregunta
  attr_accessor :tipo
  def initialize(tipo)    
    @tipo=tipo
    if @tipo=="horizontalmente" then
      @ide=1
      @mensaje=I18n.t(:WnX)+" "+I18n.t(tipo) 
    elsif @tipo=="verticalmente" then
      @ide=2
      @mensaje=I18n.t(:HnY)+" "+I18n.t(tipo)
    end
    @mensaje+=I18n.t(:scale, :tp=>I18n.t(tipo))
  end
  def metodo(yn)
    @yn=yn
    @ok=true
  end
end
#
class PreguntaTodasPag < Pregunta
  attr_accessor :nPliegos, :nX, :nY, :caben, :tiene
  def initialize(nPliegos, nX, nY, caben, tiene)
    @ide=3
    @mensaje=I18n.t(:allPdfq, :p=>tiene.to_i, :s=>nPliegos.to_i, :nX=>nX, :nY=>nY, :c=>caben.to_i)
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
#when imposing in booklets & last group of them can be reduced to minimize blank pages
class PreguntaReducir < Pregunta
  attr_reader :q, :cuadernillosPorCostura, :paginasSobran, :nCuad, :sobranMenos
  def initialize(cuadernillosPorCostura, paginasSobran, nCuad, sobranMenos, q)
    @ide=5
    @mensaje=I18n.t(:reduceq, :cXC=>cuadernillosPorCostura, :extra=>paginasSobran, :n=>nCuad, :less=>sobranMenos)
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
  attr_accessor :mensajes, :preguntas
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

end#fin modulo