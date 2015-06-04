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
    @parent = params[:parent]
    @child = params[:child]
    @month = params[:month]

    puts "Starting"


    customer = Stripe::Customer.create(
        :email => 'customer@example.com',
        :card  => params[:stripeToken],
        :description => "#{@parent} is the parent of #{@child}"
    )

    puts "Customer created"

    charge = Stripe::Charge.create(
        :amount      => to_stripe(@amount),
        :description => 'Web payment',
        :currency    => 'usd',
        :customer    => customer.id,
        :description => "#{@parent} has paid #{@amount} for #{@child}'s care in the month of #{@month}"
    )

    "charge created."

    erb :charge
  end

  # This method converts a normal decimal dollar amount to an
  # integer value representing # of cents for the charge
  def to_stripe(value)
    (value.to_f * 100).to_i
  end

  # This method takes the params array and creates a hash on customer specific data
  def customer_meta_data(p)
    { name: p[:parent], child_name: p[:child] }
  end
end




