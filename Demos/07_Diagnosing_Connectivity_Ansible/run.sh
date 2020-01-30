#!/usr/bin/env bash

ansible-playbook -e @apic_credentials.yml ./get_host_aci_details.yml
