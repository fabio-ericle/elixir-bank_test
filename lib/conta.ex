defmodule Conta do
  defstruct usuario: Usuario, saldo: 1000

  @contas "contas.txt"

  def cadastrar(usuario) do
    case buscar_contas_por_email(usuario.email) do
      nil ->
        binary = [%__MODULE__{usuario: usuario}] ++ busca_contas()
        |> :erlang.term_to_binary()
        File.write(@contas, binary)
        _ -> {:error, "Conta ja cadastrada"}
    end
  end

  def busca_contas do
    {:ok, binary} = File.read(@contas)
    :erlang.binary_to_term(binary)
  end

  def buscar_contas_por_email(email), do: Enum.find(busca_contas(), &(&1.usuario.email == email))

  def deletar(contas_deletar) do
    Enum.reduce(contas_deletar, busca_contas(), fn c, acc -> List.delete(acc, c) end)
  end

  def transferir(de, para, valor) do
    de = buscar_contas_por_email(de)
    para = buscar_contas_por_email(para)
    cond do
      valida_saldo(de.saldo, valor) ->
        {:error, "Saldo insuficiente!"}
      true ->
        contas = Conta.deletar([de , para])
        de = %Conta{de | saldo: de.saldo - valor}
        para = %Conta{para | saldo: para.saldo + valor}
        contas = contas ++ [de, para]
        Transacao.gravar("transferencia", de.usuario.email, valor, Date.utc_today(), para.usuario.email)
        File.write(@contas, :erlang.term_to_binary(contas))
    end
  end

  def sacar(conta, valor) do
    conta = buscar_contas_por_email(conta)
    cond do
      valida_saldo(conta.saldo, valor) ->
        {:error, "Saldo insuficiente!"}
      true ->
        contas = Conta.deletar([conta])
        conta = %Conta{conta | saldo: conta.saldo - valor}
        contas = contas ++ [conta]
        File.write(@contas, :erlang.term_to_binary(contas))
        {:ok, conta, "Messagem de email encaminhada!"}
    end
  end

  defp valida_saldo(saldo, valor), do: saldo < valor
end
