defmodule TrialmarkWeb.ProfileLive.Show do
  use TrialmarkWeb, :live_view

  alias Trialmark.Accounts
  alias Trialmark.Profiles

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    {:ok, 
      socket
      |> assign(:current_user, Accounts.get_user_by_session_token(user_token))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:ok, profile} = Profiles.get_profile(socket.assigns.current_user, id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:profile, profile)}
  end

  defp page_title(:show), do: "Show Profile"
  defp page_title(:edit), do: "Edit Profile"
end
