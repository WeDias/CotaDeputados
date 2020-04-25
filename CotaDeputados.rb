# ------------------------------------------------------------- #
#                                        CotaDeputados          #
#                                       Github:@WeDias          #
#                                    Licença: MIT License       #
#                                Copyright © 2020 Wesley Dias   #
# ------------------------------------------------------------- #

require "json"

ano = 2008
while ano <= 2019
  arquivo = File.read("Dados/Ano-#{ano}.json")
  dados = JSON.parse(arquivo)
  dados = dados["dados"]

  total = 0
  parlamentares = {}
  gasto_partidos = {}
  for dado in dados
    id = dado["numeroDeputadoID"]
    nome = dado["nomeParlamentar"]
    gasto = dado["valorLiquido"].to_f
    partido = dado["siglaPartido"]

    if partido.empty?
      partido = nome
    end

    if not gasto_partidos.include?(partido)
      gasto_partidos[partido] = gasto
    else
      gasto_anterior = gasto_partidos[partido].to_f
      gasto_partidos[partido] = gasto + gasto_anterior
    end

    if nome != partido
      if not parlamentares.include?(nome)
        parlamentares[nome] = {id: id, partido: partido, nome: nome,gasto: gasto}
      else
        gasto_anterior = parlamentares[nome][:gasto].to_f
        parlamentares[nome][:gasto] = gasto_anterior + gasto
      end
    end
    total += gasto
  end
  arquivo.close
  puts "-" * 100
  puts "TOTAL GASTO EM #{ano}: R$ #{"%.2f" % total}"
  puts "\nGASTOS POR POLITICO:"
  parlamentares = parlamentares.sort_by{|chave, valor| valor[:gasto]}

  cont = 1
  for parlamentar, dados in parlamentares.reverse
    id = dados[:id]
    nome = dados[:nome]
    gasto = dados[:gasto]
    porc = 100 * gasto / total
    partido = dados[:partido]
    puts "#{cont}-#{id}-#{partido}-#{nome}: R$ #{"%.2f" % gasto} #{"%.5f" %porc}%"
    cont += 1
  end

  cont = 1
  puts "\nGASTOS POR PARTIDO POLITICO:"
  gasto_partidos = gasto_partidos.sort_by{|partido, valor| valor}
  for partido, valor in gasto_partidos.reverse
    porc = 100 * valor / total
    puts "#{cont}-#{partido}: R$ #{"%.2f" % valor} #{"%.5f" % porc}%"
    cont += 1
  end
  ano += 1
end
