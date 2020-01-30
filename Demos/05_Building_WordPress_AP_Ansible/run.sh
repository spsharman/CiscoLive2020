#!/usr/bin/env bash

ansible-playbook -e @apic_credentials.yml ./create_application_profile.yaml --tags demo5
