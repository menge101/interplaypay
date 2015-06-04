require 'sinatra'
require 'stripe'

class InterPlayApp < Sinatra::Base
  Stripe.api_key = ENV['STRIPE_PRIVATE_KEY']

  get '/' do
    @public_key = ENV['STRIPE_PUBLIC_KEY']
    erb :index
  end

  post '/charge' do
    @amount = params[:amount]

    customer = Stripe::Customer.create(
        :email => 'customer@example.com',
        :card  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
        :amount      => to_stripe(@amount),
        :description => 'Sinatra Charge',
        :currency    => 'usd',
        :customer    => customer.id
    )

    erb :charge
  end

  # This method copnverts a normal decoimal dollar amount to an
  # integer value representing # of cents for the charge
  def to_stripe(value)
    (value.to_f * 100).to_i
  end
end




