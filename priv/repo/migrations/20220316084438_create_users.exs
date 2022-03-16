defmodule WeirdoLottery.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer, null: false, default: 0

      timestamps()
    end

    create index(:users, :points)
    create constraint(:users, :constraint_points_range, check: "points >= 0 and points <= 100")
  end
end
