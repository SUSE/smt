# encoding: utf-8

# File:	include/smt/complex.ycp
# Package:	Configuration of smt
# Summary:	Complex functions
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id: complex.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SmtComplexInclude
    def initialize_smt_complex(include_target)
      Yast.import "UI"
      textdomain "smt"

      Yast.import "SMTData"
      Yast.import "Directory"
      Yast.import "String"
      Yast.import "Report"

      @log_view_ID = nil
    end

    # Function for logging in the LogView widget.
    #
    # @param [String] text to be logged
    def LogThis(text)
      if UI.WidgetExists(Id(@log_view_ID))
        UI.ChangeWidget(Id(@log_view_ID), :LastLine, Ops.add(text, "\n"))
      end

      nil
    end

    # Gets the current credentials and use them to download a /repo/repoindex.xml
    # from the NUUrl. Progress is written to the LogView identified by
    # ID got as a function parameter.
    #
    # @param [Object] log_view widget ID
    def CredentialsTest(log_view)
      log_view = deep_copy(log_view)
      @log_view_ID = deep_copy(log_view)

      user = SMTData.GetCredentials("NU", "NUUser")
      pass = SMTData.GetCredentials("NU", "NUPass")
      url = SMTData.GetCredentials("NU", "NURegUrl")
      api = SMTData.GetCredentials("NU", "ApiType")

      user = "" if user == nil
      pass = "" if pass == nil

      if url == nil || url == ""
        # TRANSLATORS: error message
        Report.Error(_("No URL has been defined. Test cannot proceed."))
        return false
      end

      # File for writing the credentials
      test_file = Ops.add(Directory.tmpdir, "/curl_input_file")

      # File for downloading the /repo/repoindex.xml
      out_file = Ops.add(Directory.tmpdir, "/curl_output_file")

      # At first, credentials need to be written to a temporary file
      # because of security reasons. If used on a commandline, `ps`
      # could reveal them.

      # TRANSLATORS: LogView line
      LogThis(_("Creating a temporary file..."))

      cmd_exit = Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          Builtins.sformat(
            "echo \"[GLOBAL]\n" +
              "# URL for downloading repos/patches\n" +
              "url=%1?command=regdata&lang=en-US&version=1.0\n" +
              "# user/pass to be used for downloading\n" +
              "user=%2\n" +
              "pass=%3\n" +
              "apitype=%4\n" +
              "\" > '%5'",
            url,
            user,
            pass,
            api,
            String.Quote(test_file)
          )
        )
      )

      if cmd_exit != 0
        # TRANSLATORS: LogView line
        LogThis(
          Builtins.sformat(_("Cannot create a temporary file %1."), test_file)
        )

        return false
      end


      # TRANSLATORS: LogView line
      LogThis(_("Check credentials..."))
      cmd = Convert.to_map(
        SCR.Execute(
          path(".target.bash_output"),
          Builtins.sformat(
            "/usr/lib/YaST2/bin/regsrv-check-creds '%1'",
            String.Quote(test_file)
          )
        )
      )

      if Ops.get_integer(cmd, "exit", -1) != 0
        # TRANSLATORS: LogView line
        LogThis(_("Invalid credentials."))

        return false
      end

      # TRANSLATORS: LogView line
      LogThis(_("Success."))

      true
    end
  end
end
