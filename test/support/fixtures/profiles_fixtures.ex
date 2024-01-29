defmodule Trialmark.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trialmark.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> Enum.into(%{
        avatar_url: "some avatar_url",
        name: "some name"
      })
      |> Trialmark.Profiles.create_profile()

    profile
  end
end
