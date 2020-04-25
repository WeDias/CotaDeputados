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
  File.open("Dados/#{nome}.csv", "a:UTF-8") do |salvar|
    salvar.write "#{texto}\n"
  end
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

  salvar_dados("TotalGastoAno", "#{ano};#{"%.2f" % total}")
  parlamentares = parlamentares.sort_by{|chave, valor| valor[:gasto]}

  cont = 1
  for parlamentar, dados in parlamentares.reverse
    id = dados[:id]
    nome = dados[:nome]
    gasto = dados[:gasto]
    porc = 100 * gasto / total
    partido = dados[:partido]
    salvar_dados("GastoPolitico","#{cont};#{id};#{partido};#{nome};#{"%.2f" % gasto};#{"%.5f" %porc};#{ano}")
    cont += 1
  end

  cont = 1
  gasto_partidos = gasto_partidos.sort_by{|partido, valor| valor}
  for partido, valor in gasto_partidos.reverse
    porc = 100 * valor / total
    salvar_dados("GastoPartido", "#{cont};#{partido};#{"%.2f" % valor};#{"%.5f" % porc};#{ano}")
    cont += 1
  end
  ano += 1
end

dados = File.read("Dados/GastoPartido.csv")
dados = CSV.parse(dados)
for dado in dados
  dado = dado[0].split(";")
  posicao = dado[0].to_i
  partido = dado[1]
  gasto = dado[2]
  porcen = dado[3]
  ano = dado[4]
  if posicao <= 5
    if posicao == 1
      salvar_dados("TopGastoPartido", "Os 5 partidos que mais gastaram em #{ano}")
    end
    salvar_dados("TopGastoPartido", "#{posicao};#{partido};#{gasto};#{porcen}")
  elsif posicao == 6
    salvar_dados("TopGastoPartido", "")
  end
end

dados = File.read("Dados/GastoPolitico.csv")
dados = CSV.parse(dados)
for dado in dados
  dado = dado[0].split(";")
  posicao = dado[0].to_i
  partido = dado[2]
  nome = dado[3]
  gasto = dado[4]
  porcen = dado[5]
  ano = dado[6]
  if posicao <= 5
    if posicao == 1
      salvar_dados("TopGastoPolitico", "Os 5 deputados que mais gastaram em #{ano}")
    end
    salvar_dados("TopGastoPolitico", "#{posicao};#{partido};#{nome};#{gasto};#{porcen}")
  elsif posicao == 6
    salvar_dados("TopGastoPolitico", "")
  end
end

puts "Analise completa !"
