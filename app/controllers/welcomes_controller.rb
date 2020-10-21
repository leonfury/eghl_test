class WelcomesController < ApplicationController
    before_action :set_payment, except: [:index, :checkout_page, :make_payment]
    skip_before_action :verify_authenticity_token, :only => [:await_payment_response_backend, :await_payment_response_redirect, :payment_response_success_redirect, :payment_response_fail_redirect]
    before_action :set_api

    def index        
    end

    def checkout_page
        @payment = Payment.create()
        @amount = params[:amount]

        @callback_url = "https://eghl-test.herokuapp.com/await_payment_response_backend/#{@payment.id}"
        @return_url = "https://eghl-test.herokuapp.com/await_payment_response_redirect/#{@payment.id}"
        @approval_url = "https://eghl-test.herokuapp.com/payment_response_success_redirect/#{@payment.id}"
        @unapproval_url = "https://eghl-test.herokuapp.com/payment_response_fail_redirect/#{@payment.id}"

        @payment_id = "TEST#{Time.now.strftime('%d%m%Y%H%M%S')}"
        @hashval = Digest::SHA2.hexdigest("#{@api_pass}#{@api_id}#{@payment_id}#{@return_url}#{@approval_url}#{@unapproval_url}#{@callback_url}#{@amount}MYR192.168.2.35780")
    end

    def make_payment
        @payment = Payment.create()

        @amount = params[:amount]

        @callback_url = "https://eghl-test.herokuapp.com/await_payment_response_backend/#{@payment.id}"
        @return_url = "https://eghl-test.herokuapp.com/await_payment_response_redirect/#{@payment.id}"
        @approval_url = "https://eghl-test.herokuapp.com/payment_response_success_redirect/#{@payment.id}"
        @unapproval_url = "https://eghl-test.herokuapp.com/payment_response_fail_redirect/#{@payment.id}"
        @payment_id = "TEST#{Time.now.strftime('%d%m%Y%H%M%S')}"
        
        req = Faraday.new do |f|
            f.adapter :net_http
        end
        

        @hashval = Digest::SHA2.hexdigest("#{@api_pass}#{@api_id}#{@payment_id}#{@return_url}#{@approval_url}#{@unapproval_url}#{@callback_url}#{@amount}MYR192.168.2.35780")
        
        req = req.post(
            "https://test2pay.ghl.com/IPGSG/Payment.aspx", 
            {
                "TransactionType": "SALE",
                "PymtMethod": "ANY",
                "ServiceID": @api_id, # for
                "PaymentID": @payment_id,
                "OrderNumber": @payment_id,
                "PaymentDesc": "-",
                "MerchantApprovalURL": @approval_url, # redirect path when payment successful
                "MerchantUnApprovalURL": @unapproval_url, # redirect path when payment fail
                "MerchantReturnURL": @return_url, # redirect path fallback 
                "MerchantCallbackURL": @callback_url, # eghl calls my backend
                "Amount": @amount,
                "CurrencyCode": "MYR",
                "HashValue": @hashval,
                "CustIP": "192.168.2.35",
                "CustName": "-",
                "CustEmail": "kliwaru@gmail.com",
                "CustPhone": "0173221955",
                "PageTimeout": "780",
            }.to_json,
            {
                "Content-Type" => "text/html"
            }
        )

        if req.status == 200
            puts "==============================================================="
            puts req.status
            puts "\n\n\n"
            puts req.headers
            puts "\n\n\n"
            puts req.body
            puts "\n\n\n"
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
        puts params
        redirect_to await_payment_response_path(@payment)
    end
    
    def payment_response_success_redirect
        puts params
        redirect_to payment_response_success_path(@payment)
    end

    def payment_response_fail_redirect
        puts params
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