require 'rails_helper'

RSpec.describe Inboxes::FetchImapEmailInboxesJob do
  let(:account) { create(:account) }
  let(:imap_email_channel) do
    create(:channel_email, imap_enabled: true, imap_address: 'imap.gmail.com', imap_port: 993, imap_login: 'imap@gmail.com',
                           imap_password: 'password', account: account)
  end
  let(:email_inbox) { create(:inbox, channel: imap_email_channel, account: account) }
  let(:microsoft_imap_email_channel) do
    create(:channel_email, provider: 'microsoft', imap_enabled: true, imap_address: 'outlook.office365.com',
                           imap_port: 993, imap_login: 'imap@outlook.com', imap_password: 'password', account: account,
                           provider_config: { access_token: 'access_token' })
  end
  let(:ms_email_inbox) { create(:inbox, channel: microsoft_imap_email_channel, account: account) }

  it 'enqueues the job' do
    expect { described_class.perform_later }.to have_enqueued_job(described_class)
      .on_queue('scheduled_jobs')
  end

  context 'when called' do
    it 'fetch all the email channels' do
      expect(Inboxes::FetchImapEmailsJob).to receive(:perform_later).with(imap_email_channel).once

      described_class.perform_now
    end
  end

  context 'when microsoft inbox' do
    it 'calls ms graph channel for single tenant app' do
      with_modified_env AZURE_TENANT_ID: 'azure_tenant_id' do
        expect(Inboxes::FetchMsGraphEmailsJob).to receive(:perform_later).with(microsoft_imap_email_channel).once

        described_class.perform_now
      end
    end

    it 'calls ms graph channel for multi tenant app' do
      with_modified_env AZURE_TENANT_ID: nil do
        expect(Inboxes::FetchImapEmailsJob).to receive(:perform_later).with(microsoft_imap_email_channel).once

        described_class.perform_now
      end
    end
  end
end
