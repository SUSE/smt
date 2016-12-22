# encoding: utf-8

# File:	clients/smt.ycp
# Package:	Configuration of smt
# Summary:	Definition of dialog sequences
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id: wizard.ycp 27914 2006-02-13 14:32:08Z locilka $
#
# Main file for smt configuration. Uses all other files.
module Yast
  module SmtWizardInclude
    def initialize_smt_wizard(include_target)
      Yast.import "UI"
      textdomain "smt"

      Yast.import "CWMTab"
      Yast.import "Sequencer"
      Yast.import "CWM"
      Yast.import "Mode"
      Yast.import "CWMFirewallInterfaces"

      Yast.include include_target, "smt/helps.rb"
      Yast.include include_target, "smt/dialogs.rb"

      @widgets = {
        "cr"           => {
          "widget"            => :custom,
          "help"              => Ops.get(@HELPS, "credentials", ""),
          "custom_widget"     => Empty(),
          "handle"            => fun_ref(
            method(:HandleCredentialsDialog),
            "symbol (string, map)"
          ),
          "init"              => fun_ref(
            method(:InitCredentialsDialog),
            "void (string)"
          ),
          "store"             => fun_ref(
            method(:StoreCredentialsDialog),
            "void (string, map)"
          ),
          "validate_type"     => :function,
          "validate_function" => fun_ref(
            method(:ValidateCredentialsDialog),
            "boolean (string, map)"
          )
        },
        "db"           => {
          "widget"            => :custom,
          "help"              => Ops.get(@HELPS, "database", ""),
          "custom_widget"     => Empty(),
          "validate_type"     => :function,
          "validate_function" => fun_ref(
            method(:ValidateDatabaseDialog),
            "boolean (string, map)"
          ),
          "init"              => fun_ref(
            method(:InitDatabaseDialog),
            "void (string)"
          ),
          "store"             => fun_ref(
            method(:StoreDatabaseDialog),
            "void (string, map)"
          )
        },
        "sd"           => {
          "widget"        => :custom,
          "help"          => Ops.get(@HELPS, "scheduled_downloads", ""),
          "custom_widget" => Empty(),
          "handle"        => fun_ref(
            method(:HandleScheduledDownloadsDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitScheduledDownloadsDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreScheduledDownloadsDialog),
            "void (string, map)"
          )
        },
        "reporting"    => {
          "widget"        => :custom,
          "help"          => Ops.get(@HELPS, "reporting", ""),
          "custom_widget" => Empty(),
          "handle"        => fun_ref(
            method(:HandleReportEmailTableDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitReportEmailTableDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreReportEmailTableDialog),
            "void (string, map)"
          )
        },
        "firewall"     => CWMFirewallInterfaces.CreateOpenFirewallWidget(
          {
            # renamed in SLES11
            "services"        => [
              "service:apache2",
              "service:apache2-ssl"
            ],
            "display_details" => false
          }
        ),
        "repositories" =>
          # "store"	: StoreRepositoriesTableDialog,
          {
            "widget"        => :custom,
            "help"          => Ops.get(@HELPS, "repositories", ""),
            "custom_widget" => Empty(),
            "handle"        => fun_ref(
              method(:HandleRepositoriesTableDialog),
              "symbol (string, map)"
            ),
            "init"          => fun_ref(
              method(:InitRepositoriesTableDialog),
              "void (string)"
            )
          },
        "staging" =>
          # "store"	: StoreStagingTableDialog,
          {
            "widget"        => :custom,
            "help"          => Ops.get(@HELPS, "staging", ""),
            "custom_widget" => Empty(),
            "handle"        => fun_ref(
              method(:HandleStagingTableDialog),
              "symbol (string, map)"
            ),
            "init"          => fun_ref(
              method(:InitStagingTableDialog),
              "void (string)"
            )
          },
        "clients"      => {
          "widget"        => :custom,
          "help"          => Ops.get(@HELPS, "staging", ""),
          "custom_widget" => Empty(),
          "handle"        => fun_ref(
            method(:HandleClientsTableDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitClientsTableDialog),
            "void (string)"
          )
        }
      }

      @tabs = {
        "credentials"         => {
          # TRANSLATORS: tab-header
          "header"       => _(
            "Customer Center Access"
          ),
          "widget_names" => ["cr", "firewall"],
          "contents"     => CredentialsDialogContent()
        },
        "database"            => {
          # TRANSLATORS: tab-header
          "header"       => _(
            "Database and Reporting"
          ),
          "widget_names" => ["db", "reporting"],
          "contents"     => VBox(
            DatabaseDialogContent(),
            VSpacing(1),
            ReportEmailTableContent(),
            VStretch()
          )
        },
        "repositories"        => {
          # TRANSLATORS: tab-header
          "header"       => _("Repositories"),
          "widget_names" => ["repositories"],
          "contents"     => CatalogsTableContent()
        },
        "staging"             => {
          # TRANSLATORS: tab-header
          "header"       => _("Staging"),
          "widget_names" => ["staging"],
          "contents"     => StagingTableContent()
        },
        "clients"             => {
          # TRANSLATORS: tab-header
          "header"       => _("Clients Status"),
          "widget_names" => ["clients"],
          "contents"     => ClientsTableContent()
        },
        "scheduled_downloads" => {
          # TRANSLATORS: tab-header
          "header"       => _("Scheduled SMT Jobs"),
          "widget_names" => ["sd"],
          "contents"     => ScheduledDownloadsDialogContent()
        }
      }
    end

    def InstallCredentialsDialog
      w = CWM.CreateWidgets(
        Ops.get_list(@tabs, ["credentials", "widget_names"], []),
        @widgets
      )
      contents = CWM.PrepareDialog(
        Ops.get_term(@tabs, ["credentials", "contents"], Empty()),
        w
      )
      caption = Builtins.sformat(
        _("SMT Configuration Wizard - Step %1/%2"),
        1,
        2
      )
      help = CWM.MergeHelps(w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.NextButton
      )
      CWM.Run(w, {})
    end

    def InstallDatabaseDialog
      w = CWM.CreateWidgets(
        Ops.get_list(@tabs, ["database", "widget_names"], []),
        @widgets
      )
      contents = CWM.PrepareDialog(
        Ops.get_term(@tabs, ["database", "contents"], Empty()),
        w
      )
      caption = Builtins.sformat(
        _("SMT Configuration Wizard - Step %1/%2"),
        2,
        2
      )
      help = CWM.MergeHelps(w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        Label.NextButton
      )
      CWM.Run(w, {})
    end

    def MainSequence(sequence_type)
      wd = {}
      caption = ""

      if sequence_type == "config"
        # TRANSLATORS: dialog caption
        caption = _("Update Server Configuration")
        wd = {
          "tab" => CWMTab.CreateWidget(
            {
              "tab_order"    => [
                "credentials",
                "database",
                "scheduled_downloads"
              ],
              "tabs"         => @tabs,
              "widget_descr" => @widgets,
              "initial_tab"  => "credentials"
            }
          )
        }
      elsif sequence_type == "management"
        # TRANSLATORS: dialog caption
        caption = _("SMT Management")
        wd = {
          "tab" => CWMTab.CreateWidget(
            {
              "tab_order"    => ["repositories", "staging", "clients"],
              "tabs"         => @tabs,
              "widget_descr" => @widgets,
              "initial_tab"  => "repositories"
            }
          )
        }
      else
        Builtins.y2error("Unknown sequence_type: %1", sequence_type)
      end

      contents = VBox("tab")

      w = CWM.CreateWidgets(
        ["tab"],
        Convert.convert(
          wd,
          :from => "map <string, any>",
          :to   => "map <string, map <string, any>>"
        )
      )
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.OKButton
      )
      Wizard.DisableBackButton
      Wizard.SetAbortButton(:abort, Label.CancelButton)

      if UI.WidgetExists(Id(:rep_next))
        UI.ReplaceWidget(Id(:rep_next),
          PushButton(Id(:next), Opt(:key_F10), Label.OKButton)
        )
      end

      Wizard.SetTitleIcon("yast-smt")

      CWM.Run(w, { :abort => fun_ref(method(:ReallyExit), "boolean ()") })
    end

    def MainInstallSequence
      aliases = { "credentials" => lambda { InstallCredentialsDialog() }, "database" => lambda(
      ) do
        InstallDatabaseDialog()
      end }

      sequence = {
        "ws_start"    => "credentials",
        "credentials" => { :abort => :abort, :next => "database" },
        "database"    => { :abort => :abort, :next => :next }
      }

      Wizard.SetTitleIcon("yast-smt")

      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)
    end

    def SMTSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence("config") },
        "check" => [lambda { CheckConfigDialog() }, true],
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "check" },
        "check"    => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog
      Wizard.DisableBackButton
      Wizard.SetAbortButton(:abort, Label.CancelButton)
      Wizard.SetNextButton(:next, Label.OKButton)
      Wizard.SetTitleIcon("yast-smt")

      ret = Sequencer.Run(aliases, sequence)
      Wizard.CloseDialog

      deep_copy(ret)
    end

    def SMTManagementSequence
      aliases = {
        "read"  => [lambda { ReadManagementDialog() }, true],
        "main"  => lambda { MainSequence("management") },
        "write" => [lambda { WriteManagementDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog
      Wizard.DisableBackButton
      Wizard.SetAbortButton(:abort, Label.CancelButton)
      Wizard.SetNextButton(:next, Label.OKButton)
      Wizard.SetTitleIcon("yast-smt")

      ret = Sequencer.Run(aliases, sequence)
      Wizard.CloseDialog

      deep_copy(ret)
    end

    def SMTInstallSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainInstallSequence() },
        "check" => [lambda { CheckConfigDialog() }, true],
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "check" },
        "check"    => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.SetTitleIcon("yast-smt")
      Wizard.DisableBackButton
      Wizard.SetAbortButton(:abort, Label.CancelButton)
      Wizard.SetNextButton(:next, Label.OKButton)

      ret = Sequencer.Run(aliases, sequence)

      Wizard.RestoreNextButton
      Wizard.RestoreAbortButton
      Wizard.RestoreBackButton

      deep_copy(ret)
    end
  end
end
