defmodule Node.Models.Contract do
  use Ecto.Schema
  import Ecto.Changeset
  alias Node.Repo
  alias Node.Ecto.Types

  @primary_key false
  schema "contracts" do
    field(:address, :binary, primary_key: true)
    field(:name, Types.Atom, primary_key: true)
    field(:code, :binary)
    timestamps()
  end

  def get(%{
        address: <<0::256>>,
        contract_name: contract_name,
        function: function,
        arguments: arguments
      }) do
    <<error_code::size(32), return_value::binary>> =
      VM.run(%{
        contract_code: base_contract_code(contract_name),
        contract_address: <<0::256>>,
        contract_name: contract_name,
        function: function,
        arguments: arguments,
        sender: <<>>
      })

    if error_code == 0 do
      {:ok, return_value}
    else
      {:error, error_code}
    end
  end

  def changeset(contract, params) do
    cast(contract, params, [:address, :code, :name])
    |> validate_required([:code])
    |> unique_constraint(:name, name: :contracts_address_name_index)
  end

  def find_by(parameters) do
    defaults = %{address: <<0::256>>, name: :BaseToken}
    parameters = Map.merge(parameters, defaults)
      |> Enum.into(%{})

    Repo.get_by(__MODULE__, parameters)
  end

  def base_contract_code(contract_name) do
    File.read!(
      Application.get_env(:node, :base_contracts_path) <>
        "/#{Macro.underscore(Atom.to_string(contract_name))}.wasm"
    )
  end
end