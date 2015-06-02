require 'sinatra'
require 'stripe'

class InterPlayApp < Sinatra::Base
  set :public_key, ENV['PUBLIC_KEY']
  set :secret_key, ENV['SECRET_KEY']

  Stripe.api_key = settings.secret_key
  Stripe.publishable_key = settings.public_key

  get '/' do
    erb :index
  end

  post '/charge' do
    # Amount in cents
    @amount = params[:amount] * 100

    customer = Stripe::Customer.create(
        :email => 'customer@example.com',
        :card  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
        :amount      => @amount,
        :description => 'Sinatra Charge',
        :currency    => 'usd',
        :customer    => customer.id
    )

    erb :charge
  end
end




