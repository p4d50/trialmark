defmodule TrialmarkWeb.ProfileLive.Index do
  use TrialmarkWeb, :live_view

  alias Trialmark.Accounts
  alias Trialmark.Profiles
  alias Trialmark.Profiles.Profile

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    profiles = Profiles.list_profiles_by_user_token(user_token)
    
    socket = socket
      |> stream(:profiles, profiles)
      |> assign(:current_user, Accounts.get_user_by_session_token(user_token))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:profile, Profiles.get_profile!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Profile")
    |> assign(:current_user, socket.assigns.current_user)
    |> assign(:profile, %Profile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Profiles")
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info({TrialmarkWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Profiles.get_profile!(id)

    case Profiles.delete_profile(socket.assigns.current_user, profile) do
      {:ok, _} -> {:noreply, stream_delete(socket, :profiles, profile)}
      {:error, :unauthorized} -> {:noreply, put_flash(socket, :error, "You can't delete this profile")}
    end
  end
end
