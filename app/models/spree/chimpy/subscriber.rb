class Spree::Chimpy::Subscriber < ActiveRecord::Base
  self.table_name = "spree_chimpy_subscribers"
  validates :email, presence: true

  # Access token for a subscriber, used for unsubscribe link
  def access_token
    Spree::Chimpy::Subscriber.create_access_token(self)
  end

  private
	  # Verifier based on our application secret
	  def self.verifier
	    ActiveSupport::MessageVerifier.new(Store::Application.config.secret_key_base)
	  end

	  # Get a subscriber from a token
	  def self.read_access_token(signature)
	    id = verifier.verify(signature)
	    Spree::Chimpy::Subscriber.find_by_id id
	  rescue ActiveSupport::MessageVerifier::InvalidSignature
	    nil
	  end

	  # Class method for token generation
	  def self.create_access_token(subscriber)
	    verifier.generate(subscriber.id)
	  end

end
