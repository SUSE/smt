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

# data we need on the first screen:
# enable/disable smt
# punch hole in firewall
# NCC credentials
# NCC email used for registration
# SMT server URL

  attr_accessor :smt
  attr_accessor :firewall
  attr_accessor :secrets
  attr_accessor :db

# TODO: add validations like this:
#  validates_presence_of     :members
#  validates_inclusion_of    :group_type, :in => ["system","local"]
#  validates_format_of       :cn, :with => /[a-z]+/
#  validates_format_of       :old_cn, :with => /[a-z]+/
#  validates_numericality_of :gid

public

  def self.find
    ret = YastService.Call("SlmsServerConfig::Read")
    Rails.logger.info "Read SLMS config: #{ret.inspect}"
    return Slms.new(ret)
  end

  def update
    Rails.logger.info "Writing SLMS config: #{self.inspect}"
    YastService.Call("SlmsServerConfig::Write", { 'slms' => @slms, 'secrets' => @secrets,
        'db' => @db, 'firewall' => @firewall, 'global' => @global
    })
  end

end
