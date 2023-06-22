defmodule ExbankWeb.ErrorJSON do
  def render("401.json", _assigns) do
    %{
      error: %{
        details: "Unauthorized"
      }
    }
  end

  def render("404.json", _assigns) do
    %{
      error: %{
        details: "Not found"
      }
    }
  end

  def render("409.json", _assigns) do
    %{
      error: %{
        details: "Resource already exists"
      }
    }
  end

  def render("422.json", _assigns) do
    %{
      error: %{
        details: "Values sent are not valid"
      }
    }
  end

  def render("500.json", _assigns) do
    %{
      error: %{
        details: "Internal server error"
      }
    }
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
