ActionController::Routing::Routes.draw do |map|
  map.resources :places

  map.resources :specialities


  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
#  map.admin_user '/users/:user/roles', :controller => 'users', :action => 'edit', :user => nil
#  map.visit_reservation_search '/visit/reservation/search', :controller => 'visit_reservation', :action => 'search'
#  map.user_filter '/visit/reservation/search', :controller => 'user', :action => 'search'
#  map.doctor_schedule '/users/:user_id/worktimes/', :controller => ''

  map.search_available_worktimes '/patients/:patient_id/visit_reservations/search_form', :controller => 'visit_reservations', :action => "search_form"
  map.show_available_worktimes '/patients/:patient_id/visit_reservations/available_worktimes', :controller => 'visit_reservations', :action => "available_worktimes"

  map.resource :session
  map.resource :speciality
  map.resource :admin
  map.resources :examination_kinds
  map.resources :specialities
  map.resources :visit_reservations
  map.resources :visits
  map.resources :worktimes
  map.resources :absences


  map.resources :users, :member => { :suspend   => :put,
    :unsuspend => :put,
    :purge     => :delete }, :has_many => [ :worktimes, :absences ]


  map.resources :patients, :has_many => [ :visit_reservations ]

  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
