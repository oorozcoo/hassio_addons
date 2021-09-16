#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
NOMBRE=$(jq --raw-output ".nombre" $CONFIG_PATH)
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh_key[]" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
ZIP_PASSWORD=$(jq --raw-output '.zip_password' $CONFIG_PATH)
KEEP_LOCAL_BACKUP=$(jq --raw-output '.keep_local_backup' $CONFIG_PATH)

# create variables
SSH_ID="${HOME}/.ssh/id"

function add-ssh-key {
    echo "Adding SSH key"
    mkdir -p ~/.ssh
    (
        echo "Host remote"
        echo "    IdentityFile ${HOME}/.ssh/id"
        echo "    HostName ${SSH_HOST}"
        echo "    User ${SSH_USER}"
        echo "    Port ${SSH_PORT}"
        echo "    StrictHostKeyChecking no"
    ) > "${HOME}/.ssh/config"

    while read -r line; do
        echo "$line" >> ${HOME}/.ssh/id
    done <<< "$SSH_KEY"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id"
}

function copy-backup-to-remote {

    cd /backup/
    echo "Listando respaldos"
    ls -Altrh
    sleep 4s
    if [[ -z $ZIP_PASSWORD  ]]; then
      respaldo=`mv /backup/"${slug}".tar /backup/$NOMBRE.tar`
      echo "${respaldo}"
      ls -Altrh
      sleep 3s
      echo "Copiando $respaldo a ${REMOTE_DIRECTORY} en ${SSH_HOST} por SCP"
      scp -F "${HOME}/.ssh/config" "${respaldo}" remote:"${REMOTE_DIRECTORY}"
    else
      echo "Copiando respaldo protegido con password ${respaldo}.zip a ${REMOTE_DIRECTORY} en ${SSH_HOST} por SCP"
      zip -P "$ZIP_PASSWORD" "${respaldo}.zip" "${respaldo}".tar
      scp -F "${HOME}/.ssh/config" "${respaldo}.zip" remote:"${REMOTE_DIRECTORY}" && rm "${respaldo}.zip"
    fi

}

#function delete-local-backup {
#
#    hassio snapshots reload
#
#    if [[ ${KEEP_LOCAL_BACKUP} == "all" ]]; then
#        :
#    elif [[ -z ${KEEP_LOCAL_BACKUP} ]]; then
#        echo "Eliminando respaldo local: ${respaldo}"
#        hassio snapshots remove -name "${respaldo}"
#    else
#
#        last_date_to_keep=$(hassio snapshots list | jq .data.snapshots[].date | sort -r | \
#            head -n "${KEEP_LOCAL_BACKUP}" | tail -n 1 | xargs date -D "%Y-%m-%dT%T" +%s --date )
#
#        hassio snapshots list | jq -c .data.snapshots[] | while read backup; do
#            if [[ $(echo ${backup} | jq .date | xargs date -D "%Y-%m-%dT%T" +%s --date ) -lt ${last_date_to_keep} ]]; then
#                echo "Eliminando respaldo local: $(echo ${backup} | jq -r .slug)"
#                hassio snapshots remove -name "$(echo ${backup} | jq -r .slug)"
#            fi
#        done
#
#    fi
#}

function create-local-backup {
    name="Respaldo Automatico $(date +'%Y-%m-%d %H:%M')"
    echo "Creando Respaldo Local: \"${name}\""
    slug=$(hassio snapshots new --options name="${name}" | jq --raw-output '.data.slug')
    echo "Respaldo Creado: ${slug}"
}


add-ssh-key
create-local-backup
copy-backup-to-remote
delete-local-backup

echo "Backup process done!"
exit 0
