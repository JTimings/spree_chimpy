module Spree::Chimpy
  class Subscription
    delegate :configured?, :enqueue, to: Spree::Chimpy

    def initialize(model)
      @model      = model
    end

    def subscribe
      if subscribing? # after_create, check user really wanted to subscribe
        defer(:subscribe)
      end
    end

    def unsubscribe
      if unsubscribing? # after_destroy, don't make api call if user already unsubscribed
        defer(:unsubscribe)
      end
    end

    def update_member
      defer(:update_member)
    end

    def resubscribe(&block)
      block.call if block
      return unless configured?

      if subscribed_changed?
        if unsubscribing?
          unsubscribe
        elsif subscribing?
          subscribe
        end
      end
      if merge_vars_changed? && !unsubscribing? # api doesn't allow updating an unsubscribed member / someone not on a list
        update_member
      end
    end

  private
    def defer(event)
      #enqueue(event, @model) if allowed?
      enqueue(event, @model) if configured?
    end

    def allowed?
      configured? && @model.subscribed
    end

    def subscribing?
      #merge_vars_changed? && @model.subscribed
      @model.subscribed
    end

    def unsubscribing?
      !@new_record && !@model.subscribed
    end

    def subscribed_changed?
      @model.subscribed_changed?
    end

    def merge_vars_changed?
      Config.merge_vars.values.any? do |attr|
        name = "#{attr}_changed?".to_sym
        !@model.methods.include?(name) || @model.send(name)
      end
    end
  end
end
