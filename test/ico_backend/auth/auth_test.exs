defmodule SecretSanta.AuthTest do
  use SecretSanta.DataCase

  alias SecretSanta.Auth

  describe "users" do
    @valid_attrs %{
      email: "majron@man.com",
      username: "majronman",
      password: "Secret123",
      ethereum_public_address: "aisdghsdih1341htkn13h5h1k351h3i5h1i35",
      planned_contribution: 123.45,
      first_name: "Majron",
      middle_name: "Man",
      last_name: "Stark",
      date_of_birth: Ecto.Date.cast!("1989-12-14"),
      place_of_birth: "Pcim",
      document_type: :personal_id,
      document_number: "BTW 2545677",
      mobile: "123-456-789",
      street_address: "Na Zjeździe 9",
      town: "Kraków",
      post_code: "30-350",
      state: "małopolska",
      country: "Poland",
      country_of_residence: "Poland"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, %{user: user}} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    test "create_user/2 creates a user and hides password" do
      user = user_fixture()
      assert user.password == nil
    end

    test "create_user/2 returns error if email is already in use" do
      user_fixture()
      assert {:error, :user, changeset, _} = Auth.create_user(@valid_attrs)
      assert "has already been taken" == Map.new(changeset.errors) |> Map.get(:email) |> elem(0)
    end
  end
end
