#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
repo='mariaisabel13315-spec/isa1331'
project='isa-creations-rd-13dfb'
account='github-action-1404252966@isa-creations-rd-13dfb.iam.gserviceaccount.com'
secret='FIREBASE_SERVICE_ACCOUNT_ISA_CREATIONS_RD_13DFB'
if ! command -v gh >/dev/null 2>&1; then
  printf '\nInstalando la herramienta oficial de GitHub...\n'
  sudo apt-get update -qq
  sudo apt-get install -y -qq gh
fi
google_account="$(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
if [[ "$google_account" != 'mariaisabel13315@gmail.com' ]]; then
  printf '\nAbre Cloud Shell con mariaisabel13315@gmail.com antes de continuar.\n'
  exit 1
fi
printf '\nConecta GitHub con el codigo que aparecera en la terminal.\nAbre https://github.com/login/device y usa mariaisabel13315-spec.\nNo pegues el codigo ni claves en el chat.\n'
if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web
fi
github_user="$(gh api user --jq .login)"
if [[ "$github_user" != 'mariaisabel13315-spec' ]]; then
  printf '\nGitHub esta conectado con otra cuenta: %s. Detenido.\n' "$github_user"
  exit 1
fi
existing="$(gh secret list --repo "$repo" --json name --jq '.[] | .name')"
if ! printf '%s\n' "$existing" | grep -Fxq "$secret"; then
  gcloud iam service-accounts describe "$account" --project "$project" >/dev/null
  task_tmp="$(mktemp -d)"
  uploaded=false
  cleanup() {
    if [[ "$uploaded" != true && -s "$task_tmp/key.json" ]]; then
      key_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["private_key_id"])' "$task_tmp/key.json")"
      gcloud iam service-accounts keys delete "$key_id" --iam-account "$account" --project "$project" --quiet >/dev/null 2>&1 || true
    fi
    rm -rf "$task_tmp"
  }
  trap cleanup EXIT
  printf '\nVinculando Firebase con GitHub...\n'
  gcloud iam service-accounts keys create "$task_tmp/key.json" --iam-account "$account" --project "$project"
  gh secret set "$secret" --repo "$repo" < "$task_tmp/key.json"
  uploaded=true
  cleanup
  trap - EXIT
fi
printf '\nVinculacion terminada. Iniciando publicacion...\n'
gh workflow run firebase-hosting-merge.yml --repo "$repo" --ref main
printf '\nLa publicacion esta solicitada. Revisa su resultado aqui:\nhttps://github.com/%s/actions\n' "$repo"
