module Stripe
  module TestData
    def make_response(body, code=200)
      # When an exception is raised, restclient clobbers method_missing.  Hence we
      # can't just use the stubs interface.
      body = JSON.generate(body) if !(body.kind_of? String)
      m = mock
      m.instance_variable_set('@stripe_values', {
        :body => body,
        :code => code,
        :headers => {},
      })
      def m.body; @stripe_values[:body]; end
      def m.code; @stripe_values[:code]; end
      def m.headers; @stripe_values[:headers]; end
      m
    end

    def make_balance(params={})
      {
        :pending => [
          {:amount => 12345, :currency => "usd"}
        ],
        :available => [
          {:amount => 6789, :currency => "usd"}
        ],
        :livemode => false,
        :object => "balance"
      }.merge(params)
    end

    def make_balance_transaction(params={})
      {
        :amount => 100,
        :net => 41,
        :currency => "usd",
        :type => "charge",
        :created => 1371945005,
        :available_on => 1372549805,
        :status => "pending",
        :description => "A test balance transaction",
        :fee => 59,
        :object => "balance_transaction"
      }.merge(params)
    end

    def make_balance_transaction_array
      {
        :data => [make_balance_transaction, make_balance_transaction, make_balance_transaction],
        :object => "list",
        :url => "/v1/balance/history"
      }
    end

    def make_application_fee(params={})
      id = params[:id] || 'fee_test_fee'
      {
        :refunded => false,
        :amount => 100,
        :application => "ca_test_application",
        :user => "acct_test_user",
        :charge => "ch_test_charge",
        :id => id,
        :livemode => false,
        :currency => "usd",
        :object => "application_fee",
        :refunds => make_application_fee_refund_array(id),
        :created => 1304114826
      }.merge(params)
    end

    def make_application_fee_refund(params = {})
      {
        :object => 'fee_refund',
        :amount => 30,
        :currency => "usd",
        :created => 1308595038,
        :id => "ref_test_app_fee_refund",
        :fee => "ca_test_application",
        :metadata => {}
      }.merge(params)
    end

    def make_application_fee_array
      {
        :data => [make_application_fee, make_application_fee, make_application_fee],
        :object => 'list',
        :url => '/v1/application_fees'
      }
    end

    def make_application_fee_refund_array(fee_id)
      {
        :data => [make_application_fee_refund, make_application_fee_refund, make_application_fee_refund],
        :object => 'list',
        :url => '/v1/application_fees/' + fee_id + '/refunds'
      }
    end

    def make_customer(params={})
      id = params[:id] || 'c_test_customer'
      {
        :subscription_history => [],
        :bills => [],
        :charges => [],
        :livemode => false,
        :object => "customer",
        :id => id,
        :default_card => "cc_test_card",
        :created => 1304114758,
        :sources => make_customer_card_array(id),
        :metadata => {},
        :subscriptions => make_subscription_array(id)
      }.merge(params)
    end

    def make_customer_array
      {
        :data => [make_customer, make_customer, make_customer],
        :object => 'list',
        :url => '/v1/customers'
      }
    end

    def make_charge(params={})
      id = params[:id] || 'ch_test_charge'
      {
        :refunded => false,
        :paid => true,
        :amount => 100,
        :card => {
          :type => "Visa",
          :last4 => "4242",
          :exp_month => 11,
          :country => "US",
          :exp_year => 2012,
          :id => "cc_test_card",
          :object => "card"
        },
        :id => id,
        :reason => "execute_charge",
        :livemode => false,
        :currency => "usd",
        :object => "charge",
        :created => 1304114826,
        :refunds => make_refund_array(id),
        :metadata => {}
      }.merge(params)
    end

    def make_charge_array
      {
        :data => [make_charge, make_charge, make_charge],
        :object => 'list',
        :url => '/v1/charges'
      }
    end


    def make_dispute(params={})
      id = params[:id] || 'dp_test_dispute'
      {
        :id => id,
        :charge => "ch_test_charge",
        :amount => 500,
        :created => 1304114758,
        :status => 'needs_response',
        :livemode => false,
        :currency => 'usd',
        :object => 'dispute',
        :reason => 'fraudulent',
        :evidence => {},
      }.merge(params)
    end

    def make_dispute_array
      {
        :data => [make_dispute, make_dispute, make_dispute],
        :object => 'list',
        :url => '/v1/disputes'
      }
    end

    def make_recipient_card_array(recipient_id)
      {
        :data => [make_card, make_card, make_card],
        :object => 'list',
        :url => '/v1/recipients/' + recipient_id + '/cards'
      }
    end

    def make_customer_card_array(customer_id)
      {
        :data => [make_card, make_card, make_card],
        :object => 'list',
        :url => '/v1/customers/' + customer_id + '/sources'
      }
    end

    def make_card(params={})
      {
        :type => "Visa",
        :last4 => "4242",
        :exp_month => 11,
        :country => "US",
        :exp_year => 2012,
        :id => "cc_test_card",
        :customer => 'c_test_customer',
        :object => "card"
      }.merge(params)
    end

    def make_coupon(params={})
      {
        :duration => 'repeating',
        :duration_in_months => 3,
        :percent_off => 25,
        :id => "co_test_coupon",
        :object => "coupon",
        :metadata => {},
      }.merge(params)
    end

    def make_file(params={})
      {
        :object => "file_upload",
        :id => "fil_test_file",
        :created => 1403047735,
        :size => 4908,
        :purpose => params[:purpose] || "dispute_evidence",
        :url => nil,
        :type => nil,
      }
    end

    def make_file_array
      {
        :data => [make_file, make_file, make_file],
        :object => 'list',
        :url => '/v1/files'
      }
    end

    #FIXME nested overrides would be better than hardcoding plan_id
    def make_subscription(params = {})
      plan = params.delete(:plan) || 'gold'
      {
        :current_period_end => 1308681468,
        :status => "trialing",
        :plan => {
          :interval => "month",
          :amount => 7500,
          :trial_period_days => 30,
          :object => "plan",
          :identifier => plan
        },
        :current_period_start => 1308595038,
        :start => 1308595038,
        :object => "subscription",
        :trial_start => 1308595038,
        :trial_end => 1308681468,
        :customer => "c_test_customer",
        :id => 's_test_subscription'
      }.merge(params)
    end

    def make_refund(params = {})
      {
        :object => 'refund',
        :amount => 30,
        :currency => "usd",
        :created => 1308595038,
        :id => "ref_test_refund",
        :charge => "ch_test_charge",
        :metadata => {}
      }.merge(params)
    end

    def make_subscription_array(customer_id)
      {
        :data => [make_subscription, make_subscription, make_subscription],
        :object => 'list',
        :url => '/v1/customers/' + customer_id + '/subscriptions'
      }
    end

    def make_refund_array(charge_id)
      {
        :data => [make_refund, make_refund, make_refund],
        :object => 'list',
        :url => '/v1/charges/' + charge_id + '/refunds'
      }
    end

    def make_reversal_array(transfer_id)
      {
        :data => [make_reversal, make_reversal, make_reversal],
        :object => 'list',
        :url => '/v1/transfers/' + transfer_id + '/reversals'
      }
    end

    def make_invoice
      {
        :id => 'in_test_invoice',
        :object => 'invoice',
        :livemode => false,
        :amount_due => 1000,
        :attempt_count => 0,
        :attempted => false,
        :closed => false,
        :currency => 'usd',
        :customer => 'c_test_customer',
        :date => 1349738950,
        :lines => {
          "invoiceitems" => [
            {
              :id => 'ii_test_invoice_item',
              :object => '',
              :livemode => false,
              :amount => 1000,
              :currency => 'usd',
              :customer => 'c_test_customer',
              :date => 1349738950,
              :description => "A Test Invoice Item",
              :invoice => 'in_test_invoice'
            },
          ],
        },
        :paid => false,
        :period_end => 1349738950,
        :period_start => 1349738950,
        :starting_balance => 0,
        :subtotal => 1000,
        :total => 1000,
        :charge => nil,
        :discount => nil,
        :ending_balance => nil,
        :next_payemnt_attempt => 1349825350,
      }
    end

    def make_paid_invoice
      make_invoice.merge({
          :attempt_count => 1,
          :attempted => true,
          :closed => true,
          :paid => true,
          :charge => 'ch_test_charge',
          :ending_balance => 0,
          :next_payment_attempt => nil,
        })
    end

    def make_invoice_customer_array
      {
        :data => [make_invoice],
        :object => 'list',
        :url => '/v1/invoices?customer=test_customer'
      }
    end

    def make_recipient(params={})
      id = params[:id] || 'rp_test_recipient'
      {
        :name => "Stripe User",
        :type => "individual",
        :livemode => false,
        :object => "recipient",
        :id => "rp_test_recipient",
        :cards => make_recipient_card_array(id),
        :default_card => "debit_test_card",
        :active_account => {
          :last4 => "6789",
          :bank_name => "STRIPE TEST BANK",
          :country => "US",
          :object => "bank_account"
        },
        :created => 1304114758,
        :verified => true,
        :metadata => {}
      }.merge(params)
    end

    def make_recipient_array
      {
        :data => [make_recipient, make_recipient, make_recipient],
        :object => 'list',
        :url => '/v1/recipients'
      }
    end

    def make_transfer(params={})
      {
        :status => 'pending',
        :amount => 100,
        :account => {
          :object => 'bank_account',
          :country => 'US',
          :bank_name => 'STRIPE TEST BANK',
          :last4 => '6789'
        },
        :recipient => 'test_recipient',
        :fee => 0,
        :fee_details => [],
        :id => "tr_test_transfer",
        :reversals => make_reversal_array('tr_test_transfer'),
        :livemode => false,
        :currency => "usd",
        :object => "transfer",
        :date => 1304114826,
        :metadata => {}
      }.merge(params)
    end

    def make_transfer_array
      {
        :data => [make_transfer, make_transfer, make_transfer],
        :object => 'list',
        :url => '/v1/transfers'
      }
    end

    def make_canceled_transfer
      make_transfer.merge({
        :status => 'canceled'
      })
    end

    def make_reversal(params={})
      {
        :object => 'transfer_reversal',
        :amount => 30,
        :currency => "usd",
        :created => 1308595038,
        :id => "ref_test_reversal",
        :transfer => "tr_test_transfer",
        :metadata => {}
      }.merge(params)
    end

    def make_bitcoin_receiver(params={})
      {
        :id => 'btcrcv_test_receiver',
        :amount => 100,
        :currency => 'usd',
        :description => 'some details',
        :metadata => {},
        :object => 'bitcoin_receiver',
        :transactions => make_bitcoin_transaction_array
      }.merge(params)
    end

    def make_bitcoin_receiver_array
      {
        :data => [make_bitcoin_receiver, make_bitcoin_receiver, make_bitcoin_receiver],
        :object => 'list',
        :url => '/v1/bitcoin/receivers'
      }
    end

    def make_bitcoin_transaction(params={})
      {
        :id => 'btctxn_test_transaction',
        :object => 'bitcoin_transaction',
        :amount => 100,
        :currency => 'usd',
        :bitcoin_amount => 90,
        :receiver => 'btcrcv_test_receiver'
      }.merge(params)
    end

    def make_bitcoin_transaction_array
      {
        :data => [make_bitcoin_transaction, make_bitcoin_transaction, make_bitcoin_transaction],
        :object => 'list',
        :url => "/v1/bitcoin/receivers/btcrcv_test_receiver/transactions"
      }
    end

    def make_invalid_api_key_error
      {
        :error => {
          :type => "invalid_request_error",
          :message => "Invalid API Key provided: invalid"
        }
      }
    end

    def make_invalid_exp_year_error
      {
        :error => {
          :code => "invalid_expiry_year",
          :param => "exp_year",
          :type => "card_error",
          :message => "Your card's expiration year is invalid"
        }
      }
    end

    def make_missing_id_error
      {
        :error => {
          :param => "id",
          :type => "invalid_request_error",
          :message => "Missing id"
        }
      }
    end

    def make_api_error
      {
        :error => {
          :type => "api_error"
        }
      }
    end

    def make_delete_discount_response
      {
        :deleted => true,
        :id => "di_test_coupon"
      }
    end
  end
end
