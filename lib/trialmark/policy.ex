defmodule Trialmark.Policy do
  use LetMe.Policy

  object :profile do
    action :update, do: allow :own_resource
    action :delete, do: allow :own_resource
  end
end
