#
require 'test/unit'
require 'imposition'

#con qué archivos correr la prueba sí se recibe TODO
$entrada="/home/roberto/Documentos/e-dit/rails/active_record_querying_archivos/latex/active_record_queryingCuarto.pdf"
$salida="/home/roberto/Documentos/test.pdf"
#
$work="/tmp/impostor"#TODO éste no debiera estar

class Resultado
  attr_reader :yn, :msg
  def initialize(yn,msg)
    @yn=yn
    @msg=msg
  end
end

class TestImpostor < Test::Unit::TestCase
  def test_check()
    check=Metodos.checksRun($entrada,$salida)
    if check.instance_of? Clases::Mensaje then
      msg=check.mensaje
    end
    assert((check.instance_of? Clases::Mensaje)!=true, msg)
  end
  
  def test_nUp
    #TODO YAML
    w_=nuevo(0.point,"point")
    h_=nuevo(0.point,"point")
    wP_=nuevo(0.point,"point")
    hP_=nuevo(0.point,"point")
    nX=nuevo(3,nil)
    nY=nuevo(3,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=false
    #
    esperados=[]
    esperados.push(Clases::MensajeDato.new(1, "horizontal", 4))
    esperados.push(Clases::MensajeDato.new(1, "horizontal", 2))
    esperados.push(Clases::MensajeDato.new(1, "vertical", 4))
    esperados.push(Clases::MensajeDato.new(1, "vertical", 2))
    esperados.push(Clases::MensajeDato.new(1, "paginas", 3))
    esperados.push(Clases::MensajeDato.new(1, "paginas", 2))
    #esperados.push(Clases::Mensaje.new(1, "El pdf tiene 30 paginas, que impuestas en 3x3 son 36 paginas"))#TODO
    esperados.push(Clases::MensajeLadoLado.new(5))
    esperados.push(Clases::Mensaje.new(1,":::::::::::::::vars:::::::::::::: nX:3 nY:3 nPaginas:54 nPliegos:6 ancho:306.142 point alto:395.433 point anchoPliego:918.426 point altoPliego:1186.299 point"))
    esperados.push(Clases::MensajeTiempo.new(2,nil))
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados)
    assert(resultado.yn,resultado.msg)
  end
  #
  def nuevo(valor,unidad)
    retorno=Hash.new
    retorno["numero"]=valor
    retorno["unidad"]=unidad
    return retorno
  end
  #
  def nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados)
    impostor=Metodos.funcionar(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,nil)
    if impostor.preguntasOk then
      if impostor.valido then
        return siySoloSi(impostor.mensajes,esperados)
      else
        return Resultado.new(false,"hay un error")
      end
    else
      return Resultado.new(false,"no se esperan preguntas")
    end
  end
  def siySoloSi(mensajes, esperados)
    if esperados.size!=mensajes.size then
      return Resultado.new(false,"hay mas mensajes que los que se espera")
    end
    n=0
    esperados.each do |esperado|
      esta=false
      mensajes.each do |mensaje|
        #mensajes.count(esperado)==1
        if mensaje==esperado then
          esta=true
          n+=1
        end
      end
      if !esta then
        return Resultado.new(false,"falta mensaje:"+esperado.mensaje)
      end
    end
    if n!=esperados.size then
      return Resultado.new(false,"hay mas iguales que los que se espera")
    end
    return Resultado.new(true,nil)
  end
end
