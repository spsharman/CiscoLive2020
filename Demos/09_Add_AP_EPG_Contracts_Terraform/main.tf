provider "aci" {
  username = var.aciUser
  private_key = var.aciPrivateKey
  cert_name = var.aciCertName
  insecure = true
  url = var.aciUrl
}

resource "aci_tenant" "tenant_name" {
  name = var.tenantName
  description = "created by terraform"
}

data "aci_tenant" "tenant_common" {
  name  = "common"
}

data "aci_vrf" "common_vrf01" {
  tenant_dn  = data.aci_tenant.tenant_common.id
  name       = "vrf-01"
}

data "aci_vmm_domain" "HX-ACI" {
  provider_profile_dn = var.provider_profile_dn
  name                = "HX-ACI"
}

resource "aci_bridge_domain" "bd_name" {
  tenant_dn          = data.aci_tenant.tenant_common.id
  relation_fv_rs_ctx = data.aci_vrf.common_vrf01.name
  name               = var.bd_name
}

resource "aci_subnet" "bd1_subnet" {
  bridge_domain_dn = aci_bridge_domain.bd_name.id
  ip               = var.bd_subnet
}

resource "aci_application_profile" "app_profile" {
  tenant_dn = aci_tenant.tenant_name.id
  name      = var.app_profile_name
}

resource "aci_application_epg" "epg_frontend" {
  application_profile_dn = aci_application_profile.app_profile.id
  name                   = "Frontend"
  relation_fv_rs_bd      = aci_bridge_domain.bd_name.name
  relation_fv_rs_dom_att = [data.aci_vmm_domain.HX-ACI.id]
  relation_fv_rs_cons    = [aci_contract.contract_wordpress.name]
}

resource "aci_application_epg" "epg_backend" {
  application_profile_dn = aci_application_profile.app_profile.id
  name                   = "Backend"
  relation_fv_rs_bd      = aci_bridge_domain.bd_name.name
  relation_fv_rs_dom_att = [data.aci_vmm_domain.HX-ACI.id]
  relation_fv_rs_prov    = [aci_contract.contract_wordpress.name]
}

resource "aci_filter" "allow_mysql" {
  tenant_dn = data.aci_tenant.tenant_common.id
  name      = "tcp_src_port_any_to_dst_port_3306"
}

resource "aci_filter_entry" "mysql" {
  name        = "src_port_any_to_dst_port_3306"
  filter_dn   = aci_filter.allow_mysql.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "3306"
  d_to_port   = "3306"
  stateful    = "yes"
}

resource "aci_filter" "allow_ssh" {
  tenant_dn = data.aci_tenant.tenant_common.id
  name      = "tcp_src_port_any_to_dst_port_22"
}

resource "aci_filter_entry" "ssh" {
  name        = "src_port_any_to_dst_port_22"
  filter_dn   = aci_filter.allow_ssh.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "22"
  d_to_port   = "22"
  stateful    = "yes"
}

resource "aci_contract" "contract_wordpress" {
  tenant_dn = aci_tenant.tenant_name.id
  name      = "WordPress:Backend_to_WordPress:Frontend"
}

resource "aci_contract_subject" "wordpress_subject" {
  contract_dn                  = aci_contract.contract_wordpress.id
  name                         = "tcp"
  relation_vz_rs_subj_filt_att = [aci_filter.allow_mysql.name,aci_filter.allow_ssh.name]
}
