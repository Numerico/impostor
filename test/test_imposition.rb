#
require 'test/unit'
require 'imposition'
#
$entrada=File.dirname(__FILE__)+"/assets/test.pdf"
$salida=$dir+"/test.pdf"

#TODO YAML

class Resultado
  attr_reader :yn, :msg
  def initialize(yn,msg)
    @yn=yn
    @msg=msg
  end
end

class TestImpostor < Test::Unit::TestCase
  #funcionales
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
        return Resultado.new(false,"falta mensaje n°"+esperado.id.to_s)
      end
    end
    if n!=esperados.size then
      return Resultado.new(false,"hay mas iguales que los que se espera")
    end
    return Resultado.new(true,nil)
  end
  #
  def nuevo(valor,unidad)
    retorno=Hash.new
    retorno["numero"]=valor
    retorno["unidad"]=unidad
    return retorno
  end
  #
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
  
  #general
  def test_check()
    check=Metodos.checksRun($entrada,$salida)
    if check.instance_of? Clases::Mensaje then
      msg=check.mensaje
    end
    assert((check.instance_of? Clases::Mensaje)!=true, msg)
  end
  
  #nUp
  def test_nUp
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
    esperados=[]                          #MensajeDatos
    esperados.push(Clases::Mensaje.new(1))#1, "horizontal", 4
    esperados.push(Clases::Mensaje.new(2))#1, "horizontal", 2
    esperados.push(Clases::Mensaje.new(3))#1, "vertical", 4
    esperados.push(Clases::Mensaje.new(4))#1, "vertical", 2
    esperados.push(Clases::Mensaje.new(5))#1, "paginas", 3
    esperados.push(Clases::Mensaje.new(6))#1, "paginas", 2
    #esperados.push(Clases::Mensaje.new(7))#MensajeLadoLado
    esperados.push(Clases::Mensaje.new(8))#MensajeVars
    esperados.push(Clases::Mensaje.new(9))#MensajeTiempo
    esperados.push(Clases::Mensaje.new(10))#MensajeMultiplo
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados)
    assert(resultado.yn,resultado.msg)
  end
  
  #nUp con unidades
  def test_nUpUnidad
    w_=nuevo(0.point,"point")
    h_=nuevo(0.point,"point")
    wP_=nuevo(279.mm,"mm")
    hP_=nuevo(216.mm,"mm")
    nX=nuevo(2,nil)
    nY=nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=false
    #
    esperados=[]
    pregunta1=Clases::PreguntaEscalado.new("horizontalmente")
    pregunta1.metodo(true)
    esperados.push(pregunta1)
    pregunta2=Clases::PreguntaEscalado.new("verticalmente")
    pregunta2.metodo(true)
    esperados.push(pregunta2)
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados)
    assert(resultado.yn,resultado.msg)
  end
  
end
