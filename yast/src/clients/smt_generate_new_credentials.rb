# encoding: utf-8

# File:	include/smt_generate_new_credentials.ycp
# Package:	Configuration of smt
# Summary:	Creates new NCCcredentials file
# See:		FATE #305541
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id:$
module Yast
  class SmtGenerateNewCredentialsClient < Client
    def main
      Yast.import "YSR"
      Yast.import "SMTData"

      if SMTData.SystemIsRegistered
        Builtins.y2warning("NCCcredentials file exists, not creating a new one")
        return :next
      end

      @initial_data = {
        "nooptional"   => 1,
        "nohwdata"     => 1,
        "norefresh"    => 1,
        "yastcall"     => 1,
        "restoreRepos" => 0
      }

      Builtins.y2milestone("Creating new NCCcredentials...")
      # FATE #305541
      Builtins.y2milestone("Returned: %1", YSR.init_ctx(@initial_data))

      :next
    end
  end
end

Yast::SmtGenerateNewCredentialsClient.new.main
