# SPDX-License-Identifier: AGPL-3.0-or-later

require "../spec_helper"

# Traductions des écrans de l'extension (ADR-005 D4, D7) : chaque route de
# `/ext/URSSAF/` servie en `GET` (liste tirée du routeur de Marten),
# obtenue en fr, en et nl par un administrateur, le 5 octobre 2026, sur une
# micro-entreprise reliée à l'URSSAF simulée : mandat notifié, mandat SEPA
# enregistré, deuxième trimestre déclaré et payé (prélèvement rejeté :
# anomalie à traiter), troisième trimestre déclaré, à payer. Contrôle de
# l'interface (`PartiduoUi::Translations`) : ni marqueur de traduction
# absente, ni clé brute, ni interpolation non résolue, et toute route
# atteinte par les liens des pages.

private alias S = Urssaf::SpecSupport
private alias Api = Urssaf::Api
private alias Books = PartiduoUi::Books

describe "Traductions des écrans URSSAF (fr, en, nl)" do
  it "rend chaque écran dans chaque langue, sans clé absente, brute ni interpolation non résolue" do
    S.books
    S.connect
    S.mandate
    S.receipt("2026-04-10", "300")
    Partiduo::Config.travel_to(Time.utc(2026, 7, 5, 9, 0, 0)) { Api.declare(S.admin, Books.date("2026-04-01")).value! }
    S.declared_quarter
    browser = PartiduoUi::Accounts.signed_in
    Partiduo::Config.travel_to(Time.utc(2026, 10, 5, 9, 0, 0)) do
      S.sepa
      Api.pay(S.admin, Books.date("2026-04-01")).value!
      S.urssaf.payment_outcome = "rejected"
      Api.refresh(S.admin).value!

      explorer = PartiduoUi::Translations::Explorer.new(&.name.starts_with?("urssaf:"))
      explorer.crawl(browser, "URSSAF")
      puts "\nTraductions de URSSAF : #{explorer.report}"
      (explorer.failures + explorer.unreached.map { |route| "route jamais atteinte : #{route}" }).should eq([] of String)
    end
  end
end
