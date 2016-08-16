module Spree
  class Chimpy::SubscriberMailer < BaseMailer

    def subscriber_discount_email(email,code)
      @code = code
      I18n.with_locale(I18n.locale) do
        subject = "#{Spree.t(:enjoy_15_pc_off)}"
        mail(to: email, from: from_address, subject: subject)
      end
    end

  end
end