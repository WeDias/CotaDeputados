# ------------------------------------------------------------- #
#                                        CotaDeputados          #
#                                       Github:@WeDias          #
#                                    Licença: MIT License       #
#                                Copyright © 2020 Wesley Dias   #
# ------------------------------------------------------------- #

require "json"
require "csv"

def salvar_dados(nome, texto="")
  """
  salvar_dados() Serve para salvar os dados coletados em um arquivo csv
  :param nome: str, nome do arquivo
  :param texto: str, texto que sera escrito
  :return: None
  """
  File.write("Dados/#{nome}.csv", "#{texto}\n", mode: "a:UTF-8")
end

for arquivo in [["TotalGastoAno", "Ano;TotalGasto"],
                ["TopGastoPolitico", "Posicao;Nome;Gasto;PorcTotal;Ano"],
                ["TopGastoPartido", "Posicao;Partido;Gasto;PorcTotal;Ano"],
                ["GastoPolitico", "Posicao;Id;Partido;Nome;Gasto;PorcTotal;Ano"],
                ["GastoPartido", "Posicao;Partido;Gasto;PorcTotal;Ano"]]
  File.write("Dados/#{arquivo[0]}.csv", "#{arquivo[1]}\n", mode: "w:UTF-8")
end

ano = 2008
while ano <= 2019
  arquivo = File.read("Dados/Ano-#{ano}.json")
  dados = JSON.parse(arquivo)
  dados = dados["dados"]

  total = 0
  parlamentares = {}
  gasto_partidos = {}
  puts "analisando #{ano}..."
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
  salvar_dados("TotalGastoAno", "#{ano};#{total}")
  parlamentares = parlamentares.sort_by{|chave, valor| valor[:gasto]}

  cont = 1
  for parlamentar, dados in parlamentares.reverse
    id = dados[:id]
    nome = dados[:nome]
    gasto = dados[:gasto]
    porc = 100 * gasto / total
    partido = dados[:partido]
    if cont <= 5
      salvar_dados("TopGastoPolitico", "#{cont};#{id};#{partido};#{nome};#{"%.2f" % gasto};#{"%.5f" %porc};#{ano}")
    end
    salvar_dados("GastoPolitico","#{cont};#{id};#{partido};#{nome};#{"%.2f" % gasto};#{"%.5f" %porc};#{ano}")
    cont += 1
  end

  cont = 1
  gasto_partidos = gasto_partidos.sort_by{|partido, valor| valor}
  for partido, valor in gasto_partidos.reverse
    porc = 100 * valor / total
    if cont <= 5
      salvar_dados("TopGastoPartido", "#{cont};#{partido};#{"%.2f" % valor};#{"%.5f" % porc};#{ano}")
    end
    salvar_dados("GastoPartido", "#{cont};#{partido};#{"%.2f" % valor};#{"%.5f" % porc};#{ano}")
    cont += 1
  end
  ano += 1
end
puts "Analise completa !"
