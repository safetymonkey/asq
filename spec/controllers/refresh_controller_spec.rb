require 'rails_helper'

RSpec.describe RefreshController, type: :controller do

  # This is the Asq we're going to use in all of our tests. Using FactoryGirl
  # means that we have an actual Asq object to use instead of having to 
  # mock one out, property by property. Since we're creating it inside
  # our RSpec, we can "inject" it into the controller by intercepting
  # method calls such as Asq.find_by_id and Asq.all. 

  let (:asq) { FactoryGirl.create(:asq) }

  describe "GET #index/:id" do

    # If we want to confrim that the controller refreshes the correct Asq, 
    # we need to force Asq.find_by_id to return our pre-defined asq. Then
    # we can tell RSPec to "spy" on this Asq to make sure its refresh() 
    # method is called. 

    it "refreshes the correct Asq" do
      allow(Asq).to receive(:find_by_id).with(asq.id.to_s).and_return(asq)
      expect(asq).to receive(:refresh)
      get :index, id: asq.id.to_s
    end

    # Asq_path is a Rails helper that can be used to provide the path to the 
    # Asq object in question. If you do a "rake routes" command, you can 
    # see all the prefixes that can have "_path" (among other thigns)
    # appended to them. In this case, asq_path takes an ID to the Asq we 
    # want to redirect to. 

    it "redirects to the Asq's page after refresh" do
      allow(Asq).to receive(:find_by_id).with(asq.id.to_s).and_return(asq)
      get :index, id: asq.id.to_s
      expect(response).to redirect_to(asq_path(asq.id))
    end
  end

  describe "GET #index" do

    # The mock_setting method lives in /spec/rails_helper.rb, so all specs 
    # can use it. Take a look at what it does and tell me you wouldn't 
    # rather just do the same thing by calling mock_setting. 

    # We set vip_name to blank in order to test the code path for when Asq 
    # thinks that it's not part of a VIP. We also make sure that the controller 
    # sets last_host_check to OK. If that doesn't happen, then the test fails 
    # before getting to the expect() statement. 

    # Each Asq object returned by Asq.all has its needs_refresh? method stubbed 
    # to return true for first two asqs, and false for the third one. If 
    # refresh_asqs_in_need is working properly, two (and only two) Asq objects 
    # will receive a call to their refresh method. Anything else is a falilure.    

    it "refreshes Asqs that need it when /refresh is hit by itself and Asq ID and vip_name is empty" do
      mock_setting(:vip_name, '')
      mock_setting(:last_host_check=, 'OK')
      allow(Asq).to receive(:all).and_return([asq, asq, asq])
      allow(asq).to receive(:needs_refresh?).and_return(true, true, false)
      expect(asq).to receive(:refresh).twice
      get :index
    end

    # We set vip_name to "vip" in order to test the code path for when Asq 
    # thinks that it's part of a VIP. We also make sure that the controller 
    # sets last_host_check to OK, for the same reason as above. 

    # Simulating the open() method is how we fool the controller into thinking
    # that it actually used the open() method of the open-uri gem to contact
    # the VIP and see what the responding server says its hostname is. The idea
    # is that if the server that responds at the VIP says its hostname is X, and
    # Rails.application.hostname thinks its hostname is X, then the controller 
    # knows that it's running on the primary host of the VIP. 

    # In order to control what the test thinks its hostname is, we have to 
    # simulate a response from Rails.application.hostname. We can do that by 
    # Stubbing the Rails class to return an application object, then by making
    # that application object return the string "host" when its hostname
    # method is called. 

    # Eventually, we arrive in the same place as the prvious test. We generate 
    # three Asq objects, and test to make sure that only the two that need
    # refreshing have their refresh method invoked.  

    it "refreshes Asqs that need it when /refresh is hit by itself and vip_name matches Rails.application.hostname" do
      mock_setting(:vip_name, 'vip')
      mock_setting(:last_host_check=, 'OK')
      allow(controller).to receive(:open).and_return('host')
      application = double
      allow(Rails).to receive(:application).and_return(application)
      allow(application).to receive(:hostname).and_return('host')
      allow(Asq).to receive(:all).and_return([asq, asq, asq])
      allow(asq).to receive(:needs_refresh?).and_return(true, true, false)
      expect(asq).to receive(:refresh).twice
      get :index
    end


    it "doesn't refresh any Asqs when /refresh is hit without an Asq ID and vip_name doesn't match Rails.application.hostname" do
      mock_setting(:vip_name, 'vip')
      mock_setting(:last_host_check=, 'OK')
      allow(controller).to receive(:open).and_return('host')
      application = double
      allow(Rails).to receive(:application).and_return(application)
      allow(application).to receive(:hostname).and_return('host')
      allow(Asq).to receive(:all).and_return([asq, asq, asq])
      allow(asq).to receive(:needs_refresh?).and_return(true, true, false)
      expect(asq).to receive(:refresh).twice
      get :index
    end

    # We're not doing anything differently than we are in the above tests, 
    # we're just changing what we're expecting. Here, we're making sure
    # that when /refresh is hit by itself, the user is redirected
    # to Asq's front page. 
    
    it "redirects to the front page when /refresh is hit by itself" do
      mock_setting(:vip_name, 'vip')
      mock_setting(:last_host_check=, 'OK')
      allow(controller).to receive(:open).and_return('host')
      application = double
      allow(Rails).to receive(:application).and_return(application)
      allow(application).to receive(:hostname).and_return('host')
      get :index
      expect(response).to redirect_to(root_path)
    end

    # This test is almost the same as the above, but we want to make sure 
    # the redirect happens when /refresh is hit on a server that's not the 
    # primary host in a VIP. 

    it "redirects to the front page when /refresh is hit by itself and the server is not the primary host" do
      mock_setting(:vip_name, 'vip')
      mock_setting(:last_host_check=, 'OK')
      allow(controller).to receive(:open).and_return('host')
      application = double
      allow(Rails).to receive(:application).and_return(application)
      allow(application).to receive(:hostname).and_return('host2')
      allow(controller).to receive(:refresh_asqs_in_need)
      get :index
      expect(response).to redirect_to(root_path)
    end
  end
end
