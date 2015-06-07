require 'sinatra'
require 'stripe'

class InterPlayApp < Sinatra::Base
  Stripe.api_key = ENV['STRIPE_PRIVATE_KEY']

  get '/' do
    @public_key = ENV['STRIPE_PUBLIC_KEY']
    @months = month_options
    erb :index
  end

  post '/charge' do
    @amount = amount_normalize(params[:amount])
    @parent = params[:parent]
    @child = params[:child]
    @month = params[:month]

    if @month.include?('(')
      @month = @month.split(' ')[0]
    end

    customer = Stripe::Customer.create(
        :email => params[:stripeEmail],
        :card  => params[:stripeToken],
        :description => "#{@parent} is the parent of #{@child}"
    )

    charge = Stripe::Charge.create(
        :amount      => to_stripe(@amount),
        :currency    => 'usd',
        :customer    => customer.id,
        :description => "Interplay Web payment: #{@parent} has paid #{@amount} for #{@child}'s care in the month of #{@month}"
    )

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

  def month_options
    current_date = Date.today
    months = []
    12.times do
      months << current_date.strftime('%B')
      current_date = (current_date >> 1)
    end
    months[0] += ' (current)'
    months[1] += ' (next month)'
    months
  end

  def amount_normalize(amount)
    (((amount.to_f * 1000).to_i + 1) / 1000.0).to_s.slice!(-1)
    amount
  end
end




