require 'rails_helper'

describe SystemStatus do
  before(:each) do
    FactoryBot.create(:asq, id: 1, last_run: 1.minute.ago)
    allow(SystemStatus).to receive(:active_dj_workers).and_return(2)
    allow(Dir).to receive(:glob).and_return(['delayed_job.1', 'delayed_job.2'])
    mock_setting(:last_host_check, 'OK')
    mock_setting(:last_host_check=, '')
    allow(File).to receive(:file?).and_return(true)
    allow(File).to receive(:exist?).with('/etc/cron.d/Asq').and_return(true)
  end

  describe '::vars_hash' do
    context 'when no checks are in error' do
      it 'returns healthy' do
        expect(SystemStatus.vars_hash[:error_text]).to eq('HEALTHY')
      end
    end

    context 'when last run > 20 minutes' do
      it 'last run check fails' do
        asq = Asq.find(1)
        asq.last_run = 30.minute.ago
        asq.save!
        expect(SystemStatus.vars_hash[:error_text]).to eq('It has been 30 ' \
          'minutes since the last Asq refreshed.')
      end
    end

    context 'when not all delayed jobs are running' do
      context 'when no delayed job pid files are found' do
        it 'returns an error message' do
          allow(Dir).to receive(:glob).and_return([])
          expect(SystemStatus.vars_hash[:error_text])
            .to eq('There are no Delayed Job workers running.')
        end
      end

      context 'when the number of active workers < the number of pid files' do
        it 'returns an error message' do
          allow(SystemStatus).to receive(:active_dj_workers).and_return(0)
          expect(SystemStatus.vars_hash[:error_text])
            .to eq('There are 0 out of 2 Delayed Job workers running.')
        end
      end
    end

    context 'when cron file is not present' do
      it 'returns an error message' do
        allow(File).to receive(:exist?)
          .with('/etc/cron.d/Asq').and_return(false)
        expect(SystemStatus.vars_hash[:error_text])
          .to eq('The cron file (/etc/cron.d/Asq) does not exist on this host.')
      end
    end

    context 'when last_host_check != OK' do
      it 'last host check fails' do
        mock_setting(:last_host_check, 'ERROR')
        expect(SystemStatus.vars_hash[:error_text])
          .to eq('Primary host check has failed.')
      end
    end

    context 'when multiple errors are found' do
      it 'combines them' do
        asq = Asq.find(1)
        asq.last_run = 30.minute.ago
        asq.save!
        mock_setting(:last_host_check, 'ERROR')
        expect(SystemStatus.vars_hash[:error_text])
          .to eq('It has been 30 minutes since the last Asq refreshed. ' \
          'Primary host check has failed.')
      end
    end
  end
end
