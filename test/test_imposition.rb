#
require 'test/unit'
require 'imposition'
require 'pry'
#
$entrada=File.dirname(__FILE__)+"/assets/test.pdf"
$salida="/home/roberto/test.pdf"

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
    if esperados.size<mensajes.size then
      return Resultado.new(false,"hay mas mensajes que los que se espera")
    end
    esperados.each do |esperado|     
        return Resultado.new(false,"falta mensaje n°"+esperado.id.to_s) if !mensajes.include?(esperado)
    end
    if esperados.count{|e| mensajes.include?(e)}!=esperados.size then
      return Resultado.new(false,"hay mas iguales que los que se espera")
    end
    return Resultado.new(true,nil)
  end
  #
  #TODO DRY!
  def nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,preguntas,respuestas)
    #dummies por el clasico bug de alchemist que pasa referencias...
    w_Dummy=w_.clone
    h_Dummy=h_.clone
    wP_Dummy=wP_.clone
    hP_Dummy=hP_.clone
    impostor=Metodos.funcionar(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,preguntas,$temp,nil)
    if impostor.preguntasOk then
      if impostor.valido then
        return siySoloSi(impostor.mensajes,esperados)
      else
        return Resultado.new(false,"hay un error")
      end
    else
      if respuestas.size==0 then
        return Resultado.new(false,"no se esperan preguntas")
      else
        impostor.preguntas.each do |pregunta|
          respuestas.each do |respuesta|
            if pregunta[1]==respuesta[0] then#[1] porque preguntas tiene un hash ["escaladoH", PreguntaEscalado], por ej.
              pregunta[1].metodo(respuesta[1])
            end
          end
        end
        nUp(w_Dummy,h_Dummy,wP_Dummy,hP_Dummy,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,impostor.preguntas,respuestas)
      end
    end
  end
  
  #general
  def test_check()
    Metodos.refresh()
    #
    check=Metodos.checksRun($entrada,$salida)
    if check.instance_of? Clases::Mensaje then
      msg=check.mensaje
    end
    assert((check.instance_of? Clases::Mensaje)!=true, msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #nUp
  def test_nUp
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(0,"point")
    nX=Metodos.nuevo(3,nil)
    nY=Metodos.nuevo(3,nil)
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
    esperados.push(Clases::Mensaje.new(8))#MensajeVars
    esperados.push(Clases::Mensaje.new(9))#MensajeTiempo
    esperados.push(Clases::Mensaje.new(10))#MensajeMultiplo
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,nil)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #nUp con unidades
  def test_nUpUnidad
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(279,"mm")
    hP_=Metodos.nuevo(216,"mm")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=false
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(11))#1, "vertical", 3
    esperados.push(Clases::Mensaje.new(12))#1, "horizontal", 3
    esperados.push(Clases::Mensaje.new(5))#1, "paginas", 3
    esperados.push(Clases::Mensaje.new(7))#MensajeLadoLado
    esperados.push(Clases::Mensaje.new(6))#1, "paginas", 2
    esperados.push(Clases::Mensaje.new(8))#MensajeVars
    esperados.push(Clases::Mensaje.new(9))#MensajeTiempo
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaEscalado.new("horizontalmente"),true])#id:1
    respuestas.push([Clases::PreguntaEscalado.new("verticalmente"),true])#id:2
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
    
  #solo escala horizontalmente
  def test_cruzado
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(279,"mm")
    hP_=Metodos.nuevo(216,"mm")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=false
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(3))#alto real
    esperados.push(Clases::Mensaje.new(12))#w calculado
    esperados.push(Clases::Mensaje.new(15))#sobra w* de alto
    esperados.push(Clases::Mensaje.new(5))#todas pdf
    esperados.push(Clases::Mensaje.new(7))#no impares
    esperados.push(Clases::Mensaje.new(6))#pliegos
    esperados.push(Clases::Mensaje.new(8))#MensajeVars
    esperados.push(Clases::Mensaje.new(9))#tiempo cut&Stack
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaEscalado.new("horizontalmente"),true])#id:1
    respuestas.push([Clases::PreguntaEscalado.new("verticalmente"),false])#id:2
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #solo escala horizontalmente, pero tiene que deducirlo
  def test_cruzado_datos
    Metodos.refresh()
    #point
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(216,"mm")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=false
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(1))#h real
    esperados.push(Clases::Mensaje.new(2))#wP calculado
    esperados.push(Clases::Mensaje.new(11))#h calculado
    esperados.push(Clases::Mensaje.new(5))#todas pdf
    esperados.push(Clases::Mensaje.new(7))#no impares
    esperados.push(Clases::Mensaje.new(6))#pliegos
    esperados.push(Clases::Mensaje.new(8))#MensajeVars
    esperados.push(Clases::Mensaje.new(9))#tiempo cut&Stack
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaEscalado.new("verticalmente"),true])#id:2
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #BOOKLETS
  
  #foldable, one inside an other
  def test_nUpBooklets
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(0,"point")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=true
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(13))#PreguntacXC
    esperados.push(Clases::Mensaje.new(1))
    esperados.push(Clases::Mensaje.new(2))
    esperados.push(Clases::Mensaje.new(3))
    esperados.push(Clases::Mensaje.new(4))
    esperados.push(Clases::Mensaje.new(5))
    esperados.push(Clases::Mensaje.new(7))
    esperados.push(Clases::Mensaje.new(6))
    esperados.push(Clases::Mensaje.new(8))
    esperados.push(Clases::Mensaje.new(9))
    esperados.push(Clases::Mensaje.new(14))#MensajeTiempo Booklets
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaCXC.new(),Metodos.nuevo(0,nil)])
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #foldable
  def test_nUpBooklets_side_by_side
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(0,"point")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=true
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(13))#PreguntacXC
    esperados.push(Clases::Mensaje.new(1))
    esperados.push(Clases::Mensaje.new(2))
    esperados.push(Clases::Mensaje.new(3))
    esperados.push(Clases::Mensaje.new(4))
    esperados.push(Clases::Mensaje.new(5))
    esperados.push(Clases::Mensaje.new(7))
    esperados.push(Clases::Mensaje.new(6))
    esperados.push(Clases::Mensaje.new(8))
    esperados.push(Clases::Mensaje.new(9))
    esperados.push(Clases::Mensaje.new(14))#MensajeTiempo Booklets
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaCXC.new(),Metodos.nuevo(1,nil)])
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #foldable, in groups of booklets
  def test_nUpBooklets_groups
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(0,"point")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(1,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=true
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(13))#PreguntacXC
    esperados.push(Clases::Mensaje.new(1))
    esperados.push(Clases::Mensaje.new(2))
    esperados.push(Clases::Mensaje.new(3))
    esperados.push(Clases::Mensaje.new(4))
    esperados.push(Clases::Mensaje.new(5))
    esperados.push(Clases::Mensaje.new(7))
    esperados.push(Clases::Mensaje.new(6))
    esperados.push(Clases::Mensaje.new(8))
    esperados.push(Clases::Mensaje.new(9))
    esperados.push(Clases::Mensaje.new(14))#MensajeTiempo Booklets
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaCXC.new(),Metodos.nuevo(2,nil)])
    respuestas.push([Clases::Pregunta.new(5),false])#PreguntaReducir
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  #foldable, in groups of booklets
  def test_nUpBooklets_groups_2x2
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(0,"point")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(2,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=true
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(13))#PreguntacXC
    esperados.push(Clases::Mensaje.new(1))
    esperados.push(Clases::Mensaje.new(2))
    esperados.push(Clases::Mensaje.new(3))
    esperados.push(Clases::Mensaje.new(4))
    esperados.push(Clases::Mensaje.new(5))
    esperados.push(Clases::Mensaje.new(7))
    esperados.push(Clases::Mensaje.new(6))
    esperados.push(Clases::Mensaje.new(8))
    esperados.push(Clases::Mensaje.new(9))
    esperados.push(Clases::Mensaje.new(14))#MensajeTiempo Booklets
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaCXC.new(),Metodos.nuevo(2,nil)])
    respuestas.push([Clases::Pregunta.new(5),false])#PreguntaReducir
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end
  
  def test_nUpBooklets_groups_10
    Metodos.refresh()
    #
    w_=Metodos.nuevo(0,"point")
    h_=Metodos.nuevo(0,"point")
    wP_=Metodos.nuevo(0,"point")
    hP_=Metodos.nuevo(0,"point")
    nX=Metodos.nuevo(2,nil)
    nY=Metodos.nuevo(2,nil)
    nPaginas=""
    nPliegos=""
    cuadernillos=true
    #
    esperados=[]
    esperados.push(Clases::Mensaje.new(13))#PreguntacXC
    esperados.push(Clases::Mensaje.new(1))
    esperados.push(Clases::Mensaje.new(2))
    esperados.push(Clases::Mensaje.new(3))
    esperados.push(Clases::Mensaje.new(4))
    esperados.push(Clases::Mensaje.new(5))
    esperados.push(Clases::Mensaje.new(7))
    esperados.push(Clases::Mensaje.new(6))
    esperados.push(Clases::Mensaje.new(8))
    esperados.push(Clases::Mensaje.new(9))
    esperados.push(Clases::Mensaje.new(14))#MensajeTiempo Booklets
    #
    respuestas=[]
    respuestas.push([Clases::PreguntaCXC.new(),Metodos.nuevo(10,nil)])
    respuestas.push([Clases::Pregunta.new(5),false])#PreguntaReducir
    #
    resultado=nUp(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,esperados,nil,respuestas)
    assert(resultado.yn,resultado.msg)
  ensure
    #limpio todo, aunque se caiga
    if File.dirname($temp)!=nil then
      `rm -r #{File.dirname($temp)}`
    end
  end

end
