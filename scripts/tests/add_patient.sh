#!/usr/bin/env bash
set -e
echo "###ADD DAF USER###"
cat > temp.sh <<-\EOF
#!/bin/bash
set -e
URL="http://prodweb:8080"

AUTH=$(curl -sX POST \
  ${URL}/auth/login \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 2b89c369-7e87-4894-95f8-f3eeae99119f' \
  -H 'cache-control: no-cache' \
  -d '{
  "username": "patients_admin",
  "password": "delphix"
}')

ID=$(curl -sX POST \
  ${URL}/patients \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${AUTH}" \
  -H 'cache-control: no-cache' \
  -d '{
    "firstname": "Adam",
    "middlename": "Ulysses",
    "lastname": "Bowen",
    "ssn": "123-45-6789",
    "dob": "07/04/1776",
    "address1": "123 Main St",
    "address2": "Apt 1",
    "city": "Funkytown",
    "state": "KY",
    "zip": "11111"
}'| jq -r .id)

CITY=$(curl ${URL}/patients/${ID} \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${AUTH}" \
  -H 'cache-control: no-cache' | jq -r .city)

if [[ "${CITY}" == "Funkytown" ]]; then
  echo "Patient Successfully Added patient ${ID}"
else
  echo "Patient add failed"
  echo $CITY
fi
EOF


scp temp.sh ubuntu@jumpbox:.

ssh ubuntu@jumpbox 'chmod +x ./temp.sh && ./temp.sh'

rm temp.sh

