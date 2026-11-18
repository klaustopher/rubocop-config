class NotAuthorizedError < StandardError
  def initialize(message = "You are not allowed to perform this action")
    super
  end
end
