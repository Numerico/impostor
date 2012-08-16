begin

#####TODO
#GEMA
require 'Clases'
require 'Metodos'

#MÉThODOS
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
#
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
#
def exigePar(nX)
  nX=input("nX:")
  nX=nX["numero"]
  if nX%2!=0 then
    exigePar(nX)
  end
  return nX     
end
#
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
#
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
#
def reducirUltimo(cuadernillosPorCostura, paginasSobran, nCuad, sobranMenos)
  puts "al ultimo grupo de #{cuadernillosPorCostura} cuadernillos le sobraran #{paginasSobran}p"
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

########
#CONSOLA
#
entrada=ARGV.shift
$salida=ARGV.shift
#
work="/tmp/impostor"
#
check=Metodos.checks($requerimientos,work,entrada,$salida)
if check.instance_of? Clases::Mensaje then
  puts chek.mensaje
  exit
end
#
puts "::::::::::::impostor::::::::::::"#blink blink
#
w_=input("w:")
h_=input("h:")
wP_=input("W:")
hP_=input("H:")
nX_=input("nX:")
nY_=input("nY:")
nPaginas_=input("nPaginas:")
nPliegos_=input("nPliegos:")
cuadernillos = enBooklets()
#
def recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos, preguntas)
  impostor=Metodos.funcionar(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,preguntas)
  if impostor.preguntasOk then
    if impostor.valido then
      puts "::::::::::::mensajes:::::::::::::"#blink blink
      impostor.mensajes.each do |mensaje|
        puts mensaje.mensaje
      end
    else
      impostor.errores().each do |error|
        puts error.mensaje
      end
      puts "el programa no se ejecutara"
      exit
    end
  else
    if !impostor.preguntas["par"].ok then
      puts impostor.preguntas["par"].mensaje
      impostor.preguntas["par"].metodo(exigePar(nX))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["cXC"].ok then
      puts impostor.preguntas["cXC"].mensaje
      impostor.preguntas["cXC"].metodo(input("cXC:"))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["escaladoH"].ok then
      puts !impostor.preguntas["escaladoH"].mensaje
      impostor.preguntas["escaladoH"].metodo(escalado(impostor.preguntas["escaladoH"].tipo))
      impostor.preguntas["escaladoH"].ok=true
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["escaladoV"].ok then
      puts impostor.preguntas["escaladoV"].mensaje
      impostor.preguntas["escaladoV"].metodo(escalado(impostor.preguntas["escaladoV"].tipo))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["todasPag"].ok then
      puts impostor.preguntas["todasPag"].mensaje
      impostor.preguntas["todasPag"].metodo(todasPag(impostor.preguntas["todasPag"].nPliegos, impostor.preguntas["todasPag"].nX, impostor.preguntas["todasPag"].nY, impostor.preguntas["todasPag"].caben, impostor.preguntas["todasPag"].tiene))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    elsif !impostor.preguntas["reducir"].ok then
      puts impostor.preguntas["reducir"].mensaje
      impostor.preguntas["reducir"].metodo(reducirUltimo(impostor.preguntas["reducir"].cuadernillosPorCostura, impostor.preguntas["reducir"].paginasSobran, impostor.preguntas["reducir"].nCuad, impostor.preguntas["reducir"].sobranMenos))
      recursivo(w_,h_,wP_,hP_,nX,nY,nPaginas,nPliegos,cuadernillos,impostor.preguntas)
    end
  end
end
recursivo(w_,h_,wP_,hP_,nX_,nY_,nPaginas_,nPliegos_,cuadernillos, nil)
#
puts "::::::::::::Game Over::::::::::::"#blink blink
ensure
  #limpio todo, aunque se caiga
  if $dir!=nil then
    `rm -r #{$dir}`
  end
end
#GAME OVER