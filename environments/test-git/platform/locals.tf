locals {
    environment            = "Test"
    name_prefix            = "kuflink-test"
    
    # flip to false to remove the whole WAF stack
    enable_eb_waf          = true
    enable_s3_admin_waf    = true 

}