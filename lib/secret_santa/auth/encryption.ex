defmodule SecretSanta.Auth.Encryption do
  alias Comeonin.Bcrypt

  def password_hashing(password), do: Bcrypt.hashpwsalt(password)
  def dummy_validate_password(), do: Bcrypt.dummy_checkpw()
  def validate_password(password, hash), do: Bcrypt.checkpw(password, hash)
end
