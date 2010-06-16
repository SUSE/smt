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

require 'yast_service'

# Group model, YastModel based
class Smt < BaseModel::Base
  attr_accessor :credentials
  attr_accessor :status

public

  def self.find
    ret = YastService.Call("YaPI::SMT::Read")
    Rails.logger.info "Read SMT config: #{ret.inspect}"
    return Smt.new(ret)
  end

  def update
    Rails.logger.info "Writing SMT config: #{self.inspect}"

    # do not pass nil via DBUS
    @credentials.each do |section, v|
	v.each do |key, value|
	    v[key] = "" if value.nil?
	end
    end

    args	= {
	"status"	=> [ "b", @status ],
	"credentials"	=> [ "a{sa{ss}}", @credentials]
    }

    Rails.logger.info "args: #{args.inspect}"
    YastService.Call("YaPI::SMT::Write", args)
  end

end
