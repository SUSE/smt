# encoding: utf-8

# File:	clients/smt.ycp
# Package:	Configuration of smt
# Summary:	Main file
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id: smt.ycp 27914 2006-02-13 14:32:08Z locilka $
#
# Main file for smt configuration. Uses all other files.
module Yast
  class SmtServerClient < Client
    def main
      Yast.import "UI"
      textdomain "smt"

      Yast.import "CommandLine"
      Yast.import "Mode"
      Yast.import "GetInstArgs"

      Yast.include self, "smt/wizard.rb"

      if Builtins.size(GetInstArgs.argmap) == 0 &&
          Ops.greater_than(Builtins.size(WFM.Args), 0)
        Mode.SetUI("commandline")
        Builtins.y2milestone("Mode CommandLine not supported, exiting...")
        # TRANSLATORS: error message - the module does not provide command line interface
        CommandLine.Print(
          _("There is no user interface available for this module.")
        )
        return :auto
      end

      # Registering new agents installed during the current
      # y2base run, bnc #384994
      if Mode.installation
        Builtins.y2milestone("Registering new SCR Agents")
        SCR.RegisterNewAgents
      end

      Convert.to_symbol(SMTSequence())
    end
  end
end

Yast::SmtServerClient.new.main
