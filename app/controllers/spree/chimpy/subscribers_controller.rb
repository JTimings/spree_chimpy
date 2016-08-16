class Spree::Chimpy::SubscribersController < Spree::StoreController
  respond_to :html, :js

  def accurate_title
    Spree.t(:subscriber_settings)
  end

  def create
    @subscriber = Spree::Chimpy::Subscriber.where(email: subscriber_params[:email]).first_or_initialize
    @subscriber.update_attributes(subscriber_params)
    @ouibounce = params[:button] == "ouibounce"
    if @subscriber.save
      Spree::Chimpy::Subscription.new(@subscriber).subscribe      
      code = Spree::Promotion.find_by_name("GETSTARTED15").code rescue nil
      Spree::Chimpy::SubscriberMailer.delay.subscriber_discount_email(@subscriber.email,code) if code
      flash[:notice] = Spree.t(:success, scope: [:chimpy, :subscriber]) unless @ouibounce
      @ouibounce_error = false
    else
      flash.now[:error] = Spree.t(:failure, scope: [:chimpy, :subscriber]) unless @ouibounce
      @ouibounce_error = true
    end

    respond_with(@subscriber) do |format|
      format.html { redirect_to request.referer }
      format.js
    end
  end

  def subscriber_settings
    if params[:signature].slice! "unsubscribe"
      if @subscriber = Spree::Chimpy::Subscriber.read_access_token(params[:signature])
        @subscriber.update_attribute :receive_menu, false
        flash.now[:notice] = Spree.t(:weekly_menu_unsubscribe_success)
      else
        redirect_to root_path
        flash[:error] = Spree.t(:invalid_link)
      end
    else
      if @subscriber = Spree::Chimpy::Subscriber.read_access_token(params[:signature])
        if params[:chimpy_subscriber]
          receive_menu = params[:chimpy_subscriber][:receive_menu] == "1"  ? true : false
          subscribed = params[:chimpy_subscriber][:subscribed] == "1"  ? true : false

          @subscriber.update_attribute :receive_menu, receive_menu
          if ( @subscriber.subscribed != subscribed )
            if ( @subscriber.subscribed && !subscribed ) # user wants to unsubscribe
              Spree::Chimpy::Subscription.new(@subscriber).unsubscribe
            end
            if ( !@subscriber.subscribed && subscribed ) # user wants to subscribe
              Spree::Chimpy::Subscription.new(@subscriber).subscribe
            end
            @subscriber.update_attribute :subscribed, subscribed
          end
          
          flash.now[:notice] = Spree.t(:updated_email_preferences)  
        end
      else
        redirect_to root_path
        flash[:error] = Spree.t(:invalid_link)
      end
    end
  end

  private

    def subscriber_params
      params.require(:chimpy_subscriber).permit(:email, :subscribed, :language)
    end
end