variable "tenantName" {}
variable "bd_name" {}
variable "bd_subnet" {}
variable "app_profile_name" {}


variable "aciUser" {
    default = "automator"
}
variable "aciPrivateKey" {
    default = "automator.key"
}
variable "aciCertName" {
    default = "automator"
}
variable "aciUrl" {
    default = "https://<APIC IP here>"
}
variable "provider_profile_dn" {
    default = "uni/vmmp-VMware"
}
