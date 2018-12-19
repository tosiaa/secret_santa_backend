defmodule SecretSantaWeb.Support.UserHelper do
  use Phoenix.ConnTest

  alias SecretSanta.Auth.PersonalData
  alias SecretSanta.Auth.CorporateData

  def user_default_attrs, do: %{
    email: "john@the.com",
    password: "some password",
    ethereum_public_address: "hhi23ghsdih1341htkn13h5h1k351h3i5h1i35",
    planned_contribution: Decimal.new(123.45),
    country_of_residence: "Poland"
  }

  def default_personal_data, do: %{
    first_name: "John",
    middle_name: "The",
    last_name: "Stark",
    date_of_birth: ~D[1989-12-14],
    place_of_birth: "London",
    document_type: :personal_id,
    document_number: "AAA 2115677",
    mobile: "123-456-789",
    street_address: "Na Zjeździe 9",
    town: "Kraków",
    post_code: "30-350",
    state: "małopolska",
    country: "Poland",
  }

  def default_corporate_data, do: %{
    corporation_name: "Evil Corpo Inc.",
    tax_number: "123 345 576",
    street_address: "Elm Street 9",
    town: "London",
    post_code: "123-345",
    state: "England",
    country: "United Kingdom",
    first_name: "John",
    last_name: "Evil",
    corporate_title: "CEO",
    contact_email: "john.evil@mail.com"
  }

  def default_personal_user, do: Map.merge(user_default_attrs(), default_personal_data())

  def default_corporate_user, do: Map.merge(user_default_attrs(), default_corporate_data())

  def user_login_attrs, do: %{
    email: "john@the.com",
    password: "some password"
  }

  def fixture(:user, :personal) do
    {:ok, user} = SecretSanta.Auth.create_user(default_personal_user(), PersonalData)
    user
  end

  def fixture(:user, :corporate) do
    {:ok, user} = SecretSanta.Auth.create_user(default_corporate_user(), CorporateData)
    user
  end

  def secure_conn(conn, user_type \\ :personal) do
    %{user: user} = resp = fixture(:user, user_type)
    {:ok, jwt, _} = user |> SecretSantaWeb.Guardian.encode_and_sign(%{}, token_type: :token)

    sconn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Token " <> jwt)

    {sconn, resp}
  end
end
