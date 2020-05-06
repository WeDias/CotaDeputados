# frozen_string_literal: true

# cotadeputados.rb
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

require 'json'
require 'csv'

def salvar_dados(nome, texto = '')
  # salvar_dados() Serve para salvar os dados coletados em um arquivo csv
  # :param nome: str, nome do arquivo
  # :param texto: str, texto que sera escrito
  # :return: nil
  File.write("Dados/#{nome}.csv", "#{texto}\n", mode: 'a:UTF-8')
end

{ TotalGastoAno: 'Ano;TotalGasto',
  TopGastoPolitico: 'Posicao;Id;Partido;Nome;Gasto;PorcTotal;Ano',
  TopGastoPartido: 'Posicao;Partido;Gasto;PorcTotal;Ano',
  GastoPolitico: 'Posicao;Id;Partido;Nome;Gasto;PorcTotal;Ano',
  GastoPartido: 'Posicao;Partido;Gasto;PorcTotal;Ano' }.each do |chave, valor|
  File.write("Dados/#{chave[0..chave.length]}.csv",
             "#{valor}\n", mode: 'w:UTF-8')
end

ano = 2008
while ano <= 2019
  arquivo = File.read("Dados/Ano-#{ano}.json")
  dados = JSON.parse(arquivo)
  dados = dados['dados']

  total = 0
  parlamentares = {}
  gasto_partidos = {}
  puts "analisando #{ano}..."
  dados.each do |dado|
    id = dado['numeroDeputadoID']
    nome = dado['nomeParlamentar']
    gasto = dado['valorLiquido'].to_f
    partido = dado['siglaPartido']

    partido = nome if partido.empty?

    if !gasto_partidos.include?(partido)
      gasto_partidos[partido] = gasto
    else
      gasto_anterior = gasto_partidos[partido].to_f
      gasto_partidos[partido] = gasto + gasto_anterior
    end

    if nome != partido
      if !parlamentares.include?(nome)
        parlamentares[nome] = { id: id,
                                partido: partido,
                                nome: nome,
                                gasto: gasto }
      else
        gasto_anterior = parlamentares[nome][:gasto].to_f
        parlamentares[nome][:gasto] = gasto_anterior + gasto
      end
    end
    total += gasto
  end
  salvar_dados('TotalGastoAno', "#{ano};#{total}")
  parlamentares = parlamentares.sort_by { |_chave, valor| valor[:gasto] }

  cont = 1
  parlamentares.reverse.each do |_parlamentar, dado|
    id = dado[:id]
    nome = dado[:nome]
    gasto = dado[:gasto]
    porc = 100 * gasto / total
    partido = dado[:partido]
    if cont <= 5
      salvar_dados('TopGastoPolitico',
                   "#{cont};#{id};#{partido};#{nome};"\
                        "#{gasto.round(2)};#{porc.round(5)};#{ano}")
    end
    salvar_dados('GastoPolitico',
                 "#{cont};#{id};#{partido};#{nome};"\
                      "#{gasto.round(2)};#{porc.round(5)};#{ano}")
    cont += 1
  end

  cont = 1
  gasto_partidos = gasto_partidos.sort_by { |_partido, valor| valor }
  gasto_partidos.reverse.each do |partido, valor|
    porc = 100 * valor / total
    if cont <= 5
      salvar_dados('TopGastoPartido', "#{cont};#{partido};"\
                        "#{valor.round(2)};#{porc.round(5)};#{ano}")
    end
    salvar_dados('GastoPartido', "#{cont};#{partido};"\
                      "#{valor.round(2)};#{porc.round(5)};#{ano}")
    cont += 1
  end
  ano += 1
end
puts 'Analise completa !'
