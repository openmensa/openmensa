# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
require_dependency "message"

describe "Developers" do
  let(:user) { create(:user) }
  let(:developer) { create(:developer) }
  let(:parser) { create(:parser, user_id: developer.id) }
  let(:canteen) { create(:canteen) }

  context "as a developer" do
    before do
      parser
      login_as developer
      click_on "Profil"
    end

    context "without existing parser" do
      let(:parser) { nil }

      it "is able to add a new parser" do
        click_on "Neuen Parser anlegen"
        expect(page).to have_link_to "https://doc.openmensa.org/parsers/"
        expect(page).to have_link_to "https://doc.openmensa.org/feed/v2/"

        fill_in "Name", with: "Magdeburg"
        click_on "Speichern"

        expect(page).to have_content "Der Parser wurde erfolgreich angelegt."
      end
    end

    context "with existing parser" do
      it "is able to edit a new parser" do
        click_on parser.name
        click_on "Ändere die Parser-Einstellungen"

        fill_in "Name", with: "Magdeburg"
        click_on "Speichern"

        expect(page).to have_content "Der Parser wurde erfolgreich aktualisiert."
      end

      it "is able to import sources from index url" do
        index_url = "http://example.org/sources.json"
        stub_request(:any, index_url)
          .to_return(body: JSON.generate(
            "left" => "http://example.org/left/meta.xml",
            "right" => "http://example.org/right/meta.xml"
          ), status: 200)
        stub_request(:any, "http://example.org/left/meta.xml")
          .to_return(status: 404)
        stub_request(:any, "http://example.org/right/meta.xml")
          .to_return(body: mock_file("metafeed.xml"), status: 200)

        click_on parser.name
        expect(page).to have_no_link("Aktualisiere Quellen mittels Index-URL")

        click_on "Ändere die Parser-Einstellungen"
        fill_in "Index-URL", with: index_url
        click_on "Speichern"

        click_on "Aktualisiere Quellen mittels Index-URL"

        expect(page).to have_content "1 Quellen neu."
        expect(page).to have_content "1 Quellen angelegt."
      end

      it "is able to delete a parser" do
        pending "todo"
        click_on parser.name

        click_on "Parser archivieren"

        expect(page).to have_content "Der Parser wurde archiviert!"
      end

      it "is able to add a source with its canteen" do
        click_on parser.name

        click_on "Neue Quelle/Mensa hinzufügen"

        within(:xpath, '//section[header="Neue Quelle hinzufügen"]') do
          fill_in "Name", with: "test"
          fill_in "Meta-URL", with: "http://example.org/test/meta.xml"
        end

        within(:xpath, '//section[header="Angaben zur Mensa"]') do
          fill_in "canteen_name", with: "Neue Mensa"
          fill_in "Stadt / Region", with: "Regensburg"
        end

        click_on "Hinzufügen"

        expect(page).to have_content("Quelle wurde erfolgeich hinzufgefügt.")
      end

      context "with archived parser" do
        it "is able to reactive a parser" do
          pending "todo"
          click_on "Neuen Parser anlegen"

          click_on "\#{parser.name}\" reaktivieren"

          expect(page).to have_content "Der Parser wurde reaktiviert!"
        end
      end

      context "with a existing source without meta url" do
        let!(:source) { create(:source, parser:, canteen:) }
        let!(:feed) { create(:feed, source:) }

        it "is able to edit the source" do
          click_on parser.name
          click_on "Editiere #{source.name}"

          within(:xpath, '//section[header="Editiere Quelle"]') do
            fill_in "Name", with: "Testname"
            click_on "Speichern"
          end

          expect(page).to have_content "Testname"
          expect(page).to have_content "Die Quelle wurde erfolgeich aktualisiert."
        end

        it "is able to add a new feed" do
          click_on parser.name
          click_on "Editiere #{source.name}"

          within(:xpath, '//section[header="Neuer Feed"]') do
            fill_in "Name", with: "Full"
            fill_in "URL", with: "http://example.org/test/full.xml"
            fill_in "Wiederholungsinterval(e)", with: "10 3"
          end

          click_on "Feed anlegen"

          expect(page).to have_content "Der neuer Feed wurde erfolgreich angelegt."
          expect(page).to have_content "Feed Full"
        end

        it "is able to edit a feed" do
          click_on parser.name
          click_on "Editiere #{source.name}"

          within(:xpath, "//section[header=\"Feed #{feed.name}\"]") do
            fill_in "Name", with: "Replacefeed"
            fill_in "Wiederholungsinterval(e)", with: ""
            click_on "Speichern"
          end

          expect(page).to have_content "Der Feed wurde erfolgreich aktualisiert."
          expect(page).to have_content "Replacefeed"
        end

        it "is able to delete/archive a feed" do
          click_on parser.name
          click_on "Editiere #{source.name}"

          within(:xpath, "//section[header=\"Feed #{feed.name}\"]") do
            click_on "Löschen"
          end

          expect(page).to have_content "Der Feed wurde erfolgreich geschlöscht."
          expect(page).to have_no_content feed.name
        end

        context "without feedbacks" do
          it "is able to see a info about this state" do
            visit canteen_path(canteen)

            click_on "Nutzerrückmeldungen"

            expect(page).to have_content("Aktuell liegen keine Nutzerrückmeldungen für diese Mensa vor!")
          end
        end

        context "with previous created feedback" do
          let!(:feedback) { create(:feedback, canteen:) }

          it "is able to see the feedbacks message" do
            click_on parser.name
            click_on "Öffne Feedback für #{canteen.name}"

            expect(page).to have_content(feedback.message)
          end

          it "is able to see feedback via canteen page" do
            visit canteen_path(canteen)

            click_on "Nutzerrückmeldungen"

            expect(page).to have_content(feedback.message)
          end
        end

        context "with previous created data proposals" do
          let!(:data_proposal) { create(:data_proposal, canteen:) }

          it "is able to see the data_proposal" do
            click_on parser.name
            click_on "Öffne Änderungsvorschläge für #{canteen.name}"

            expect(page).to have_content(data_proposal.city)
          end

          it "is able to see feedback via canteen page" do
            visit canteen_path(canteen)

            click_on "Änderungsvorschläge"

            expect(page).to have_content(data_proposal.city)
          end
        end

        context "with previous messsages" do
          let!(:error) { create(:feedUrlUpdatedInfo, messageable: source) }

          it "is able to view fetch messages / errors" do
            click_on parser.name

            click_on "Mitteilungen für #{source.name}"

            expect(page).to have_content(error.to_html)
          end
        end
      end

      context "with a existing source with meta url" do
        let!(:source) do
          create(:source, parser:,
            meta_url: "http://example.org/test/meta.xml")
        end
        let!(:feed) { create(:feed, source:, name: "oldfeed") }

        it "is not able to edit feeds" do
          click_on parser.name
          click_on "Editiere #{source.name}"

          expect(page).to have_no_xpath("//section[header=\"Feed #{feed.name}\"]")
          expect(page).to have_no_xpath('//section[header="Neuer Feed"]')
          expect(page).to have_no_link("Feed anlegen")
        end

        it "is able to let feeds sync via meta url" do
          stub_request(:any, source.meta_url)
            .to_return(body: mock_file("metafeed.xml"), status: 200)
          click_on parser.name
          click_on "Editiere #{source.name}"

          click_on "Synchronisiere Feeds"
          expect(page).to have_content "2 Feeds hinzugefügt."
          expect(page).to have_content "1 Feeds gelöscht."
        end
      end
    end
  end
end
