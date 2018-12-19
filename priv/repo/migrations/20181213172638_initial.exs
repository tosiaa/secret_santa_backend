defmodule SecretSanta.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :login, :string, null: false
      add :password_hash, :string, null: false
      add :name, :string, null: false
      add :wishes, :string
      timestamps()
    end

    create table(:circles) do 
      add :name, :string, null: false
      add :secret, :string, null: false
      add :is_open, :boolean, default: false
      timestamps()
    end

    create table(:users_circles) do
      add :user_id, references(:users)
      add :circle_id, references(:circles)
      add :privileges, :map
    end

    create table(:lotteries) do
      add :pairing, :map, null: false
      add :deadline, :date, null: false
      add :circle_id, references(:circles)
    end

    create unique_index(:circles, [:secret])
    create unique_index(:users, [:login])
    create unique_index(:users_circles, [:user_id, :circle_id])
  end
end
