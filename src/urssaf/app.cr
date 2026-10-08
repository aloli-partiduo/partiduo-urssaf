# SPDX-License-Identifier: AGPL-3.0-or-later

require "./manifest"
require "./config"
require "./secrets"
require "./iban"
require "./oauth2"
require "./transport"
require "./models/**"
require "./services/**"
require "./api/**"

# Extension URSSAF de Partiduo (ADR-007 D7) : tierce déclaration des
# micro-entrepreneurs par l'*API Tierce Déclaration auto-entrepreneur* de
# l'URSSAF. Partiduo déclare le chiffre d'affaires *calculé par le module
# `micro`* (ADR-007 D1), par catégorie et par période, sans ressaisie, avec
# le mandat du micro-entrepreneur recueilli, notifié et révocable ; il
# garde l'accusé et les cotisations dues. Même plan qu'une application du
# cœur (DECISIONS C1) ; `transport.cr` est l'interface abstraite, branchée
# sur une URSSAF simulée dans les specs et sur le bac à sable du portail
# https://portailapi.urssaf.fr après souscription (démarche de l'opérateur,
# tiers déclarant, CSS art. L133-11).
module Urssaf
  # Lue à la compilation dans `shard.yml`, seule source du numéro : chaque
  # commit y incrémente le dernier chiffre.
  VERSION = {{
              (read_file("#{__DIR__}/../../shard.yml")
                .lines
                .find(&.starts_with?("version:")) || "version: 0.0.0")
                .gsub(/^version:\s*/, "")
                .chomp
            }}

  # Code du registre (ADR-003 D2) : `urssaf` dans `PARTIDUO_MODULES`.
  CODE = "URSSAF"

  class App < Marten::App
    label "urssaf"
  end

  INSTALLED_APPS = [Urssaf::App] of Marten::Apps::Config.class
end
