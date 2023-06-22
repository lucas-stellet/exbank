defmodule Flow do
  @moduledoc false

  defstruct assigns: %{}, halt: false, response: nil

  @type t :: %__MODULE__{
          assigns: map(),
          halt: boolean(),
          response: any()
        }

  @spec new_flow(initial_assigns :: map()) :: t()
  def new_flow(initial_assigns) do
    %__MODULE__{
      assigns: initial_assigns,
      halt: false
    }
  end

  @spec assign(flow :: t(), key :: atom(), value :: function() | any()) :: t()
  def assign(flow, key, func) when is_function(func) do
    value = func.(flow.assigns)

    %__MODULE__{
      flow
      | assigns: Map.put(flow.assigns, key, value)
    }
  end

  def assign(flow, key, value) do
    %__MODULE__{
      flow
      | assigns: Map.put(flow.assigns, key, value)
    }
  end

  @spec multiple_assigns(flow :: t(), assigns :: keyword()) :: t()
  def multiple_assigns(flow, assigns) do
    update = Enum.into(assigns, %{})

    %__MODULE__{
      flow
      | assigns: Map.merge(flow.assigns, update)
    }
  end

  @spec halt(response :: any()) :: t()
  def halt(response) do
    %__MODULE__{
      assigns: %{},
      response: response,
      halt: true
    }
  end

  @spec finish_with(flow :: t(), key :: atom()) :: {:ok, any()} | {:error, any()}
  def finish_with(flow, key) when is_atom(key) do
    case flow do
      %__MODULE__{assigns: assigns, halt: false} ->
        {:ok, Map.get(assigns, key)}

      %__MODULE__{halt: true, response: response} ->
        {:error, response}
    end
  end

  @spec finish_with(flow :: t(), func :: function()) :: {:ok, any()} | {:error, any()}
  def finish_with(flow, func) when is_function(func) do
    case flow do
      %__MODULE__{assigns: assigns, halt: false} ->
        {:ok, func.(assigns)}

      %__MODULE__{halt: true, response: response} ->
        {:error, response}
    end
  end

  @spec finish_with(flow :: t(), success_func :: function(), error_func :: function()) ::
          {:ok, any()} | {:error, any()}
  def finish_with(flow, success_func, error_func) do
    case flow do
      %__MODULE__{assigns: assigns, halt: false} ->
        {:ok, success_func.(assigns)}

      %__MODULE__{halt: true, response: response, assigns: assigns} ->
        {:error, error_func.(assigns, response)}
    end
  end
end
