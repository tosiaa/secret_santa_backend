defmodule SecretSanta.FieldsHelper do
  def get_iso_timestamps(%{inserted_at: inserted_at, updated_at: updated_at}) do
    [inserted_at, updated_at]
    |> Enum.map(&NaiveDateTime.to_iso8601/1)
    |> List.to_tuple()
  end
end
