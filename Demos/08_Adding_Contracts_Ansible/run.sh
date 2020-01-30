#!/usr/bin/env bash

ansible-playbook -e @apic_credentials.yml ./add_aci_contract.yml
