class PaymentsController < ApplicationController
  before_filter :authenticate_user!

  include ActiveMerchant::Billing::Integrations

  def show
    @paypal_payment = Payment.find(params[:id])

    abort_if_not_owner(@paypal_payment) and return

    respond_to do |format|
      format.json { render json: @paypal_payment }
    end
  end

  def create
    @payment = ManualPayment.new(params[:payment])
    @payment.registration = current_registration
    if @payment.save
      redirect_to profile_url, notice: 'ManualPayment was successfully recorded.'
    else
      @registration = current_registration
      render 'users/show'
    end
  end

  def destroy
    payment = ManualPayment.find(params[:id])

    if !payment.nil? and payment.destroyable?(current_user)
      payment.destroy
      redirect_to profile_url, notice: 'Payment was removed.'
    else
      redirect_to profile_url, alert: 'Unauthorised access.'
    end
  end

  def checkout

    if params[:type] == 'pre_registration'
      pre_registration_payment = true
    else
      pre_registration_payment = false
    end

    @paypal_payment = PaypalPayment.generate current_registration, pre_registration_payment
    paypal_request = PaypalRequest.new paypal_request_params(@paypal_payment)

      setup_payment_options = [
        completed_payment_url(@paypal_payment.id),
        canceled_payment_url(@paypal_payment.id)
      ]

    redirect_to paypal_request.setup_payment *setup_payment_options

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace

      @payment = ManualPayment.new
      @paypal_payment.errors[:base] << "Paypal Payment error #{e.message}"
      @registration = current_registration
      render 'users/show' and return
  end

  def completed
    @paypal_payment = PaypalPayment.find(params[:id])

    #handle express checkout
    if params[:token] && params[:PayerID]

      paypal_request = PaypalRequest.new paypal_request_params(@paypal_payment)

      paypal_request.complete_payment params[:token], params[:PayerID]
    end

    abort_if_not_owner(@paypal_payment) and return
    render 'users/completed'
  end

  def canceled
    @paypal_payment = PaypalPayment.find(params[:id])
    abort_if_not_owner(@paypal_payment) and return
    @paypal_payment.cancel!
    render 'users/canceled'
  end

  private

  def log_notify notify
    logger.error "notify amount #{notify.amount}"
    logger.error "status: #{notify.complete?}"
  end

  def abort_if_not_owner(payment)
    redirect_to profile_url, alert: 'Error' if payment.nil? || !payment.owner?(current_user)
  end

  def paypal_request_params payment
    {
      payment: payment,
      logger: logger,
      request: request,
      paypal_login: current_tournament.paypal_login,
      paypal_password: current_tournament.paypal_password,
      paypal_signature: current_tournament.paypal_signature
    }

  end

end
