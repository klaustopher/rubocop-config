class ApiToken < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  attr_reader :plaintext

  before_validation :generate, on: :create

  def self.digest(token)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, token)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  private

  def generate
    @plaintext = SecureRandom.base58(32)
    self.digest = self.class.digest(@plaintext)
  end
end
