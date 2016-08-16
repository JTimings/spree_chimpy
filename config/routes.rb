Spree::Core::Engine.add_routes do

  namespace :chimpy, path: "" do
    resource :subscribers, only: [:create]
    # secure settings and unsubscribe links for chimpy subscribers
    match '/subscriber-settings/:signature', to: 'subscribers#subscriber_settings', as: 'subscriber_settings', via: [:get, :put]
    get '/subscriber-settings/unsubscribe:signature', to: 'subscribers#subscriber_settings', as: 'unsubscribe_subscriber_settings'
  end

end
