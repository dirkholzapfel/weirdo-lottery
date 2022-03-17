defmodule WeirdoLottery.Lottery do
  @moduledoc """
  The Lottery context.
  """

  import Ecto.Query, warn: false
  alias WeirdoLottery.{Repo, Users.User}

  @spec draw_winners(integer()) :: list(User.t())
  @doc """
  Returns a list with up to 2 winning `User{}` elements.

  A user is a potential winner if they have more `points` than
  the given `points_threshold`.

  The winners are drawn in a random way.

  ## Examples

      iex> draw_winners(23)
      [%User{}, %User{}]

  """
  def draw_winners(points_threshold \\ 0) do
    query =
      from u in User,
        where: u.points > ^points_threshold,
        order_by: fragment("RANDOM()"),
        select: [:id, :points],
        limit: 2

    Repo.all(query)
  end
end
