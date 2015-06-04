require 'sinatra'
require 'stripe'

class InterPlayApp < Sinatra::Base
  public_key = ENV['PUBLIC_KEY']
  secret_key = ENV['SECRET_KEY']

  Stripe.api_key = secret_key

  get '/' do
    erb :index
  end

  post '/charge' do
    # Amount in cents
    @amount = params[:amount] * 100

    puts "Stripe token: #{params[:stripeToken]}"

    customer = Stripe::Customer.create(
        :email => 'customer@example.com',
        :card  => params[:stripeToken]
    )

    puts "Customer created."

    charge = Stripe::Charge.create(
        :amount      => @amount,
        :description => 'Sinatra Charge',
        :currency    => 'usd',
        :card => params[:stripeToken]
        #:customer    => customer.id
    )

    puts "Charged."

    erb :charge
  end
end




