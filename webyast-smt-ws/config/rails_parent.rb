#--
# Copyright (c) 2009-2010 Novell, Inc.
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

class RailsParent
  
  def RailsParent.parent
    parent = ENV["RAILS_PARENT"]
    unless parent
      parent = File.expand_path(File.join('..','..','..', 'webservice'), File.dirname(__FILE__))
      unless File.directory?( parent || "" )
	$stderr.puts "Nope: #{parent}\nPlease set RAILS_PARENT environment"
	exit 1
      end
    end
    parent
  end
  
end
