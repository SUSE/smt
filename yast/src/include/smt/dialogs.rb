# encoding: utf-8

# File:	include/smt/dialogs.ycp
# Package:	Configuration of smt
# Summary:	Dialogs definitions
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id: dialogs.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SmtDialogsInclude

    REQUIRED_PACKAGES = [ "smt" ]

    def initialize_smt_dialogs(include_target)
      Yast.import "UI"
      textdomain "smt"

      Yast.include include_target, "smt/helps.rb"
      Yast.include include_target, "smt/complex.rb"

      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "SMTData"
      Yast.import "Label"
      Yast.import "Confirm"
      Yast.import "Progress"
      Yast.import "Message"
      Yast.import "PackageSystem"
      Yast.import "SuSEFirewall"
      Yast.import "FileUtils"
      Yast.import "GPG"
      Yast.import "Hostname"
      Yast.import "Package"

      @sl = 100

      @text_mode = UI.TextMode

      @smt_cron_scripts = {
        "/usr/lib/SMT/bin/smt-repeated-register"    => _("SCC Registration"),
        "/usr/lib/SMT/bin/smt-daily"                => _(
          "Synchronization of Updates"
        ),
        "/usr/lib/SMT/bin/smt-gen-report"           => _(
          "Generation of Reports"
        ),
        "/usr/lib/SMT/bin/smt-run-jobqueue-cleanup" => _("Job Queue Cleanup")
      }

      @status_icons_dir = "/usr/share/icons/hicolor/16x16/status"

      @smt_status_icons = {
        # clients
        "critical"            => Builtins.sformat(
          "%1/client-%2.xpm",
          @status_icons_dir,
          "critical"
        ),
        "unknown"             => Builtins.sformat(
          "%1/client-%2.xpm",
          @status_icons_dir,
          "unknown"
        ),
        "updates-available"   => Builtins.sformat(
          "%1/client-%2.xpm",
          @status_icons_dir,
          "updates-available"
        ),
        "up-to-date"          => Builtins.sformat(
          "%1/client-%2.xpm",
          @status_icons_dir,
          "up-to-date"
        ),
        # repositories
        "repo-up-to-date"     => Builtins.sformat(
          "%1/repo-%2.xpm",
          @status_icons_dir,
          "up-to-date"
        ),
        "repo-not-up-to-date" => Builtins.sformat(
          "%1/repo-%2.xpm",
          @status_icons_dir,
          "not-up-to-date"
        )
      }

      @smt_patch_icons = {
        # current status
        "a" => Builtins.sformat(
          "%1/patch-%2.xpm",
          @status_icons_dir,
          "used"
        ),
        "f" => Builtins.sformat(
          "%1/patch-%2.xpm",
          @status_icons_dir,
          "not-used"
        ),
        # current action (to be removed, to be used)
        "-" => Builtins.sformat(
          "%1/patch-%2.xpm",
          @status_icons_dir,
          "remove"
        ),
        "+" => Builtins.sformat("%1/patch-%2.xpm", @status_icons_dir, "use")
      }

      # patch categories translation map
      @patch_categories = {
        # Patch category
        "recommended" => _("Recommended"),
        # Patch category
        "optional"    => _("Optional"),
        # Patch category
        "security"    => _("Security")
      }

      # BNC #513169
      # Selective mirroring in YaST should be logged to a default location
      @default_mirrroring_log = "/var/log/smt/smt-mirror.log"

      @report_e_mails = []

      @yes = UI.Glyph(:CheckMark)
      # opposite to check-mark used in UI, usually not translated
      @no = _("-")

      @catalogs_info = {}

      @current_filter_level = -1

      # Stores all the details about the currently listed patches
      #
      #
      # **Structure:**
      #
      #     $["patchid" : $[patch_details], ...]
      @current_patches = {}

      # Currently selected catalog.
      # Variable is filled up when redrawing a table.
      @selected_catalog = ""

      # Currently selected staging group.
      # Variable is filled up when redrawing a table.
      @selected_staging_group = "default"

      # Only some repositories support filtering, although
      # snapshots can be created from every repository
      @filtering_allowed_for_repository = false

      @known_patch_statuses = {
        "PATCHSTATUS_P" => _("Package manager patches: %1"),
        "PATCHSTATUS_S" => _("Security patches: %1"),
        "PATCHSTATUS_R" => _("Recommended patches: %1"),
        "PATCHSTATUS_O" => _("Optional patches: %1")
      }

      @clients_status = {}

      @signing_passphrase = nil

      @filters = []

      @nrdays_to_names = {
        "0" => _("Sunday"),
        "1" => _("Monday"),
        "2" => _("Tuesday"),
        "3" => _("Wednesday"),
        "4" => _("Thursday"),
        "5" => _("Friday"),
        "6" => _("Saturday")
      }

      @smt_support_checked = nil

      @cron_rpms_checked = false
      @cron_rpms_installed = nil
    end

    def CredentialsDialogContent
      HBox(
        HStretch(),
        HSquash(
          VBox(
            VWeight(2, VStretch()),
            # TRANSLATORS: check box
            Left(
              CheckBox(
                Id("enable_smt_service"),
                _("&Enable Subscription Management Tool Service (SMT)")
              )
            ),
            Left("firewall"),
            VWeight(1, VStretch()),
            Left(
              Frame(
                _("Customer Center Configuration"),
                VBox(
                  HSquash(
                    MinWidth(
                      40,
                      # TRANSLATORS: check box
                      CheckBox(
                        Id("custom"),
                        Opt(:notify),
                        _("&Use Custom Server")
                      )
                    )
                  ),
                  HSquash(
                    MinWidth(
                      40,
                      # TRANSLATORS: text entry
                      InputField(Id("NURegUrl"), _("&Registration Server Url"))
                    )
                  ),
                  HSquash(
                    MinWidth(
                      40,
                      # TRANSLATORS: text entry
                      InputField(Id("NUUrl"), _("&Download Server Url"))
                    )
                  ),
                  HSquash(
                    MinWidth(
                      40,
                      # TRANSLATORS: text entry (User name)
                      InputField(Id("NUUser"), _("&User"))
                    )
                  ),
                  HSquash(
                    MinWidth(
                      40,
                      # TRANSLATORS: password entry
                      Password(Id("NUPass"), _("&Password"))
                    )
                  ),
                  VSpacing(1),
                  # TRANSLATORS: push button
                  PushButton(
                    Id("test_NU_credentials"),
                    Opt(:key_F6),
                    _("&Test...")
                  )
                )
              )
            ),
            VWeight(1, VStretch()),
            Left(
              HSquash(
                MinWidth(
                  45,
                  # TRANSLATORS: text entry (e-mail)
                  InputField(
                    Id("nccEmail"),
                    _("&SCC E-mail Used for Registration")
                  )
                )
              )
            ),
            Left(
              HSquash(
                MinWidth(
                  45,
                  # TRANSLATORS: text entry (URL)
                  InputField(Id("url"), _("&Your SMT Server URL"))
                )
              )
            ),
            VWeight(1, VStretch()),
            VWeight(2, VStretch())
          )
        ),
        HStretch()
      )
    end

    def DatabaseDialogContent
      HBox(
        HStretch(),
        HSquash(
          VBox(
            VStretch(),
            Left(
              HSquash(
                MinWidth(
                  40,
                  # TRANSLATORS: password entry
                  Password(Id("DB-password-1"), _("Database &Password"))
                )
              )
            ),
            Left(
              HSquash(
                MinWidth(
                  40,
                  # TRANSLATORS: password entry
                  Password(Id("DB-password-2"), _("C&onfirm Password"))
                )
              )
            ),
            VStretch()
          )
        ),
        HStretch()
      )
    end

    def ScheduledDownloadsDialogContent
      VBox(
        Left(Label(_("List of Scheduled Jobs"))),
        Table(
          Id("scheduled_NU_mirroring"),
          Opt(:vstretch),
          Header(
            _("Job to Run"),
            # TRANSLATORS: table header item
            _("Frequency"),
            # TRANSLATORS: table header item
            _("Day of the Week"),
            # TRANSLATORS: table header item
            _("Day of the Month"),
            # TRANSLATORS: table header item
            _("Hour"),
            # TRANSLATORS: table header item
            _("Minute")
          ),
          []
        ),
        Left(
          HBox(
            PushButton(Id(:add), Opt(:key_F3), _("&Add...")),
            PushButton(Id(:edit), Opt(:key_F4), _("&Edit...")),
            PushButton(Id(:delete), Opt(:key_F5), Label.DeleteButton)
          )
        )
      )
    end

    def ReportEmailTableContent
      HBox(
        HStretch(),
        HSquash(
          MinWidth(
            40,
            VBox(
              Table(
                Id(:report_table),
                Header(_("E-mail addresses to send reports to")),
                []
              ),
              Left(
                HBox(
                  PushButton(Id(:add), _("&Add...")),
                  PushButton(Id(:edit), Label.EditButton),
                  PushButton(Id(:delete), Label.DeleteButton)
                )
              )
            )
          )
        ),
        HStretch()
      )
    end

    def GetPatchCategoryItems
      items = Builtins.maplist(@patch_categories) do |id, localized|
        Item(Id(id), localized)
      end

      items = Builtins.sort(items) do |x, y|
        Ops.less_than(Ops.get_string(x, 1, ""), Ops.get_string(y, 1, ""))
      end

      Builtins.prepend(items, Item(Id("all"), _("All")))
    end

    def ResetPatchCategoryFilter
      UI.ChangeWidget(Id(:category_filter), :Value, "all")

      nil
    end

    def GetSelectedPatchFilter
      selected_filter = Convert.to_string(
        UI.QueryWidget(Id(:category_filter), :Value)
      )

      selected_filter = "" if selected_filter == nil || selected_filter == "all"

      selected_filter
    end

    def StagingTableContent
      VBox(
        HBox(
          HSquash(
            HBox(
              ReplacePoint(
                Id(:catalogs_rp),
                ComboBox(Id(:catalogs), _("Repository &Name"), [])
              ),
              ComboBox(
                Id(:category_filter),
                Opt(:notify),
                _("&Patch Category"),
                GetPatchCategoryItems()
              )
            )
          ),
          HStretch(),
          VBox(ReplacePoint(Id(:repo_details), Empty()))
        ),
        Table(
          Id(:patches_table),
          Opt(:hstretch, :vstretch, :notify, :immediate),
          Header(
            _("Patch Name"),
            _("Version"),
            _("Category"),
            _("Testing"),
            _("Production"),
            _("Summary")
          ),
          []
        ),
        HBox(
          Label(_("Patch Details")),
          HStretch(),
          ReplacePoint(Id(:patches_table_rp), Empty())
        ),
        VSquash(MinHeight(4, RichText(Id(:patch_details), ""))),
        Left(
          HBox(
            PushButton(Id(:toggle_patch_status), _("&Toggle Patch Status")),
            HStretch(),
            MenuButton(
              Id(:change_status),
              _("Change &Status"),
              [
                Item(Id(:additional_filters), _("&Exclude from Snapshot...")),
                term(
                  :menu,
                  Id(:all_listed),
                  _("&All listed..."),
                  [
                    Item(Id(:all_listed_enable), _("&Enable")),
                    Item(Id(:all_listed_disable), _("&Disable"))
                  ]
                )
              ]
            ),
            MenuButton(
              Id(:create_snapshot),
              _("Create Snapshot..."),
              [
                Item(
                  Id(:create_snapshot_testing),
                  _("From Full Mirror to &Testing")
                ),
                Item(
                  Id(:create_snapshot_production),
                  _("From Testing to &Production")
                )
              ]
            )
          )
        )
      )
    end

    def CatalogsTableContent
      VBox(
        HBox(
          Left(TextEntry(Id(:repos_filter), Opt(:notify), _("Repository Filter"), "")),
          VBox(
            VSpacing(1),
            PushButton(Id(:filter), Opt(:default), _("Filter"))
          ),
          HStretch()
        ),
        Table(
          Id(:catalogs_table),
          Opt(:hstretch, :vstretch, :notify, :immediate),
          Header(
            _("Name"),
            _("Target"),
            _("Mirroring"),
            _("Staging"),
            _("Mirrored"),
            _("Description")
          ),
          []
        ),
        Left(
          HBox(
            PushButton(Id(:toggle_mirroring), _("Toggle &Mirroring")),
            PushButton(Id(:toggle_staging), _("Toggle &Staging")),
            HStretch(),
            PushButton(Id(:mirror_now), _("Mirror &Now"))
          )
        )
      )
    end

    def ClientsTableContent
      VBox(
        Left(ReplacePoint(Id(:clients_filter), Empty())),
        Table(
          Id(:clients_table),
          Opt(:hstretch, :vstretch, :notify, :immediate),
          Header(_("Status"), _("Host Name"), _("Last Contact")),
          []
        ),
        VSquash(MinHeight(5, RichText(Id(:client_details), "")))
      )
    end

    def ReadDialog
      # Checking for root's permissions
      return :abort if !Confirm.MustBeRoot

      Progress.New(
        # TRANSLATORS: Dialog caption
        _("Initializing SMT Configuration"),
        " ",
        4,
        [
          # TRANSLATORS: Progress stage
          _("Read SMT configuration"),
          # TRANSLATORS: Progress stage
          _("Read SMT status"),
          # TRANSLATORS: Progress stage
          _("Read firewall settings"),
          # TRANSLATORS: Progress stage
          _("Read cron settings")
        ],
        [
          # TRANSLATORS: Bussy message /progress/
          _("Reading SMT configuration..."),
          # TRANSLATORS: Bussy message /progress/
          _("Reading SMT status..."),
          # TRANSLATORS: Bussy message /progress/
          _("Reading firewall settings..."),
          # TRANSLATORS: Bussy message /progress/
          _("Reading cron settings..."),
          Message.Finished
        ],
        ""
      )
      Wizard.SetTitleIcon("yast-smt")
      Wizard.RestoreHelp(Ops.get(@HELPS, "read", ""))

      Progress.NextStage
      Builtins.sleep(@sl)

      Package.InstallAll(REQUIRED_PACKAGES) or return :abort

      SMTData.ReadCredentials
      SMTData.ReadFirstRun
      SMTData.StorePasswordTMP

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.ReadSMTServiceStatus

      Progress.NextStage
      Builtins.sleep(@sl)

      orig = Progress.set(false)
      SuSEFirewall.Read
      Progress.set(orig)

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.ReadCronSettings
      SMTData.CronRandomize

      Progress.NextStage
      Builtins.sleep(@sl)

      Progress.Finish

      :next
    end

    def RegisterOrFillUpCredentials
      Wizard.SetContents(
        # Dialog caption
        _("SCC Credentials"),
        HSquash(
          VBox(
            # Informative text
            Label(
              _(
                "System does not appear to be registered in SCC.\nChoose one of the options below."
              )
            ),
            VSpacing(1),
            RadioButtonGroup(
              Id("NCCCredentialsRBB"),
              Opt(:notify),
              HBox(
                HSpacing(2),
                VBox(
                  # Radio button
                  Left(
                    RadioButton(
                      Id("skip"),
                      Opt(:notify),
                      _("&Skip Registration")
                    )
                  ),
                  VSpacing(1),
                  # Radio button
                  Left(
                    RadioButton(
                      Id("registration"),
                      Opt(:notify),
                      _("Register in &SUSE Customer Center")
                    )
                  ),
                  VSpacing(1)
                )
              )
            )
          )
        ),
        # Help "SCC Credentials", #1
        _(
          "<p><b><big>SCC Credentials</big></b><br>\n" +
            "You need to register your SMT in SUSE Customer Center to get it working\n" +
            "properly. Choose one of the listed options.</p>"
        ) +
          # Help "SCC Credentials", #2
          _(
            "<p>Choosing <b>Register in SUSE Customer Center</b> would\n" +
              "call regular SUSE Customer Center Configuration module,\n" +
              "<b>Generate New SCC Credentials</b> just creates new SCC Credentials\n" +
              "file without calling SUSE Customer Center Configuration module.</p>"
          ),
        true,
        true
      )
      Wizard.SetTitleIcon("registration")

      dialog_ret = nil
      ret = :next

      # Initial dialog settings
      decision = "registration"
      UI.ChangeWidget(Id("NCCCredentialsRBB"), :CurrentButton, decision)

      while true
        dialog_ret = UI.UserInput

        if dialog_ret == :next
          decision = Convert.to_string(
            UI.QueryWidget(Id("NCCCredentialsRBB"), :CurrentButton)
          )
          Builtins.y2milestone("User decision: %1", decision)
          if decision == "skip"
            if Popup.AnyQuestion(
                # Pop-up dialog caption
                _("Warning"),
                # Pop-up question
                _(
                  "Leaving the SCC credentials empty might cause SMT not to work properly.\nAre you sure you want to really skip it?"
                ),
                # Button label
                _("&Yes, Skip It"),
                # Button label
                _("&Cancel"),
                :focus_no
              )
              Builtins.y2warning(
                "User decided to skip registration or entering SCC credentials"
              )
              ret = :next
            else
              next
            end
          elsif decision == "registration"
            PackageSystem.EnsureTargetInit
            wfmret = WFM.CallFunction("inst_scc")
            Builtins.y2milestone("inst_scc returned: %1", wfmret)
            ret = :again
          end
          break
        elsif dialog_ret == :back
          ret = :back
          break
        elsif dialog_ret == "skip" || dialog_ret == "registration"
          decision = Convert.to_string(
            UI.QueryWidget(Id("NCCCredentialsRBB"), :CurrentButton)
          )
        elsif dialog_ret == :abort || dialog_ret == :cancel
          if Popup.ReallyAbort(true)
            ret = :abort
            break
          end
        else
          Builtins.y2error("Unknown user input: %1", dialog_ret)
        end
      end

      ret
    end

    # FATE #305541, Check if SCCcredentials file exists and offer registration
    # or creating the file if it doesn't
    def CheckConfigDialog
      # defualt dialog return
      dialog_ret = :next

      if SMTData.GetSMTServiceStatus != true
        Builtins.y2milestone(
          "SMT Service is not enabled, not checking the config"
        )
        return dialog_ret
      end

      while SMTData.SystemIsRegistered != true
        Builtins.y2warning(
          "No SCCcredentials present, offering registration, etc."
        )
        dialog_ret = RegisterOrFillUpCredentials()
        Builtins.y2milestone("Dialog ret: %1", dialog_ret)

        if dialog_ret == :abort || dialog_ret == :back || dialog_ret == :next
          break
        end
      end

      # Check succeeded after some iterations...
      if dialog_ret == :again
        dialog_ret = :next 
        # Aborted? Skip the other tests
      elsif dialog_ret == :abort
        return dialog_ret
      end

      if SMTData.CheckAndAdjustCredentialsFileAccess != true
        Report.Error(
          Builtins.sformat(
            # Pop-up error message, %1 is replaced with file name, %2 with username
            _(
              "SMT is unable to set %1 file permissions\nto be readable by %2 user."
            ),
            SMTData.GetSCCcredentialsFile,
            SMTData.GetCredentials("DB", "user")
          )
        )
      end

      dialog_ret
    end

    def CheckAlreadyMirroredRepositories
      if SMTData.CheckAndAdjustMirroredReposAccess != true
        Report.Error(
          Builtins.sformat(
            # Pop-up error message, %1 is replaced with directory name, %2 with username
            _(
              "SMT is unable to set %1 directory permission\nto be recursively writable by %2 user."
            ),
            SMTData.GetMirroredReposDirectory,
            SMTData.GetCredentials("DB", "user")
          )
        )
      end

      nil
    end

    def WritePatches
      # Writing the patches filters, storing to database
      Builtins.y2milestone("Writing patches...")
      success = SCR.Write(path(".smt.staging.patches"), nil)
      Builtins.y2milestone("Writing patches returned: %1", success)

      nil
    end

    def CheckRobotsTXT
      mirror_to = SMTData.GetCredentials("LOCAL", "MirrorTo")

      if mirror_to == nil || mirror_to == ""
        Builtins.y2error("Wrong LOCAL->MirrorTo")
        return nil
      end

      mirror_to = Ops.add(mirror_to, "/robots.txt")

      return true if !FileUtils.Exists(mirror_to)

      # Checking for
      cmd = Builtins.sformat(
        "grep '^Allow:[ \\t]\\+/\\?repo/keys/\\?' '%1'",
        mirror_to
      )
      cmd_ret = Convert.to_integer(SCR.Execute(path(".target.bash"), cmd))

      # 0 -> some lines found
      # 1 -> nothing found
      # 2 -> error
      if cmd_ret == 2
        Builtins.y2warning("Cannot check robots.txt")
        return false
      elsif cmd_ret == 0
        Builtins.y2milestone("File robots.txt seem to allow /repo/keys")
        return true
      end

      Builtins.y2warning("File robots.txt found! (cmd ret: %1)", cmd_ret)
      Report.Warning(
        Builtins.sformat(
          _(
            "File %1 has been found in your document root.\n" +
              "\n" +
              "Please, make sure, that '/repo/keys' is listed as an allowed directory\n" +
              "or remove the file. Otherwise SMT server might not work properly."
          ),
          mirror_to
        )
      )

      false
    end

    def WriteDialog
      stages = [
        # TRANSLATORS: Progress stage
        _("Adjust SMT configuration"),
        # TRANSLATORS: Progress stage
        _("Adjust database configuration"),
        # TRANSLATORS: Progress stage
        _("Check and install server certificate"),
        # TRANSLATORS: Progress stage
        _("Adjust Web-server configuration"),
        # TRANSLATORS: Progress stage
        _("Adjust SMT service"),
        # TRANSLATORS: Progress stage
        _("Write firewall settings"),
        # TRANSLATORS: Progress stage
        _("Write cron settings"),
        # TRANSLATORS: Progress stage
        _("Check mirrored repositories"),
        # TRANSLATORS: Progress stage
        _("Run synchronization check")
      ]
      steps = [
        # TRANSLATORS: Bussy message /progress/
        _("Adjusting SMT configuration..."),
        # TRANSLATORS: Bussy message /progress/
        _("Adjusting database configuration..."),
        # TRANSLATORS: Bussy message /progress/
        _("Checking and installing server certificate..."),
        # TRANSLATORS: Bussy message /progress/
        _("Adjusting Web server configuration..."),
        # TRANSLATORS: Bussy message /progress/
        _("Adjusting SMT service..."),
        # TRANSLATORS: Bussy message /progress/
        _("Writing firewall settings..."),
        # TRANSLATORS: Bussy message /progress/
        _("Writing cron settings..."),
        # TRANSLATORS: Bussy message /progress/
        _("Checking mirrored repositories..."),
        # TRANSLATORS: Bussy message /progress/
        _("Running synchronization check..."),
        Message.Finished
      ]

      Progress.New(
        # TRANSLATORS: Dialog caption
        _("Writing SMT Configuration"),
        " ",
        Builtins.size(stages),
        stages,
        steps,
        ""
      )

      Wizard.SetTitleIcon("yast-smt")
      Wizard.RestoreHelp(Ops.get(@HELPS, "write", ""))

      SMTData.WriteCredentials

      Progress.NextStage
      Builtins.sleep(@sl)

      Progress.NextStage
      Builtins.sleep(@sl)

      # uses credentials
      SMTData.StartDatabaseIfNeeded
      SMTData.WriteDatabaseSettings
      SMTData.ChangePasswordIfDifferent

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.WriteCASettings

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.CheckAndAdjustApacheConfiguration

      CheckRobotsTXT()

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.WriteSMTServiceStatus

      Progress.NextStage
      Builtins.sleep(@sl)

      orig = Progress.set(false)
      SuSEFirewall.Write
      Progress.set(orig)

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.WriteCronSettings

      Progress.NextStage
      Builtins.sleep(@sl)

      SMTData.WriteFirstRunStatus
      Builtins.sleep(@sl)

      Progress.NextStage

      # BNC #521013: Checking uses smt agent that connects to database
      # Database has to be already running
      CheckAlreadyMirroredRepositories()

      Progress.NextStage

      SMTData.RunSmallSync if SMTData.GetSMTServiceStatus == true

      Progress.Finish

      :next
    end

    def ReadManagementDialog
      Progress.New(
        # TRANSLATORS: Dialog caption
        _("Initializing SMT Configuration"),
        " ",
        1,
        # TRANSLATORS: Progress stage
        [
          # TRANSLATORS: Progress stage
          _("Read SMT configuration")
        ],
        [
          # TRANSLATORS: Bussy message /progress/
          _("Reading SMT configuration..."),
          Message.Finished
        ],
        ""
      )
      Wizard.SetTitleIcon("yast-smt")
      Wizard.RestoreHelp(Ops.get(@HELPS, "read", ""))

      Progress.NextStage

      Package.InstallAll(REQUIRED_PACKAGES) or return :abort

      SMTData.ReadCredentials

      Progress.Finish

      :next
    end

    def WriteManagementDialog
      Progress.New(
        # TRANSLATORS: Dialog caption
        _("Writing Changes"),
        " ",
        1,
        [
          # TRANSLATORS: Progress stage
          _("Write patches")
        ],
        [
          # TRANSLATORS: Bussy message /progress/
          _("Writing patches..."),
          Message.Finished
        ],
        ""
      )
      Wizard.SetTitleIcon("yast-smt")
      Wizard.RestoreHelp(Ops.get(@HELPS, "write", ""))

      Progress.NextStage

      WritePatches()

      Progress.Finish

      :next
    end

    def InitCredentialsDialog(id)
      Builtins.foreach(["NUUser", "NUPass", "NURegUrl", "NUUrl"]) do |one_entry|
        value = SMTData.GetCredentials("NU", one_entry)
        value = "" if value == nil
        UI.ChangeWidget(Id(one_entry), :Value, value)
      end

      Builtins.foreach(["nccEmail", "url"]) do |one_entry|
        value = SMTData.GetCredentials("LOCAL", one_entry)
        value = "" if value == nil
        UI.ChangeWidget(Id(one_entry), :Value, value)
      end

      # BNC #514304
      # Using fallback FQDN if no URL is set in configuration
      if SMTData.GetCredentials("LOCAL", "url") == ""
        value = Hostname.CurrentFQ

        if value != nil
          if Builtins.regexpmatch(value, ".*[ \t\n]+.*")
            value = Builtins.regexpsub(value, "(.*)[ \t\n]+.*", "\\1")
          end

          if Ops.greater_than(Builtins.size(value), 0)
            value = Builtins.sformat("http://%1/", value)
            Builtins.y2milestone("Using '%1'", value)
            UI.ChangeWidget(Id("url"), :Value, value)
          end
        end
      end

      regurl = SMTData.GetCredentials("NU", "NURegUrl")
      api_type = SMTData.GetCredentials("NU", "ApiType")
      if api_type != "SCC"
        api_type = "SCC"
        regurl = "https://scc.suse.com/connect"
        UI.ChangeWidget(Id("NURegURL"), :Value, regurl)
        UI.ChangeWidget(Id("NUURL"), :Value, "https://updates.suse.com/")
      end
      if regurl == "https://scc.suse.com/connect"
        UI.ChangeWidget(Id("custom"), :Value, false)
        UI.ChangeWidget(Id("NURegUrl"), :Enabled, false)
        UI.ChangeWidget(Id("NUUrl"), :Enabled, false)
      else
        UI.ChangeWidget(Id("custom"), :Value, true)
        UI.ChangeWidget(Id("NURegUrl"), :Enabled, true)
        UI.ChangeWidget(Id("NUUrl"), :Enabled, true)
      end

      UI.ChangeWidget(
        Id("enable_smt_service"),
        :Value,
        SMTData.GetSMTServiceStatus
      )

      nil
    end

    def StoreCredentialsDialog(id, event)
      event = deep_copy(event)
      Builtins.foreach(["NUUser", "NUPass", "NURegUrl", "NUUrl"]) do |one_entry|
        SMTData.SetCredentials(
          "NU",
          one_entry,
          Convert.to_string(UI.QueryWidget(Id(one_entry), :Value))
        )
      end

      Builtins.foreach(["nccEmail", "url"]) do |one_entry|
        SMTData.SetCredentials(
          "LOCAL",
          one_entry,
          Convert.to_string(UI.QueryWidget(Id(one_entry), :Value))
        )
      end

      SMTData.SetCredentials("NU", "ApiType", "SCC")
      new_service_status = Convert.to_boolean(
        UI.QueryWidget(Id("enable_smt_service"), :Value)
      )
      Builtins.y2milestone(
        "New SMT status: %1",
        new_service_status == true ? "enabled" : "disabled"
      )
      SMTData.SetSMTServiceStatus(new_service_status)

      nil
    end

    def InitDatabaseDialog(id)
      value = SMTData.GetCredentials("DB", "pass")
      value = "" if value == nil

      # bnc #390085
      UI.ChangeWidget(
        Id("DB-password-1"),
        :Label,
        Builtins.sformat(
          "Database Password for %1 User",
          SMTData.GetCredentials("DB", "user")
        )
      )
      UI.ChangeWidget(
        Id("DB-password-2"),
        :Label,
        Builtins.sformat(
          "Database Password for %1 User Once Again",
          SMTData.GetCredentials("DB", "user")
        )
      )

      UI.ChangeWidget(Id("DB-password-1"), :Value, value)
      UI.ChangeWidget(Id("DB-password-2"), :Value, value)

      nil
    end

    def StoreDatabaseDialog(id, event)
      event = deep_copy(event)
      SMTData.SetCredentials(
        "DB",
        "pass",
        Convert.to_string(UI.QueryWidget(Id("DB-password-1"), :Value))
      )

      nil
    end

    def ValidateDatabaseDialog(id, event)
      event = deep_copy(event)
      pass_1 = Convert.to_string(UI.QueryWidget(Id("DB-password-1"), :Value))
      pass_2 = Convert.to_string(UI.QueryWidget(Id("DB-password-2"), :Value))

      if pass_1 != pass_2
        UI.SetFocus(Id("DB-password-1"))
        # TRANSLATORS: error report
        Report.Error(_("The first and the second password do not match."))
        return false
      end

      # pass_1 and pass_2 are equal
      if pass_1 == nil || pass_1 == ""
        UI.SetFocus(Id("DB-password-1"))
        # TRANSLATORS: error report, actually containing a question
        if !Popup.ContinueCancel(
            _(
              "Password should not be empty.\n" +
                "\n" +
                "Would you like to continue nevertheless?"
            )
          )
          return false
        end
      end

      Builtins.y2milestone("Password validation passed")
      true
    end

    def ValidateCredentialsDialog(id, event)
      event = deep_copy(event)
      orig_url = SMTData.GetCredentials("NU", "NURegUrl")
      url = Convert.to_string(UI.QueryWidget(Id("url"), :Value))

      if url == nil || url == ""
        UI.SetFocus(Id("url"))
        # Pop-up error message
        Report.Error(
          _(
            "The SMT URL must not be empty.\n" +
              "\n" +
              "Enter your SMT server URL in the following format: http:://server.name/\n"
          )
        )
        return false 
        # BNC #518222: Check for 'http://.+' or 'https://.+' in URL
      elsif !Builtins.regexpmatch(url, "^[ \t]*http://.+") &&
          !Builtins.regexpmatch(url, "^[ \t]*https://.+")
        UI.SetFocus(Id("url"))
        Report.Error(
          _(
            "Invalid SMT Server URL.\n" +
              "\n" +
              "URL should start with 'http://' or 'https://'."
          )
        )
        return false
      end

      nuuser = Convert.to_string(UI.QueryWidget(Id("NUUser"), :Value))
      if nuuser == nil || nuuser == ""
        UI.SetFocus(Id("NUUser"))
        # Pop-up error message
        Report.Error(_("Update server user must not be empty."))
        return false
      end

      nupass = Convert.to_string(UI.QueryWidget(Id("NUPass"), :Value))
      if nupass == nil || nupass == ""
        UI.SetFocus(Id("NUPass"))
        # Pop-up error message
        Report.Error(_("Update server password must not be empty."))
        return false
      end

      true
    end

    def TestCredentials
      UI.OpenDialog(
        MinSize(
          52,
          12,
          VBox(
            # TRANSLATORS: LogView label
            LogView(Id("test_log"), _("&Test Details"), 5, 100),
            VSpacing(1),
            PushButton(Id(:ok), Opt(:default, :key_F10), Label.OKButton)
          )
        )
      )

      # complex.ycp
      ret = CredentialsTest("test_log")

      if ret == true
        # TRANSLATORS: LogView line
        UI.ChangeWidget(
          Id("test_log"),
          :LastLine,
          "\n" + _("Test result: success") + "\n"
        )
      else
        # TRANSLATORS: LogView line
        UI.ChangeWidget(
          Id("test_log"),
          :LastLine,
          "\n" + _("Test result: failure") + "\n"
        )
      end

      UI.UserInput
      UI.CloseDialog

      ret
    end

    def HandleCredentialsDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")
      custom = Convert.to_boolean(UI.QueryWidget(Id("custom"), :Value))

      if action == "test_NU_credentials"
        StoreCredentialsDialog(id, event)
        TestCredentials()
      elsif action == "custom"
        if Convert.to_boolean(UI.QueryWidget(Id("custom"), :Value))
          UI.ChangeWidget(Id("NURegUrl"), :Enabled, true)
          UI.ChangeWidget(Id("NUUrl"), :Enabled, true)
          UI.ChangeWidget(Id("NURegUrl"), :Value, "")
          UI.ChangeWidget(Id("NUUrl"), :Value, "")
        else
          UI.ChangeWidget(Id("NURegUrl"), :Enabled, false)
          UI.ChangeWidget(Id("NUUrl"), :Enabled, false)
          UI.ChangeWidget(
            Id("NURegUrl"),
            :Value,
            "https://scc.suse.com/connect"
          )
          UI.ChangeWidget(
            Id("NUUrl"),
            :Value,
            "https://updates.suse.com/"
          )
        end
      end

      nil
    end

    def InitReportEmails
      reportEmail = SMTData.GetCredentials("REPORT", "reportEmail")

      if reportEmail == nil
        Builtins.y2warning("REPORT/reportEmail not defined yet")
        reportEmail = ""
      end

      reportEmail = Builtins.mergestring(
        Builtins.splitstring(reportEmail, " \t"),
        ""
      )
      @report_e_mails = Builtins.toset(Builtins.splitstring(reportEmail, ","))

      nil
    end

    def StoreReportEmails
      SMTData.SetCredentials(
        "REPORT",
        "reportEmail",
        Builtins.mergestring(@report_e_mails, ",")
      )

      nil
    end

    def RedrawReportEmailsTable
      items = Builtins.maplist(@report_e_mails) do |one_email|
        Item(Id(one_email), one_email)
      end

      UI.ChangeWidget(Id(:report_table), :Items, items)

      edit_delete_stat = Ops.greater_than(Builtins.size(items), 0)
      UI.ChangeWidget(Id(:edit), :Enabled, edit_delete_stat)
      UI.ChangeWidget(Id(:delete), :Enabled, edit_delete_stat)

      nil
    end

    def InitReportEmailTableDialog(id)
      InitReportEmails()
      RedrawReportEmailsTable()

      nil
    end

    def StoreReportEmailTableDialog(id, event)
      event = deep_copy(event)
      StoreReportEmails()

      nil
    end

    def AdjustRepositoriesButtons
      current_item = Convert.to_string(
        UI.QueryWidget(Id(:catalogs_table), :CurrentItem)
      )

      # nothing listed / nothing selected
      return if current_item == nil || current_item == ""

      # [Mirror Now]
      new_status_mirror = Ops.get_boolean(
        @catalogs_info,
        [current_item, "mirroring"],
        true
      )
      UI.ChangeWidget(Id(:mirror_now), :Enabled, new_status_mirror)

      new_status_staging = Ops.get_boolean(
        @catalogs_info,
        [current_item, "mirroring"],
        true
      ) ||
        Ops.get_boolean(@catalogs_info, [current_item, "staging"], true)
      UI.ChangeWidget(Id(:toggle_staging), :Enabled, new_status_staging)

      nil
    end

    def RedrawCatalogsTable(catalogs_filters)
      catalogs_filters = deep_copy(catalogs_filters)
      Builtins.y2milestone("Filter used: %1", catalogs_filters)

      current_item = Convert.to_string(
        UI.QueryWidget(Id(:catalogs_table), :CurrentItem)
      )

      catalog_filter = nil
      if ! catalogs_filters.empty?
        catalog_filter = catalogs_filters[0]
      end

      @catalogs_info = {}

      # busy message
      uio = UI.OpenDialog(
        Label(_("Getting list of the currently available repositories..."))
      )

      catalogs_states = Convert.convert(
        SCR.Read(path(".smt.repositories.all")),
        :from => "any",
        :to   => "map <string, map <string, any>>"
      )
      if catalogs_states == nil
        Builtins.y2error("Error getting available repositories")
        catalogs_states = {}
      end

      mirroring = nil
      staging = nil
      catalog_id = nil

      # Constructing the Filter UI
      # $[0:["openSUSE", "SLE", ...], 1:["11.1", "SDK", ...], ...]
      current_item_present = false

      items = Builtins.maplist(catalogs_states) do |catalogid, one_catalog|
        if catalog_filter != nil
          if one_catalog["NAME"].downcase.include? catalog_filter.downcase
            Builtins.y2debug("match")
          else
            next nil
          end
        end
        mirroring = Ops.get_string(one_catalog, "DOMIRROR", "") == "Y"
        staging = Ops.get_string(one_catalog, "STAGING", "") == "Y"
        catalog_id = Ops.get_string(one_catalog, "CATALOGID", "0")
        splititem_nr = -1
        # used later in Handle* function
        Ops.set(
          @catalogs_info,
          catalogid,
          {
            "mirroring" => mirroring,
            "staging"   => staging,
            "name"      => Ops.get_string(one_catalog, "NAME", ""),
            "catalog_id" => catalog_id,
            # empty /--/ == no specific target
            "target"    => Builtins.regexpmatch(
              Ops.get_string(one_catalog, "TARGET", ""),
              "^-+$"
            ) ?
              "" :
              Ops.get_string(one_catalog, "TARGET", "")
          }
        )
        if current_item == Ops.get_string(one_catalog, "ID", "")
          current_item_present = true
        end
        Item(
          Id(Ops.get_string(one_catalog, "ID", "")),
          Ops.get_locale(one_catalog, "NAME", _("Unknown")),
          Ops.get_locale(one_catalog, "TARGET", _("Unknown")),
          mirroring ? @yes : @no,
          staging ? @yes : @no,
          Ops.get_string(one_catalog, "LAST_MIRROR", "") != "" ?
            Ops.get_string(one_catalog, "LAST_MIRROR", "") :
            @no,
          Ops.get_string(one_catalog, "DESCRIPTION", "")
        )
      end

      items = Builtins.filter(items) { |item| item != nil }

      items = Builtins.sort(items) do |a, b|
        Ops.less_than(Ops.get_string(a, 1, ""), Ops.get_string(b, 1, ""))
      end

      items = [] if items == nil

      UI.CloseDialog if uio == true

      UI.ChangeWidget(Id(:catalogs_table), :Items, items)
      if current_item_present && current_item != nil
        UI.ChangeWidget(Id(:catalogs_table), :CurrentItem, current_item)
      end

      AdjustRepositoriesButtons()

      nil
    end

    def InitRepositoriesTableDialog(id)
      RedrawCatalogsTable([])

      nil
    end

    def FormatHTMLPatchDescription(description)
      max = 512

      while Builtins.regexpmatch(description, "\n\n") &&
          Ops.greater_than(max, 0)
        max = Ops.subtract(max, 1)
        description = Builtins.regexpsub(
          description,
          "(.*)\n\n(.*)",
          "\\1<br><br>\\2"
        )
      end

      description
    end

    # Returns whether a patch is filtered by any current 'category' filter.
    #
    # @param string patch ID
    # @return [Boolean] whether filtered
    def IsPatchFilteredByType(patchid)
      this_patch = {
        "type"         => Ops.get_string(
          @current_patches,
          [patchid, "type"],
          ""
        ),
        "repositoryid" => @selected_catalog,
        "group"        => @selected_staging_group
      }

      Convert.to_boolean(
        SCR.Read(path(".smt.staging.category_filter"), this_patch)
      ) == true
    end

    def GetTranslatedPatchCategory(patch_category)
      # Used as a fallback
      # %1 is replaced with a patch category
      Ops.get(
        @patch_categories,
        patch_category,
        Builtins.sformat(_("Patch category '%1'"), patch_category)
      )
    end

    # Fills up details widget with the current patch description
    def RedrawPatchesDetails
      sel_patchid = Convert.to_string(
        UI.QueryWidget(Id(:patches_table), :CurrentItem)
      )

      # No repositories at all (with staging enabled)
      if @selected_catalog == nil || @selected_catalog == ""
        UI.ChangeWidget(Id(:patch_details), :Value, "") 
        # No patch listed, no patch selected
      elsif sel_patchid == nil || sel_patchid == ""
        UI.ChangeWidget(
          Id(:patch_details),
          :Value,
          _("There are no patches available in this repository.")
        )
        return
      end

      # If a patch is filtered by the 'patch type' filter, we don't offer
      # to change it...
      filtered_by_type = IsPatchFilteredByType(sel_patchid)

      buttons_enabled = filtered_by_type == false &&
        @filtering_allowed_for_repository == true
      UI.ChangeWidget(Id(:toggle_patch_status), :Enabled, buttons_enabled)

      patch_description = Ops.get_string(
        @current_patches,
        [sel_patchid, "description"],
        ""
      )

      if filtered_by_type
        patch_description = Builtins.sformat(
          # %1 is replaced with a warning that patch is filtered-out by a category filter
          # %2 is replaced with patch description
          _("%1\n\n%2"),
          Builtins.sformat(
            # Connected with the text above, informs user about the current patch state
            # %1 is replaced with a translated patch type
            _(
              "<b>Patch is filtered-out by patch-category filter (%1) and thus cannot be enabled in this dialog.</b>"
            ),
            GetTranslatedPatchCategory(
              Ops.get_string(@current_patches, [sel_patchid, "type"], "")
            )
          ),
          patch_description
        )
      end

      UI.ChangeWidget(
        Id(:patch_details),
        :Value,
        FormatHTMLPatchDescription(patch_description)
      )

      nil
    end

    def UpdateRepoDetails
      additional_info = []

      if @selected_catalog == nil || @selected_catalog == ""
        additional_info = Builtins.add(
          additional_info,
          _("There are no repositories with staging enabled")
        )
      else
        details = Convert.to_map(
          SCR.Read(
            path(".smt.staging.repository.details"),
            {
              "repositoryid" => @selected_catalog,
              "group"        => @selected_staging_group
            }
          )
        )

        additional_info = Builtins.add(
          additional_info,
          Builtins.sformat(
            _("Mirror timestamp: %1"),
            Ops.get_string(details, "full", "") != nil &&
              Ops.greater_than(
                Builtins.size(Ops.get_string(details, "full", "")),
                0
              ) ?
              Ops.get_string(details, "full", "") :
              _("Never mirrored")
          )
        )

        additional_info = Builtins.add(
          additional_info,
          Builtins.sformat(
            _("Testing snapshot timestamp: %1"),
            Ops.get_string(details, "testing", "") != nil &&
              Ops.greater_than(
                Builtins.size(Ops.get_string(details, "testing", "")),
                0
              ) ?
              Ops.get_string(details, "testing", "") :
              _("Never created")
          )
        )

        additional_info = Builtins.add(
          additional_info,
          Builtins.sformat(
            _("Production snapshot timestamp: %1"),
            Ops.get_string(details, "production", "") != nil &&
              Ops.greater_than(
                Builtins.size(Ops.get_string(details, "production", "")),
                0
              ) ?
              Ops.get_string(details, "production", "") :
              _("Never created")
          )
        )
      end

      if Ops.greater_than(Builtins.size(additional_info), 0)
        UI.ReplaceWidget(
          Id(:repo_details),
          Label(Opt(:boldFont), Builtins.mergestring(additional_info, "\n"))
        )
      else
        UI.ReplaceWidget(Id(:repo_details), Empty())
      end

      nil
    end

    def GetPatchStatusIcon(patch)
      patch = deep_copy(patch)
      Ops.get_boolean(patch, "testing", false) ?
        Ops.get_boolean(patch, "filtered", false) ? "-" : "a" :
        Ops.get_boolean(patch, "filtered", false) ? "f" : "+"
    end

    # Redraws the whole table of patches from the current repository.
    #
    # @param string patch category filter (one of the well known
    # categories ["security", "recommended", "optional"] or "" for no filter used)
    def RedrawPatchesTable(category_filter)
      # default
      @filtering_allowed_for_repository = false

      selected_catalog_group = Convert.to_string(
        UI.QueryWidget(Id(:catalogs), :Value)
      )
      # The currently selected catalog
      l = Builtins.splitstring(selected_catalog_group, "-")
      @selected_catalog = Ops.get(l, 0, "")

      if Ops.greater_than(Builtins.size(l), 2)
        l = Builtins.remove(l, 0)
        @selected_staging_group = Builtins.mergestring(l, "")
      else
        @selected_staging_group = Ops.get(l, 1, "default")
      end

      # Better to evaluate boolen (for each patch)
      use_category_filter = category_filter != nil && category_filter != ""

      # The same current item should be selected after redrawing
      current_item = Convert.to_string(
        UI.QueryWidget(Id(:patches_table), :CurrentItem)
      )
      ci_is_listed = false

      items = []

      if @selected_catalog == nil || @selected_catalog == ""
        Builtins.y2milestone("No catalog selected")
      else
        @filtering_allowed_for_repository = Convert.to_boolean(
          SCR.Read(
            path(".smt.repository.staging_allowed"),
            { "repositoryid" => @selected_catalog }
          )
        )
        Builtins.y2milestone(
          "Repository %1 filtering allowed: %2",
          @selected_catalog,
          @filtering_allowed_for_repository
        )

        @current_patches = {}

        patches = Convert.convert(
          SCR.Read(
            path(".smt.staging.patches"),
            {
              "repositoryid" => @selected_catalog,
              "group"        => @selected_staging_group
            }
          ),
          :from => "any",
          :to   => "list <map>"
        )
        if patches == nil
          Builtins.y2error(
            "Cannot get patches for catalog: %1",
            @selected_catalog
          )
        else
          testing_status = ""
          production_status = ""

          items = Builtins.maplist(patches) do |one_patch|
            # Filtering-out patches not matching the filter
            if use_category_filter &&
                category_filter != Ops.get_string(one_patch, "type", "")
              next nil
            end
            Ops.set(
              @current_patches,
              Ops.get_string(one_patch, "patchid", ""),
              one_patch
            )
            # To select the same current_item again
            if !ci_is_listed &&
                Ops.get_string(one_patch, "patchid", "") == current_item
              ci_is_listed = true
            end
            testing_status = GetPatchStatusIcon(one_patch)
            production_status = Ops.get_boolean(one_patch, "production", false) ? "a" : "f"
            Item(
              Id(Ops.get_string(one_patch, "patchid", "")),
              Ops.get_string(one_patch, "name", ""),
              Builtins.tostring(Ops.get_integer(one_patch, "version", 0)),
              GetTranslatedPatchCategory(Ops.get_string(one_patch, "type", "")),
              @text_mode ?
                testing_status :
                term(
                  :cell,
                  term(:icon, Ops.get(@smt_patch_icons, testing_status, ""))
                ),
              @text_mode ?
                production_status :
                term(
                  :cell,
                  term(:icon, Ops.get(@smt_patch_icons, production_status, ""))
                ),
              Ops.get_string(one_patch, "title", "")
            )
          end
        end
      end

      # If filter is used, remove 'nil's
      items = Builtins.filter(items) { |one_item| one_item != nil } if use_category_filter

      items = Builtins.sort(items) do |a, b|
        Ops.less_than(Ops.get_string(a, 1, ""), Ops.get_string(b, 1, ""))
      end

      any_catalog = @selected_catalog != nil && @selected_catalog != ""
      enable_buttons = Ops.greater_than(Builtins.size(items), 0) &&
        @filtering_allowed_for_repository == true

      UI.ChangeWidget(Id(:patches_table), :Items, items)
      UI.ChangeWidget(Id(:toggle_patch_status), :Enabled, enable_buttons)
      UI.ChangeWidget(Id(:change_status), :Enabled, enable_buttons)

      additional_info = enable_buttons == true || any_catalog != true ?
        Empty() :
        Label(_("Repository does not allow patch-filtering"))
      UI.ReplaceWidget(Id(:patches_table_rp), additional_info)

      if ci_is_listed
        UI.ChangeWidget(Id(:patches_table), :CurrentItem, current_item)
      end

      RedrawPatchesDetails()
      UpdateRepoDetails()

      nil
    end

    def GetPatchStatus(client_info)
      client_info = deep_copy(client_info)
      ret = true

      Builtins.foreach(@known_patch_statuses) do |patch_status, translation|
        if Ops.get(client_info, patch_status) == nil ||
            Ops.greater_than(Ops.get_integer(client_info, patch_status, 0), 0)
          ret = false
          raise Break
        end
      end

      ret
    end

    def RedrawClientsTableDetails
      current_item = Convert.to_integer(
        UI.QueryWidget(Id(:clients_table), :CurrentItem)
      )
      description = ""

      if current_item != nil
        client_info = Ops.get(@clients_status, current_item, {})
        status = GetPatchStatus(client_info)

        description = Builtins.sformat(
          # %1 Client (is|is not) up-to-date
          # %2 There are some patches pending...
          _("%1<br>%2"),
          status == true ?
            _("Client is up-to-date") :
            _("<b>Client is not up-to-date</b>"),
          status != true ?
            Builtins.sformat(
              # %1 is replaced with a comma-separated pieces of info, e.g., 'Security patches: 5'
              _("There are some patches pending:<br>%1"),
              # Merges list of pieces of info
              Builtins.mergestring(
                Builtins.maplist(@known_patch_statuses) do |key, translation|
                  Builtins.sformat(
                    translation,
                    # if the number of patches is defined but nil
                    Ops.get_integer(client_info, key, 0) == nil ?
                      # Number of patches pending
                      _("Status is unknown") :
                      Ops.get_integer(client_info, key, 0)
                  )
                end,
                ", "
              )
            ) :
            ""
        )
      else
        description = _(
          "There are no registered clients or their status is unknown"
        )
      end

      UI.ChangeWidget(Id(:client_details), :Value, description)

      nil
    end

    def RedrawClientsTableDialog
      @clients_status = Convert.convert(
        SCR.Read(path(".smt.clients.status")),
        :from => "any",
        :to   => "map <integer, map <string, any>>"
      )

      status = nil
      statusstring = nil

      items = Builtins.maplist(@clients_status) do |id, values|
        status = GetPatchStatus(values)
        statusstring = Ops.get_string(values, "STATUSSTRING", "")
        Item(
          Id(id),
          term(
            :cell,
            term(:icon, Ops.get(@smt_status_icons, statusstring, "")),
            Ops.get_locale(values, "STATUSLABEL", _("Unknown Status"))
          ),
          Ops.get_string(values, "HOSTNAME", Ops.get_string(values, "GUID", "")),
          Ops.get_locale(values, "LASTCONTACT", _("Never"))
        )
      end

      items = [] if items == nil

      items = Builtins.sort(items) do |a, b|
        Ops.less_than(
          Ops.get_string(a, [1, 1], ""),
          Ops.get_string(b, [1, 1], "")
        )
      end

      UI.ChangeWidget(Id(:clients_table), :Items, items)

      RedrawClientsTableDetails()

      nil
    end

    def InitClientsTableDialog(id)
      RedrawClientsTableDialog()

      nil
    end

    def RedrawRepositoriesStagingMenu
      catalogs = Convert.convert(
        SCR.Read(path(".smt.staging.repositories")),
        :from => "any",
        :to   => "map <string, map>"
      )
      staging_groups = Convert.convert(
        SCR.Read(path(".smt.staging.groups")),
        :from => "any",
        :to   => "list <string>"
      )
      repository_uptodate = nil

      # Remember the selected value
      current_value = nil
      if UI.WidgetExists(:catalogs)
        current_value = Convert.to_string(UI.QueryWidget(Id(:catalogs), :Value))
      end

      items = []
      Builtins.foreach(catalogs) do |catalogid, one_catalog|
        Builtins.foreach(staging_groups) do |groupname|
          Builtins.y2milestone("Checking: %1-%2", catalogid, groupname)
          repository_uptodate = Convert.to_boolean(
            SCR.Read(
              path(".smt.staging.repository.uptodate"),
              {
                "repositoryid" => catalogid,
                "type"         => "testing",
                "group"        => groupname
              }
            )
          ) &&
            Convert.to_boolean(
              SCR.Read(
                path(".smt.staging.repository.uptodate"),
                {
                  "repositoryid" => catalogid,
                  "type"         => "production",
                  "group"        => groupname
                }
              )
            )
          items = Builtins.add(
            items,
            Item(
              Id(Ops.add(Ops.add(catalogid, "-"), groupname)),
              term(
                :icon,
                repository_uptodate ?
                  Ops.get(@smt_status_icons, "repo-up-to-date", "") :
                  Ops.get(@smt_status_icons, "repo-not-up-to-date", "")
              ),
              Ops.get_string(one_catalog, "TARGET", "") != "" ?
                # Catalog Name (Target)
                Builtins.sformat(
                  _("%1 (%2)(%3)"),
                  Ops.get_string(one_catalog, "NAME", ""),
                  Ops.get_string(one_catalog, "TARGET", ""),
                  groupname
                ) :
                Builtins.sformat(
                  _("%1 (%2)"),
                  Ops.get_string(one_catalog, "NAME", ""),
                  groupname
                ),
              Ops.add(Ops.add(catalogid, "-"), groupname) == current_value
            )
          )
        end
      end

      items = Builtins.sort(items) do |x, y|
        Ops.less_than(
          Builtins.toupper(Ops.get_string(x, 2, "")),
          Builtins.toupper(Ops.get_string(y, 2, ""))
        )
      end

      items = [] if items == nil

      items = Builtins.sort(items) do |a, b|
        Ops.less_than(Ops.get_string(a, 2, ""), Ops.get_string(b, 2, ""))
      end

      UI.ReplaceWidget(
        Id(:catalogs_rp),
        Left(
          ComboBox(Id(:catalogs), Opt(:notify), _("Repository &Name"), items)
        )
      )

      if Ops.greater_than(Builtins.size(items), 0)
        UI.ChangeWidget(Id(:create_snapshot), :Enabled, true)
        UI.ChangeWidget(Id(:category_filter), :Enabled, true)
        UI.ChangeWidget(Id(:catalogs), :Enabled, true)
      else
        UI.ChangeWidget(Id(:create_snapshot), :Enabled, false)
        UI.ChangeWidget(Id(:category_filter), :Enabled, false)
        UI.ChangeWidget(Id(:catalogs), :Enabled, false)
      end

      nil
    end

    def InitStagingTableDialog(id)
      RedrawRepositoriesStagingMenu()
      RedrawPatchesTable("")

      nil
    end

    def AdjustAdditionalFilters
      # a mlti-selection-box label
      msb_label = _("Exclude All Patches of Selected Categories")

      UI.OpenDialog(
        VBox(
          MinWidth(
            Builtins.size(msb_label),
            MarginBox(
              1,
              1,
              VBox(MultiSelectionBox(Id(:category_filters), msb_label, []))
            )
          ),
          ButtonBox(
            PushButton(Id(:ok), Opt(:okButton), Label.OKButton),
            PushButton(Id(:cancel), Opt(:cancelButton), Label.CancelButton)
          )
        )
      )

      items = Builtins.maplist(@patch_categories) do |patch_type, type_translated|
        query = {
          "type"         => patch_type,
          "repositoryid" => @selected_catalog,
          "group"        => @selected_staging_group
        }
        Item(
          Id(patch_type),
          type_translated,
          SCR.Read(path(".smt.staging.category_filter"), query) == true
        )
      end

      UI.ChangeWidget(Id(:category_filters), :Items, items) if items != nil

      ret = UI.UserInput
      if ret == :ok
        newly_active_filters = Convert.convert(
          UI.QueryWidget(Id(:category_filters), :SelectedItems),
          :from => "any",
          :to   => "list <string>"
        )

        Builtins.foreach(@patch_categories) do |patch_type, type_translated|
          command = {
            "type"         => patch_type,
            "repositoryid" => @selected_catalog,
            "group"        => @selected_staging_group,
            "status"       => Builtins.contains(
              newly_active_filters,
              patch_type
            )
          }
          SCR.Write(path(".smt.staging.category_filter"), command)
        end
      end

      UI.CloseDialog

      nil
    end

    def SetPatchStatus(patchid, new_status)
      SCR.Write(
        path(".smt.staging.patch.status"),
        {
          "repositoryid" => @selected_catalog,
          "group"        => @selected_staging_group,
          "patchid"      => patchid,
          "status"       => new_status
        }
      )
    end

    def ReportFilteringNotAllowed
      # a pop-up message
      Report.Message(
        _(
          "This repository does not allow patch filtering.\nYou can create snapshots of its current stage though."
        )
      )

      nil
    end

    def TogglePatchStatus
      if @filtering_allowed_for_repository != true
        ReportFilteringNotAllowed()
        return
      end

      sel_patchid = Convert.to_string(
        UI.QueryWidget(Id(:patches_table), :CurrentItem)
      )

      if IsPatchFilteredByType(sel_patchid)
        # a pop-up message
        Report.Message(
          _(
            "This patch is filtered-out by a category-based filter\nand thus its status cannot be changed in this dialog."
          )
        )
        return
      end

      status = Ops.get_boolean(
        @current_patches,
        [sel_patchid, "filtered"],
        false
      )

      # Fallback
      status = false if status == nil

      # Inverting the status: "filtered" used as new "status"
      if SetPatchStatus(sel_patchid, status) != true
        Report.Error(_("Unable to change the current patch status."))
      end

      current_status = Convert.to_boolean(
        SCR.Read(
          path(".smt.staging.patch.status"),
          {
            "repositoryid" => @selected_catalog,
            "group"        => @selected_staging_group,
            "patchid"      => sel_patchid
          }
        )
      )

      # update the cache
      Ops.set(
        @current_patches,
        [sel_patchid, "filtered"],
        current_status == false
      )
      status_icon = GetPatchStatusIcon(
        Ops.get(@current_patches, sel_patchid, {})
      )
      UI.ChangeWidget(
        Id(:patches_table),
        term(:Item, sel_patchid, 3),
        @text_mode ?
          status_icon :
          term(:icon, Ops.get(@smt_patch_icons, status_icon, ""))
      )
      # focus the table again
      UI.SetFocus(Id(:patches_table))

      nil
    end

    def ChangeAllListedPatches(new_state)
      if @filtering_allowed_for_repository != true
        ReportFilteringNotAllowed()
        return
      end

      Builtins.foreach(@current_patches) do |patchid, patchdetails|
        # Patch cannot be changed
        next if IsPatchFilteredByType(patchid)
        # Patch has already the requierd status
        if Ops.get_boolean(@current_patches, [patchid, "filtered"], false) != new_state
          next
        end
        SetPatchStatus(patchid, new_state)
      end

      nil
    end

    def AskForSnapshotSigningKey(snapshot_settings)
      backup_settings = snapshot_settings.value

      # uses 'repositoryid' key
      can_be_filtered = Convert.to_boolean(
        SCR.Read(
          path(".smt.repository.staging_allowed"),
          snapshot_settings.value
        )
      )

      # Repository cannot be filtered, thus cannot be modified
      # thus doesn't need to be re/signed
      if can_be_filtered != true
        Builtins.y2milestone(
          "Repository cannot be filtered, re/signing not required"
        )
        return true
      end

      # Read the key ID only if defined
      key_id = SMTData.GetCredentialsDefined("LOCAL", "signingKeyID") == true ?
        SMTData.GetCredentials("LOCAL", "signingKeyID") :
        nil

      # No re/signing key in use, ignoring
      if key_id == nil || key_id == ""
        Builtins.y2milestone("No signing key used")
        return true
      end

      Builtins.y2milestone("Using KeyID: %1", key_id)
      Ops.set(snapshot_settings.value, "key", key_id)

      # Read the signingKeyPassphrase only if defined
      tmp_passphrase = SMTData.GetCredentialsDefined(
        "LOCAL",
        "signingKeyPassphrase"
      ) == true ?
        SMTData.GetCredentials("LOCAL", "signingKeyPassphrase") :
        nil

      # Passphrase defined in config file
      if tmp_passphrase != nil
        Builtins.y2milestone("Using KeyPassphrase from config file")
        Ops.set(snapshot_settings.value, "passphrase", tmp_passphrase)
        return true 
        # Passphrase already entered
      elsif @signing_passphrase != nil
        Builtins.y2milestone("Using cached KeyPassphrase")
        Ops.set(snapshot_settings.value, "passphrase", @signing_passphrase)
        return true
      end

      # 0xABDEF -> ABDEF
      key_id_match = key_id
      if Builtins.regexpmatch(key_id_match, "^0x.*")
        key_id_match = Builtins.regexpsub(key_id_match, "^0x(.*)", "\\1")
      end

      keys = Builtins.filter(GPG.PrivateKeys) do |one_key|
        Ops.get(one_key, "id") == key_id_match ||
          Ops.get(one_key, "id") == Ops.add("0x", key_id_match)
      end

      # Key description
      key_description = Builtins.sformat("Key ID: %1", key_id)

      if Ops.greater_than(Builtins.size(keys), 0)
        # Multiline key description
        key_description = Builtins.sformat(
          _("Key ID: %1\nUID: %2\nFingerprint: %3"),
          key_id,
          Builtins.mergestring(Ops.get_list(keys, [0, "uid"], []), "\n"),
          Ops.get_string(keys, [0, "fingerprint"], "")
        )
      end

      UI.OpenDialog(
        VBox(
          # pop-up heading
          Left(Heading(_("Signing Key Passphrase"))),
          # pop-up dialog message
          # %1 is replaced with a (possibly multiline) key descrioption
          Left(
            Label(
              Builtins.sformat(
                _(
                  "SMT is configured to sign the snapshot with the following key:\n" +
                    "\n" +
                    "%1\n" +
                    "\n" +
                    "Enter the key passphrase and press OK,\n" +
                    "otherwise press Cancel to skip the signing procedure."
                ),
                key_description
              )
            )
          ),
          VSpacing(1),
          HSquash(
            MinWidth(
              25,
              VBox(
                Password(Id(:pass1), Opt(:hstretch), _("Key &Passphrase")),
                Password(Id(:pass2), Opt(:hstretch), _("&Once Again"))
              )
            )
          ),
          ButtonBox(
            PushButton(Id(:ok), Opt(:okButton, :default), Label.OKButton),
            PushButton(Id(:cancel), Opt(:cancelButton), Label.CancelButton)
          )
        )
      )

      UI.SetFocus(Id(:pass1))
      ret = nil

      while true
        ret = UI.UserInput

        if ret == :cancel
          Builtins.y2warning("Signing will be disabled")
          snapshot_settings.value = deep_copy(backup_settings)
          break
        elsif ret == :ok
          p1 = Convert.to_string(UI.QueryWidget(Id(:pass1), :Value))
          p2 = Convert.to_string(UI.QueryWidget(Id(:pass2), :Value))

          if p1 != p2
            # pop-up error message
            Report.Error(_("Entered passphrases are not identical."))
            UI.SetFocus(Id(:pass1))
            next
          end

          Builtins.y2milestone("Passphrase has been entered")
          Ops.set(snapshot_settings.value, "passphrase", p1)
          break
        end
      end

      UI.CloseDialog

      true
    end

    def CreateSnapshot(type)
      snapshot_settings = {
        "repositoryid" => @selected_catalog,
        "group"        => @selected_staging_group,
        "type"         => type
      }
      # Do not log any passwords!
      Builtins.y2milestone("Creating snapshot: %1", snapshot_settings)

      # We allow to change the content just for the 'testing'
      # snapshot, 'production' is just a copy of that
      if type == "testing" &&
          (
            snapshot_settings_ref = arg_ref(snapshot_settings);
            _AskForSnapshotSigningKey_result = AskForSnapshotSigningKey(
              snapshot_settings_ref
            );
            snapshot_settings = snapshot_settings_ref.value;
            _AskForSnapshotSigningKey_result
          ) != true
        return false
      end

      # a bussy message
      UI.OpenDialog(Label(_("Creating repository snapshot...")))

      Builtins.y2milestone("Writing patches...")
      # Flush the cache (filters) from memory to database
      SCR.Write(path(".smt.staging.patches"), nil)

      Builtins.y2milestone("Writing snapshot...")
      # Create snapshot
      ret = SCR.Write(path(".smt.staging.snapshot"), snapshot_settings)
      Builtins.y2milestone("Creating snapshot finished with result: %1", ret)

      UI.CloseDialog

      if ret != true
        # a pop-up error message
        Report.Error(_("An error has occurred while creating the snapshot."))
      end

      RedrawRepositoriesStagingMenu()
      UpdateRepoDetails()

      ret
    end

    def HandleClientsTableDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")

      RedrawClientsTableDetails() if action == :clients_table

      nil
    end

    def HandleStagingTableDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")
      reason = Ops.get(event, "EventReason")

      # Selected another patch in table or double-click
      if action == :patches_table
        # Double-click on patch in table
        if reason == "Activated"
          TogglePatchStatus() 
          # The rest...
        else
          RedrawPatchesDetails()
        end
      elsif action == :toggle_patch_status
        TogglePatchStatus() 
        # Selected another catalog
      elsif action == :catalogs
        # Reset the category filter when selecting another catalog
        ResetPatchCategoryFilter()
        RedrawPatchesTable("")
      elsif action == :additional_filters
        AdjustAdditionalFilters()
        RedrawPatchesTable(GetSelectedPatchFilter())
      elsif action == :category_filter
        RedrawPatchesTable(GetSelectedPatchFilter())
      elsif action == :all_listed_enable
        ChangeAllListedPatches(true)
        RedrawPatchesTable(GetSelectedPatchFilter())
      elsif action == :all_listed_disable
        ChangeAllListedPatches(false)
        RedrawPatchesTable(GetSelectedPatchFilter())
      elsif action == :create_snapshot_testing
        CreateSnapshot("testing")
        RedrawPatchesTable(GetSelectedPatchFilter())
      elsif action == :create_snapshot_production
        CreateSnapshot("production")
        RedrawPatchesTable(GetSelectedPatchFilter())
      end

      nil
    end

    #    void StoreStagingTableDialog (string id, map event) {
    #    }

    def EmailValid(e_mail)
      # very simple e-mail validator
      Builtins.regexpmatch(e_mail, ".+@.+\\..+")
    end

    def HandleAddEditEmailAddress(e_mail)
      e_mail = "" if e_mail == nil

      UI.OpenDialog(
        VBox(
          HSquash(
            MinWidth(
              40,
              InputField(
                Id("e-mail"),
                e_mail == "" ? _("New &E-Mail") : _("Editing &E-Mail"),
                e_mail
              )
            )
          ),
          HBox(
            PushButton(Id(:ok), Opt(:default, :key_F10), Label.OKButton),
            HSpacing(2),
            PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton)
          )
        )
      )

      UI.SetFocus(Id("e-mail"))

      ret = nil
      while true
        ret = UI.UserInput

        # Cancel pressed
        break if ret != :ok

        # OK pressed
        new_mail = Convert.to_string(UI.QueryWidget(Id("e-mail"), :Value))

        if EmailValid(new_mail)
          @report_e_mails = Builtins.filter(@report_e_mails) do |one_email|
            one_email != e_mail
          end
          @report_e_mails = Builtins.toset(
            Builtins.add(@report_e_mails, new_mail)
          )
          break
        else
          Report.Error(
            Builtins.sformat(_("E-mail '%1' is not valid."), new_mail)
          )
          UI.SetFocus(Id("e-mail"))
        end
      end

      UI.CloseDialog

      RedrawReportEmailsTable() if ret == :ok

      nil
    end

    def HandleReportEmailTableDialog(id, event)
      event = deep_copy(event)
      return nil if id != "reporting"

      event_id = Ops.get(event, "ID")

      if event_id == :add
        HandleAddEditEmailAddress("")
      elsif event_id == :edit
        currently_selected = Convert.to_string(
          UI.QueryWidget(Id(:report_table), :CurrentItem)
        )
        HandleAddEditEmailAddress(currently_selected)
      elsif event_id == :delete
        currently_selected = Convert.to_string(
          UI.QueryWidget(Id(:report_table), :CurrentItem)
        )
        if Confirm.Delete(currently_selected)
          @report_e_mails = Builtins.filter(@report_e_mails) do |one_email|
            one_email != currently_selected
          end
          RedrawReportEmailsTable()
        end
      end

      nil
    end

    def ToggleRepository(current_id, entry)
      if current_id == nil
        Builtins.y2error("Erroneous ID: %1", current_id)
        # pop-up error message
        Report.Error(_("Internal Error: Cannot toggle the current state."))
        return nil
      end

      current_state = Ops.get_boolean(@catalogs_info, [current_id, entry])

      if current_state == nil
        Builtins.y2error(
          "Erroneous entry: %1 (%2)",
          Ops.get(@catalogs_info, current_id, {}),
          entry
        )
        # pop-up error message
        Report.Error(_("Internal Error: Cannot toggle the current state."))
        return nil
      end

      cmd_params = { "repositoryid" => current_id }
      col_to_change = 0
      new_state = current_state == false

      if entry == "mirroring"
        Ops.set(cmd_params, "mirroring", new_state)
        col_to_change = 2
      elsif entry == "staging"
        Ops.set(cmd_params, "staging", new_state)
        col_to_change = 3
      else
        Builtins.y2error("Unknown entry to change: %1", entry)
        # pop-up error message
        Report.Error(_("Internal Error: Cannot toggle the current state."))
        return nil
      end

      success = SCR.Write(path(".smt.repository.set"), cmd_params)
      Builtins.y2milestone("Adjusting repository %1: %2", cmd_params, success)

      if success != true
        Report.Error(_("Internal Error: Cannot toggle the current state."))
      else
        # Switch the current state
        current_state = current_state == false
        Ops.set(@catalogs_info, [current_id, entry], current_state)
        UI.ChangeWidget(
          Id(:catalogs_table),
          term(:Item, current_id, col_to_change),
          current_state == true ? @yes : @no
        )
      end

      AdjustRepositoriesButtons()

      nil
    end

    def MirrorRepository(repository_id)
      if repository_id == nil || repository_id == ""
        Builtins.y2error("Unable to mirror: %1", repository_id)
      end

      Builtins.y2milestone("Mirroring repository: %1", repository_id)

      cmd = Builtins.sformat(
        "/usr/sbin/smt-mirror -L '%1' --repository '%2'",
        String.Quote(@default_mirrroring_log),
        String.Quote(repository_id)
      )

      Builtins.y2milestone("Starting process: %1", cmd)
      process_PID = Convert.to_integer(
        SCR.Execute(path(".process.start_shell"), cmd)
      )
      Builtins.y2milestone("Got PID: %1", process_PID)

      if process_PID == nil
        # Error message
        Report.Error(_("Unable to mirror the selected repository."))
        return
      end

      UI.OpenDialog(
        VBox(
          Left(Heading(_("Mirroring Repository"))),
          MinWidth(80, LogView(Id(:log), _("&Progress"), 16, 1024)),
          ReplacePoint(Id(:button), PushButton(Id(:cancel), _("&Stop")))
        )
      )

      UI.ChangeWidget(
        Id(:log),
        :LastLine,
        Builtins.sformat(
          _("Started mirroring the selected repository with process ID: %1\n"),
          process_PID
        )
      )

      line = ""
      ret = nil
      aborted = false

      while Convert.to_boolean(SCR.Read(path(".process.running"), process_PID)) == true
        line = Convert.to_string(
          SCR.Read(path(".process.read_line"), process_PID)
        )

        if line != nil
          UI.ChangeWidget(Id(:log), :LastLine, Ops.add(line, "\n"))
        else
          Builtins.sleep(200)
        end

        ret = UI.PollInput

        if ret == :cancel
          Builtins.y2milestone("Really abort?")
          if Popup.AnyQuestion(
              # a headline
              _("Aborting the Mirroring"),
              # a pop-up question
              _("Are you sure you want to abort the current mirroring process?"),
              # push button
              _("Abort Mirroring"),
              # push button
              _("Continue Mirroring"),
              :focus_no
            )
            UI.ChangeWidget(Id(:log), :LastLine, _("Aborting...\n"))
            Builtins.y2milestone("Aborting...")
            SCR.Execute(path(".process.kill"), process_PID)
            aborted = true
            break
          end
        end
      end
      exit_code = SCR.Read(path(".process.status"), process_PID)
      Builtins.y2milestone("Mirror exit status: %1", exit_code)

      # any lines left in buffer?
      line = Convert.to_string(SCR.Read(path(".process.read"), process_PID))
      if line != nil && Ops.greater_than(Builtins.size(line), 0)
        UI.ChangeWidget(Id(:log), :LastLine, Ops.add(line, "\n"))
      end

      if !aborted
        # Flush the internal cache after mirroring
        Builtins.y2milestone(
          "Staging allowed: %1: %2",
          repository_id,
          SCR.Read(
            path(".smt.repository.staging_allowed"),
            { "repositoryid" => repository_id, "force_check" => true }
          )
        )

        # BNC #519216: Purge cache right after mirroring
        SCR.Execute(
          path(".smt.repository.purge_cache"),
          {
            "repositoryid" => repository_id,
            "group"        => @selected_staging_group
          }
        )

        if exit_code == 0
          UI.ChangeWidget(Id(:log), :LastLine, _("Finished\n"))
        else
          line = Convert.to_string(SCR.Read(path(".process.read_stderr"), process_PID))
          if line != nil && Ops.greater_than(Builtins.size(line), 0)
            UI.ChangeWidget(Id(:log), :LastLine, Ops.add(line, "\n"))
          end
          UI.ChangeWidget(Id(:log), :LastLine, _("Mirroring failed\n"))
        end
        UI.ReplaceWidget(Id(:button), PushButton(Id(:ok), Label.OKButton))
        UI.UserInput
      end
      SCR.Execute(path(".process.release"), process_PID)

      UI.CloseDialog

      nil
    end

    def HandleRepositoriesTableDialog(id, event)
      event = deep_copy(event)
      return nil if id != "repositories"

      event_id = Ops.get(event, "ID")

      current_id = Convert.to_string(
        UI.QueryWidget(Id(:catalogs_table), :CurrentItem)
      )

      if event_id == :toggle_mirroring
        ToggleRepository(current_id, "mirroring")
      elsif event_id == :toggle_staging
        ToggleRepository(current_id, "staging")
      elsif event_id == :mirror_now
        MirrorRepository(@catalogs_info[current_id]["catalog_id"])
        RedrawCatalogsTable(@filters)
      elsif event_id == :catalogs_table
        # Table->double_click
        if Ops.get_string(event, "EventReason", "") == "Activated"
          ToggleRepository(current_id, "mirroring") 
          # Table->selected(_other_item)
        else
          AdjustRepositoriesButtons()
        end
      elsif event_id == :filter || (event_id == :repos_filter && event["EventReason"] == "Activated")
        filter = UI.QueryWidget(Id(:repos_filter), :Value)
        @filters = filter.empty? ? [] : [filter]
        RedrawCatalogsTable(@filters)
      end

      # Catalog have been toggled, re-focus the table again
      UI.SetFocus(Id(:catalogs_table)) unless event_id == :repos_filter
      nil
    end

    def CutZeros(with_zeros)
      if Builtins.regexpmatch(with_zeros, "^0.+")
        with_zeros = Builtins.regexpsub(with_zeros, "^0(.+)", "\\1")
      end

      with_zeros
    end

    def CutPerriodicalSigns(settings)
      settings = deep_copy(settings)
      tmp_settings = deep_copy(settings)

      Builtins.foreach(["hour", "minute", "day_of_month", "day_of_month"]) do |key|
        if Builtins.regexpmatch(Ops.get_string(settings, key, ""), "\\*/")
          Ops.set(
            settings,
            key,
            Builtins.regexpsub(
              Ops.get_string(settings, key, ""),
              "\\*/(.*)",
              "\\1"
            )
          )
        end
      end

      if tmp_settings != settings
        Builtins.y2milestone(
          "Periodicall settings changed %1 -> %2",
          tmp_settings,
          settings
        )
      end

      deep_copy(settings)
    end

    def FindJobName(command)
      ret = nil

      Builtins.foreach(@smt_cron_scripts) do |script_command, script_name|
        if Builtins.regexpmatch(command, script_command)
          ret = script_name
          raise Break
        end
      end

      # BNC #520557: Manual or additional cron commands
      if ret == nil
        Builtins.y2error("Unknown cron command: %1", command)
        ret = Builtins.sformat(_("Command: %1"), command)
      end

      ret
    end

    def FindJobScript(command)
      ret = ""

      Builtins.foreach(@smt_cron_scripts) do |script_command, script_name|
        if Builtins.regexpmatch(command, script_command)
          ret = script_command
          raise Break
        end
      end

      ret
    end

    # Redraws the table of currently scheduled NU mirrorings.
    def RedrawScheduledMirroringTable
      # Offer adding the script only if exists
      if @smt_support_checked != true
        @smt_support_checked = true

        if FileUtils.Exists("/usr/sbin/smt-support")
          Builtins.y2milestone("SMT support script exists")
          Ops.set(
            @smt_cron_scripts,
            "/usr/sbin/smt-support -U",
            _("Uploading Support Configs")
          )
        else
          Builtins.y2milestone("SMT support script does not exist")
        end
      end

      items = []

      counter = -1
      Builtins.foreach(SMTData.GetCronSettings) do |one_entry|
        counter = Ops.add(counter, 1)
        next if one_entry == nil || one_entry == {}
        Builtins.foreach(
          ["day_of_month", "day_of_week", "hour", "minute", "month"]
        ) do |key|
          Ops.set(one_entry, key, "*") if Ops.get(one_entry, key) == nil
        end
        item = Item(Id(counter))
        item = Builtins.add(
          item,
          FindJobName(Ops.get_string(one_entry, "command", ""))
        )
        # covers */15 - every 15 minutes/hours
        periodically = false
        # More often than 'daily'
        if Builtins.regexpmatch(Ops.get_string(one_entry, "hour", ""), "\\*/") ||
            Builtins.regexpmatch(
              Ops.get_string(one_entry, "minute", ""),
              "\\*/"
            )
          periodically = true
          # Script-call period, used as a table item
          item = Builtins.add(item, _("Periodically"))
          item = Builtins.add(item, "--")
          item = Builtins.add(item, "--") 
          # Monthly
        elsif Ops.get_string(one_entry, "day_of_month", "*") != "*"
          # Script-call period, used as a table item
          item = Builtins.add(item, _("Monthly"))
          item = Builtins.add(item, "--")
          item = Builtins.add(
            item,
            Ops.get_locale(one_entry, "day_of_month", _("Undefined"))
          ) 
          # Weekly
        elsif Ops.get_string(one_entry, "day_of_week", "*") != "*"
          # Script-call period, used as a table item
          item = Builtins.add(item, _("Weekly"))
          item = Builtins.add(
            item,
            Ops.get(
              @nrdays_to_names,
              Ops.get_string(one_entry, "day_of_week", ""),
              _("Undefined")
            )
          )
          item = Builtins.add(item, "--") 
          # Daily
        else
          # Script-call period, used as a table item
          item = Builtins.add(item, _("Daily"))
          item = Builtins.add(item, "--")
          item = Builtins.add(item, "--")
        end
        one_entry = CutPerriodicalSigns(one_entry)
        if periodically && Ops.get_string(one_entry, "hour", "*") != "*" &&
            Ops.get_string(one_entry, "hour", "0") != "0"
          item = Builtins.add(
            item,
            Builtins.sformat(
              _("Every %1 hours"),
              Ops.get_locale(one_entry, "hour", _("Undefined"))
            )
          )
        elsif periodically
          item = Builtins.add(item, "--")
        else
          item = Builtins.add(
            item,
            Ops.get_locale(one_entry, "hour", _("Undefined"))
          )
        end
        if periodically && Ops.get_string(one_entry, "minute", "*") != "*" &&
            Ops.get_string(one_entry, "minute", "0") != "0"
          item = Builtins.add(
            item,
            Builtins.sformat(
              _("Every %1 minutes"),
              Ops.get_locale(one_entry, "minute", _("Undefined"))
            )
          )
        elsif periodically
          item = Builtins.add(item, "--")
        else
          item = Builtins.add(
            item,
            Ops.get_locale(one_entry, "minute", _("Undefined"))
          )
        end
        items = Builtins.add(items, item)
      end

      if items == nil
        items = []
        Builtins.y2error("Erroneous items!")
      end
      UI.ChangeWidget(Id("scheduled_NU_mirroring"), :Items, items)

      buttons_enabled = items != nil && Builtins.size(items) != 0
      UI.ChangeWidget(Id(:edit), :Enabled, buttons_enabled)
      UI.ChangeWidget(Id(:delete), :Enabled, buttons_enabled)

      nil
    end

    def DisableScheduledMirroringTable
      UI.ChangeWidget(Id("scheduled_NU_mirroring"), :Enabled, false)
      UI.ChangeWidget(Id(:add), :Enabled, false)
      UI.ChangeWidget(Id(:edit), :Enabled, false)
      UI.ChangeWidget(Id(:delete), :Enabled, false)

      nil
    end

    def InitScheduledDownloadsDialog(id)
      # Lazy check for cron but only once
      if @cron_rpms_checked != true
        @cron_rpms_checked = true
        @cron_rpms_installed = PackageSystem.CheckAndInstallPackagesInteractive(
          ["cron"]
        )
        Builtins.y2milestone("cron RPM is installed: %1", @cron_rpms_installed)
      end

      if @cron_rpms_installed != true
        DisableScheduledMirroringTable()
        # TRANSLATORS: informational message (Report::Message)
        Report.Message(
          _(
            "Scheduled jobs have been disabled due to missing packages.\n" +
              "To install the missing packages and set up the scheduled jobs,\n" +
              "you need to restart the YaST SMT Configuration module."
          )
        )
        return
      end

      RedrawScheduledMirroringTable()

      nil
    end

    def AdjustAddEditDialogToFrequency
      current_freq = Convert.to_symbol(UI.QueryWidget(Id(:frequency), :Value))

      day_of_week_available = false
      day_of_month_available = false

      if current_freq == :weekly
        day_of_week_available = true
      elsif current_freq == :monthly
        day_of_month_available = true
      end

      if current_freq == :periodically
        UI.ChangeWidget(Id("hour"), :Label, _("Every H-th &Hour"))
        UI.ChangeWidget(Id("minute"), :Label, _("Every M-th &Minute"))
      else
        UI.ChangeWidget(Id("hour"), :Label, _("&Hour"))
        UI.ChangeWidget(Id("minute"), :Label, _("&Minute"))
      end

      UI.ChangeWidget(Id("day_of_week"), :Enabled, day_of_week_available)
      UI.ChangeWidget(Id("day_of_month"), :Enabled, day_of_month_available)

      nil
    end

    # Validates and saves the cron entry.
    def ValidateAndSaveScheduledMirroring(schd_id)
      settings = {
        "day_of_month" => "*",
        "day_of_week"  => "*",
        "hour"         => "*",
        "minute"       => "*",
        "month"        => "*",
        "command"      => ""
      }

      current_freq = Convert.to_symbol(UI.QueryWidget(Id(:frequency), :Value))

      hour = Builtins.tostring(UI.QueryWidget(Id("hour"), :Value))
      minute = Builtins.tostring(UI.QueryWidget(Id("minute"), :Value))
      day_of_month = Builtins.tostring(
        UI.QueryWidget(Id("day_of_month"), :Value)
      )
      day_of_week = Builtins.tostring(UI.QueryWidget(Id("day_of_week"), :Value))

      Ops.set(settings, "hour", CutZeros(hour))
      Ops.set(settings, "minute", CutZeros(minute))

      # Periodical frequency needs to add "*/X" periodical sign
      if current_freq == :periodically
        if Ops.get_string(settings, "hour", "0") != "0" &&
            Ops.get_string(settings, "hour", "*") != "*"
          Ops.set(
            settings,
            "hour",
            Builtins.sformat("*/%1", Ops.get_string(settings, "hour", "0"))
          )
        else
          Ops.set(settings, "hour", "*")
        end
        if Ops.get_string(settings, "minute", "0") != "0" &&
            Ops.get_string(settings, "minute", "*") != "*"
          Ops.set(
            settings,
            "minute",
            Builtins.sformat("*/%1", Ops.get_string(settings, "minute", "0"))
          )
        else
          Ops.set(settings, "minute", "*")
        end
      elsif current_freq == :weekly
        Ops.set(settings, "day_of_week", day_of_week)
      elsif current_freq == :monthly
        Ops.set(settings, "day_of_month", day_of_month)
      end

      command = Convert.to_string(UI.QueryWidget(Id(:job_to_run), :Value))
      Ops.set(settings, "command", command)

      if schd_id != nil && Ops.greater_than(schd_id, -1)
        SMTData.ReplaceCronJob(schd_id, settings)
      else
        SMTData.AddNewCronJob(settings)
      end

      true
    end

    # Opens up dialog for adding or editing a cron-job entry.
    #
    # @param [Fixnum] schd_id offset ID in the list of current jobs
    #        -1 for adding a new entry
    def AddEditScheduledMirroring(schd_id)
      settings = {}
      editing = false
      dialog_ret = false

      if schd_id != nil && Ops.greater_than(schd_id, -1)
        settings = Ops.get(SMTData.GetCronSettings, schd_id, {})
        if settings == nil
          Builtins.y2error(
            "Wrong settings on offset %1: %2",
            schd_id,
            SMTData.GetCronSettings
          )
        end
        editing = true
      end

      day_of_week = Builtins.maplist(@nrdays_to_names) do |dof_id, dof_name|
        Item(Id(dof_id), dof_name, Ops.get(settings, "day_of_week") == dof_id)
      end

      freqency_sel = :daily

      # "*/15" - Every 15 minutes, hours
      if Builtins.regexpmatch(Ops.get_string(settings, "hour", ""), "\\*/") ||
          Builtins.regexpmatch(Ops.get_string(settings, "minute", ""), "\\*/")
        freqency_sel = :periodically
        settings = CutPerriodicalSigns(settings) 
        # Monthly
      elsif Ops.get_string(settings, "day_of_month", "*") != "*"
        freqency_sel = :monthly 
        # Weekly
      elsif Ops.get_string(settings, "day_of_week", "*") != "*"
        freqency_sel = :weekly
      end

      Ops.set(settings, "hour", "0") if Ops.get(settings, "hour") == "*"

      Ops.set(settings, "minute", "0") if Ops.get(settings, "minute") == "*"

      if Ops.get(settings, "day_of_month") == "*"
        Ops.set(settings, "day_of_month", "0")
      end

      hour = Builtins.tointeger(CutZeros(Ops.get_string(settings, "hour", "0")))
      minute = Builtins.tointeger(
        CutZeros(Ops.get_string(settings, "minute", "0"))
      )
      day_of_month = Builtins.tointeger(
        CutZeros(Ops.get_string(settings, "day_of_month", "0"))
      )

      scripts = Builtins.maplist(@smt_cron_scripts) do |script_command, script_name|
        Item(Id(script_command), script_name)
      end

      scripts = Builtins.sort(scripts) do |x, y|
        Ops.less_than(Ops.get_string(x, 1, "A"), Ops.get_string(y, 1, "A"))
      end

      UI.OpenDialog(
        VBox(
          HSpacing(35),
          Left(
            Heading(
              editing ?
                _("Editing a SMT Scheduled Job") :
                _("Adding New SMT Scheduled Job")
            )
          ),
          VSpacing(1),
          HBox(
            Left(
              ComboBox(
                Id(:frequency),
                Opt(:notify),
                _("&Frequency"),
                [
                  Item(Id(:daily), _("Daily"), freqency_sel == :daily),
                  Item(Id(:weekly), _("Weekly"), freqency_sel == :weekly),
                  Item(Id(:monthly), _("Monthly"), freqency_sel == :monthly),
                  Item(
                    Id(:periodically),
                    _("Periodically"),
                    freqency_sel == :periodically
                  )
                ]
              )
            ),
            HSpacing(2),
            Left(ComboBox(Id(:job_to_run), _("&Job to Run"), scripts))
          ),
          VSpacing(1),
          Frame(
            _("Job Start Time"),
            HBox(
              HSpacing(2),
              VBox(
                ComboBox(
                  Id("day_of_week"),
                  Opt(:hstretch),
                  _("Day of the &Week"),
                  day_of_week
                ),
                IntField(Id("hour"), _("&Hour"), 0, 24, hour)
              ),
              HSpacing(2),
              VBox(
                IntField(
                  Id("day_of_month"),
                  _("&Day of the Month"),
                  1,
                  31,
                  day_of_month
                ),
                IntField(Id("minute"), _("&Minute"), 0, 59, minute)
              ),
              HSpacing(2)
            )
          ),
          VSpacing(1),
          HBox(
            PushButton(
              Id(:ok),
              Opt(:default, :key_F10),
              editing ? Label.OKButton : Label.AddButton
            ),
            HSpacing(2),
            PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton)
          )
        )
      )

      AdjustAddEditDialogToFrequency()

      # select the right script if editing already entered cron job
      if editing
        script = FindJobScript(Ops.get_string(settings, "command", ""))

        # BNC #520557: Handling unknown script
        if script == "" || script == nil
          Builtins.y2error("Unable to determine script name %1", settings)

          scripts = Builtins.add(
            scripts,
            Item(
              Id(Ops.get_string(settings, "command", "")),
              Builtins.sformat(
                _("Command: %1"),
                Ops.get_string(settings, "command", "")
              )
            )
          )
          UI.ChangeWidget(Id(:job_to_run), :Items, scripts)

          script = Ops.get_string(settings, "command", "")
        end

        UI.ChangeWidget(Id(:job_to_run), :Value, script)
      end

      ret = nil

      while true
        ret = UI.UserInput

        if ret == :frequency
          AdjustAddEditDialogToFrequency()
        elsif ret == :ok || ret == :next
          if !ValidateAndSaveScheduledMirroring(schd_id)
            next
          else
            dialog_ret = true
            break
          end
        elsif ret == :cancel
          dialog_ret = false
          break
        else
          Builtins.y2error("Unhandled ret: %1", ret)
        end
      end

      UI.CloseDialog

      dialog_ret
    end

    def SetFocusTable
      UI.SetFocus(Id("scheduled_NU_mirroring"))

      nil
    end

    def HandleScheduledDownloadsDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")

      changed = false

      # Add
      if action == :add
        changed = AddEditScheduledMirroring(-1)
        SetFocusTable() 

        # Edit
      elsif action == :edit
        current_item = Convert.to_integer(
          UI.QueryWidget(Id("scheduled_NU_mirroring"), :CurrentItem)
        )
        changed = AddEditScheduledMirroring(current_item)
        SetFocusTable() 

        # Delete
      elsif action == :delete
        current_item = Convert.to_integer(
          UI.QueryWidget(Id("scheduled_NU_mirroring"), :CurrentItem)
        )

        if !Confirm.DeleteSelected
          SetFocusTable()
          return nil
        end

        SMTData.RemoveCronJob(current_item)
        changed = true
        SetFocusTable()
      end

      RedrawScheduledMirroringTable() if changed

      nil
    end

    def StoreScheduledDownloadsDialog(id, event)
      event = deep_copy(event)
      nil
    end

    def ReallyExit
      # TRANSLATORS: yes-no popup
      Popup.YesNo(_("Really exit?\nAll changes will be lost."))
    end
  end
end
