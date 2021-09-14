defmodule Transacao do
  defstruct data: Date.utc_today, tipo: nil, valor: 0, de: nil, para: nil

  @transacoes "transacoes.txt"

  def gravar(tipo, de, valor, data, para \\ nil) do
    transacoes = todas()
    |> :erlang.binary_to_term()
    transacoes = transacoes ++
      [%__MODULE__{tipo: tipo, de: de, valor: valor, data: data, para: para}]
    File.write(@transacoes, :erlang.term_to_binary((transacoes)))
    transacoes
  end

  def todas(), do: busca_transacoes()
  def por_ano(ano), do: Enum.filter(todas(), &(&1.data.year == ano))
  def por_mes(anos, mes), do: Enum.filter(todas(), &(&1.data.year == anos && &1.data.month == mes))
  def por_dia(data), do: Enum.filter(todas(), &(&1.data == data))
  defp busca_transacoes do
    {:ok, binario} = File.read(@transacoes)
    binario
    |> :erlang.binary_to_term()
  end

  def calcular_total() do
    todas()
    |> calcular()
  end
  def calcular_mes(ano, mes) do
    por_mes(ano, mes)
    |> calcular()
  end
  def calcular_ano(ano) do
    por_ano(ano)
    |> calcular()
  end
  def calcular_dia(data) do
    por_dia(data)
    |> calcular()
  end
  defp calcular(transacoes) do
    {transacoes, Enum.reduce(transacoes, 0, fn x, acc -> acc + x.valor end)}
  end
end
