defmodule Trialmark.Policy.Checks do
  alias Trialmark.Accounts.User

  @doc """
  Checks whether the user ID of the object matches the ID of the current user.

  Assumes that the object has a `:user_id` field.
  """
  def own_resource(%User{id: id}, %{user_id: id}) when is_integer(id), do: true
  def own_resource(_, _), do: false
end
