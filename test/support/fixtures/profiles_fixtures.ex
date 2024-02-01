defmodule Trialmark.ProfilesFixtures do
  alias Trialmark.AccountsFixtures

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trialmark.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture() 

    {:ok, profile} =
      attrs
      |> Enum.into(%{
        avatar_url: "some avatar_url",
        name: "some name"
      })
      |> Trialmark.Profiles.create_profile(user)

    profile
  end
end
