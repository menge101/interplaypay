require 'spec_helper'

RSpec.describe InterPlayApp do
  include Rack::Test::Methods

  context 'on the index page' do
    before(:all) do
      get '/'
      @response = last_response
    end

    it 'should have a background color of #71B532' do
      expect(@response.body.include?('background-color: #71B532')).to be_truthy
    end
    
    it 'should have a logo' do
      expect(@response.body.include?('img src="/images/interplay_logo.jpg" class="img-responsive" alt="Interplay Childcare center"')).to be_truthy
    end

    it 'should include a text field for childs name' do
      expect(@response.body.include?('type="text"  id="childName" name="child"')).to be_truthy
    end

    it 'should include a text field for parents name' do
      expect(@response.body.include?('type="text" name="parent" id="parentName"')).to be_truthy
    end

    it 'should include a dropdown for the month' do
      expect(@response.body.include?('select name="month"')).to be_truthy
    end

    it 'should mark the current month as current' do
      current_month = Date.today.strftime("%B")
      expect(@response.body.include?("#{current_month} (current)")).to be_truthy
    end

    it 'should mark the next month as next month' do
      next_month = (Date.today >> 1).strftime("%B")
      expect(@response.body.include?("#{next_month} (next month)")).to be_truthy
    end

    it 'should include a text box for the amount' do
      expect(@response.body.include?('type="text" id="amount" name="amount"')).to be_truthy
    end

    it 'should have a $ on the amount field' do
      expect(@response.body.include?('div class="input-group-addon">$')).to be_truthy
    end
  end

  context 'on the charge page' do
    before(:each) do
      Stripe.api_key = 'some_fake_key'
      params = { amount: '10.00', parent: 'Homer', child: 'Maggie', month: 'Jaguar',
                 stripeEmail: 'r@e.t', stripeToken: 'stripeToken' }

      customer_double = double("Stripe::Customer")
      charge_double = double("Stripe::Charge")
      allow(Stripe::Customer).to receive(:create).and_return(customer_double)
      allow(customer_double).to receive(:id).and_return(1)
      allow(Stripe::Charge).to receive(:create).and_return(charge_double)
      post '/charge', params
      @response = last_response
    end

    it 'should thank the parent' do
      expect(@response.body.include?('Thank you for your payment Homer.')).to be_truthy
    end

    it 'should state how much was paid and for what' do
      expect(@response.body.include?("You have paid $10.00 for Maggie's care for the month of Jaguar")).to be_truthy
    end
  end
end