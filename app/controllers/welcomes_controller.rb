class WelcomesController < ApplicationController
    before_action :set_payment, except: [:index, :checkout_page, :make_payment]
    skip_before_action :verify_authenticity_token, :only => [:await_payment_response_backend, :await_payment_response_redirect, :payment_response_success_redirect, :payment_response_fail_redirect]
    before_action :set_api

    def index        
    end

    def checkout_page
        @payment = Payment.create()

        @callback_url = "https://eghl-test.herokuapp.com/await_payment_response_backend/#{@payment.id}"
        @return_url = "https://eghl-test.herokuapp.com/await_payment_response_redirect/#{@payment.id}"
        @approval_url = "https://eghl-test.herokuapp.com/payment_response_success_redirect/#{@payment.id}"
        @unapproval_url = "https://eghl-test.herokuapp.com/payment_response_fail_redirect/#{@payment.id}"

        @payment_id = "TESTHOST#{Time.now.strftime("%d%m%Y%H%M")}"
        @hashval = Digest::SHA2.hexdigest("#{@api_pass}#{@api_id}#{@payment_id}#{@return_url}#{@approval_url}#{@unapproval_url}#{@callback_url}228.00MYR192.168.2.35780")
    end

    def make_payment
        @payment = Payment.create()
        req = Faraday.new do |f|
            f.adapter :net_http
        end

        approve_url =
        fail_url =
        return_url =
        callback_url = 
        hashval = Digest::SHA2.hexdigest("#{@api_pass}#{@api_id}A3BHPF20171001018074S2SS2SS2SS2S299.48MYR192.168.1.1")

        req = req.post(
            "https://test2pay.ghl.com/IPGSG/Payment.aspx", 
            {
                "TransactionType": "SALE",
                "PymtMethod": "ANY",
                "ServiceID": @api_id, # for
                "PaymentID": "A3BHPF20171001018074",
                "OrderNumber": "A3BHPF",
                "PaymentDesc": "-",
                "MerchantApprovalURL": "S2S", # redirect path when payment successful
                "MerchantUnApprovalURL": "S2S", # redirect path when payment fail
                "MerchantReturnURL": "S2S", # redirect path fallback 
                "MerchantCallbackURL": "S2S", # eghl calls my backend
                "Amount": "299.48",
                "CurrencyCode": "MYR",
                "HashValue": hashval,
                "CustIP": "192.168.1.1",
                "CustName": "-",
                "CustEmail": "kliwaru@gmail.com",
                "CustPhone": "0173221955",
            }.to_json,
            {
                "Content-Type" => "text/html"
            }
        )

        if req.status == 200
            render inline: req.body
        else
            notice = "SOMETHING WENT WRONG!"
            redirect_to root_path
        end
    end

    # callback_url for billplz
    def await_payment_response_backend 
        @payment.update(details: params)
        if params["paid"] == "true"
            @payment.update(payment_status: "success")
        end
    end

    # redirect url
    def await_payment_response
    end

    # from frontend AJAX
    def check_payment_status
        render :json => { status: @payment.payment_status }
    end

    def payment_response_success
    end

    def payment_response_fail
    end

    def await_payment_response_redirect
        redirect_to await_payment_response_path(@payment)
    end
    
    def payment_response_success_redirect
        redirect_to payment_response_success_path(@payment)
    end

    def payment_response_fail_redirect
        redirect_to payment_response_fail_path(@payment)
    end


    private
    def set_payment
        @payment = Payment.find(params[:id])
    end

    def set_api
        @api_id = "sit"
        @api_pass = "sit12345"
    end
end