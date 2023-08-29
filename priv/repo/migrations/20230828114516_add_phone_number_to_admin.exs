defmodule Ecom.Repo.Migrations.AddPhoneNumberToAdmins do
  use Ecto.Migration

  def change do
    alter table(:admins) do
      add :phone_number, :string
    end
  end
end