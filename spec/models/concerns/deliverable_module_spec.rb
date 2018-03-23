require 'rails_helper'

RSpec.describe DeliverableModule do
  let(:asq) { FactoryBot.build(:asq) }
  let(:dummy_class) do
    Class.new do
      include ActiveModel::Model
      include DeliverableModule
      attr_accessor :asq, :id
    end
  end
  let(:dummy_instance) { dummy_class.new(id: 1, asq: asq) }

  describe 'on create callback' do
    it 'adds deliverable to asq.deliveries' do
      expect(Delivery).to receive(:create)
        .with(deliverable: dummy_instance, asq: asq)
      dummy_instance.send(:create_delivery)
    end
  end

  describe 'on destroy callback' do
    it 'adds deliverable to asq.deliveries' do
      dum1 = double
      del_dubs = [dum1, dum1, dum1]
      allow(Delivery).to receive(:where).and_return(del_dubs)
      expect(dum1).to receive(:destroy).exactly(3).times
      dummy_instance.send(:destroy_delivery)
    end
  end

  describe '.should_archive_file?' do
    it 'returns true' do
      expect(dummy_instance.should_archive_file?).to be_truthy
    end
  end

  describe '.should_log?' do
    context 'while skip_logging flagged' do
      it 'returns false' do
        # sets skip logging flog w/o testing flag logic
        dummy_instance.instance_variable_set(:@skip_logging, true)
        expect(dummy_instance.should_log?).to be_falsy
      end
    end

    context 'while skip_logging not flagged' do
      it 'returns true' do
        expect(dummy_instance.should_log?).to be_truthy
      end
    end
  end

  describe '.deliver' do
    describe 'default delivery paths' do
      describe '.deliver_alarm' do
        it 'calls .deliver_report' do
          expect(dummy_instance).to receive(:deliver_report)
          dummy_instance.send(:deliver_alarm)
        end
      end
      describe '.deliver_clear' do
        it 'calls .deliver_report' do
          expect(dummy_instance).to receive(:deliver_report)
          dummy_instance.send(:deliver_clear)
        end
      end
    end

    context 'asq.query_type is report' do
      it 'calls deliver_report' do
        our_asq = FactoryBot.build(:asq)
        dummy_instance.asq = our_asq
        expect(dummy_instance).to receive(:deliver_report)
        dummy_instance.deliver
      end
      context 'meets_sub_requirements? is false' do
        it 'does not call delivery_report' do
          our_asq = FactoryBot.build(:asq)
          dummy_instance.asq = our_asq
          allow(dummy_instance).to receive(:meets_sub_requirements?)
            .and_return(false)
          expect(dummy_instance).to_not receive(:deliver_report)
          dummy_instance.deliver
        end
      end
      context 'when in operational_error' do
        it 'will not deliver' do
          asq = FactoryBot.build(:asq, status: 'operational_error')
          dummy_instance.asq = asq
          expect(dummy_instance).to_not receive(:deliver_report)
          dummy_instance.deliver
        end
      end
    end

    context 'asq.query_type is monitor' do
      context 'asq.in_alert? is true' do
        context 'asq.formerly_in_alert? is false' do
          it 'calls deliver_alarm' do
            our_asq = FactoryBot.build(
              :asq,
              query_type: 'monitor',
              status: 'alert_new')
            dummy_instance.asq = our_asq
            expect(dummy_instance).to receive(:deliver_alarm)
            dummy_instance.deliver
          end
        end
        context 'and asq.deliver_on_every_refresh is true' do
          it 'calls deliver_alarm' do
            our_asq = FactoryBot.build(
              :asq,
              query_type: 'monitor',
              status: 'alert_still',
              deliver_on_every_refresh: true)
            dummy_instance.asq = our_asq
            expect(dummy_instance).to receive(:deliver_alarm).and_call_original
            expect(dummy_instance).to receive(:deliver_report)
            dummy_instance.deliver
          end
        end
      end

      context 'asq.in_alert? is false' do
        context 'asq.deliver_on_all_clear is false' do
          it 'does not call deliver_alarm' do
            our_asq = FactoryBot.build(
              :asq,
              query_type: 'monitor',
              status: 'clear_new',
              deliver_on_all_clear: false)
            dummy_instance.asq = our_asq
            expect(dummy_instance).not_to receive(:deliver_alarm)
            dummy_instance.deliver
          end
        end
        context 'and asq.deliver_on_all_clear is true' do
          it 'calls deliver_alarm' do
            our_asq = FactoryBot.build(
              :asq,
              query_type: 'monitor',
              status: 'clear_new',
              deliver_on_all_clear: true)
            dummy_instance.asq = our_asq
            expect(dummy_instance).to receive(:deliver_clear)
            dummy_instance.deliver
          end
          context 'and asq.formerly_in_error? is false' do
            it 'does not deliver_alarm' do
              our_asq = FactoryBot.build(
                :asq,
                query_type: 'monitor',
                status: 'clear_still',
                deliver_on_all_clear: true)
              dummy_instance.asq = our_asq
              expect(dummy_instance).not_to receive(:deliver_clear)
              dummy_instance.deliver
            end
          end
        end
      end
    end
    context 'while asq is in an unhandled state' do
      it 'throws and error' do
        our_asq = FactoryBot.build(
          :asq,
          query_type: 'monitor',
          status: 'alert_still',
          deliver_on_every_refresh: false)
        dummy_instance.asq = our_asq
        allow(dummy_instance).to receive(:meets_requirements?).and_return(true)
        expect { dummy_instance.deliver }.to raise_error(RuntimeError)
      end
    end
  end
end
