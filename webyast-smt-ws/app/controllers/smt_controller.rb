#--
# Copyright (c) 2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

class SmtController < ApplicationController
  
  before_filter :login_required

  def show
    permission_check "org.opensuse.yast.modules.yapi.smt.read"
    smt = Smt.find

    # check for nil
    smt = {} if smt.nil?

    respond_to do |format|
      format.xml  { render :xml => smt.to_xml}
      format.json { render :json => smt.to_json }
    end
  end

  def update
    permission_check "org.opensuse.yast.modules.yapi.smt.write"
    root = params["smt"]
    if root == nil || root == {}
      # TODO: error handling
    end

    smt = Smt.find
    smt.load root
    smt.save

    respond_to do |format|
      format.xml  { render :xml => smt.to_xml}
      format.json { render :json => smt.to_json }
    end
  end

  # see update
  def create
    update
  end

end
