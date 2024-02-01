defmodule Trialmark.ProfilesTest do
  use Trialmark.DataCase

  alias Trialmark.Profiles

  describe "profiles" do
    alias Trialmark.Accounts

    import Trialmark.AccountsFixtures
    import Trialmark.ProfilesFixtures

    @invalid_attrs %{name: nil, avatar_url: nil}

    test "list_user_profiles/1 returns all profiles associated to user" do
      profile = profile_fixture()
      {:ok, profiles} = Profiles.list_users_profiles(profile.user)

      assert Map.delete(Enum.at(profiles, 1), :user) == Map.delete(profile, :user)
    end

    test "list_profiles_by_user_token/1 returns all profiles associated to user" do
      profile = profile_fixture()
      token = Accounts.generate_user_session_token(profile.user)
      {:ok, profiles} = Profiles.list_profiles_by_user_token(token)

      assert Map.delete(Enum.at(profiles, 1), :user) == Map.delete(profile, :user)
    end

    test "get_profile/2 returns the profile with given id" do
      generated_profile = profile_fixture()
      {:ok, profile} = Profiles.get_profile(generated_profile.user, generated_profile.id)

      assert Map.delete(generated_profile, :user) == Map.delete(profile, :user)
    end

    test "create_profile/2 with valid data creates a profile" do
      user = user_fixture()
      valid_attrs = %{name: "some name", avatar_url: "some avatar_url"}

      assert {:ok, profile} = Profiles.create_profile(valid_attrs, user)
      assert profile.name == "some name"
      assert profile.avatar_url == "some avatar_url"
      assert profile.user_id == user.id
    end

    test "create_profile/2 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} = Profiles.create_profile(@invalid_attrs, user)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      update_attrs = %{name: "some updated name", avatar_url: "some updated avatar_url"}

      assert {:ok, profile} = Profiles.update_profile(profile.user, profile, update_attrs)
      assert profile.name == "some updated name"
      assert profile.avatar_url == "some updated avatar_url"
    end

    #test "update_profile/2 with invalid data returns error changeset" do
    #  profile = profile_fixture()
    #  assert {:error, %Ecto.Changeset{}} = Profiles.update_profile(profile, @invalid_attrs)
    #  assert profile == Profiles.get_profile!(profile.id)
    #end

    #test "delete_profile/1 deletes the profile" do
    #  profile = profile_fixture()
    #  assert {:ok, %Profile{}} = Profiles.delete_profile(profile)
    #  assert_raise Ecto.NoResultsError, fn -> Profiles.get_profile!(profile.id) end
    #end

    #test "change_profile/1 returns a profile changeset" do
    #  profile = profile_fixture()
    #  assert %Ecto.Changeset{} = Profiles.change_profile(profile)
    #end
  end
end
