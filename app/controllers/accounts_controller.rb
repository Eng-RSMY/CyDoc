class AccountsController < ApplicationController
  in_place_edit_for :booking, :amount_as_string
  in_place_edit_for :booking, :value_date
  in_place_edit_for :booking, :title
  in_place_edit_for :booking, :comments

  # Filters
  before_filter Accounting::ValueDateFilter
  
  def value_date_scope
    if session[:value_date_scope].nil?
      value_date_scope = Date.today.year
    end

    session[:value_date_scope]
  end

  def value_date_scope=(value)
    year = value.to_i
    session[:value_date_scope] = Date.new(year, 1, 1)..Date.new(year, 12, 31)
  end
  
  def set_value_date_filter
    self.value_date_scope = params[:year]
    
    redirect_to params[:uri]
  end
  
  # GET /accounts
  def index
    @accounts = Accounting::Account.paginate(:page => params['page'], :per_page => 20, :order => 'code')
    
    respond_to do |format|
      format.html {
        render :action => 'list'
      }
    end
  end

  # GET /accounts/1
  def show
    @account = Accounting::Account.find(params[:id])
    
    # We're getting hit by will_paginate bug #120 (http://sod.lighthouseapp.com/projects/17958/tickets/120-paginate-association-with-finder_sql-raises-typeerror)
    # This needs the will_paginate version from http://github.com/jwood/will_paginate/tree/master to work.
    @bookings = @account.bookings.paginate(:page => params['page'], :per_page => 20, :order => 'value_date, id')
    respond_to do |format|
      format.html {
        render :action => 'show'
      }
      format.js { }
    end
  end
end
