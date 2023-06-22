defprotocol Exbank.BankProviders.BankAccount do
  @doc "Current balance on account"
  @spec current_balance(t) :: integer()
  def current_balance(data)

  @doc "Available balance on account"
  @spec available_balance(t) :: integer()
  def available_balance(data)

  @doc "Account number"
  @spec number(t) :: binary()
  def number(data)

  @doc "Account alias"
  @spec alias(t) :: binary()
  def alias(data)

  @doc "Account external id reference"
  @spec external_id(t) :: binary()
  def external_id(data)
end
