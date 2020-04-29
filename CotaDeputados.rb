# CotaDeputados.rb
# Github:@WeDias

# MIT License

# Copyright (c) 2020 Wesley Ribeiro Dias

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require "json"
require "csv"

def salvar_dados(nome, texto="")
  # salvar_dados() Serve para salvar os dados coletados em um arquivo csv
  # :param nome: str, nome do arquivo
  # :param texto: str, texto que sera escrito
  # :return: nil
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
