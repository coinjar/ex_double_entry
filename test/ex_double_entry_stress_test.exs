defmodule ExDoubleEntryStressTest do
  use ExDoubleEntry.DataCase
  import ExDoubleEntry
  import Ecto.Query
  alias ExDoubleEntry.{Repo, Line}

  @processes 5
  @account_pairs_per_process 5
  @transfers_per_account 20

  test "stress test" do
    accounts_config = Application.fetch_env!(:ex_double_entry, :accounts)
    transfers_config = Application.fetch_env!(:ex_double_entry, :transfers)

    {new_accounts_config, new_transfer_config} =
      Enum.reduce(1..@account_pairs_per_process, {accounts_config, transfers_config}, fn n,
                                                                                         {ac, tc} ->
        acc_a_identifier = :"acc-#{n}-a"
        acc_b_identifier = :"acc-#{n}-b"

        merged_accounts_config =
          Map.merge(ac, %{
            acc_a_identifier => [],
            acc_b_identifier => []
          })

        transfers_config_items = tc[:stress_test] ++ [{acc_a_identifier, acc_b_identifier}]

        merged_transfers_config =
          Map.merge(tc, %{
            stress_test: transfers_config_items
          })

        {merged_accounts_config, merged_transfers_config}
      end)

    Application.put_env(:ex_double_entry, :accounts, new_accounts_config)
    Application.put_env(:ex_double_entry, :transfers, new_transfer_config)

    tasks =
      for _ <- 1..@processes do
        Task.async(fn ->
          {amount_out, amount_in} =
            Enum.reduce(1..@account_pairs_per_process, {0, 0}, fn n, {aa, bb} ->
              acc_a_identifier = :"acc-#{n}-a"
              acc_b_identifier = :"acc-#{n}-b"

              scope = Enum.random([nil, "scope-#{n}"])

              acc_a =
                try do
                  make_account!(acc_a_identifier, scope: scope)
                rescue
                  _ -> lookup_account!(acc_a_identifier, scope: scope)
                end

              acc_b =
                try do
                  make_account!(acc_b_identifier, scope: scope)
                rescue
                  _ -> lookup_account!(acc_b_identifier, scope: scope)
                end

              {amount_aa, amount_bb} =
                Enum.reduce(1..@transfers_per_account, {0, 0}, fn _, {a, b} ->
                  amount = :rand.uniform(1_000_00)

                  {:ok, {amount_a, amount_b}} =
                    lock_accounts([acc_a, acc_b], fn ->
                      {:ok, _} =
                        transfer!(
                          money: Money.new(amount, :USD),
                          from: acc_a,
                          to: acc_b,
                          code: :stress_test
                        )

                      amount_a = -amount
                      amount_b = amount

                      scope_cond = fn query, value ->
                        case value do
                          nil ->
                            query
                            |> where([q], is_nil(q.account_scope))
                            |> where([q], is_nil(q.partner_scope))

                          _ ->
                            query
                            |> where([q], q.account_scope == ^value)
                            |> where([q], q.partner_scope == ^value)
                        end
                      end

                      lines_a =
                        from(
                          l in Line,
                          where: l.account_identifier == ^acc_a_identifier,
                          where: l.partner_identifier == ^acc_b_identifier,
                          where: l.code == :stress_test,
                          order_by: [desc: l.balance_amount]
                        )
                        |> scope_cond.(scope)
                        |> Repo.all()

                      lines_b =
                        from(
                          l in Line,
                          where: l.account_identifier == ^acc_b_identifier,
                          where: l.partner_identifier == ^acc_a_identifier,
                          where: l.code == :stress_test,
                          order_by: [asc: l.balance_amount]
                        )
                        |> scope_cond.(scope)
                        |> Repo.all()

                      {lines_a_amount, lines_a_balance_amount} =
                        Enum.reduce(lines_a, {0, 0}, fn line, {amount, _ba} ->
                          {amount + line.amount, line.balance_amount}
                        end)

                      assert lines_a_amount == lines_a_balance_amount

                      {lines_b_amount, lines_b_balance_amount} =
                        Enum.reduce(lines_b, {0, 0}, fn line, {amount, _ba} ->
                          {amount + line.amount, line.balance_amount}
                        end)

                      assert lines_b_amount == lines_b_balance_amount

                      assert lines_a_balance_amount + lines_b_balance_amount == 0

                      {a + amount_a, b + amount_b}
                    end)

                  {amount_a, amount_b}
                end)

              IO.write(".")

              {aa + amount_aa, bb + amount_bb}
            end)

          assert amount_out + amount_in == 0
        end)
      end

    Task.await_many(tasks, :infinity)

    assert Line |> Repo.all() |> Enum.count() ==
             @processes * @account_pairs_per_process * @transfers_per_account * 2
  end
end
