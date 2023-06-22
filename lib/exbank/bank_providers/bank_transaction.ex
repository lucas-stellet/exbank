defprotocol Exbank.BankProviders.BankTransaction do
  @doc "Transaction date"
  @spec date(t) :: binary()
  def date(data)

  @doc "Transaction amount"
  @spec amount(t) :: Money.t()
  def amount(data)

  @doc "Transaction description"
  @spec description(t) :: binary()
  def description(data)

  @doc "Transaction external id"
  @spec external_id(t) :: binary()
  def external_id(data)
end
