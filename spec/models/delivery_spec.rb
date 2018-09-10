require 'rails_helper'

RSpec.describe Delivery, type: :model do
  let(:delivery) { Delivery.new }
  let(:deliverable) { double }
  let(:asq) { FactoryBot.create(:asq) }

  describe '.deliver' do
    before :example do
      @delivery = Delivery.new
      @deliverable = double
      @asq = FactoryBot.build(:asq)
      @activity = double

      allow(@delivery).to receive(:deliverable).and_return(@deliverable)
      allow(@deliverable).to receive(:asq).and_return(@asq)
      allow(@deliverable).to receive(:should_archive_file?).and_return(true)
      allow(@deliverable).to receive(:should_log?).and_return(true)
      allow(@delivery).to receive(:deliverable_type).and_return('EmailDelivery')
      allow(@asq).to receive(:log).and_return(@activity)
      allow(@activity).to receive(:archive_file)
      allow(@deliverable).to receive(:deliver).and_return(true)
      allow(Rails.application).to receive(:feature_archive_file_enabled).and_return(true)
    end

    it 'relays deliver to deliverable' do
      expect(@deliverable).to receive(:deliver)
      @delivery.deliver
    end

    it 'calls asq.log on delivery' do
      expect(@asq).to receive(:log).and_return(@activity)
      @delivery.deliver
    end

    context '_deliver throws exception' do
      it 'calls asq.log' do
        allow(@deliverable).to receive(:deliver).and_raise(StandardError)
        expect(@asq).to receive(:log)
          .with('error', 'EmailDelivery failed: StandardError')
        @delivery.deliver
      end
    end

    context 'while should_archive_file? is true' do
      it 'creates archived file on delivery' do
        expect(@activity).to receive(:archive_file)
        @delivery.deliver
      end
    end

    context 'while should_archive_file? is false' do
      it 'creates archived file on delivery' do
        allow(@deliverable).to receive(:should_archive_file?).and_return(false)
        expect(@activity).not_to receive(:archive_file)
        @delivery.deliver
      end
    end

    context 'while feature_archive_file_enabled is false' do
      before(:example) do
        allow(Rails.application).to receive(:feature_archive_file_enabled).and_return(false)
      end
      it 'does not create archive file on delivery' do
        expect(@activity).not_to receive(:archive_file)
        @delivery.deliver
      end
    end

    context 'deliverable is nil' do
      it 'deliver returns false' do
        delivery = Delivery.new
        expect(delivery.deliver).to be_falsy
      end
    end

    context 'deliverable_type is none' do
      before(:example) do
        allow(delivery).to receive(:deliverable_type).and_return('None')
      end

      it 'deliver returns false if deliverable_type is none' do
        expect(delivery.deliver).to be_falsy
      end
    end

    context 'while deliverable.delivery returns false' do
      before(:example) do
        allow(deliverable).to receive(:deliver).and_return(false)
      end

      it 'does not log activity' do
        expect(asq).not_to receive(:log)
        delivery.deliver
      end
    end

    context 'while deliverable.delivery returns true' do
      it 'relays deliver to deliverable' do
        expect(@deliverable).to receive(:deliver)
        @delivery.deliver
      end

      it 'logs activity' do
        expect(@asq).to receive(:log)
        @delivery.deliver
      end
    end

    context 'while deliverable.delivery throws an exception' do
      before(:example) do
        allow(@deliverable).to receive(:deliver).and_raise('boom')
      end
      it 'logs activity' do
        expect(@asq).to receive(:log)
        @delivery.deliver
      end
    end

  end
end
