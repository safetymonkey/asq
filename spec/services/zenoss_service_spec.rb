require 'rails_helper'

RSpec.describe ZenossService do
  before(:each) do
    @asq = FactoryGirl.build(:asq)
    allow(RestClient::Request).to receive(:execute).and_return(response)
    allow(response).to receive(:code).and_return(200)
    # We have to allow any call to Settings.method_missing to return something,
    # otherwise RSpec will throw an error the first time the code being tested
    # tries to access a setting other than one called out in mock_setting.
    allow(Settings).to receive(:method_missing).and_return('')
  end

  let(:response) { double }

  describe '#post' do
    it 'calls RestClient::Request.execute' do
      expect(RestClient::Request).to receive(:execute)
      ZenossService.post(@asq)
    end
  end

  context 'basic HTTP parameters' do
    it 'does a POST action' do
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(method: :post))
      ZenossService.post(@asq)
    end

    it 'posts the correct url' do
      url = Faker::Internet.url
      mock_setting(:zenoss_url, url)
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(url: url))
      ZenossService.post(@asq)
    end

    it 'posts the correct username' do
      username = Faker::Internet.user_name
      mock_setting(:zenoss_username, username)
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(user: username))
      ZenossService.post(@asq)
    end

    it 'posts the correct password' do
      password = Faker::Lorem
      mock_setting(:zenoss_password, password)
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(password: password))
      ZenossService.post(@asq)
    end

    it 'posts a JSON header type' do
      headers = hash_including(content_type: :json)
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(headers: headers))
      ZenossService.post(@asq)
    end

    it 'states during POST that it accepts JSON' do
      headers = hash_including(accept: :json)
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(headers: headers))
      ZenossService.post(@asq)
    end
  end

  context 'zenoss payload' do
    it 'posts the correct Zenoss "action" property' do
      expected_result = /"action":"EventsRouter"/
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(payload: expected_result))
      ZenossService.post(@asq)
    end

    it 'posts the correct Zenoss "method" property' do
      expected_result = /"method":"add_event"/
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(payload: expected_result))
      ZenossService.post(@asq)
    end

    it 'posts the correct Zenoss "type" property' do
      expected_result = /"type":"rpc"/
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(payload: expected_result))
      ZenossService.post(@asq)
    end

    it 'posts the correct Zenoss "tid" property' do
      expected_result = /"tid":1/
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(payload: expected_result))
      ZenossService.post(@asq)
    end

    context 'zenoss payload data hash' do
      it 'posts the current summary when the Asq is clear' do
        expected_result = /"summary":"#{@asq.name} is clear."/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(@asq)
      end

      it 'posts the current summary when the Asq is in alert' do
        asq_in_alert = FactoryGirl.build(:asq_in_alert)
        expected_result = /"summary":"#{asq_in_alert.name} is in alert."/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(asq_in_alert)
      end

      it 'posts the instance the Asq is hosted on' do
        hostname = Faker::Internet.domain_name
        mock_setting(:vip_name, hostname)
        expected_result = /"device":"#{hostname}"/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(@asq)
      end

      it 'posts the correct asq name' do
        expected_result = /"component":"#{@asq.name}"/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(@asq)
      end

      it 'posts the current severity when the Asq is clear' do
        expected_result = /"severity":"Clear"/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(@asq)
      end

      it 'posts the current severity when the Asq is in alert' do
        asq_in_alert = FactoryGirl.build(:asq_in_alert)
        expected_result = /"severity":"Critical"/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(asq_in_alert)
      end

      it 'posts the correct evclasskey value' do
        expected_result = /"evclasskey":"ASQ"/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(@asq)
      end

      it 'posts the correct evclass value' do
        expected_result = /"evclass":"\/ASQ"/
        expect(RestClient::Request).to receive(:execute)
          .with(hash_including(payload: expected_result))
        ZenossService.post(@asq)
      end
    end
  end

  context 'response handling' do
    it 'recognizes HTTP 200' do
      allow(response).to receive(:code).and_return(200)
      expect(ZenossService.post(@asq)).to be true
    end

    it 'recognizes HTTP 500' do
      allow(response).to receive(:code).and_return(500)
      allow(RestClient::Request).to receive(:execute) do
        raise RestClient::RequestFailed.new(response, 500)
      end
      expect { ZenossService.post(@asq) }
        .to raise_error(StandardError, /500/)
    end

    it 'recognizes HTTP 404' do
      allow(response).to receive(:code).and_return(404)
      allow(RestClient::Request).to receive(:execute) do
        raise RestClient::RequestFailed.new(response, 404)
      end
      expect { ZenossService.post(@asq) }
        .to raise_error(StandardError, /404/)
    end

    it 'recognizes HTTP 403' do
      allow(response).to receive(:code).and_return(403)
      allow(RestClient::Request).to receive(:execute) do
        raise RestClient::RequestFailed.new(response, 403)
      end
      expect { ZenossService.post(@asq) }
        .to raise_error(StandardError, /403/)
    end

    it 'redirects to a new URL' do
      redirected = false
      redirect_url = Faker::Internet.url
      headers = { location: redirect_url }
      redirect_response = double
      allow(redirect_response).to receive(:headers).and_return(headers)
      allow(redirect_response).to receive(:code).and_return(302)
      allow(RestClient::Request).to receive(:execute) do
        if !redirected
          redirected = true
          raise RestClient::RequestFailed.new(redirect_response, 302)
        else
          response
        end
      end
      expect(RestClient::Request).to receive(:execute)
        .with(hash_including(url: redirect_url))
      ZenossService.post(@asq)
    end

    it 'gives up after too many retries' do
      redirect_response = double
      redirect_url = Faker::Internet.url
      headers = { location: redirect_url }
      allow(redirect_response).to receive(:headers).and_return(headers)
      allow(redirect_response).to receive(:code).and_return(302)
      allow(RestClient::Request).to receive(:execute) do
        raise RestClient::RequestFailed.new(redirect_response, 302)
      end
      expect { ZenossService.post(@asq) }
        .to raise_error(StandardError, "Failed to post #{@asq.name} to Zenoss after 2 tries.")
    end
  end
end
