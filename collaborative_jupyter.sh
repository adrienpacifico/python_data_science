#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${ROOT_DIR}/infra/collab_jupyter_gcp"
CONFIG_FILE="${COLLAB_JUPYTER_ENV:-${ROOT_DIR}/collaborative_jupyter.env}"

usage() {
  cat <<'EOF'
Usage: ./collaborative_jupyter.sh <command>

Commands:
  deploy   Create or update the GCP infrastructure with Terraform
  start    Start the VM
  stop     Stop the VM
  status   Show VM status and the Jupyter URL
  url      Print the Jupyter URL
  destroy  Destroy the GCP infrastructure with Terraform
  clean    Remove local Terraform cache/state files only
EOF
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

load_config() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Missing config file: ${CONFIG_FILE}" >&2
    echo "Copy collaborative_jupyter.env.example to collaborative_jupyter.env and fill it in." >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"

  : "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required in ${CONFIG_FILE}}"
  : "${GCP_REGION:?GCP_REGION is required in ${CONFIG_FILE}}"
  : "${GCP_ZONE:?GCP_ZONE is required in ${CONFIG_FILE}}"
  : "${INSTANCE_NAME:?INSTANCE_NAME is required in ${CONFIG_FILE}}"
  : "${MACHINE_TYPE:?MACHINE_TYPE is required in ${CONFIG_FILE}}"
  : "${DISK_SIZE_GB:?DISK_SIZE_GB is required in ${CONFIG_FILE}}"
  : "${JUPYTER_PORT:?JUPYTER_PORT is required in ${CONFIG_FILE}}"
  : "${JUPYTER_TOKEN:?JUPYTER_TOKEN is required in ${CONFIG_FILE}}"
  : "${NOTEBOOK_DIR:?NOTEBOOK_DIR is required in ${CONFIG_FILE}}"
  : "${SPOT_INSTANCE:?SPOT_INSTANCE is required in ${CONFIG_FILE}}"
}

terraform_args=()

build_terraform_args() {
  terraform_args=(
    -var="gcp_project_id=${GCP_PROJECT_ID}"
    -var="gcp_region=${GCP_REGION}"
    -var="gcp_zone=${GCP_ZONE}"
    -var="instance_name=${INSTANCE_NAME}"
    -var="machine_type=${MACHINE_TYPE}"
    -var="disk_size_gb=${DISK_SIZE_GB}"
    -var="jupyter_port=${JUPYTER_PORT}"
    -var="jupyter_token=${JUPYTER_TOKEN}"
    -var="notebook_dir=${NOTEBOOK_DIR}"
    -var="spot_instance=${SPOT_INSTANCE}"
  )
}

terraform_infra() {
  terraform -chdir="${INFRA_DIR}" "$@"
}

resolve_ip() {
  if [[ -f "${INFRA_DIR}/terraform.tfstate" ]]; then
    terraform_infra output -raw jupyter_ip 2>/dev/null && return 0
  fi

  gcloud compute addresses describe "${INSTANCE_NAME}-ip" \
    --project "${GCP_PROJECT_ID}" \
    --region "${GCP_REGION}" \
    --format='value(address)'
}

show_url() {
  local ip
  ip="$(resolve_ip)"
  echo "http://${ip}:${JUPYTER_PORT}/lab?token=${JUPYTER_TOKEN}"
}

cmd_deploy() {
  build_terraform_args
  terraform_infra init
  terraform_infra apply "${terraform_args[@]}" -auto-approve

  echo
  echo "Jupyter URL:"
  show_url
}

cmd_start() {
  gcloud compute instances start "${INSTANCE_NAME}" \
    --project "${GCP_PROJECT_ID}" \
    --zone "${GCP_ZONE}"

  echo
  echo "Jupyter URL:"
  show_url
}

cmd_stop() {
  gcloud compute instances stop "${INSTANCE_NAME}" \
    --project "${GCP_PROJECT_ID}" \
    --zone "${GCP_ZONE}"
}

cmd_status() {
  gcloud compute instances describe "${INSTANCE_NAME}" \
    --project "${GCP_PROJECT_ID}" \
    --zone "${GCP_ZONE}" \
    --format='table(name,status,machineType.basename(),networkInterfaces[0].accessConfigs[0].natIP)'

  echo
  echo "Jupyter URL:"
  show_url
}

cmd_destroy() {
  build_terraform_args
  terraform_infra init
  terraform_infra destroy "${terraform_args[@]}" -auto-approve
}

cmd_clean() {
  rm -rf "${INFRA_DIR}/.terraform" "${INFRA_DIR}/terraform.tfstate.d"
  rm -f \
    "${INFRA_DIR}/.terraform.lock.hcl" \
    "${INFRA_DIR}/terraform.tfstate" \
    "${INFRA_DIR}/terraform.tfstate.backup"
}

main() {
  require_command terraform
  require_command gcloud
  load_config

  case "${1:-}" in
    deploy)
      cmd_deploy
      ;;
    start)
      cmd_start
      ;;
    stop)
      cmd_stop
      ;;
    status)
      cmd_status
      ;;
    url)
      show_url
      ;;
    destroy)
      cmd_destroy
      ;;
    clean)
      cmd_clean
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "${@}"
