# encoding: utf-8

# File:	modules/SMTData.ycp
# Package:	Configuration of SMT
# Summary:	SMT global data and functions
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id:$
require "yast"

module Yast
  class SMTDataClass < Module
    def main
      Yast.import "UI"
      textdomain "smt"

      Yast.import "Message"
      Yast.import "Service"
      Yast.import "Report"
      Yast.import "FileUtils"
      Yast.import "String"
      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "PackageSystem"
      Yast.import "Wizard"
      Yast.import "Progress"
      Yast.import "Directory"
      Yast.import "ProductControl"

      @all_credentials = {}

      @smt_conf = "/etc/smt.conf"

      # script entered into a crontab
      @cron_mirror_script = "/usr/bin/smt-mirror.pl"
      # cron
      @path_to_cron = "/etc/smt.d/novell.com-smt"

      @path_to_ncc_sync_script = "/usr/sbin/smt-ncc-sync"
      @path_to_scc_sync_script = "/usr/sbin/smt-scc-sync"
      @user_for_sync_script = "root"

      @server_cert = "/etc/ssl/certs/YaST-CA.pem"
      @apache_cert = "/srv/www/htdocs/smt.crt"

      # own control file
      @smt_control_file = "/usr/share/YaST2/control/smt_control.xml"

      @smt_cron_settings = []

      @first_run = nil

      @first_run_file = Builtins.sformat(
        "%1/smt-already-adjusted",
        Directory.vardir
      )

      @smt_enabled = nil

      @smt_services = ["smt"]

      @smt_database = "mysql"

      @SCCcredentials_file = "/etc/zypp/credentials.d/SCCcredentials"
      @NCCcredentials_file = "/etc/zypp/credentials.d/NCCcredentials"

      @read_api_type = "NCC"

      @initial_config = false

      @_smt_user = nil
      @_smt_user_loaded = false

      @smt_enabled_initial = nil

      @ca_already_called = false

      @mysql_root_password = ""

      # bnc #389804
      @database_already_exists = false

      @initial_password = nil
    end

    def GetSCCcredentialsFile
      @SCCcredentials_file
    end

    def SystemIsRegistered
      FileUtils.Exists(@SCCcredentials_file) || FileUtils.Exist(@NCCCredentials_file)
    end

    def InitialConfig
      @initial_config
    end

    def ApiTypeChanged
      return false if InitialConfig()
      @read_api_type != Ops.get(@all_credentials, ["NU", "ApiType"], "NCC")
    end

    # Returns SMT user (LOCAL->smtUser) or nil if not set or erroneous
    def GetSMTUser
      return @_smt_user if @_smt_user_loaded == true

      @_smt_user_loaded = true

      @_smt_user = GetCredentials("LOCAL", "smtUser")
      if @_smt_user == nil || @_smt_user == ""
        # The default user
        @_smt_user = "smt"
      end


      user_exists = Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          Builtins.sformat(
            "/usr/bin/getent passwd '%1'",
            String.Quote(@_smt_user)
          )
        )
      )

      if user_exists == 0
        Builtins.y2milestone("User %1 exists", @_smt_user)
      else
        Builtins.y2error("User %1 doesn't exist!", @_smt_user)
        # Pop-up error message, %1 is replaced with the SMT user name,
        # %2 with the SMT config file
        Report.Error(
          Builtins.sformat(
            _(
              "SMT configuration is broken.\nLOCAL->smtUser %1 defined in %2 does not exist on the system."
            ),
            @_smt_user,
            @smt_conf
          )
        )
      end

      @_smt_user
    end

    # Returns whether a SCCcredentials file is accessible by SMT user
    # defined in LOCAL->smtUser. Returns nil if the file does not exist.
    #
    # @return [Boolean] whether accessible
    def CredentialsFileAccessible
      smt_user = GetSMTUser()
      return nil if smt_user == nil || smt_user == ""

      Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          Builtins.sformat(
            "echo '' | /usr/bin/sudo -S -u '%1' /bin/cat '%2'",
            String.Quote(smt_user),
            String.Quote(@SCCcredentials_file)
          )
        )
      ) == 0
    end

    # Adjusts SCCcredentials file permissions to be accessible
    # by SMT user defined in LOCAL->smtUser.
    # By default it adjusts file ACL to "read", or it changes the
    # file owner and permissions to smt:root.
    def AdjustSCCCredentialsFileAccess
      smt_user = GetSMTUser()

      if smt_user == nil || smt_user == ""
        Builtins.y2error("LOCAL->smtUser: %1", smt_user)
        return
      end

      cmd = Builtins.sformat(
        "/usr/bin/setfacl -m u:%1:r '%2'",
        smt_user,
        String.Quote(@SCCcredentials_file)
      )
      setfacl = Convert.to_integer(SCR.Execute(path(".target.bash"), cmd)) == 0
      Builtins.y2milestone("Adjusting file ACL (%1) returned %2", cmd, setfacl)

      # check whether the file is really accessible
      if CredentialsFileAccessible()
        if FileUtils.Exists("/usr/bin/getfacl")
          Builtins.y2milestone(
            "Credentials file is accessible now: %1",
            SCR.Execute(
              path(".target.bash_output"),
              Builtins.sformat(
                "/usr/bin/getfacl --access '%1' 2>/dev/null",
                String.Quote(@SCCcredentials_file)
              )
            )
          )
        else
          Builtins.y2milestone("Credentials file is accessible now")
        end
        return
      end

      cmd = Builtins.sformat(
        "/bin/chown %1:root '%2'; /bin/chmod ug+r '%2'",
        smt_user,
        String.Quote(@SCCcredentials_file)
      )
      chownchmod = Convert.to_integer(SCR.Execute(path(".target.bash"), cmd)) == 0
      Builtins.y2milestone(
        "Adjusting file access (%1) returned %2",
        cmd,
        chownchmod
      )

      nil
    end

    # Returns directory where the remote repositories are mirrored to.
    #
    # @return [String] directory
    def GetMirroredReposDirectory
      directory = GetCredentials("LOCAL", "MirrorTo")
      directory = "/srv/www/htdocs" if directory == nil

      Builtins.sformat("%1/repo/", directory)
    end

    # Returns whether the directory for mirroring repositories is writable
    # by the SMT user (or whether it was possible to make it so).
    #
    # @return [Boolean] (see above)
    def CheckAndAdjustMirroredReposAccess
      user = GetCredentials("DB", "user")
      user = "smt" if user == nil

      directory = GetMirroredReposDirectory()

      if Convert.to_boolean(
          SCR.Read(path(".smt.check_directory"), { "directory" => directory })
        ) == true
        return true
      end

      cmd = Builtins.sformat(
        "/bin/chown -R '%1:www' '%2' && /bin/chmod -R u+w '%2'",
        String.Quote(user),
        String.Quote(directory)
      )
      Builtins.y2milestone("Changing directory owner and permissions: %1", cmd)
      cmd_ret = Convert.to_map(SCR.Execute(path(".target.bash_output"), cmd))

      if Ops.get_integer(cmd_ret, "exit", -1) == 0
        Builtins.y2milestone("Successful: %1", cmd_ret)
        return true
      end

      Builtins.y2error(
        "Cannot change directory (%1) owner (%2) and permissions: %3",
        user,
        directory,
        cmd_ret
      )

      nil
    end

    # Checks (and adjusts) the SCCcredentials file permissions the be readable
    # by SMT user defined in LOCAL->smtUser. Returns if accessible and/or permissions
    # successfuly set. If the file does not exist, nil is returned.
    #
    # @return [Boolean] if succesful (file exists and is accessible)
    def CheckAndAdjustCredentialsFileAccess
      if SystemIsRegistered() != true
        Builtins.y2warning("Credentials file does not exist")
        return nil
      end

      state = CredentialsFileAccessible()
      Builtins.y2milestone(
        "Initial state: SCCcredentials are readable by SMT user: %1",
        state
      )

      if state == true
        return true
      elsif state == nil
        return false
      end

      AdjustSCCCredentialsFileAccess()

      state = CredentialsFileAccessible()
      Builtins.y2milestone(
        "Final state: SCCcredentials are readable by SMT user: %1",
        state
      )

      state
    end

    # Returns list of scheduled NU mirrorings.
    #
    # @return [Array<Hash>]
    #
    #
    # **Structure:**
    #
    #     [
    #        $[
    #          "command":"...",
    #          "day_of_month":"...",
    #          "day_of_week":"...",
    #          "hour":"...",
    #          "minute":"...",
    #          "month":"...",
    #          "user":"...",
    #        ],
    #        ...
    #      ]
    def GetCronSettings
      deep_copy(@smt_cron_settings)
    end

    # Adds new cron job.
    #
    # @param [Hash] new_cron_job
    #
    # @see #GetCronSettings()
    def AddNewCronJob(new_cron_job)
      new_cron_job = deep_copy(new_cron_job)
      Ops.set(new_cron_job, "user", @user_for_sync_script)

      @smt_cron_settings = Builtins.add(@smt_cron_settings, new_cron_job)

      nil
    end

    # Replaces the current cron job settings with new ones.
    #
    # @param [Fixnum] cron_job_id (offset)
    # @param [Hash] new_settings
    #
    # @see #GetCronSettings()
    def ReplaceCronJob(cron_job_id, new_settings)
      new_settings = deep_copy(new_settings)
      if cron_job_id == nil || Ops.less_than(cron_job_id, 0)
        Builtins.y2error("Undefined offset: %1", cron_job_id)
        return
      end

      Ops.set(new_settings, "user", @user_for_sync_script)

      Ops.set(@smt_cron_settings, cron_job_id, new_settings)

      nil
    end

    # Removes a current cron job.
    #
    # @param [Fixnum] cron_job_id (offset)
    #
    # @see #GetCronSettings()
    def RemoveCronJob(cron_job_id)
      if cron_job_id == nil || Ops.less_than(cron_job_id, 0)
        Builtins.y2error("Undefined offset: %1", cron_job_id)
        return
      end

      @smt_cron_settings = Builtins.remove(@smt_cron_settings, cron_job_id)

      nil
    end

    # Reads whether the configuration process has been already done.
    def ReadFirstRun
      if !FileUtils.Exists(@first_run_file)
        Builtins.y2milestone(
          "File %1 doesn't exist -> this is a first-run",
          @first_run_file
        )
        @first_run = true
      else
        Builtins.y2milestone("Not a first-time run...")
        @first_run = false
      end

      nil
    end

    # Writes that the configuration has been already done.
    def WriteFirstRunStatus
      if !SCR.Write(path(".target.ycp"), String.Quote(@first_run_file), [])
        Builtins.y2error("Cannot create file %1", @first_run_file)
      end

      nil
    end

    # Returns whether the current YaST run is the first run of the SMT configuration.
    def IsFirstRun
      @first_run
    end

    def ReadSMTServiceStatus
      @smt_enabled = false
      @smt_enabled_initial = false

      if IsFirstRun() == nil
        Builtins.y2error("Cannot evaluate first_run!")
      elsif IsFirstRun() == true
        @smt_enabled_initial = true
        @smt_enabled = true
        return
      end

      # default (changed later to false if something doesn't work)
      @smt_enabled = true
      @smt_enabled_initial = true

      Builtins.foreach(@smt_services) do |one_service|
        if !Service.Enabled(one_service)
          @smt_enabled = false
          @smt_enabled_initial = false
        end
      end

      nil
    end

    def GetSMTServiceStatus
      @smt_enabled
    end

    def SetSMTServiceStatus(new_status)
      if new_status == nil
        Builtins.y2error("Cannot set 'nil' status!")
        return
      end

      @smt_enabled = new_status

      nil
    end

    def WriteSMTServiceStatus
      if GetSMTServiceStatus() == true
        Builtins.foreach(@smt_services) do |one_service|
          # dependencies are now handled by systemd
          Service.Enable(one_service)
          Service.Start(one_service)
        end
      else
        Builtins.foreach(@smt_services) do |one_service|
          Service.Stop(one_service)
          Service.Disable(one_service)
        end
      end

      true
    end

    # Returns value for credentials entry.
    #
    # @see #SetCredentials
    #
    # @param [String] location
    # @param [String] entry_name
    # @return [String] value
    #
    # @example
    #   GetCredentials ("LOCAL", "MirrorTo") -> "/srv/www/htdocs"
    def GetCredentials(location, entry_name)
      if !Builtins.haskey(@all_credentials, location)
        Builtins.y2warning("Key %1 not defined", location)
        return ""
      elsif !Builtins.haskey(
          Ops.get(@all_credentials, location, {}),
          entry_name
        )
        Builtins.y2warning("Key %1/%2 not defined", location, entry_name)
        return ""
      end

      Ops.get(@all_credentials, [location, entry_name], "")
    end

    # Returns whether pair location/entry_name is known.
    #
    # @param [String] location
    # @param [String] entry_name
    # @return [Boolean] if known
    #
    # @example
    #   GetCredentialsDefined ("LOCAL", "MirrorTo") -> true
    #   GetCredentialsDefined ("LOCAL", "Unknown") -> false
    def GetCredentialsDefined(location, entry_name)
      Builtins.haskey(@all_credentials, location) &&
        Builtins.haskey(Ops.get(@all_credentials, location, {}), entry_name)
    end

    # Sets name/value credential pairs.
    #
    # @see #GetCredentials
    #
    # @param [String] location
    # @param [String] entry_name
    # @param [String] value
    #
    # @example
    #   SetCredentials ("LOCAL", "MirrorTo", "/srv/www/htdocs")
    def SetCredentials(location, entry_name, value)
      if !Builtins.haskey(@all_credentials, location)
        Ops.set(@all_credentials, location, {})
      end

      Ops.set(@all_credentials, [location, entry_name], value)

      nil
    end

    # Reads the current SMT credentials into the memory
    #
    # @return [Boolean] if successful
    def ReadCredentials
      @all_credentials = {}

      Ops.set(@all_credentials, "NU", {})

      Builtins.foreach(SCR.Dir(path(".smt_conf.section"))) do |section|
        section_path = Builtins.add(path(".smt_conf.value"), section)
        Builtins.foreach(SCR.Dir(section_path)) do |one_entry|
          SetCredentials(
            section,
            one_entry,
            Convert.to_string(SCR.Read(Builtins.add(section_path, one_entry)))
          )
        end
      end

      @read_api_type = Ops.get(@all_credentials, ["NU", "ApiType"], "NCC")
      if Ops.get(@all_credentials, ["NU", "NUUser"], "MIRRORUSER") == ""
        @initial_config = true
      end

      Builtins.y2milestone("Initial configuration: %1", @initial_config)
      true
    end

    # Writes the current credentials to the SMT configuration file.
    #
    # @return [Boolean] if successful
    def WriteCredentials
      failed = false

      Builtins.foreach(@all_credentials) do |base_key, current_credentials|
        Builtins.foreach(current_credentials) do |key, value|
          if ApiTypeChanged() &&
              Builtins.contains(["NUUrl", "NURegUrl", "ApiType"], key)
            # avoid writing these options, they get written by the migratino script
            Builtins.y2debug(
              "Not changing API information before customer center switch"
            )
          elsif !SCR.Write(
              Builtins.add(Builtins.add(path(".smt_conf.value"), base_key), key),
              value
            )
            Builtins.y2error("Cannot write to smt.conf/%1/%2", base_key, key)
            failed = true
          end
        end
      end

      if failed == false
        if !SCR.Write(path(".smt_conf"), nil)
          Builtins.y2error("Cannot write to smt.conf")
          failed = true
        end
      end

      failed == false
    end

    # Function checks and adjusts the apache configuration
    # to be usable by SMT.
    #
    # @return [Boolean] if successful
    def CheckAndAdjustApacheConfiguration
      apache_conf_file = "/etc/sysconfig/apache2"

      apache_conf_changed = false

      if !SCR.RegisterAgent(
          path(".http_server_conf"),
          term(:ag_ini, term(:SysConfigFile, apache_conf_file))
        )
        Builtins.y2error("Cannot register agent")
        Message.CannotWriteSettingsTo(apache_conf_file)
        return false
      end

      # "perl" in /etc/sysconfig/apache2:APACHE_MODULES
      ap_modules = Convert.to_string(
        SCR.Read(path(".http_server_conf.APACHE_MODULES"))
      )
      ap_modules_old = ap_modules

      ap_modules_l = Builtins.splitstring(ap_modules, " \t")
      ap_modules_l = Builtins.filter(ap_modules_l) do |one_ap_module|
        one_ap_module != nil && one_ap_module != ""
      end
      ap_modules_l = Builtins.toset(
        Convert.convert(
          Builtins.union(ap_modules_l, ["perl"]),
          :from => "list",
          :to   => "list <string>"
        )
      )
      ap_modules = Builtins.mergestring(ap_modules_l, " ")

      if ap_modules != ap_modules_old
        Builtins.y2milestone("Writing APACHE_MODULES")
        SCR.Write(path(".http_server_conf.APACHE_MODULES"), ap_modules)
        apache_conf_changed = true
      end

      # SSL in /etc/sysconfig/apache2:APACHE_SERVER_FLAGS
      ap_serflag = Convert.to_string(
        SCR.Read(path(".http_server_conf.APACHE_SERVER_FLAGS"))
      )
      ap_serflag_old = ap_serflag

      ap_serflag_l = Builtins.splitstring(ap_serflag, " \t")
      ap_serflag_l = Builtins.filter(ap_serflag_l) do |one_ap_serflag|
        one_ap_serflag != nil && one_ap_serflag != ""
      end
      ap_serflag_l = Builtins.toset(
        Convert.convert(
          Builtins.union(ap_serflag_l, ["SSL"]),
          :from => "list",
          :to   => "list <string>"
        )
      )
      ap_serflag = Builtins.mergestring(ap_serflag_l, " ")

      if ap_serflag != ap_serflag_old
        Builtins.y2milestone("Writing APACHE_SERVER_FLAGS")
        SCR.Write(path(".http_server_conf.APACHE_SERVER_FLAGS"), ap_serflag)
        apache_conf_changed = true
      end

      # Something has been changed
      # Apache conf needs writing
      # and Apache service needs restarting
      if apache_conf_changed
        Builtins.y2milestone("Writing sysconfig/apache conf")
        if !SCR.Write(path(".http_server_conf"), nil)
          Builtins.y2error("Cannot write apache2 conf")
          Message.CannotWriteSettingsTo(apache_conf_file)
          return false
        end
      end

      if !SCR.UnregisterAgent(path(".http_server_conf"))
        Builtins.y2error("Cannot unregister agent")
      end

      true
    end

    def RunSmallSync
      path_to_sync_script = @path_to_ncc_sync_script
      if GetCredentials("NU", "ApiType") == "SCC"
        path_to_sync_script = @path_to_scc_sync_script
      end
      if !FileUtils.Exists(path_to_sync_script)
        Builtins.y2error("Sync script doesn't exist")
        Report.Error(
          Builtins.sformat(
            _(
              "Synchronization script %1 does not exist.\n" +
                "\n" +
                "Please, check your SMT installation."
            ),
            path_to_sync_script
          )
        )
        return false
      end

      Builtins.y2milestone("Running sync: %1", path_to_sync_script)

      cmd_out = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), path_to_sync_script)
      )
      if Ops.get_integer(cmd_out, "exit", -1) != 0
        UI.OpenDialog(
          HBox(
            VSpacing(19),
            VBox(
              HSpacing(70),
              Left(Label(_("Running the synchronization script failed."))),
              RichText(
                Opt(:hstretch, :vstretch),
                Builtins.sformat(
                  _(
                    "<p><b><big>Details:</big></b></p>\n" +
                      "                                         <p><b>stdout:</b><br><pre>%1</pre></p>\n" +
                      "                                         <p><b>stderr:</b><br><pre>%2</pre></p>"
                  ),
                  Ops.get_string(cmd_out, "stdout", ""),
                  Ops.get_string(cmd_out, "stderr", "")
                )
              ),
              PushButton(Id(:ok), Opt(:default, :key_F10), Label.OKButton)
            )
          )
        )
        UI.UserInput
        UI.CloseDialog
      end

      true
    end

    # Reads SMT cron settings and fills up internal data variables.
    def ReadCronSettings
      if !FileUtils.Exists(@path_to_cron)
        Builtins.y2milestone("Creating file %1", @path_to_cron)
        cmd = Convert.to_map(
          SCR.Execute(
            path(".target.bash_output"),
            Builtins.sformat("touch '%1'", String.Quote(@path_to_cron))
          )
        )

        if Ops.get_integer(cmd, "exit", -1) != 0
          Builtins.y2error("Cannot create file %1: %2", @path_to_cron, cmd)
        end
      end

      @smt_cron_settings = Convert.convert(
        SCR.Read(path(".smt_cron")),
        :from => "any",
        :to   => "list <map>"
      )

      nil
    end

    def CronRandomize
      return if !IsFirstRun()

      Builtins.y2milestone("First-run: randomizing cron times")

      # to get different 'random' numbers :->>>
      Builtins.srandom

      hour_smt_daily = 20
      minute_smt_daily = 0

      # randomize smt-daily
      counter = -1
      Builtins.foreach(GetCronSettings()) do |one_cron_job|
        counter = Ops.add(counter, 1)
        if Builtins.regexpmatch(
            Ops.get_string(one_cron_job, "command", ""),
            "smt-daily"
          )
          # 20:00 - 02:59
          hour_calc = Ops.subtract(Builtins.random(7), 4)
          if Ops.greater_or_equal(hour_calc, 0)
            hour_smt_daily = hour_calc
          else
            hour_smt_daily = Ops.add(24, hour_calc)
          end

          minute_smt_daily = Builtins.random(59)

          Ops.set(one_cron_job, "hour", Builtins.tostring(hour_smt_daily))
          Ops.set(one_cron_job, "minute", Builtins.tostring(minute_smt_daily))
          Builtins.y2milestone(
            "smt-daily randomized, hour: %1, minute: %2",
            Ops.get_string(one_cron_job, "hour", ""),
            Ops.get_string(one_cron_job, "minute", "")
          )
          ReplaceCronJob(counter, one_cron_job)
        end
      end

      # randomize smt-gen-report
      counter = -1
      Builtins.foreach(GetCronSettings()) do |one_cron_job|
        counter = Ops.add(counter, 1)
        if Builtins.regexpmatch(
            Ops.get_string(one_cron_job, "command", ""),
            "smt-gen-report"
          )
          # 4:00 - 6:59
          hour_report = Ops.add(Builtins.random(3), 4)
          Ops.set(one_cron_job, "hour", Builtins.tostring(hour_report))
          Ops.set(one_cron_job, "minute", Builtins.tostring(minute_smt_daily))
          Builtins.y2milestone(
            "smt-gen-report randomized, hour: %1, minute: %2",
            Ops.get_string(one_cron_job, "hour", ""),
            Ops.get_string(one_cron_job, "minute", "")
          )
          ReplaceCronJob(counter, one_cron_job)
        end
      end

      # randomize smt-repeated-register
      # 450 (seconds) == 7.5 minutes
      SetCredentials(
        "LOCAL",
        "rndRegister",
        Builtins.tostring(Builtins.random(450))
      )

      # take care the the post script do not reschedule again
      SCR.Execute(
        path(".target.bash"),
        "touch /var/lib/smt/RESCHEDULE_SYNC_DONE"
      )

      nil
    end

    def WriteCronSettings
      service_name = "cron"

      if @smt_cron_settings == nil || Builtins.size(@smt_cron_settings) == 0
        if FileUtils.Exists(@path_to_cron) &&
            !Convert.to_boolean(
              SCR.Execute(path(".target.remove"), @path_to_cron)
            )
          Builtins.y2error("Cannot remove %1 cron-file", @path_to_cron)
        else
          Builtins.y2milestone("No cron settings at all")
          return true
        end
      end

      if !SCR.Write(path(".smt_cron"), @smt_cron_settings)
        Builtins.y2error("Writing cron failed")
        Report.Error(_("Cannot write cron settings."))
        return false
      end

      if Ops.greater_than(Builtins.size(@smt_cron_settings), 0)
        if !Service.Enabled(service_name)
          Service.Enable(service_name)
        else
          Builtins.y2milestone("Service cron already enabled, skipping ...")
        end
      end

      if !Service.Restart(service_name)
        Builtins.y2error("Reloading %1 failed", service_name)
        # TRANSLATORS: error message, %1 is replaced with a service-name
        Report.Error(
          Builtins.sformat(_("Reloading service %1 has failed."), service_name)
        )
        return false
      end

      true
    end

    # Handles a missing CA certificate.
    # Returns boolean value whether CA checking should be finished.
    #
    # @return [Boolean] whether to finish the CA checking
    def HandleMissingCACert
      Builtins.y2milestone("CA file %1 doesn't exist", @server_cert)
      ca_mgm_package = "yast2-ca-management"

      if Popup.AnyQuestion(
          # TRANSLATORS: Pop-up question headline
          _("Missing Server Certificate"),
          # TRANSLATORS: Pop-up question, %1 is replaced with a file name
          Builtins.sformat(
            _(
              "Server certificate %1 does not exist.\n" +
                "Would you like to run CA management to create one?\n" +
                "\n" +
                "The server certificate is vitally important for the NU server to support SSL.\n"
            ),
            @server_cert
          ),
          _("&Run CA management"),
          _("&Skip"),
          @ca_already_called ? :focus_no : :focus_yes
        )
        # Package needs to be installed
        if PackageSystem.CheckAndInstallPackagesInteractive([ca_mgm_package])
          Builtins.y2milestone("Running ca_mgm")
          @ca_already_called = true

          Wizard.OpenNextBackDialog
          progress_orig = Progress.set(false)

          # bnc #400782
          # Custom control file can make ProductControl not to find anything
          previous_custom_control_file = ProductControl.custom_control_file
          if previous_custom_control_file != ""
            Builtins.y2milestone(
              "Previous custom_control_file: %1",
              previous_custom_control_file
            )
          end

          # bnc #471162
          # Use own control file (do not depend on the system one which might be missing)
          ProductControl.custom_control_file = @smt_control_file
          ProductControl.Init

          # Call installation proposal (service: CA)
          ret = WFM.call("inst_proposal", [{ "proposal" => "smt_ca" }])

          Builtins.y2milestone(
            "Restoring previous custom_control_file: %1",
            previous_custom_control_file
          )
          ProductControl.custom_control_file = previous_custom_control_file
          ProductControl.Init

          Builtins.y2milestone("Service proposal returned: %1", ret)
          Progress.set(progress_orig)
          Wizard.CloseDialog

          return false 
          # Package is not installed and couldn't be installed
        else
          Report.Error(
            Builtins.sformat(
              _("Cannot run CA management because package %1 is not installed."),
              ca_mgm_package
            )
          )
          return true
        end
      else
        Builtins.y2warning("User doesn't want to run CA management.")
        return true
      end
    end


    # Function migrates SMT between NCC and SCC
    #
    # @return [Boolean] if successful
    def MigrateCustomerCenter
      ret = {}
      if Ops.get(@all_credentials, ["NU", "ApiType"], "NCC") == "NCC"
        ret = Convert.convert(
          SCR.Execute(
            path(".target.bash_output"),
            "/usr/sbin/smt-scc-ncc-migration"
          ),
          :from => "any",
          :to   => "map <string, any>"
        )
      else
        ret = Convert.convert(
          SCR.Execute(
            path(".target.bash_output"),
            "/usr/sbin/smt-ncc-scc-migration"
          ),
          :from => "any",
          :to   => "map <string, any>"
        )
      end
      if Ops.get_integer(ret, "exit", -1) != 0
        Report.Error(_("Changing the customer center back-end failed"))
        Builtins.y2error("Customer center back-end migration output: %1", ret)
        return false
      end
      Builtins.y2debug("Customer center back-end migration output: %1", ret)
      true
    end

    # Function checks whether a server certificate exists and copies it
    # to the apache directory. If a server certificate doesn't exist,
    # user is offered to run the CA management.
    #
    # @return [Boolean] if successful
    def WriteCASettings
      ret = false

      # check the existence of file and offer to run CA managament
      # if it doesn't then check the existence again... and again...
      while true
        # Server certificate is missing
        if !FileUtils.Exists(@server_cert)
          break if HandleMissingCACert() 

          # Server certificate exists
        else
          ret = true
          break
        end
      end

      ret
    end

    def AskForRootPassword(message)
      ret = nil

      UI.OpenDialog(
        VBox(
          VSpacing(1),
          Heading(_("Database root Password Required")),
          VSpacing(1),
          HBox(
            HSpacing(2),
            VBox(
              message != "" && message != nil ?
                VBox(Label(message), VSpacing(1)) :
                Empty(),
              Password(Id(:root_password), _("Enter the MySQL root &Password"))
            ),
            HSpacing(2)
          ),
          VSpacing(1),
          HBox(
            PushButton(Id(:ok), Opt(:default, :key_F10), Label.OKButton),
            HSpacing(2),
            PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton)
          ),
          VSpacing(1)
        )
      )

      UI.SetFocus(Id(:root_password))

      user_ret = UI.UserInput
      if user_ret == :ok
        ret = Convert.to_string(UI.QueryWidget(Id(:root_password), :Value))
      end

      UI.CloseDialog

      ret
    end

    # @return [Boolean] whether to try again
    def HandleSMTDBSetupRetcode(retcode_was)
      # 2 : Cannot read the SMT configuration file
      if retcode_was == 2
        return Report.AnyQuestion(
          Builtins.sformat(_("Unable to read %1"), "/etc/smt.conf"),
          _(
            "SMT was not able to read the configuration file.\n" +
              "Please, check the file and click Retry.\n" +
              "\n" +
              "To skip this, click Skip.\n"
          ),
          _("&Retry"),
          _("&Skip"),
          :yes_button
        ) 

        # 4 : Cannot connect to database (wrong mysql root password?)
      elsif retcode_was == 4
        @mysql_root_password = AskForRootPassword(
          _(
            "SMT was not able to connect to the database.\nThe root password was probably wrong.\n"
          )
        )
        if @mysql_root_password != nil
          return true
        else
          return false
        end 

        # 5 : SMT database already exists
      elsif retcode_was == 5
        @database_already_exists = true
        Builtins.y2milestone("SMT database already exists")
        return false 

        # 7 : Cannot create Database smt
      elsif retcode_was == 7
        return Report.AnyQuestion(
          _("Cannot create database"),
          _(
            "SMT was not able to create the database.\nClick Retry to try again.\n"
          ),
          _("&Retry"),
          _("&Skip"),
          :yes_button
        ) 

        # 21: Database migration failed
      elsif retcode_was == 21
        return Report.AnyQuestion(
          _("Database migration failed"),
          _(
            "SMT has failed to migrate the database.\nClick Retry to try again.\n"
          ),
          _("&Retry"),
          _("&Skip"),
          :yes_button
        )
      else
        Builtins.y2warning("Return code %1 not handled", retcode_was)
      end

      false
    end

    def AskForNewRootPassword
      ret = nil

      UI.OpenDialog(
        VBox(
          VSpacing(1),
          Heading(_("Adjusting New Database root Password")),
          VSpacing(1),
          HBox(
            HSpacing(2),
            VBox(
              Label(
                _(
                  "The current MySQL root password is empty.\n" +
                    "\n" +
                    "                                          For security reasons, please, set a new one."
                )
              ),
              VSpacing(1),
              Password(Id(:new_root_password_1), _("New MySQL root &Password")),
              Password(Id(:new_root_password_2), _("New Password &Again"))
            ),
            HSpacing(2)
          ),
          VSpacing(1),
          HBox(
            PushButton(Id(:ok), Opt(:default, :key_F10), Label.OKButton),
            HSpacing(2),
            PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton)
          ),
          VSpacing(1)
        )
      )

      UI.SetFocus(Id(:new_root_password_1))

      while true
        user_ret = UI.UserInput

        if user_ret == :cancel
          ret = nil
          break
        elsif user_ret == :ok
          pass_1 = Convert.to_string(
            UI.QueryWidget(Id(:new_root_password_1), :Value)
          )
          pass_2 = Convert.to_string(
            UI.QueryWidget(Id(:new_root_password_2), :Value)
          )

          if pass_1 == nil || pass_1 == ""
            UI.SetFocus(Id(:new_root_password_1))
            Report.Error(_("Set up a new password, please."))
            next
          elsif pass_1 != pass_2
            UI.SetFocus(Id(:new_root_password_2))
            Report.Error(_("The first and the second password do not match."))
            next
          end

          Builtins.y2milestone("New password provided")
          ret = pass_1
          break
        end
      end

      UI.CloseDialog

      ret
    end

    def GetMysqlHostname
      hostname = "localhost"

      db_config = GetCredentials("DB", "config")
      Builtins.foreach(Builtins.splitstring(db_config, ";")) do |one_db_item|
        if Builtins.regexpmatch(one_db_item, ".*host=.*")
          hostname = Builtins.regexpsub(one_db_item, ".*host=(.*)", "\\1")
          Builtins.y2milestone("Hostname found: %1", hostname)
          raise Break
        end
      end

      hostname
    end

    def SetNewRootPassword(new_mysql_root_password)
      Builtins.y2milestone("Adjusting new root password")

      mysql_command = Builtins.sformat(
        "SET PASSWORD FOR root@%1=PASSWORD('%2');",
        GetMysqlHostname(),
        String.Quote(new_mysql_root_password)
      )

      mysql_command_file = Builtins.sformat(
        "%1/smt-rootpass-filename",
        Directory.tmpdir
      )
      SCR.Write(path(".target.string"), mysql_command_file, "")
      # rw only for owner
      SCR.Execute(
        path(".target.bash"),
        Builtins.sformat("chmod 0600 '%1'", String.Quote(mysql_command_file))
      )
      SCR.Write(path(".target.string"), mysql_command_file, mysql_command)

      cmd_cmd = Builtins.sformat(
        "mysql -u root -h %1 < '%2'",
        GetMysqlHostname(),
        mysql_command_file
      )
      cmd = Convert.to_map(SCR.Execute(path(".target.bash_output"), cmd_cmd))
      if Ops.get_integer(cmd, "exit", -1) != 0
        Builtins.y2error("Cannot set new root password: %1", cmd)
        Report.Error(_("Setting up new MySQL root password failed."))
        return false
      end

      Builtins.y2milestone("Successful %1", cmd)
      true
    end

    def StartDatabaseIfNeeded
      if !Service.Start(@smt_database)
        Builtins.y2error("Cannot start database")
        return false
      end

      true
    end

    def WriteDatabaseSettings
      # Keeping the service stopped
      if @smt_enabled_initial == false && !GetSMTServiceStatus()
        Builtins.y2milestone("SMT is disabled, not adjusting database...")
        return true
      end

      # check whether mysql root password is empty
      root_password_empty = Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          Builtins.sformat(
            "echo 'show databases;' | mysql -u root -h %1 2>/dev/null",
            GetMysqlHostname()
          )
        )
      ) == 0

      # root password is empty
      # ask user to set a new one
      if root_password_empty
        # exception: SMT user is root
        if GetSMTUser() == "root"
          Builtins.y2warning("SMT user is root, using root's new password")
          @mysql_root_password = GetCredentials("DB", "pass")
        else
          Builtins.y2warning("mysql root password is empty")
          @mysql_root_password = AskForNewRootPassword()

          if @mysql_root_password == nil
            Builtins.y2error("New password not provided")
            return false
          end
        end

        if !SetNewRootPassword(@mysql_root_password)
          Builtins.y2warning("Unable to set new root password, using empty one")
          @mysql_root_password = ""
        end 
        # root password has been already set
      else
        Builtins.y2milestone(
          "mysql root password is not empty, asking for it..."
        )
        @mysql_root_password = AskForRootPassword(
          _("SMT needs to set up the database.")
        )
        if @mysql_root_password == nil
          Builtins.y2error("Mysql-root password not provided")
          return false
        end
      end

      smt_command_file = Builtins.sformat(
        "%1/smt-command-filename",
        Directory.tmpdir
      )
      SCR.Write(path(".target.string"), smt_command_file, "")
      # rw only for owner
      SCR.Execute(
        path(".target.bash"),
        Builtins.sformat("chmod 0600 '%1'", String.Quote(smt_command_file))
      )

      ret = false

      while true
        # /usr/lib/SMT/bin/smt-db setup --yast
        # * mysql root password
        # * smt user name
        # * smt user password
        # * verify smt user password
        smt_db_command = Builtins.sformat(
          "%1\n%2\n%3\n%4\n",
          @mysql_root_password,
          GetCredentials("DB", "user"),
          GetCredentials("DB", "pass"),
          GetCredentials("DB", "pass")
        )

        # always write it again, bnc 387414
        SCR.Write(path(".target.string"), smt_command_file, smt_db_command)

        Builtins.y2milestone("Calling smt-db setup")
        retcode = Convert.to_integer(
          SCR.Execute(
            path(".target.bash"),
            Builtins.sformat(
              "/usr/lib/SMT/bin/smt-db setup --yast < '%1'",
              smt_command_file
            )
          )
        )
        Builtins.y2milestone("smt-db setup returned: %1", retcode)

        if retcode == 0
          Builtins.y2milestone("Success")
          ret = true
          break
        else
          if !HandleSMTDBSetupRetcode(retcode)
            Builtins.y2milestone("Finishing SMT-DB setup")
            break
          end
        end
      end

      SCR.Execute(path(".target.remove"), smt_command_file)

      ret
    end

    # Function remembers initial SMT-user password
    def StorePasswordTMP
      if @initial_password == nil
        @initial_password = GetCredentials("DB", "pass")
      else
        Builtins.y2error("Initial password already set!")
      end

      nil
    end

    # Function changes the SMT-user passowrd if different
    # than the initial one
    def ChangePasswordIfDifferent
      # Keeping the service stopped
      if @smt_enabled_initial == false && !GetSMTServiceStatus()
        Builtins.y2milestone("SMT is disabled, not adjusting database...")
        return true
      end

      # bnc #389804
      # exit 5 from smt-db setup means that database exists and cpw
      # should be called
      if @database_already_exists != true
        Builtins.y2milestone(
          "Database and user were just created, skipping cpw ..."
        )
        return true
      end

      new_password = GetCredentials("DB", "pass")

      if @initial_password == new_password
        Builtins.y2milestone("SMT-user password is the same")
        return true
      end

      # /usr/lib/SMT/bin/smt-db cpw
      # * mysql root password
      # * smt user name
      # * smt user password
      # * verify smt user password
      smt_cpw_command = Builtins.sformat(
        "%1\n%2\n%3\n",
        @initial_password,
        GetCredentials("DB", "pass"),
        GetCredentials("DB", "pass")
      )

      smt_command_file = Builtins.sformat(
        "%1/smt-cpw-command-filename",
        Directory.tmpdir
      )
      SCR.Write(path(".target.string"), smt_command_file, "")
      # rw only for owner
      SCR.Execute(
        path(".target.bash"),
        Builtins.sformat("chmod 0600 '%1'", String.Quote(smt_command_file))
      )
      SCR.Write(path(".target.string"), smt_command_file, smt_cpw_command)

      Builtins.y2milestone("Calling smt-db cpw")
      retcode = Convert.to_integer(
        SCR.Execute(
          path(".target.bash"),
          Builtins.sformat(
            "/usr/lib/SMT/bin/smt-db cpw --yast < '%1'",
            smt_command_file
          )
        )
      )
      Builtins.y2milestone("smt-db setup returned: %1", retcode)

      if retcode != 0
        Report.Error(_("Cannot change SMT user password."))
        return false
      else
        return true
      end

      SCR.Execute(path(".target.remove"), smt_command_file)
    end

    publish :function => :GetSCCcredentialsFile, :type => "string ()"
    publish :function => :SystemIsRegistered, :type => "boolean ()"
    publish :function => :InitialConfig, :type => "boolean ()"
    publish :function => :ApiTypeChanged, :type => "boolean ()"
    publish :function => :GetCredentials, :type => "string (string, string)"
    publish :function => :GetMirroredReposDirectory, :type => "string ()"
    publish :function => :CheckAndAdjustMirroredReposAccess, :type => "boolean ()"
    publish :function => :CheckAndAdjustCredentialsFileAccess, :type => "boolean ()"
    publish :function => :GetCronSettings, :type => "list <map> ()"
    publish :function => :AddNewCronJob, :type => "void (map)"
    publish :function => :ReplaceCronJob, :type => "void (integer, map)"
    publish :function => :RemoveCronJob, :type => "void (integer)"
    publish :function => :ReadFirstRun, :type => "void ()"
    publish :function => :WriteFirstRunStatus, :type => "void ()"
    publish :function => :IsFirstRun, :type => "boolean ()"
    publish :function => :ReadSMTServiceStatus, :type => "void ()"
    publish :function => :GetSMTServiceStatus, :type => "boolean ()"
    publish :function => :SetSMTServiceStatus, :type => "void (boolean)"
    publish :function => :WriteSMTServiceStatus, :type => "boolean ()"
    publish :function => :GetCredentialsDefined, :type => "boolean (string, string)"
    publish :function => :SetCredentials, :type => "void (string, string, string)"
    publish :function => :ReadCredentials, :type => "boolean ()"
    publish :function => :WriteCredentials, :type => "boolean ()"
    publish :function => :CheckAndAdjustApacheConfiguration, :type => "boolean ()"
    publish :function => :RunSmallSync, :type => "boolean ()"
    publish :function => :ReadCronSettings, :type => "void ()"
    publish :function => :CronRandomize, :type => "void ()"
    publish :function => :WriteCronSettings, :type => "boolean ()"
    publish :function => :MigrateCustomerCenter, :type => "boolean ()"
    publish :function => :WriteCASettings, :type => "boolean ()"
    publish :function => :StartDatabaseIfNeeded, :type => "boolean ()"
    publish :function => :WriteDatabaseSettings, :type => "boolean ()"
    publish :function => :StorePasswordTMP, :type => "void ()"
    publish :function => :ChangePasswordIfDifferent, :type => "boolean ()"
  end

  SMTData = SMTDataClass.new
  SMTData.main
end
