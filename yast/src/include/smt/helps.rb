# encoding: utf-8

# File:	include/smt/helps.ycp
# Package:	Configuration of smt
# Summary:	Help texts of all the dialogs
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id: helps.ycp 27914 2006-02-13 14:32:08Z locilka $
module Yast
  module SmtHelpsInclude
    def initialize_smt_helps(include_target)
      textdomain "smt"

      @HELPS = {
        "credentials" =>
          # TRANSLATORS: help a1
          _(
            "<p><big><b>Customer Center Access</b></big><br>\nEnter the credentials for Novell Updates (NU) here.</p>\n"
          ) +
            # TRANSLATORS: help a2
            _(
              "<p>It is important to select properly the protocol to communicate with the Customer Center,\n" +
                "since the SUSE Customer Center uses different communication protocol than the\n" +
                "Novell Customer Center. We recommend to use SUSE Customer Center where possible.</p>\n"
            ) +
            # TRANSLATORS: help a3
            _(
              "<p><b>User</b> and <b>Password</b> are needed for Customer Center authentication.\n" +
                "To test the credentials you entered, click <b>Test</b>.\n" +
                "SMT then connects to the Customer Center server for authentication and download of\n" +
                "test data.</p>\n"
            ) +
            # TRANSLATORS: help a4
            _(
              "<p>E-mail should be the one you used to register to the customer center.</p>"
            ),
        "database" =>
          # TRANSLATORS: help b1
          _(
            "<p><big><b>Database</b></big><br>\n" +
              "For security reasons, SMT requires a separate user to connect to the database.\n" +
              "With <b>Database Password</b>, set or change the database\n" +
              "password for that user. The password should not be empty.</p>\n"
          ),
        "reporting" =>
          # TRANSLATORS: help c1
          _(
            "<p><big><b>Reporting</b></big><br>\nHere you can set up a list of e-mail addresses that SMT will send reports to.</p>\n"
          ),
        "scheduled_downloads" =>
          # TRANSLATORS: help d1
          _(
            "<p><big><b>Schedule SMT Jobs</b></big><br>\nHere you can edit periodical SMT jobs.</p>"
          ) +
            # TRANSLATORS: help d2
            _("<p>When adding a new job, first select a <b>Job to Run</b>.</p>") +
            # TRANSLATORS: help d3
            _(
              "<p>When editing a current job or adding new one, the <b>Frequency</b> selection box\n" +
                "switches dialog mode according to the currently selected value.\n" +
                "Some fields are enabled or disabled accordingly, e.g., <b>Day of the Week</b>\n" +
                "is disabled for <tt>Daily</tt> job frequency.</p>\n"
            ),
        "repositories" =>
          # TRANSLATORS: help e1
          _(
            "<p><big><b>Repositories</b></big><br>\nHere you can see all repositories available for mirroring.</p>"
          ) +
            # TRANSLATORS: help e2
            _(
              "<p>To set mirroring on or off, select a repository in the table\nand click <b>Toggle Mirroring</b>.</p>"
            ) +
            # TRANSLATORS: help e3
            _(
              "<p><b>Staging</b> offers you to create testing and production\n" +
                "snapshots. To enable or disable this feature, select a repository\n" +
                "in the table and click <b>Toggle Staging</b>.</p>"
            ),
        "staging" =>
          # TRANSLATORS: help f1
          _(
            "<p><big><b>Staging</b></big><br>\n" +
              "Here you can create testing and production snapshots from the mirrored\n" +
              "repositories that have <tt>staging</tt> enabled. Repositories that contain\n" +
              "patches allow patch-filtering, otherwise you can create full snapshots only\n" +
              "(without any fitler in use).</p>"
          ) +
            # TRANSLATORS: help f2
            _(
              "<p>Choosing a <b>Repository Name</b> will switch the current\n" +
                "repository. Choosing a <b>Patch Category</b> applies a listing filter\n" +
                "on the current repository.</p>"
            ) +
            # TRANSLATORS: help f3
            _(
              "<p>To enable or disable <tt>patches</tt> in the snapshot,\nselect a patch in the table and click <b>Toggle Patch Status</b>.</p>"
            ) +
            # TRANSLATORS: help f4, '-&gt;' is actually '->' in HTML
            _(
              "<p>If you want to change more patches at once, you can also use\n<b>Change Status-&gt;All Listed Patches...-&gt;Enable/Disable</b></p>"
            ) +
            # TRANSLATORS: help f5, '-&gt;' is actually '->' in HTML
            _(
              "<p>To exclude all patches of a selected type from the <tt>testing</tt>\n" +
                "snapshot, use <b>Change Status-&gt;Exclude from Snapshot...</b>.\n" +
                "Such patch cannot be enabled unless you remove the filter again.</p>"
            ) +
            _(
              "<p>To create <tt>testing</tt> or <tt>production</tt> snapshots\nclick <b>Create Snapshot...-&gt;From Full Mirror to Testing/From Testing to Production</b>.</p>"
            ) +
            _(
              "<p><b>Testing</b> snapshot is always created from the mirrored repository,\n<b>production</b> is always created as a copy of the <b>testing</b> one.</p>"
            )
      }
    end
  end
end
